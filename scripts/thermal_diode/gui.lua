--- Thermal Diode GUI
--- Provides a simple interface for setting the temperature threshold.
--- Updates dynamically to show live temperature and diode state.

local tenebris = require("lib.tenebris")
local thermal_diode = require("scripts.thermal_diode.init")

local gui = {}

-- GUI element names
local GUI_FRAME = "thermal_diode_frame"
local GUI_CLOSE_BUTTON = "thermal_diode_close"
local GUI_THRESHOLD_FIELD = "thermal_diode_threshold"
local GUI_THRESHOLD_CIRCUIT = "thermal_diode_threshold_circuit"
local GUI_TEMPERATURE_SIGNAL = "thermal_diode_temperature_signal"
local GUI_THRESHOLD_SIGNAL = "thermal_diode_threshold_signal"
local GUI_OUTPUT_SIGNAL = "thermal_diode_output_signal"
local GUI_OUTPUT_CONSTANT = "thermal_diode_output_constant"
local GUI_INPUT_TEMP = "thermal_diode_input_temp"
local GUI_OUTPUT_TEMP = "thermal_diode_output_temp"
local GUI_DIODE_STATUS = "thermal_diode_status"

-- Storage for tracking which diode each player has open
local function get_player_diode_storage()
    if not storage.thermal_diode_gui then
        storage.thermal_diode_gui = {}
    end
    return storage.thermal_diode_gui
end


