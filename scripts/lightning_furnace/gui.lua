--- Lightning Furnace GUI Module
--- Displays a custom GUI panel showing energy status for both the lightning collector and furnace buffer.

local tenebris = require("lib.tenebris")
local lifecycle = tenebris.composite_entity.lifecycle
local event_manager = tenebris.event_manager

local GUI_ID = "lightning_furnace_energy_panel"
local COLLECTOR_ENTITY = tenebris.ENTITY.LIGHTNING_COLLECTOR_HIDDEN

--- Creates the GUI panel for a player
--- @param player LuaPlayer The player to create the GUI for
--- @param furnace_entity LuaEntity The lightning furnace entity
--- @return LuaGuiElement|nil The created frame, or nil if creation failed
local function create_gui(player, furnace_entity)
    if not player or not furnace_entity or not furnace_entity.valid then
        return nil
    end

    -- Remove existing GUI if any
    if player.gui.relative[GUI_ID] then
        player.gui.relative[GUI_ID].destroy()
    end

    local frame = player.gui.relative.add({
        type = "frame",
        name = GUI_ID,
        direction = "vertical",
        anchor = {
            gui = defines.relative_gui_type.furnace_gui,
            position = defines.relative_gui_position.right
        }
    })

    -- Title
    frame.add({
        type = "label",
        caption = {"gui.lightning-energy-status"},
        style = "frame_title"
    })

    local content_flow = frame.add({
        type = "flow",
        name = "content_flow",
        direction = "vertical"
    })
    content_flow.style.vertical_spacing = 8
    content_flow.style.padding = 8

    -- Lightning Collector Section
    local collector_flow = content_flow.add({
        type = "flow",
        name = "collector_flow",
        direction = "vertical"
    })
    collector_flow.add({
        type = "label",
        name = "collector_label",
        caption = {"gui.lightning-collector"}
    })
    collector_flow.add({
        type = "progressbar",
        name = "collector_energy_bar",
        value = 0
    }).style.horizontally_stretchable = true
    collector_flow.add({
        type = "label",
        name = "collector_value_label",
        caption = ""
    })

    -- Furnace Buffer Section
    local furnace_flow = content_flow.add({
        type = "flow",
        name = "furnace_flow",
        direction = "vertical"
    })
    furnace_flow.add({
        type = "label",
        name = "furnace_label",
        caption = {"gui.furnace-buffer"}
    })
    furnace_flow.add({
        type = "progressbar",
        name = "furnace_energy_bar",
        value = 0
    }).style.horizontally_stretchable = true
    furnace_flow.add({
        type = "label",
        name = "furnace_value_label",
        caption = ""
    })
    furnace_flow.add({
        type = "label",
        name = "furnace_consumption_label",
        caption = "",
        style = "label_with_left_padding"
    })

    return frame
end

--- Updates the GUI with current energy values
--- @param player LuaPlayer The player whose GUI to update
--- @param furnace_entity LuaEntity The lightning furnace entity
local function update_gui(player, furnace_entity)
    if not player or not furnace_entity or not furnace_entity.valid then
        return
    end

    local gui_frame = player.gui.relative[GUI_ID]
    if not gui_frame or not gui_frame.valid then
        return
    end

    -- Get composite data via new API
    local composite_id = lifecycle.get_by_interface(furnace_entity)
    if not composite_id then
        return
    end
    
    local composite = lifecycle.get(composite_id)
    if not composite or not composite.entities then
        return
    end

    -- Get the lightning collector by name
    local collector_entity = composite.entities[COLLECTOR_ENTITY]
    if not collector_entity or not collector_entity.valid then
        return
    end

    -- Update Collector Energy
    local collector_energy = collector_entity.energy or 0
    local collector_capacity = collector_entity.electric_buffer_size or 1
    local collector_percent = collector_energy / collector_capacity

    local content_flow = gui_frame.content_flow
    if content_flow then
        local collector_flow = content_flow.collector_flow
        if collector_flow then
            local bar = collector_flow.collector_energy_bar
            if bar then bar.value = collector_percent end
            
            local label = collector_flow.collector_value_label
            if label then
                label.caption = string.format("%.1f / %.1f MJ (%.0f%%)",
                    collector_energy / 1000000,
                    collector_capacity / 1000000,
                    collector_percent * 100)
            end
        end
    end

    -- Update Furnace Energy
    local furnace_energy = furnace_entity.energy or 0
    local furnace_capacity = furnace_entity.electric_buffer_size or 1
    local furnace_percent = furnace_energy / furnace_capacity

    if content_flow then
        local furnace_flow = content_flow.furnace_flow
        if furnace_flow then
            local bar = furnace_flow.furnace_energy_bar
            if bar then bar.value = furnace_percent end
            
            local label = furnace_flow.furnace_value_label
            if label then
                label.caption = string.format("%.1f / %.1f MJ (%.0f%%)",
                    furnace_energy / 1000000,
                    furnace_capacity / 1000000,
                    furnace_percent * 100)
            end
            
            -- Show current energy consumption
            local consumption_label = furnace_flow.furnace_consumption_label
            if consumption_label then
                -- Get base consumption and module effects
                local base_consumption = 10000000 -- 10MW base
                local consumption_bonus = furnace_entity.consumption_bonus or 0
                local actual_consumption = base_consumption * (1 + consumption_bonus)
                
                -- Check if furnace has work to do (is crafting OR has items waiting)
                local has_work = furnace_entity.is_crafting() or 
                                (furnace_entity.get_inventory(defines.inventory.furnace_source) and
                                 not furnace_entity.get_inventory(defines.inventory.furnace_source).is_empty())
                
                local status = ""
                if has_work then
                    status = string.format("⚡ Consuming: %.1f MW", actual_consumption / 1000000)
                else
                    -- Hardcoded 1MW drain (manually implemented in lua due to input_flow_limit = 0W)
                    status = "⚡ Idle (1.0 MW drain)"
                end
                consumption_label.caption = status
            end
        end
    end
end

--- Handler for when a GUI is opened
--- @param event EventData.on_gui_opened
local function on_gui_opened(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    
    if not player or not entity or not entity.valid then
        return
    end

    if entity.name == tenebris.ENTITY.LIGHTNING_FURNACE then
        create_gui(player, entity)
        update_gui(player, entity)
    end
end

--- Handler for when a GUI is closed
--- @param event EventData.on_gui_closed
local function on_gui_closed(event)
    local player = game.players[event.player_index]
    if not player then
        return
    end

    local gui_frame = player.gui.relative[GUI_ID]
    if gui_frame and gui_frame.valid then
        gui_frame.destroy()
    end
end

--- Handler for periodic GUI updates (every tick for smooth display)
local function on_tick_update_gui()
    for _, player in pairs(game.players) do
        if player.opened and player.opened.object_name == "LuaEntity" then
            local entity = player.opened
            if entity and entity.valid and entity.name == tenebris.ENTITY.LIGHTNING_FURNACE then
                update_gui(player, entity)
            end
        end
    end
end

-- Register event handlers
event_manager.subscribe(tenebris.EVENTS.ON_GUI_OPENED, "lightning_furnace_gui_open", on_gui_opened, tenebris.PRIORITY.UI)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "lightning_furnace_gui_close", on_gui_closed, tenebris.PRIORITY.UI)
event_manager.subscribe(tenebris.EVENTS.ON_TICK, "lightning_furnace_gui_update", on_tick_update_gui, tenebris.PRIORITY.UI)

return {}
