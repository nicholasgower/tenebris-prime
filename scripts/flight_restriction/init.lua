--- Tenebris Flight Restriction System
--- Prevents mech armor from hovering on Tenebris until tenebris-mech-adaptation tech is researched.
--- Uses a sticker with ground_target = true to force players to stay grounded.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local flight_restriction = {}

-- Constants
local STICKER_NAME = "tenebris-atmospheric-pressure-sticker"
local TECH_NAME = "tenebris-mech-adaptation"


--- Check if a force has researched the mech adaptation tech
--- @param force LuaForce
--- @return boolean
local function has_mech_adaptation(force)
    local tech = force.technologies[TECH_NAME]
    return tech and tech.researched
end


--- Apply the flight restriction sticker to a player character
--- @param player LuaPlayer
local function apply_flight_restriction(player)
    if not player or not player.valid or not player.character then
        return
    end
    
    -- Check if player already has the sticker
    local stickers = player.character.stickers
    if stickers then
        for _, sticker in pairs(stickers) do
            if sticker.name == STICKER_NAME then
                -- Already has the sticker, no need to reapply
                return
            end
        end
    end
    
    -- Apply the sticker
    player.character.surface.create_entity({
        name = STICKER_NAME,
        position = player.character.position,
        target = player.character,
        force = "neutral"
    })
end


--- Remove the flight restriction sticker from a player character
--- @param player LuaPlayer
local function remove_flight_restriction(player)
    if not player or not player.valid or not player.character then
        return
    end
    
    -- Remove all instances of the sticker
    local stickers = player.character.stickers
    if stickers then
        for _, sticker in pairs(stickers) do
            if sticker.name == STICKER_NAME and sticker.valid then
                sticker.destroy()
            end
        end
    end
end


--- Check if a player should have the flight restriction applied
--- @param player LuaPlayer
--- @return boolean
local function should_restrict_flight(player)
    if not player or not player.valid then
        return false
    end
    
    -- Check if on Tenebris surface
    if not tenebris.is_tenebris_surface(player.surface) then
        return false
    end
    
    -- Check if force has researched the tech
    if has_mech_adaptation(player.force) then
        return false
    end
    
    return true
end


--- Handle player changing surfaces
--- @param event EventData.on_player_changed_surface
local function on_player_changed_surface(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    if should_restrict_flight(player) then
        apply_flight_restriction(player)
    else
        -- Player left Tenebris or tech is researched, remove sticker
        remove_flight_restriction(player)
    end
end


--- Handle player respawning
--- @param event EventData.on_player_respawned
local function on_player_respawned(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    if should_restrict_flight(player) then
        apply_flight_restriction(player)
    end
end


--- Handle research completion
--- @param event EventData.on_research_finished
local function on_research_finished(event)
    if event.research.name ~= TECH_NAME then
        return
    end
    
    -- Tech completed! Remove sticker from all players in this force
    local force = event.research.force
    
    for _, player in pairs(force.players) do
        remove_flight_restriction(player)
        
        -- Optional: Show a message to the player
        if player.valid and player.character then
            player.create_local_flying_text({
                text = {"", "[img=technology/", TECH_NAME, "] Atmospheric adaptation complete - flight enabled"},
                create_at_cursor = false,
                position = player.position
            })
        end
    end
end


-- Register event handlers
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_SURFACE, "flight_restriction_surface_change", on_player_changed_surface)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_RESPAWNED, "flight_restriction_respawn", on_player_respawned)
event_manager.subscribe(tenebris.EVENTS.ON_RESEARCH_FINISHED, "flight_restriction_research", on_research_finished)


return flight_restriction
