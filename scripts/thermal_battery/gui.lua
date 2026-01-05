--- Thermal Battery GUI
--- Displays heat capacity and current energy storage.
--- Updates dynamically to show live temperature and energy values.

local tenebris = require("lib.tenebris")

local gui = {}

-- GUI element names
local GUI_FRAME = "thermal_battery_frame"
local GUI_CLOSE_BUTTON = "thermal_battery_close"
local GUI_CAPACITY = "thermal_battery_capacity"
local GUI_TEMPERATURE = "thermal_battery_temperature"
local GUI_ENERGY = "thermal_battery_energy"

-- Quality-based specific heat values (must match prototypes)
local QUALITY_SPECIFIC_HEAT = {
    normal = 100,
    uncommon = 130,
    rare = 160,
    epic = 200,
    legendary = 250
}

-- Base temperature (ambient/minimum)
local BASE_TEMP = 15

-- Storage for tracking which battery each player has open
local function get_player_battery_storage()
    if not storage.thermal_battery_gui then
        storage.thermal_battery_gui = {}
    end
    return storage.thermal_battery_gui
end


--- Formats energy value in appropriate units
--- @param energy_mj number Energy in MJ
--- @return string formatted
local function format_energy(energy_mj)
    if energy_mj >= 1000 then
        return string.format("%.1f GJ", energy_mj / 1000)
    else
        return string.format("%.1f MJ", energy_mj)
    end
end


--- Recursively finds a GUI element by name within a parent
--- @param parent LuaGuiElement The parent element to search in
--- @param name string The element name to find
--- @return LuaGuiElement|nil element The found element or nil
local function find_element(parent, name)
    if parent[name] then
        return parent[name]
    end
    for _, child in pairs(parent.children) do
        local found = find_element(child, name)
        if found then
            return found
        end
    end
    return nil
end


--- Gets the heat entity from a thermal battery
--- The reactor entity IS the heat entity (no longer separate)
--- @param interface_entity LuaEntity The interface/reactor entity
--- @return LuaEntity|nil heat_entity
local function get_heat_entity(interface_entity)
    -- The interface entity is now a reactor, so it IS the heat entity
    if interface_entity and interface_entity.valid then
        return interface_entity
    end
    return nil
end


--- Gets the specific heat for a quality level
--- @param quality_name string The quality name
--- @return number specific_heat in MJ
local function get_specific_heat(quality_name)
    return QUALITY_SPECIFIC_HEAT[quality_name] or QUALITY_SPECIFIC_HEAT.normal
end


--- Creates the thermal battery info panel for a player (attached to native GUI)
--- @param player LuaPlayer The player
--- @param interface_entity LuaEntity The interface entity
local function create_gui(player, interface_entity)
    -- Close existing info panel if open
    gui.close(player)
    
    -- Get heat entity
    local heat_entity = get_heat_entity(interface_entity)
    if not heat_entity then
        return
    end
    
    -- Get quality and specific heat
    local quality_name = interface_entity.quality and interface_entity.quality.name or "normal"
    local specific_heat = get_specific_heat(quality_name)
    
    -- Get current values
    local current_temp = math.floor(heat_entity.temperature or BASE_TEMP)
    local max_temp = 1000  -- From prototype
    local current_energy = specific_heat * math.max(0, current_temp - BASE_TEMP)
    local max_energy = specific_heat * (max_temp - BASE_TEMP)
    
    -- Store which battery this player is viewing
    get_player_battery_storage()[player.index] = {
        interface = interface_entity,
        heat_entity = heat_entity,
        specific_heat = specific_heat
    }
    
    -- Entity GUI is already open (this handler fires from ON_GUI_OPENED)
    -- Just create the info panel attached to it
    
    -- Create info panel attached to the entity GUI using relative GUI
    local anchor = {
        gui = defines.relative_gui_type.reactor_gui,
        position = defines.relative_gui_position.right,
    }
    
    local frame = player.gui.relative.add{
        type = "frame",
        name = GUI_FRAME,
        direction = "vertical",
        anchor = anchor,
    }
    
    -- Title
    local title_bar = frame.add{
        type = "flow",
        direction = "horizontal",
    }
    title_bar.style.horizontal_spacing = 8
    
    title_bar.add{
        type = "label",
        caption = "Energy Status",
        style = "frame_title",
    }
    
    -- Content flow
    local content = frame.add{
        type = "flow",
        direction = "vertical",
    }
    content.style.padding = 8
    
    -- Quality indicator (if not normal)
    if quality_name ~= "normal" then
        local quality_label = content.add{
            type = "label",
            caption = "Quality: " .. quality_name:gsub("^%l", string.upper),
        }
        quality_label.style.font_color = {r = 0.8, g = 0.8, b = 1}
        quality_label.style.bottom_margin = 4
    end
    
    -- Heat Capacity
    local capacity_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    capacity_row.add{
        type = "label",
        caption = "Heat Capacity:",
    }
    local capacity_value = capacity_row.add{
        type = "label",
        name = GUI_CAPACITY,
        caption = string.format("%d MJ/°C", specific_heat),
    }
    capacity_value.style.font_color = {r = 0.7, g = 0.9, b = 1}
    
    -- Current Temperature
    local temp_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    temp_row.style.top_margin = 4
    temp_row.add{
        type = "label",
        caption = "Temperature:",
    }
    local temp_value = temp_row.add{
        type = "label",
        name = GUI_TEMPERATURE,
        caption = string.format("%d°C", current_temp),
    }
    -- Color temperature based on heat level
    local heat_ratio = (current_temp - BASE_TEMP) / (max_temp - BASE_TEMP)
    if heat_ratio > 0.7 then
        temp_value.style.font_color = {r = 1, g = 0.3, b = 0.3}  -- Hot red
    elseif heat_ratio > 0.3 then
        temp_value.style.font_color = {r = 1, g = 0.6, b = 0.4}  -- Warm orange
    else
        temp_value.style.font_color = {r = 0.7, g = 0.9, b = 1}  -- Cool blue
    end
    
    -- Energy Storage
    local energy_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    energy_row.style.top_margin = 4
    energy_row.add{
        type = "label",
        caption = "Energy Stored:",
    }
    local energy_value = energy_row.add{
        type = "label",
        name = GUI_ENERGY,
        caption = string.format("%s / %s", format_energy(current_energy), format_energy(max_energy)),
    }
    energy_value.style.font_color = {r = 1, g = 0.8, b = 0.4}