--- Creates the thermal diode GUI for a player
--- @param player LuaPlayer The player
--- @param composite_id string The composite ID of the diode
--- @param diode_data table The diode tracking data
local function create_gui(player, composite_id, diode_data)
    -- Close existing GUI if open
    gui.close(player)
    
    -- Store which diode this player is editing
    get_player_diode_storage()[player.index] = composite_id
    
    -- Get current values
    local current_threshold = diode_data.threshold or 500
    local input_temp = 0
    local output_temp = 0
    local is_open = diode_data.is_open or false
    
    if diode_data.input and diode_data.input.valid then
        input_temp = math.floor(diode_data.input.temperature or 0)
    end
    if diode_data.output and diode_data.output.valid then
        output_temp = math.floor(diode_data.output.temperature or 0)
    end
    
    -- Create the GUI
    local frame = player.gui.screen.add{
        type = "frame",
        name = GUI_FRAME,
        direction = "vertical",
    }
    frame.auto_center = true
    
    -- Titlebar with close button
    local titlebar = frame.add{
        type = "flow",
        direction = "horizontal",
    }
    titlebar.drag_target = frame
    
    titlebar.add{
        type = "label",
        caption = "Thermal Diode",
        style = "frame_title",
        ignored_by_interaction = true,
    }
    
    local filler = titlebar.add{
        type = "empty-widget",
        style = "draggable_space_header",
        ignored_by_interaction = true,
    }
    filler.style.height = 24
    filler.style.horizontally_stretchable = true
    
    titlebar.add{
        type = "sprite-button",
        name = GUI_CLOSE_BUTTON,
        sprite = "utility/close",
        style = "close_button",
    }
    
    -- Content flow
    local content = frame.add{
        type = "flow",
        direction = "vertical",
    }
    content.style.padding = 8
    
    -- Description
    content.add{
        type = "label",
        caption = "Heat flows when input temperature ≥ threshold.",
    }
    
    -- Display signals section header
    local display_header = content.add{
        type = "label",
        caption = "── Display Signals ──",
    }
    display_header.style.top_margin = 8
    display_header.style.font = "default-semibold"
    
    -- Temperature signal row
    local temp_signal_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    temp_signal_row.style.vertical_align = "center"
    temp_signal_row.style.top_margin = 4
    
    temp_signal_row.add{
        type = "label",
        caption = "Temperature:",
    }
    
    local temperature_signal = temp_signal_row.add{
        type = "choose-elem-button",
        name = GUI_TEMPERATURE_SIGNAL,
        elem_type = "signal",
    }
    if diode_data.temperature_signal then
        temperature_signal.elem_value = diode_data.temperature_signal
    end
    
    -- Threshold section header
    local threshold_header = content.add{
        type = "label",
        caption = "── Threshold ──",
    }
    threshold_header.style.top_margin = 8
    threshold_header.style.font = "default-semibold"
    
    -- Threshold constant row
    local threshold_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    threshold_row.style.vertical_align = "center"
    threshold_row.style.top_margin = 4
    
    threshold_row.add{
        type = "label",
        caption = "Default (°C):",
    }
    
    local textfield = threshold_row.add{
        type = "textfield",
        name = GUI_THRESHOLD_FIELD,
        text = tostring(current_threshold),
        numeric = true,
        allow_decimal = false,
        allow_negative = false,
    }
    textfield.style.width = 80
    
    -- Circuit override label (shown when circuit is connected)
    local circuit_label = threshold_row.add{
        type = "label",
        name = GUI_THRESHOLD_CIRCUIT,
        caption = "",
    }
    circuit_label.style.font_color = {r = 0.5, g = 0.8, b = 1.0}  -- Cyan to indicate circuit control
    circuit_label.visible = false
    
    -- Threshold signal override row
    local signal_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    signal_row.style.vertical_align = "center"
    signal_row.style.top_margin = 4
    
    signal_row.add{
        type = "label",
        caption = "Signal override:",
    }
    
    local threshold_signal = signal_row.add{
        type = "choose-elem-button",
        name = GUI_THRESHOLD_SIGNAL,
        elem_type = "signal",
    }
    if diode_data.threshold_signal then
        threshold_signal.elem_value = diode_data.threshold_signal
    end
    
    -- Circuit output section header
    local output_header = content.add{
        type = "label",
        caption = "── Circuit Output ──",
    }
    output_header.style.top_margin = 12
    output_header.style.font = "default-semibold"
    
    -- Output signal row
    local output_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    output_row.style.vertical_align = "center"
    output_row.style.top_margin = 4
    
    output_row.add{
        type = "label",
        caption = "Output:",
    }
    
    local output_signal = output_row.add{
        type = "choose-elem-button",
        name = GUI_OUTPUT_SIGNAL,
        elem_type = "signal",
    }
    if diode_data.output_signal then
        output_signal.elem_value = diode_data.output_signal
    end
    
    output_row.add{
        type = "label",
        caption = " =",
    }
    
    local output_constant = output_row.add{
        type = "textfield",
        name = GUI_OUTPUT_CONSTANT,
        text = tostring(diode_data.output_constant or 1),
        numeric = true,
        allow_decimal = false,
        allow_negative = true,
    }
    output_constant.style.width = 60
    
    output_row.add{
        type = "label",
        caption = " when open",
    }
    
    -- Status section
    local status_header = content.add{
        type = "label",
        caption = "── Status ──",
    }
    status_header.style.top_margin = 12
    status_header.style.font = "default-semibold"
    
    -- Input temperature
    local input_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    input_row.style.top_margin = 4
    input_row.add{
        type = "label",
        caption = "Input Temperature:",
    }
    local input_value = input_row.add{
        type = "label",
        name = GUI_INPUT_TEMP,
        caption = string.format("%d°C", input_temp),
    }
    input_value.style.font_color = {r = 1, g = 0.6, b = 0.4}  -- Orange/warm color
    
    -- Output temperature
    local output_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    output_row.style.top_margin = 2
    output_row.add{
        type = "label",
        caption = "Output Temperature:",
    }
    local output_value = output_row.add{
        type = "label",
        name = GUI_OUTPUT_TEMP,
        caption = string.format("%d°C", output_temp),
    }
    output_value.style.font_color = {r = 1, g = 0.6, b = 0.4}
    
    -- Diode state
    local state_row = content.add{
        type = "flow",
        direction = "horizontal",
    }
    state_row.style.top_margin = 2
    state_row.add{
        type = "label",
        caption = "State:",
    }
    local state_label = state_row.add{
        type = "label",
        name = GUI_DIODE_STATUS,
        caption = is_open and "● Open" or "● Closed",
    }
    if is_open then
        state_label.style.font_color = {r = 0.3, g = 1, b = 0.3}  -- Green
    else
        state_label.style.font_color = {r = 1, g = 0.3, b = 0.3}  -- Red
    end
    
    player.opened = frame
end


--- Closes the thermal diode GUI for a player
--- @param player LuaPlayer The player
function gui.close(player)
    local frame = player.gui.screen[GUI_FRAME]
    if frame then
        frame.destroy()
    end
    get_player_diode_storage()[player.index] = nil
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


