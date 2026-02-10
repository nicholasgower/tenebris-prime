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


--- Check if an entity already has the flight restriction sticker
--- @param entity LuaEntity
--- @return boolean
local function has_flight_restriction_sticker(entity)
    local stickers = entity.stickers
    if stickers then
        for _, sticker in pairs(stickers) do
            if sticker.name == STICKER_NAME then
                return true
            end
        end
    end
    return false
end


--- Apply the flight restriction sticker to an entity (character or vehicle)
--- @param entity LuaEntity
local function apply_flight_restriction_to_entity(entity)
    if not entity or not entity.valid then
        return
    end
    
    -- Check if entity already has the sticker
    if has_flight_restriction_sticker(entity) then
        return
    end
    
    -- Apply the sticker
    entity.surface.create_entity({
        name = STICKER_NAME,
        position = entity.position,
        target = entity,
        force = "neutral"
    })
end


--- Apply the flight restriction sticker to a player character
--- @param player LuaPlayer
local function apply_flight_restriction(player)
    if not player or not player.valid or not player.character then
        return
    end
    
    apply_flight_restriction_to_entity(player.character)
end


--- Remove the flight restriction sticker from an entity (character or vehicle)
--- @param entity LuaEntity
local function remove_flight_restriction_from_entity(entity)
    if not entity or not entity.valid then
        return
    end
    
    -- Remove all instances of the sticker
    local stickers = entity.stickers
    if stickers then
        for _, sticker in pairs(stickers) do
            if sticker.name == STICKER_NAME and sticker.valid then
                sticker.destroy()
            end
        end
    end
end


--- Remove the flight restriction sticker from a player character
--- @param player LuaPlayer
local function remove_flight_restriction(player)
    if not player or not player.valid or not player.character then
        return
    end
    
    remove_flight_restriction_from_entity(player.character)
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


--- Handle player entering a vehicle
--- @param event EventData.on_player_driving_changed_state
local function on_player_driving_changed_state(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    if event.entered then
        -- Player just entered a vehicle
        if player.vehicle and should_restrict_flight(player) then
            apply_flight_restriction_to_entity(player.vehicle)
        end
    else
        -- Player exited a vehicle - no need to remove sticker from vehicle
        -- It will be handled when the vehicle is destroyed or when appropriate
    end
end


--- Handle entity creation to apply flight restriction to vehicles on Tenebris
--- @param event EventData.on_built_entity
local function on_built_entity(event)
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    -- Check if it's a vehicle or spider vehicle
    if entity.type ~= "car" and entity.type ~= "spider-vehicle" then
        return
    end
    
    -- Check if on Tenebris
    if not tenebris.is_tenebris_surface(entity.surface) then
        return
    end
    
    -- Check if any force that owns this vehicle doesn't have the tech
    -- For now, apply to all vehicles created on Tenebris (neutral assumption)
    -- In the future, could check the vehicle's force if needed
    apply_flight_restriction_to_entity(entity)
end


--- Handle robots placing entities to apply flight restriction
--- @param event EventData.on_robot_built_entity
local function on_robot_built_entity(event)
    local entity = event.created_entity
    if not entity or not entity.valid then return end
    
    -- Check if it's a vehicle or spider vehicle
    if entity.type ~= "car" and entity.type ~= "spider-vehicle" then
        return
    end
    
    -- Check if on Tenebris
    if not tenebris.is_tenebris_surface(entity.surface) then
        return
    end
    
    apply_flight_restriction_to_entity(entity)
end


--- Handle research completion
--- @param event EventData.on_research_finished
local function on_research_finished(event)
    if event.research.name ~= TECH_NAME then
        return
    end
    
    -- Tech completed! Remove sticker from all players and vehicles in this force
    local force = event.research.force
    
    -- Remove from all players in this force
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
    
    -- Remove stickers from all vehicles owned by this force on Tenebris surfaces
    for _, surface in pairs(game.surfaces) do
        if tenebris.is_tenebris_surface(surface) then
            -- Find all cars and spider vehicles on this surface owned by this force
            local vehicles = surface.find_entities_filtered({
                type = {"car", "spider-vehicle"},
                force = force
            })
            for _, vehicle in pairs(vehicles) do
                remove_flight_restriction_from_entity(vehicle)
            end
        end
    end
end


-- Register event handlers
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_SURFACE, "flight_restriction_surface_change", on_player_changed_surface)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_RESPAWNED, "flight_restriction_respawn", on_player_respawned)
event_manager.subscribe(tenebris.EVENTS.ON_RESEARCH_FINISHED, "flight_restriction_research", on_research_finished)

-- Vehicle-related event subscriptions
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_DRIVING_CHANGED_STATE, "flight_restriction_vehicle_enter", on_player_driving_changed_state)
event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "flight_restriction_built_entity", on_built_entity)
event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_BUILT_ENTITY, "flight_restriction_robot_built", on_robot_built_entity)


return flight_restriction
