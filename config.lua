Config = {}

-- Leave as nil to use your sv_maxclients convar automatically.
Config.MaxPlayers = nil

Config.RequireSteam = true -- kick players who don't have Steam open

Config.AcePermissions = {
    bypass = "queue.bypass",
    priority = "queue.priority"
}

Config.PriorityLevels = {
    bypass = 3,
    priority = 2,
    default = 1
}

-- true: players with bypass skip the queue and join even when the server is full
Config.BypassSkipsQueue = true

Config.ReconnectGrace = 300 -- seconds a dropped player keeps their place in line
Config.JoinTimeout = 120 -- seconds a released player may take to finish loading before their slot is freed
Config.UpdateInterval = 5 -- seconds between queue position updates

Config.QueueBanner = {
    enabled = true, -- false = plain text only
    text = "Welcome to Our Server! Please wait in the queue...",
    imageUrl = "https://example.com/banner.png" -- leave "" for no image
}

Config.Messages = {
    position  = "You are in the queue. Position: %d/%d. Please wait...",
    steam     = "You need to have Steam open to join this server.",
    license   = "Couldn't find your Rockstar license. Restart FiveM and try again.",
    duplicate = "You connected from another session."
}