--- Updates the dynamic status elements for a player's open GUI
--- @param player LuaPlayer The player
--- @param composite_id string The composite ID
local function update_gui(player, composite_id)
    local frame = player.gui.screen[GUI_FRAME]
    if not frame then return end
    
    local diode_data = thermal_diode.get_by_composite_id(composite_id)
    if not diode_data then return end
    
    -- Update input temperature
    local input_label = find_element(frame, GUI_INPUT_TEMP)
    if input_label then
        local input_temp = 0
        if diode_data.input and diode_data.input.valid then
            input_temp = math.floor(diode_data.input.temperature or 0)
        end
        input_label.caption = string.format("%d°C", input_temp)
    end
    
    -- Update output temperature
    local output_label = find_element(frame, GUI_OUTPUT_TEMP)
    if output_label then
        local output_temp = 0
        if diode_data.output and diode_data.output.valid then
            output_temp = math.floor(diode_data.output.temperature or 0)
        end
        output_label.caption = string.format("%d°C", output_temp)
    end
    
    -- Update diode state
    local state_label = find_element(frame, GUI_DIODE_STATUS)
    if state_label then
        local is_open = diode_data.is_open or false
        state_label.caption = is_open and "● Open" or "● Closed"
        if is_open then
            state_label.style.font_color = {r = 0.3, g = 1, b = 0.3}
        else
            state_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
        end
    end
    
    -- Update threshold field based on circuit override
    local threshold_field = find_element(frame, GUI_THRESHOLD_FIELD)
    local circuit_label = find_element(frame, GUI_THRESHOLD_CIRCUIT)
    local circuit_threshold = thermal_diode.get_circuit_threshold(composite_id)
    
    if circuit_threshold then
        -- Circuit is connected - hide textfield, show label
        if threshold_field then
            threshold_field.visible = false
        end
        if circuit_label then
            circuit_label.caption = string.format("%d°C (from circuit)", math.floor(circuit_threshold))
            circuit_label.visible = true
        end
    else
        -- No circuit - show textfield, hide label
        if threshold_field then
            threshold_field.visible = true
        end
        if circuit_label then
            circuit_label.visible = false
        end
    end
end


--- Opens the GUI for a thermal diode
--- @param player LuaPlayer The player
--- @param entity LuaEntity The thermal diode interface entity
function gui.open(player, entity)
    local diode_data, composite_id = thermal_diode.get_by_interface(entity)
    if not diode_data or not composite_id then
        return
    end
    
    create_gui(player, composite_id, diode_data)
end


-- Event handlers
local event_manager = tenebris.event_manager


-- Handle entity open (player clicks on diode)
-- We intercept the native combinator GUI and replace it with our custom one
event_manager.subscribe(tenebris.EVENTS.ON_GUI_OPENED, "thermal_diode_gui_opened", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    if entity.name == "tenebris-steel-thermal-diode" or entity.name == "tenebris-ceramic-thermal-diode" then
        -- Close the native combinator GUI that Factorio opened
        player.opened = nil
        
        -- Open our custom GUI
        gui.open(player, entity)
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle GUI closed
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "thermal_diode_gui_closed", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    
    local element = event.element
    if element and element.valid and element.name == GUI_FRAME then
        gui.close(player)
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle button clicks
event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLICK, "thermal_diode_gui_click", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    if element.name == GUI_CLOSE_BUTTON then
        local player = game.get_player(event.player_index)
        if player then
            gui.close(player)
        end
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle text field changes (auto-save threshold)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_TEXT_CHANGED, "thermal_diode_gui_text_changed", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end
    
    local composite_id = get_player_diode_storage()[player.index]
    if not composite_id then return end
    
    if element.name == GUI_THRESHOLD_FIELD then
        -- Ignore changes if circuit is controlling threshold
        local circuit_threshold = thermal_diode.get_circuit_threshold(composite_id)
        if circuit_threshold then
            return  -- Circuit is in control, ignore manual input
        end
        local threshold = tonumber(element.text)
        if threshold then
            thermal_diode.set_threshold(composite_id, threshold)
        end
    elseif element.name == GUI_OUTPUT_CONSTANT then
        local constant = tonumber(element.text)
        if constant then
            thermal_diode.set_output_constant(composite_id, constant)
        end
    end
end, tenebris.PRIORITY.NORMAL)


-- Handle signal chooser changes (auto-save)
event_manager.subscribe(tenebris.EVENTS.ON_GUI_ELEM_CHANGED, "thermal_diode_gui_elem_changed", function(event)
    local element = event.element
    if not element or not element.valid then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end
    
    local composite_id = get_player_diode_storage()[player.index]
    if not composite_id then return end
    
    if element.name == GUI_TEMPERATURE_SIGNAL then
        thermal_diode.set_temperature_signal(composite_id, element.elem_value)
    elseif element.name == GUI_THRESHOLD_SIGNAL then
        thermal_diode.set_threshold_signal(composite_id, element.elem_value)
    elseif element.name == GUI_OUTPUT_SIGNAL then
        thermal_diode.set_output_signal(composite_id, element.elem_value)
    end
end, tenebris.PRIORITY.NORMAL)


-- Periodic update for open GUIs (every 0.5 seconds)
event_manager.subscribe_nth_tick(30, "thermal_diode_gui_update", function(event)
    local player_storage = get_player_diode_storage()
    
    for player_index, composite_id in pairs(player_storage) do
        local player = game.get_player(player_index)
        if player and player.valid then
            update_gui(player, composite_id)
        else
            -- Clean up invalid player entries
            player_storage[player_index] = nil
        end
    end
end, tenebris.PRIORITY.UI)


return gui

