--- Piezoelectric Inserter GUI Module
--- Provides a toggle button to switch between normal and long-handed reach modes.
--- Settings are preserved across copy/paste and blueprints.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local ENTITY_NAME = "piezoelectric-inserter"
local GUI_ID = "piezo_inserter_reach_panel"
local TOGGLE_SWITCH_NAME = "piezo_inserter_reach_switch"
local STORAGE_KEY = "piezo_inserter_modes"

-- Relative offset values for normal vs long-handed reach (relative to inserter, facing north)
-- These match the vanilla inserter vs long-handed-inserter differences
local OFFSETS = {
    normal = {
        pickup = { x = 0, y = -0.97 },
        drop = { x = 0, y = 0.97 },
    },
    long = {
        pickup = { x = 0, y = -1.97 },
        drop = { x = 0, y = 1.97 },
    },
}

--- Rotates an offset based on entity direction
--- @param offset table {x, y} offset relative to north-facing
--- @param direction defines.direction The entity's direction
--- @return table rotated {x, y} rotated offset
local function rotate_offset(offset, direction)
    if direction == defines.direction.north or direction == nil then
        return { x = offset.x, y = offset.y }
    elseif direction == defines.direction.east then
        -- 90° clockwise: (x, y) → (-y, x)
        return { x = -offset.y, y = offset.x }
    elseif direction == defines.direction.south then
        -- 180°: (x, y) → (-x, -y)
        return { x = -offset.x, y = -offset.y }
    elseif direction == defines.direction.west then
        -- 270° clockwise: (x, y) → (y, -x)
        return { x = offset.y, y = -offset.x }
    end
    return { x = offset.x, y = offset.y }
end

--- Calculates absolute map position from inserter position and relative offset
--- @param entity LuaEntity The inserter entity
--- @param offset table {x, y} relative offset (for north-facing)
--- @return table position {x, y} absolute map position
local function calculate_absolute_position(entity, offset)
    local rotated = rotate_offset(offset, entity.direction)
    return {
        entity.position.x + rotated.x,
        entity.position.y + rotated.y,
    }
end

--- Ensures storage is initialized for a force
--- @param force_name string
local function ensure_storage(force_name)
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}
    end
    if not storage[STORAGE_KEY][force_name] then
        storage[STORAGE_KEY][force_name] = {}
    end
end

--- Gets the current mode for an inserter
--- @param entity LuaEntity
--- @return string mode "normal" or "long"
local function get_mode(entity)
    if not entity or not entity.valid or not entity.unit_number then
        return "normal"
    end
    ensure_storage(entity.force.name)
    return storage[STORAGE_KEY][entity.force.name][entity.unit_number] or "normal"
end

--- Sets the mode for an inserter and updates its positions
--- @param entity LuaEntity
--- @param mode string "normal" or "long"
local function set_mode(entity, mode)
    if not entity or not entity.valid or not entity.unit_number then
        return
    end
    
    ensure_storage(entity.force.name)
    storage[STORAGE_KEY][entity.force.name][entity.unit_number] = mode
    
    -- Apply the position changes (absolute map coordinates)
    local offsets = OFFSETS[mode] or OFFSETS.normal
    entity.pickup_position = calculate_absolute_position(entity, offsets.pickup)
    entity.drop_position = calculate_absolute_position(entity, offsets.drop)
end

--- Toggles the mode for an inserter
--- @param entity LuaEntity
--- @return string new_mode The new mode after toggling
local function toggle_mode(entity)
    local current = get_mode(entity)
    local new_mode = current == "normal" and "long" or "normal"
    set_mode(entity, new_mode)
    return new_mode
end

--- Cleans up storage when an inserter is removed
--- @param entity LuaEntity
local function cleanup_storage(entity)
    if not entity or not entity.unit_number then
        return
    end
    if storage[STORAGE_KEY] and storage[STORAGE_KEY][entity.force.name] then
        storage[STORAGE_KEY][entity.force.name][entity.unit_number] = nil
    end
end

