# FiveM Queue System

A simple, customizable queue for FiveM servers. When the server is full, players wait in line and see their position. VIPs and staff can be moved up the line or skip it completely.

## Features
- **Priority queue**: three levels (default, priority, bypass) controlled by ACE permissions
- **Fair ordering**: players with the same priority are served in the order they joined
- **Bypass**: staff or VIPs can skip the queue and join even when the server is full
- **Reconnect grace**: if someone crashes or drops while waiting, they keep their place for a few minutes
- **Banner**: optional banner image and welcome text on the connecting screen
- **Live position**: players see where they are in line, updated every few seconds
- **Automatic slot count**: reads your `sv_maxclients`, so there's nothing to keep in sync

## Installation
1. Copy the folder into your resources.
2. Add it to your `server.cfg`:
   ```
   ensure Queue-System
   ```
3. Give players their permissions:
   ```
   add_ace group.vip queue.priority allow
   add_ace group.admin queue.bypass allow
   ```
4. Adjust `config.lua` to taste.

## Config
- `MaxPlayers`: leave as `nil` to use `sv_maxclients`, or set a number to override it
- `RequireSteam`: turn off if you don't use Steam on your server
- `AcePermissions` and `PriorityLevels`: permission names and their weights
- `BypassSkipsQueue`: whether bypass players skip the line and ignore the player cap
- `ReconnectGrace`: seconds a dropped player keeps their place
- `JoinTimeout`: seconds a released player has to finish loading before their slot is freed
- `UpdateInterval`: seconds between position updates
- `QueueBanner`: turn the banner on or off, set the text and image URL
- `Messages`: all the text players see

The banner is shown as a card on the connecting screen. If you'd rather have plain text, set `QueueBanner.enabled = false`.

## Exports (server)
```lua
exports['Queue-System']:GetQueueSize() -- how many players are waiting
```
