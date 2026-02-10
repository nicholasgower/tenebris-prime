--- Mercury & Tenebrace Poisoning System
--- Applies poisoning stickers to players from mercury pools and tenebrace proximity.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local mercury_poisoning = {}

-- Constants
local MERCURY_STICKER = "tenebris-mercury-poisoning-sticker"
local TENEBRACE_STICKER = "tenebris-tenebrace-spore-sticker"
local MERCURY_TILE = "tenebris-mercury-tile"
local TENEBRACE_RADIUS = 2  -- Tiles


--- Check if a player is standing on mercury
--- @param player LuaPlayer
--- @return boolean
local function is_on_mercury(player)
    if not player or not player.valid or not player.character then
        return false
    end
    
    -- Flying players don't touch the mercury
    if player.character.is_flying then
        return false
    end
    
    local surface = player.surface
    local position = player.character.position
    
    -- Get the tile at the player's position
    local tile = surface.get_tile(position.x, position.y)
    return tile and tile.valid and tile.name == MERCURY_TILE
end


--- Check if a player is near a tenebrace plant
--- @param player LuaPlayer
--- @return boolean
local function is_near_tenebrace(player)
    if not player or not player.valid or not player.character then
        return false
    end
    
    local surface = player.surface
    local position = player.character.position
    
    -- Find tenebrace entities within radius
    local nearby = surface.find_entities_filtered({
        position = position,
        radius = TENEBRACE_RADIUS,
        name = "tenebrace",
        limit = 1
    })
    
    return #nearby > 0
end


--- Apply a sticker to a player character
--- @param player LuaPlayer
--- @param sticker_name string
local function apply_sticker(player, sticker_name)
    if not player or not player.valid or not player.character then
        return
    end
    
    -- Check if player already has this sticker (don't stack)
    local stickers = player.character.stickers
    if stickers then
        for _, sticker in pairs(stickers) do
            if sticker.name == sticker_name then
                -- Already has the sticker, refresh duration by destroying and recreating
                sticker.destroy()
                break
            end
        end
    end
    
    -- Apply the sticker
    player.character.surface.create_entity({
        name = sticker_name,
        position = player.character.position,
        target = player.character,
        force = "neutral"
    })
end


--- Handle player position changes
--- @param event EventData.on_player_changed_position
local function on_player_changed_position(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    -- Only check on Tenebris surfaces
    if not tenebris.is_tenebris_surface(player.surface) then
        return
    end
    
    -- Check mercury tiles
    if is_on_mercury(player) then
        apply_sticker(player, MERCURY_STICKER)
    end
    
    -- Check tenebrace proximity
    if is_near_tenebrace(player) then
        apply_sticker(player, TENEBRACE_STICKER)
    end
end


-- Register event handler
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_POSITION, "mercury_poisoning", on_player_changed_position)


return mercury_poisoning
