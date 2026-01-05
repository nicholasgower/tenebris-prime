--- Composite Entity Event Subscriptions
--- Registers global handlers for composite entity lifecycle.
--- Only handles interface entity events - hidden entities are non-interactable.
---
--- @module composite_entity.events

local tenebris = require("lib.tenebris")
local lifecycle = require("lib.composite_entity.lifecycle")
local storage = require("lib.composite_entity.storage")

local COMPOSITE_PRIORITY = tenebris.PRIORITY.CRITICAL

--- Handles interface entity creation
local function on_entity_created(event)
    local entity = event.entity or event.created_entity or event.destination
    if not entity or not entity.valid then
        return
    end
    
    -- Check if this is an interface entity
    local is_interface = lifecycle.is_interface_entity(entity)
    if is_interface then
        lifecycle.on_interface_created(entity, event)
    end
end

--- Handles interface entity mined
local function on_entity_mined(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Check if this is an interface entity
    local is_interface = lifecycle.is_interface_entity(entity)
    if is_interface then
        lifecycle.on_interface_destroyed(entity, event)
    end
end

--- Handles interface entity destroyed
local function on_entity_destroyed(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Check if this is an interface entity
    local is_interface = lifecycle.is_interface_entity(entity)
    if is_interface then
        lifecycle.on_interface_destroyed(entity, event)
    end
end

--- Handles interface entity rotated
local function on_entity_rotated(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Check if this is an interface entity
    local is_interface = lifecycle.is_interface_entity(entity)
    if is_interface then
        lifecycle.on_interface_orientation_changed(entity, event.previous_direction)
    end
end

--- Handles interface entity flipped
local function on_entity_flipped(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Check if this is an interface entity
    local is_interface = lifecycle.is_interface_entity(entity)
    if is_interface then
        lifecycle.on_interface_orientation_changed(entity, nil)
    end
end

--- Handles selection change for heat indicator visibility
local function on_selected_entity_changed(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    -- Hide previous selection's indicators
    if event.last_entity and event.last_entity.valid then
        local last_id = storage.get_composite_id_for_interface(event.last_entity)
        if last_id then
            lifecycle.set_heat_indicators_visible(last_id, false)
        end
    end
    
    -- Show current selection's indicators
    local selected = player.selected
    if selected and selected.valid then
        local selected_id = storage.get_composite_id_for_interface(selected)
        if selected_id then
            lifecycle.set_heat_indicators_visible(selected_id, true)
        end
    end
end

--- Initialize storage
local function on_init()
    storage.initialize()
end

--- Initialize storage on configuration change
local function on_configuration_changed(event)
    storage.initialize()
    -- Rebuild type index for saves that don't have it yet
    storage.rebuild_type_index()
end

-- Register event handlers
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "composite_lifecycle", on_entity_created, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_BUILT_ENTITY, "composite_lifecycle", on_entity_created, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_CLONED, "composite_lifecycle", on_entity_created, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.SCRIPT_RAISED_BUILT, "composite_lifecycle", on_entity_created, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.SCRIPT_RAISED_REVIVE, "composite_lifecycle", on_entity_created, COMPOSITE_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_MINED_ENTITY, "composite_lifecycle", on_entity_mined, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_MINED_ENTITY, "composite_lifecycle", on_entity_mined, COMPOSITE_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "composite_lifecycle", on_entity_destroyed, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.SCRIPT_RAISED_DESTROY, "composite_lifecycle", on_entity_destroyed, COMPOSITE_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_ROTATED_ENTITY, "composite_lifecycle", on_entity_rotated, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_FLIPPED_ENTITY, "composite_lifecycle", on_entity_flipped, COMPOSITE_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_SELECTED_ENTITY_CHANGED, "composite_heat_indicators", on_selected_entity_changed, tenebris.PRIORITY.NORMAL)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_INIT, "composite_lifecycle", on_init, COMPOSITE_PRIORITY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "composite_lifecycle", on_configuration_changed, COMPOSITE_PRIORITY)

return {}
