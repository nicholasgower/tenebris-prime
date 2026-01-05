--- Piezoelectric Generator GUI
--- Custom interface for viewing generator stats when clicking the power pole
---
--- @module quartz_forest.gui

local tenebris = require("lib.tenebris")
local piezo_constants = require("lib.piezoelectric_constants")

local event_manager = tenebris.event_manager
local lifecycle = tenebris.composite_entity.lifecycle
local PRIORITY = tenebris.PRIORITY.UI
local TIERS = piezo_constants.TIERS

local gui = {}

--- GUI element names
local GUI_PREFIX = "piezo_generator_"
local FRAME_NAME = GUI_PREFIX .. "frame"

--- Get tier info from pole entity name
--- @param pole_name string
--- @return table|nil tier
local function get_tier_from_pole(pole_name)
    for i = 1, 4 do
        local tier = piezo_constants.get_tier(i)
        if tier and tier.pole_name == pole_name then
            return tier
        end
    end
    return nil
end

--- Get tier info from interface entity name
--- @param interface_name string
--- @return table|nil tier
local function get_tier_from_interface(interface_name)
    for _, tier in ipairs(TIERS) do
        if tier.interface_name == interface_name then
            return tier
        end
    end
    return nil
end

--- Format power value for display
--- @param watts number
--- @return string
local function format_power(watts)
    if watts >= 1e9 then
        return string.format("%.1f GW", watts / 1e9)
    elseif watts >= 1e6 then
        return string.format("%.1f MW", watts / 1e6)
    elseif watts >= 1e3 then
        return string.format("%.1f kW", watts / 1e3)
    else
        return string.format("%.0f W", watts)
    end
end

--- Create the piezoelectric generator GUI
--- @param player LuaPlayer
--- @param interface LuaEntity The interface entity
--- @param tier table The tier info
function gui.create(player, interface, tier)
    -- Close any existing GUI
    gui.destroy(player)
    
    if not tier then return end
    
    local composite_id = lifecycle.get_by_interface(interface)
    local composite = composite_id and lifecycle.get(composite_id)
    local generator = composite and composite.entities[tier.generator_name]
    
    -- Create main frame
    local frame = player.gui.screen.add{
        type = "frame",
        name = FRAME_NAME,
        direction = "vertical"
    }
    frame.auto_center = true
    
    -- Store references for updates
    frame.tags = {
        composite_id = composite_id,
        tier_num = tier.tier
    }
    
    -- Title bar with title and close button
    local title_flow = frame.add{
        type = "flow",
        direction = "horizontal"
    }
    title_flow.style.horizontally_stretchable = true
    
    title_flow.add{
        type = "label",
        caption = {"tenebris.piezo-generator-title"},
        style = "frame_title"
    }
    
    -- Drag handle (empty widget that fills space)
    local drag = title_flow.add{
        type = "empty-widget",
        style = "draggable_space_header"
    }
    drag.style.horizontally_stretchable = true
    drag.style.height = 24
    drag.drag_target = frame
    
    title_flow.add{
        type = "sprite-button",
        name = GUI_PREFIX .. "close",
        sprite = "utility/close",
        style = "close_button"
    }
    
    -- Content frame
    local content = frame.add{
        type = "frame",
        direction = "vertical",
        style = "inside_shallow_frame_with_padding"
    }
    content.style.minimal_width = 280
    
    -- Tier info
    local tier_flow = content.add{type = "flow", direction = "horizontal"}
    tier_flow.add{type = "label", caption = {"tenebris.piezo-tier-label"}, style = "heading_2_label"}
    tier_flow.add{type = "label", name = GUI_PREFIX .. "tier", caption = tostring(tier.tier)}
    
    content.add{type = "line"}
    
    -- Power output section
    content.add{type = "label", caption = {"tenebris.piezo-power-header"}, style = "heading_2_label"}
    
    local power_table = content.add{type = "table", column_count = 2}
    power_table.style.column_alignments[2] = "right"
    
    power_table.add{type = "label", caption = {"tenebris.piezo-max-output"}}
    power_table.add{type = "label", caption = tier.power_output}
    
    power_table.add{type = "label", caption = {"tenebris.piezo-current-output"}}
    power_table.add{type = "label", name = GUI_PREFIX .. "current_output", caption = "0 W"}
    
    power_table.add{type = "label", caption = {"tenebris.piezo-coverage"}}
    power_table.add{type = "label", caption = string.format("%d tiles", tier.supply_radius)}
    
    content.add{type = "line"}
    
    -- Heat status section
    content.add{type = "label", caption = {"tenebris.piezo-heat-header"}, style = "heading_2_label"}
    
    local heat_table = content.add{type = "table", column_count = 2}
    heat_table.style.column_alignments[2] = "right"
    
    heat_table.add{type = "label", caption = {"tenebris.piezo-temperature"}}
    heat_table.add{type = "label", name = GUI_PREFIX .. "temperature", caption = "-- °C"}
    
    heat_table.add{type = "label", caption = {"tenebris.piezo-min-temp"}}
    heat_table.add{type = "label", caption = string.format("%d °C", tier.min_working_temp)}
    
    -- Status indicator
    content.add{type = "line"}
    local status_flow = content.add{type = "flow", direction = "horizontal"}
    status_flow.add{type = "label", caption = {"tenebris.piezo-status"}}
    status_flow.add{type = "label", name = GUI_PREFIX .. "status", caption = {"tenebris.piezo-status-offline"}}
    
    -- Initial update
    gui.update(player)
    
    -- Set as opened
    player.opened = frame
