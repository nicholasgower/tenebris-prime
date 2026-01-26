--- Shield Disabler System
--- Disables energy shields on Tenebris Prime due to atmospheric interference
--- Uses an event-driven registry to track shields for optimal performance

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local CHECK_INTERVAL = 60  -- Drain shields every 60 ticks (1 second)

--- Initialize storage for shield tracking
local function init_storage()
    storage.tenebris_active_shields = storage.tenebris_active_shields or {}
end

--- Scans a grid and returns all shield equipment in it
local function get_shields_from_grid(grid)
    if not grid or not grid.valid then
        return {}
    end
    
    local shields = {}
    for _, equipment in pairs(grid.equipment) do
        if equipment.valid and equipment.type == "energy-shield-equipment" then
            table.insert(shields, equipment)
        end
    end
    return shields
end

--- Updates the shield registry for a specific player
local function update_player_shields(player_index)
    local player = game.get_player(player_index)
    if not player or not player.valid then
        storage.tenebris_active_shields[player_index] = nil
        return
    end
    
    -- Only track if player is on Tenebris
    if not tenebris.is_tenebris_surface(player.surface) then
        storage.tenebris_active_shields[player_index] = nil
        return
    end
    
    local shields_data = {
        character_shields = {},
        vehicle_shields = {}
    }
    
    -- Scan character armor
    if player.character and player.character.valid and player.character.grid then
        shields_data.character_shields = get_shields_from_grid(player.character.grid)
    end
    
    -- Scan vehicle grid
    local vehicle = player.vehicle
    if vehicle and vehicle.valid and vehicle.grid then
        shields_data.vehicle_shields = get_shields_from_grid(vehicle.grid)
    end
    
    -- Only store if player has shields
    if #shields_data.character_shields > 0 or #shields_data.vehicle_shields > 0 then
        storage.tenebris_active_shields[player_index] = shields_data
    else
        storage.tenebris_active_shields[player_index] = nil
    end
end

--- Rebuilds the entire shield registry (used on init/config change)
local function rebuild_all_shields()
    init_storage()
    storage.tenebris_active_shields = {}
    
    for _, player in pairs(game.players) do
        if player.valid and tenebris.is_tenebris_surface(player.surface) then
            update_player_shields(player.index)
        end
    end
end

--- Drains all tracked shields to zero
local function on_tick_drain_shields(event)
    if not storage.tenebris_active_shields then
        return
    end

    for player_index, shields_data in pairs(storage.tenebris_active_shields) do
        -- Drain character shields
        for _, equipment in pairs(shields_data.character_shields or {}) do
            if equipment.valid then
                equipment.shield = 0
            end
        end
        
        -- Drain vehicle shields
        for _, equipment in pairs(shields_data.vehicle_shields or {}) do
            if equipment.valid then
                equipment.shield = 0
            end
        end
    end
end

--- Handles equipment being placed by a player
local function on_player_placed_equipment(event)
    init_storage()
    local equipment = event.equipment
    if not equipment or not equipment.valid or equipment.type ~= "energy-shield-equipment" then
        return
    end
    
    update_player_shields(event.player_index)
end

--- Handles equipment being removed by a player
local function on_player_removed_equipment(event)
    init_storage()
    -- Always update when equipment is removed, as it might have been a shield
    update_player_shields(event.player_index)
end

--- Handles equipment inserted by any means (robots, scripts, etc.)
local function on_equipment_inserted(event)
    init_storage()
    local equipment = event.equipment
    if not equipment or not equipment.valid or equipment.type ~= "energy-shield-equipment" then
        return
    end
    
    local grid = event.grid
    if not grid or not grid.valid then
        return
    end
    
    -- Find which player owns this grid
    for _, player in pairs(game.connected_players) do
        if tenebris.is_tenebris_surface(player.surface) then
            -- Check character grid
            if player.character and player.character.grid == grid then
                update_player_shields(player.index)
                return
            end
            -- Check vehicle grid
            if player.vehicle and player.vehicle.grid == grid then
                update_player_shields(player.index)
                return
            end
        end
    end
end

--- Handles equipment removed by any means
local function on_equipment_removed(event)
    init_storage()
    local grid = event.grid
    if not grid or not grid.valid then
        return
    end
    
    -- Find which player owns this grid and update
    for _, player in pairs(game.connected_players) do
        if tenebris.is_tenebris_surface(player.surface) then
            if (player.character and player.character.grid == grid) or
               (player.vehicle and player.vehicle.grid == grid) then
                update_player_shields(player.index)
                return
            end
        end
    end
end

--- Handles player changing surface
local function on_player_changed_surface(event)
    init_storage()
    update_player_shields(event.player_index)
end

--- Handles player entering/exiting vehicles
local function on_player_driving_changed_state(event)
    init_storage()
    local player = game.get_player(event.player_index)
    if player and player.valid and tenebris.is_tenebris_surface(player.surface) then
        update_player_shields(event.player_index)
    end
end

-- Initialize storage on mod load
event_manager.subscribe(tenebris.EVENTS.ON_INIT, "shield_disabler_init", init_storage, tenebris.PRIORITY.NORMAL)
event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "shield_disabler_config", rebuild_all_shields, tenebris.PRIORITY.NORMAL)

-- Subscribe to equipment events
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_PLACED_EQUIPMENT, "shield_disabler_placed", on_player_placed_equipment, tenebris.PRIORITY.NORMAL)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_REMOVED_EQUIPMENT, "shield_disabler_removed", on_player_removed_equipment, tenebris.PRIORITY.NORMAL)
event_manager.subscribe(tenebris.EVENTS.ON_EQUIPMENT_INSERTED, "shield_disabler_inserted", on_equipment_inserted, tenebris.PRIORITY.NORMAL)
event_manager.subscribe(tenebris.EVENTS.ON_EQUIPMENT_REMOVED, "shield_disabler_removed_any", on_equipment_removed, tenebris.PRIORITY.NORMAL)

-- Subscribe to player state changes
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_SURFACE, "shield_disabler_surface_change", on_player_changed_surface, tenebris.PRIORITY.NORMAL)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_DRIVING_CHANGED_STATE, "shield_disabler_driving", on_player_driving_changed_state, tenebris.PRIORITY.NORMAL)

-- Periodic shield draining
event_manager.subscribe_nth_tick(CHECK_INTERVAL, "shield_disabler_tick", on_tick_drain_shields, tenebris.PRIORITY.NORMAL)