end


--- Closes the thermal battery GUI for a player
--- @param player LuaPlayer The player
function gui.close(player)
    -- Check both relative and screen GUIs
    local frame = player.gui.relative[GUI_FRAME]
    if frame then
        frame.destroy()
    end
    frame = player.gui.screen[GUI_FRAME]
    if frame then
        frame.destroy()
    end
    get_player_battery_storage()[player.index] = nil
end


--- Opens the GUI for a thermal battery
--- @param player LuaPlayer The player
--- @param entity LuaEntity The thermal battery interface entity
function gui.open(player, entity)
    create_gui(player, entity)
end


--- Updates the dynamic status elements for a player's open GUI
--- @param player LuaPlayer The player
--- @param battery_data table The stored battery data
local function update_gui(player, battery_data)
    local frame = player.gui.relative[GUI_FRAME] or player.gui.screen[GUI_FRAME]
    if not frame then return end
    
    local heat_entity = battery_data.heat_entity
    if not heat_entity or not heat_entity.valid then
        gui.close(player)
        return
    end
    
    local specific_heat = battery_data.specific_heat
    local current_temp = math.floor(heat_entity.temperature or BASE_TEMP)
    local max_temp = 1000
    local current_energy = specific_heat * math.max(0, current_temp - BASE_TEMP)
    local max_energy = specific_heat * (max_temp - BASE_TEMP)
    local heat_ratio = (current_temp - BASE_TEMP) / (max_temp - BASE_TEMP)
    
    -- Update temperature
    local temp_label = find_element(frame, GUI_TEMPERATURE)
    if temp_label then
        temp_label.caption = string.format("%d°C", current_temp)
        if heat_ratio > 0.7 then
            temp_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
        elseif heat_ratio > 0.3 then
            temp_label.style.font_color = {r = 1, g = 0.6, b = 0.4}
        else
            temp_label.style.font_color = {r = 0.7, g = 0.9, b = 1}
        end
    end
    
    -- Update energy
    local energy_label = find_element(frame, GUI_ENERGY)
    if energy_label then
        energy_label.caption = string.format("%s / %s", format_energy(current_energy), format_energy(max_energy))
    end
end


-- Event handlers
local event_manager = tenebris.event_manager


-- Handle entity open (player clicks on battery)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_OPENED, "thermal_battery_gui_opened", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    -- Check for all quality variants
    if string.find(entity.name, "^tenebris%-thermal%-battery") then
        gui.open(player, entity)
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle GUI closed (either our panel or the entity GUI)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "thermal_battery_gui_closed", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    -- Close our info panel if the entity GUI was closed
    local entity = event.entity
    if entity and entity.valid and string.find(entity.name, "^tenebris%-thermal%-battery") then
        gui.close(player)
        return
    end
    
    -- Also close if our panel itself was closed
    local element = event.element
    if element and element.valid and element.name == GUI_FRAME then
        gui.close(player)
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle close button click
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLICK, "thermal_battery_gui_click", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    if element.name == GUI_CLOSE_BUTTON then
        local player = game.get_player(event.player_index)
        if player then
            gui.close(player)
        end
    end
end, tenebris.PRIORITY.NORMAL)


-- Periodic update for open GUIs (every 0.5 seconds)
event_manager.subscribe_nth_tick(30, "thermal_battery_gui_update", function(event)
    local player_storage = get_player_battery_storage()
    
    for player_index, battery_data in pairs(player_storage) do
        local player = game.get_player(player_index)
        if player and player.valid then
            update_gui(player, battery_data)
        else
            -- Clean up invalid player entries
            player_storage[player_index] = nil
        end
    end
end, tenebris.PRIORITY.UI)


return gui