end

--- Destroy the GUI
--- @param player LuaPlayer
function gui.destroy(player)
    local frame = player.gui.screen[FRAME_NAME]
    if frame then
        frame.destroy()
    end
end

--- Update the GUI with current values
--- @param player LuaPlayer
function gui.update(player)
    local frame = player.gui.screen[FRAME_NAME]
    if not frame then return end
    
    local tags = frame.tags
    if not tags or not tags.composite_id then return end
    
    -- Get composite from ID
    local composite = lifecycle.get(tags.composite_id)
    if not composite then return end
    
    local tier = piezo_constants.get_tier(tags.tier_num)
    if not tier then return end
    
    local interface = composite.entities[tier.interface_name]
    local generator = composite.entities[tier.generator_name]
    
    -- Get temperature from interface
    local temperature = 0
    if interface and interface.valid and interface.temperature then
        temperature = interface.temperature
    end
    
    local min_temp = tier.min_working_temp or 500
    
    -- Find and update labels by searching the frame
    local function find_label(name)
        local function search(element)
            if element.name == name then return element end
            for _, child in pairs(element.children or {}) do
                local found = search(child)
                if found then return found end
            end
            return nil
        end
        return search(frame)
    end
    
    local temp_lbl = find_label(GUI_PREFIX .. "temperature")
    if temp_lbl then
        temp_lbl.caption = string.format("%.0f °C", temperature)
    end
    
    -- Update current output
    local output_lbl = find_label(GUI_PREFIX .. "current_output")
    if output_lbl and generator and generator.valid then
        local energy = generator.energy_generated_last_tick or 0
        output_lbl.caption = format_power(energy * 60)  -- Convert per-tick to per-second
    end
    
    -- Update status
    local status_lbl = find_label(GUI_PREFIX .. "status")
    if status_lbl then
        if temperature >= min_temp then
            status_lbl.caption = {"tenebris.piezo-status-online"}
            status_lbl.style.font_color = {0, 1, 0}
        else
            status_lbl.caption = {"tenebris.piezo-status-offline"}
            status_lbl.style.font_color = {1, 0.3, 0.3}
        end
    end
end

-- =============================================================================
-- Event handlers
-- =============================================================================

--- Handle GUI opened - intercept pole and interface clicks
event_manager.subscribe(tenebris.EVENTS.ON_GUI_OPENED, "piezo_gui_opened", function(event)
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    local player = game.players[event.player_index]
    
    -- Check if it's one of our hidden poles
    if entity.name:match("tenebris%-piezoelectric%-pole%-hidden") then
        local tier = get_tier_from_pole(entity.name)
        if tier then
            -- Find the interface via composite
            local composite_id = lifecycle.get_by_interface(entity)
            if not composite_id then
                -- Pole is a component, not interface - need to find via different method
                -- For poles, we need to find nearby interface
                local interfaces = entity.surface.find_entities_filtered{
                    position = entity.position,
                    radius = 1,
                    name = tier.interface_name
                }
                if #interfaces > 0 then
                    local interface = interfaces[1]
                    player.opened = nil
                    gui.create(player, interface, tier)
                end
            end
        end
        return
    end
    
    -- Check if it's one of our heat interfaces
    if entity.name:match("tenebris%-piezoelectric%-interface%-tier") then
        local tier = get_tier_from_interface(entity.name)
        if tier then
            player.opened = nil
            gui.create(player, entity, tier)
        end
    end
end, PRIORITY)

--- Handle GUI clicks
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLICK, "piezo_gui_click", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    if element.name == GUI_PREFIX .. "close" then
        local player = game.players[event.player_index]
        gui.destroy(player)
    end
end, PRIORITY)

--- Handle GUI closed
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "piezo_gui_closed", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    if element.name == FRAME_NAME then
        local player = game.players[event.player_index]
        gui.destroy(player)
    end
end, PRIORITY)

--- Periodic update for open GUIs
event_manager.subscribe_nth_tick(30, "piezo_gui_update", function(_)
    for _, player in pairs(game.players) do
        if player.gui.screen[FRAME_NAME] then
            gui.update(player)
        end
    end
end, PRIORITY)


return gui