--- Creates the GUI panel for a player
--- @param player LuaPlayer
--- @param entity LuaEntity
local function create_gui(player, entity)
    if not player or not entity or not entity.valid then
        return
    end
    
    -- Remove existing GUI if any
    if player.gui.relative[GUI_ID] then
        player.gui.relative[GUI_ID].destroy()
    end
    
    local current_mode = get_mode(entity)
    
    local frame = player.gui.relative.add({
        type = "frame",
        name = GUI_ID,
        direction = "vertical",
        anchor = {
            gui = defines.relative_gui_type.inserter_gui,
            position = defines.relative_gui_position.right,
        },
    })
    
    -- Title
    frame.add({
        type = "label",
        caption = { "gui.piezo-inserter-reach-title" },
        style = "frame_title",
    })
    
    local content = frame.add({
        type = "flow",
        direction = "vertical",
    })
    content.style.padding = 8
    content.style.vertical_spacing = 8
    
    -- Toggle switch with labels
    content.add({
        type = "switch",
        name = TOGGLE_SWITCH_NAME,
        switch_state = current_mode == "long" and "right" or "left",
        left_label_caption = { "gui.piezo-inserter-label-normal" },
        right_label_caption = { "gui.piezo-inserter-label-long" },
        tooltip = { "gui.piezo-inserter-toggle-tooltip" },
    })
end

--- Updates the GUI to reflect current mode
--- @param player LuaPlayer
--- @param entity LuaEntity
local function update_gui(player, entity)
    local frame = player.gui.relative[GUI_ID]
    if not frame or not frame.valid then
        return
    end
    
    local current_mode = get_mode(entity)
    
    -- Update switch state
    local content = frame.children[2]  -- Flow after title
    if content and content[TOGGLE_SWITCH_NAME] then
        content[TOGGLE_SWITCH_NAME].switch_state = current_mode == "long" and "right" or "left"
    end
end

--- Destroys the GUI for a player
--- @param player LuaPlayer
local function destroy_gui(player)
    if player.gui.relative[GUI_ID] then
        player.gui.relative[GUI_ID].destroy()
    end
end

--#region Event Handlers

