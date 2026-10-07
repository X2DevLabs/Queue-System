local queue = {}
local connecting = {}
local reconnectData = {}
local seqCounter = 0

local maxPlayers = Config.MaxPlayers or GetConvarInt('sv_maxclients', 32)

local function GetPriority(src)
    if IsPlayerAceAllowed(src, Config.AcePermissions.bypass) then
        return Config.PriorityLevels.bypass
    elseif IsPlayerAceAllowed(src, Config.AcePermissions.priority) then
        return Config.PriorityLevels.priority
    end
    return Config.PriorityLevels.default
end

local function SortQueue()
    table.sort(queue, function(a, b)
        if a.priority ~= b.priority then return a.priority > b.priority end
        return a.seq < b.seq
    end)
end

local function CountConnecting()
    local n = 0
    for _ in pairs(connecting) do n = n + 1 end
    return n
end

local function FreeSlots()
    return maxPlayers - GetNumPlayerIndices() - CountConnecting()
end

local function Release(entry)
    connecting[entry.player] = os.time()
    entry.deferrals.done()
end

local function BuildCard(statusText)
    local body = {}
    local banner = Config.QueueBanner

    if banner.imageUrl and banner.imageUrl ~= '' then
        body[#body + 1] = { type = 'Image', url = banner.imageUrl, size = 'Stretch' }
    end
    body[#body + 1] = {
        type = 'TextBlock', text = banner.text, wrap = true,
        horizontalAlignment = 'Center', weight = 'Bolder', size = 'Medium'
    }
    body[#body + 1] = {
        type = 'TextBlock', text = statusText, wrap = true, horizontalAlignment = 'Center'
    }

    return json.encode({
        ['$schema'] = 'http://adaptivecards.io/schemas/adaptive-card.json',
        type = 'AdaptiveCard',
        version = '1.3',
        body = body
    })
end

local function Render(entry, position)
    local status = Config.Messages.position:format(position, #queue)
    if Config.QueueBanner.enabled then
        entry.deferrals.presentCard(BuildCard(status))
    else
        entry.deferrals.update(status)
    end
end

local function ProcessQueue()
    while #queue > 0 and FreeSlots() > 0 do
        Release(table.remove(queue, 1))
    end
end

local function DropFromQueue(src)
    for i, entry in ipairs(queue) do
        if entry.player == src then
            reconnectData[entry.license] = { seq = entry.seq, droppedAt = os.time() }
            table.remove(queue, i)
            return
        end
    end
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    local license = GetPlayerIdentifierByType(src, 'license')
    if not license then
        return deferrals.done(Config.Messages.license)
    end

    if Config.RequireSteam and not GetPlayerIdentifierByType(src, 'steam') then
        return deferrals.done(Config.Messages.steam)
    end

    for i, old in ipairs(queue) do
        if old.license == license then
            table.remove(queue, i)
            pcall(old.deferrals.done, Config.Messages.duplicate)
            break
        end
    end

    local priority = GetPriority(src)

    if Config.BypassSkipsQueue and priority >= Config.PriorityLevels.bypass then
        connecting[src] = os.time()
        return deferrals.done()
    end

    local seq
    local saved = reconnectData[license]
    if saved and os.time() - saved.droppedAt <= Config.ReconnectGrace then
        seq = saved.seq
    else
        seqCounter = seqCounter + 1
        seq = seqCounter
    end
    reconnectData[license] = nil

    local entry = { player = src, license = license, priority = priority, seq = seq, deferrals = deferrals }
    queue[#queue + 1] = entry
    SortQueue()

    ProcessQueue()

    for i, e in ipairs(queue) do
        if e == entry then
            Render(entry, i)
            break
        end
    end
end)

AddEventHandler('playerJoining', function(tempId)
    connecting[tonumber(tempId)] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    connecting[src] = nil
    DropFromQueue(src)
end)

CreateThread(function()
    local ticks = 0

    while true do
        Wait(1000)
        ticks = ticks + 1
        local now = os.time()

        for id, since in pairs(connecting) do
            if now - since > Config.JoinTimeout then
                connecting[id] = nil
            end
        end

            for license, data in pairs(reconnectData) do
            if now - data.droppedAt > Config.ReconnectGrace then
                reconnectData[license] = nil
            end
        end

        ProcessQueue()

        if ticks % Config.UpdateInterval == 0 then
            for i, entry in ipairs(queue) do
                Render(entry, i)
            end
        end
    end
end)

exports('GetQueueSize', function()
    return #queue
end)