--- Handler for when a GUI is opened
--- @param event EventData.on_gui_opened
local function on_gui_opened(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    
    if not player or not entity or not entity.valid then
        return
    end
    
    if entity.name == ENTITY_NAME then
        create_gui(player, entity)
    end
end

--- Handler for when a GUI is closed
--- @param event EventData.on_gui_closed
local function on_gui_closed(event)
    local player = game.players[event.player_index]
    if player then
        destroy_gui(player)
    end
end

--- Handler for switch state changes
--- @param event EventData.on_gui_switch_state_changed
local function on_gui_switch_state_changed(event)
    if event.element.name ~= TOGGLE_SWITCH_NAME then
        return
    end
    
    local player = game.players[event.player_index]
    if not player or not player.opened then
        return
    end
    
    local entity = player.opened
    if not entity.valid or entity.name ~= ENTITY_NAME then
        return
    end
    
    -- Set mode based on switch state
    local new_mode = event.element.switch_state == "right" and "long" or "normal"
    set_mode(entity, new_mode)
end

--- Handler for entity settings pasted (copy/paste support)
--- @param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
    local source = event.source
    local destination = event.destination
    
    if not source or not source.valid or source.name ~= ENTITY_NAME then
        return
    end
    if not destination or not destination.valid or destination.name ~= ENTITY_NAME then
        return
    end
    
    -- Copy mode from source to destination
    local mode = get_mode(source)
    set_mode(destination, mode)
end

--- Handler for when an entity is built (apply blueprint settings)
--- @param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.script_raised_built
local function on_entity_built(event)
    local entity = event.entity
    if not entity or not entity.valid or entity.name ~= ENTITY_NAME then
        return
    end
    
    -- Check for blueprint tags
    local tags = event.tags
    if tags and tags.piezo_inserter_mode then
        set_mode(entity, tags.piezo_inserter_mode)
    end
end

--- Handler for when an entity is removed (cleanup storage)
--- @param event EventData.on_player_mined_entity | EventData.on_robot_mined_entity | EventData.on_entity_died
local function on_entity_removed(event)
    local entity = event.entity
    if not entity or entity.name ~= ENTITY_NAME then
        return
    end
    cleanup_storage(entity)
end

--- Handler for when an entity is rotated (recalculate positions)
--- @param event EventData.on_player_rotated_entity
local function on_entity_rotated(event)
    local entity = event.entity
    if not entity or not entity.valid or entity.name ~= ENTITY_NAME then
        return
    end
    
    -- Re-apply the current mode to update positions for new direction
    local mode = get_mode(entity)
    if mode ~= "normal" then
        -- Only need to re-apply if not in default mode
        local offsets = OFFSETS[mode]
        entity.pickup_position = calculate_absolute_position(entity, offsets.pickup)
        entity.drop_position = calculate_absolute_position(entity, offsets.drop)
    end
end

--#endregion

--#region Blueprint Support

--- Adds mode to blueprint entity tags
--- Called via on_player_setup_blueprint
--- @param event EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(event)
    local player = game.players[event.player_index]
    if not player then return end
    
    -- Get the blueprint being set up
    local blueprint = player.blueprint_to_setup
    if not blueprint or not blueprint.valid_for_read then
        blueprint = player.cursor_stack
    end
    if not blueprint or not blueprint.valid_for_read or not blueprint.is_blueprint then
        return
    end
    
    -- Get blueprint entities
    local entities = blueprint.get_blueprint_entities()
    if not entities then return end
    
    -- Get the mapping from event
    local mapping = event.mapping.get()
    if not mapping then return end
    
    -- Check each blueprint entity
    for i, bp_entity in pairs(entities) do
        if bp_entity.name == ENTITY_NAME then
            -- Find the real entity via mapping
            local real_entity = mapping[i]
            if real_entity and real_entity.valid then
                local mode = get_mode(real_entity)
                if mode ~= "normal" then
                    -- Only store non-default modes
                    blueprint.set_blueprint_entity_tag(i, "piezo_inserter_mode", mode)
                end
            end
        end
    end
end

--#endregion

--#region Registration

-- Register event handlers
event_manager.subscribe(tenebris.EVENTS.ON_GUI_OPENED, "piezo_inserter_gui_open", on_gui_opened, tenebris.PRIORITY.UI)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "piezo_inserter_gui_close", on_gui_closed, tenebris.PRIORITY.UI)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_SWITCH_STATE_CHANGED, "piezo_inserter_gui_switch", on_gui_switch_state_changed, tenebris.PRIORITY.UI)
event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_SETTINGS_PASTED, "piezo_inserter_settings_paste", on_entity_settings_pasted, tenebris.PRIORITY.NORMAL)

-- Entity lifecycle
event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "piezo_inserter_built", on_entity_built, tenebris.PRIORITY.NORMAL, 
    {{ filter = "name", name = ENTITY_NAME }})
event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_BUILT_ENTITY, "piezo_inserter_robot_built", on_entity_built, tenebris.PRIORITY.NORMAL,
    {{ filter = "name", name = ENTITY_NAME }})
event_manager.subscribe(tenebris.EVENTS.SCRIPT_RAISED_BUILT, "piezo_inserter_script_built", on_entity_built, tenebris.PRIORITY.NORMAL,
    {{ filter = "name", name = ENTITY_NAME }})

-- Cleanup on removal
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_MINED_ENTITY, "piezo_inserter_mined", on_entity_removed, tenebris.PRIORITY.NORMAL,
    {{ filter = "name", name = ENTITY_NAME }})
event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_MINED_ENTITY, "piezo_inserter_robot_mined", on_entity_removed, tenebris.PRIORITY.NORMAL,
    {{ filter = "name", name = ENTITY_NAME }})
event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "piezo_inserter_died", on_entity_removed, tenebris.PRIORITY.NORMAL,
    {{ filter = "name", name = ENTITY_NAME }})

-- Rotation support (recalculate positions when inserter is rotated)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_ROTATED_ENTITY, "piezo_inserter_rotated", on_entity_rotated, tenebris.PRIORITY.NORMAL)

-- Blueprint support
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_SETUP_BLUEPRINT, "piezo_inserter_blueprint", on_player_setup_blueprint, tenebris.PRIORITY.NORMAL)

--#endregion

return {}

