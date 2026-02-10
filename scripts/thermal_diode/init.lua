--- Thermal Diode Controller
--- Manages heat flow through thermal diodes based on temperature thresholds.
--- Swaps endpoints between closed (single connection) and open (both connections).

local tenebris = require("lib.tenebris")
local lifecycle = require("lib.composite_entity.lifecycle")

local thermal_diode = {}

-- Storage key for tracking diodes
local STORAGE_KEY = "thermal_diode_tracker"

-- Default threshold
local DEFAULT_THRESHOLD = 500

-- Check interval in ticks (60 = 1 second)
local CHECK_INTERVAL = 60

-- Helper to generate endpoint prototype names for a variant
local function make_endpoint_protos(variant)
    local prefix = "tenebris-" .. variant .. "-thermal-diode-endpoint-"
    return {
        [defines.direction.north] = {
            input_closed = prefix .. "closed-n",
            input_open = prefix .. "open-ns",
            output_closed = prefix .. "closed-s",
            output_open = prefix .. "open-ns",
        },
        [defines.direction.south] = {
            input_closed = prefix .. "closed-s",
            input_open = prefix .. "open-ns",
            output_closed = prefix .. "closed-n",
            output_open = prefix .. "open-ns",
        },
        [defines.direction.east] = {
            input_closed = prefix .. "closed-e",
            input_open = prefix .. "open-ew",
            output_closed = prefix .. "closed-w",
            output_open = prefix .. "open-ew",
        },
        [defines.direction.west] = {
            input_closed = prefix .. "closed-w",
            input_open = prefix .. "open-ew",
            output_closed = prefix .. "closed-e",
            output_open = prefix .. "open-ew",
        },
    }
end

-- Endpoint prototype names by variant and direction
local ENDPOINT_PROTOTYPES = {
    steel = make_endpoint_protos("steel"),
    ceramic = make_endpoint_protos("ceramic"),
}

--- Gets the prototype names for a given variant and direction
local function get_prototypes(direction, variant)
    variant = variant or "steel"
    local variant_protos = ENDPOINT_PROTOTYPES[variant] or ENDPOINT_PROTOTYPES.steel
    return variant_protos[direction] or variant_protos[defines.direction.north]
end

--- Ensures storage is initialized
local function ensure_storage()
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}  -- Keyed by force_name
    end
end


--- Swaps an endpoint, preserving temperature
--- @param composite_id string The composite ID
--- @param entity_key string The entity key ("input" or "output")
--- @param new_prototype string The new prototype name
--- @return LuaEntity|nil new_entity
local function swap_heat_endpoint(composite_id, entity_key, new_prototype)
    local new_entity, old_entity = lifecycle.swap_entity(composite_id, entity_key, new_prototype)
    
    if new_entity and old_entity and old_entity.valid then
        new_entity.temperature = old_entity.temperature or 15
        old_entity.destroy()
    elseif old_entity and old_entity.valid then
        old_entity.destroy()
    end
    
    return new_entity
end


--- Updates the combinator display to show open/closed state
--- This also handles output signal if configured
--- @param diode_data table The diode tracking data
local function update_combinator_state(diode_data)
    if not diode_data.interface or not diode_data.interface.valid then
        return
    end
    
    local control = diode_data.interface.get_or_create_control_behavior()
    if not control then
        return
    end
    
    -- In Factorio 2.0, decider combinators use conditions and outputs arrays
    -- Comparator shows = when open, ≠ when closed (visual indicator only)
    local temp_sig = diode_data.temperature_signal or {type = "virtual", name = "signal-H"}
    local threshold_sig = diode_data.threshold_signal or {type = "virtual", name = "signal-T"}
    local output_sig = diode_data.output_signal or {type = "virtual", name = "signal-fire"}
    local threshold_value = diode_data.threshold or 500
    local output_value = diode_data.output_constant or 1
    local params = {
        conditions = {
            {
                first_signal = temp_sig,
                comparator = diode_data.is_open and "=" or "≠",
                constant = threshold_value,
            }
        },
        outputs = {
            {
                signal = output_sig,
                copy_count_from_input = false,
                constant = output_value,
            }
        }
    }
    
    control.parameters = params
end


--- Opens the diode (swaps to double-sided endpoints)
--- @param diode_data table The diode tracking data
--- @param composite_id string The composite ID for storage updates
local function open_diode(diode_data, composite_id)
    if diode_data.is_open then
        return  -- Already open
    end
    
    local protos = get_prototypes(diode_data.direction, diode_data.variant)
    diode_data.input = swap_heat_endpoint(composite_id, "input", protos.input_open)
    diode_data.output = swap_heat_endpoint(composite_id, "output", protos.output_open)
    diode_data.is_open = true
    
    update_combinator_state(diode_data)
end


--- Closes the diode (swaps to single-sided endpoints)
--- @param diode_data table The diode tracking data
--- @param composite_id string The composite ID for storage updates
local function close_diode(diode_data, composite_id)
    if not diode_data.is_open then
        return  -- Already closed
    end
    
    local protos = get_prototypes(diode_data.direction, diode_data.variant)
    diode_data.input = swap_heat_endpoint(composite_id, "input", protos.input_closed)
    diode_data.output = swap_heat_endpoint(composite_id, "output", protos.output_closed)
    diode_data.is_open = false
    
    update_combinator_state(diode_data)
end


--- Called when a thermal diode composite is created
--- @param composite_id string The composite ID
--- @param entities table The entities in the composite
--- @param direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @param variant string "steel" or "ceramic"
function thermal_diode.on_diode_created(composite_id, entities, direction, mirroring, variant)
    ensure_storage()
    
    variant = variant or "steel"
    local interface_name = "tenebris-" .. variant .. "-thermal-diode"
    local interface = entities[interface_name]
    local input = entities["input"]
    local output = entities["output"]
    local force_name = interface and interface.force and interface.force.name
    
    if not interface or not input or not output then
        game.print("[Thermal Diode] Failed to create: missing entities")
        return
    end
    
    if not force_name then
        game.print("[Thermal Diode] Failed to create: no force")
        return
    end
    
    -- Ensure force table exists
    if not storage[STORAGE_KEY][force_name] then
        storage[STORAGE_KEY][force_name] = {}
    end

    -- Store diode data (keyed by force, then composite_id)
    local actual_direction = direction or defines.direction.north
    local diode_data = {
        interface = interface,
        input = input,
        output = output,
        variant = variant,  -- "steel" or "ceramic"
        is_open = false,  -- Starts closed
        surface = interface.surface,
        force = interface.force,
        threshold = DEFAULT_THRESHOLD,
        direction = actual_direction,
        -- Default circuit signals
        temperature_signal = {type = "virtual", name = "signal-H"},  -- Display signal for temperature input
        threshold_signal = {type = "virtual", name = "signal-T"},     -- Signal to read threshold from circuit
        output_signal = {type = "virtual", name = "signal-fire"},     -- Signal to output when open
        output_constant = 1,                                          -- Constant value to output when open
    }
    
    storage[STORAGE_KEY][force_name][composite_id] = diode_data
    
    -- Composite creates with north-direction prototypes; swap if placed in different direction
    if actual_direction ~= defines.direction.north then
        local protos = get_prototypes(actual_direction, variant)
        diode_data.input = swap_heat_endpoint(composite_id, "input", protos.input_closed)
        diode_data.output = swap_heat_endpoint(composite_id, "output", protos.output_closed)
    end
    
    -- Set initial combinator state (closed)
    update_combinator_state(diode_data)
end


--- Called when a thermal diode composite is rotated or flipped
--- @param composite_id string The composite ID
--- @param entities table The entities in the composite
--- @param direction defines.direction The new entity direction
--- @param mirroring defines.mirroring The new entity mirroring
--- @param variant string "steel" or "ceramic" (passed from composite, but we use stored variant)
function thermal_diode.on_diode_orientation_changed(composite_id, entities, direction, mirroring, variant)
    ensure_storage()
    
    -- Find diode_data first to get the variant
    local force_name = nil
    local per_force = nil
    local diode_data = nil
    
    -- Try to find the diode_data by iterating forces (since we don't know the interface name yet)
    for fn, per_force_data in pairs(storage[STORAGE_KEY] or {}) do
        if per_force_data[composite_id] then
            force_name = fn
            per_force = per_force_data
            diode_data = per_force_data[composite_id]
            break
        end
    end
    
    if not diode_data then
        return
    end
    
    -- Get the interface using the stored variant
    local interface_name = "tenebris-" .. diode_data.variant .. "-thermal-diode"
    local interface = entities and entities[interface_name]
    
    -- Update entity references (composite system teleports them)
    diode_data.input = entities["input"]
    diode_data.output = entities["output"]
    if interface then
        diode_data.interface = interface
    end
    
    -- Update direction and swap to correct prototypes
    local old_direction = diode_data.direction
    diode_data.direction = direction or defines.direction.north
    
    -- If direction changed, swap endpoints to correct prototypes
    if old_direction ~= diode_data.direction then
        local protos = get_prototypes(diode_data.direction, diode_data.variant)
        if diode_data.is_open then
            diode_data.input = swap_heat_endpoint(composite_id, "input", protos.input_open)
            diode_data.output = swap_heat_endpoint(composite_id, "output", protos.output_open)
        else
            diode_data.input = swap_heat_endpoint(composite_id, "input", protos.input_closed)
            diode_data.output = swap_heat_endpoint(composite_id, "output", protos.output_closed)
        end
    end
end


--- Called when a thermal diode composite is destroyed
--- @param composite_id string The composite ID
--- @param entities table The entities in the composite
function thermal_diode.on_diode_destroyed(composite_id, entities)
    ensure_storage()
    
    -- Find and remove from storage by composite_id
    for force_name, per_force in pairs(storage[STORAGE_KEY] or {}) do
        if per_force[composite_id] then
            per_force[composite_id] = nil
            break
        end
    end
end


--- Gets diode data by interface entity
--- @param interface LuaEntity The interface entity
--- @return table|nil diode_data, string|nil composite_id, string|nil force_name
function thermal_diode.get_by_interface(interface)
    ensure_storage()
    
    if not interface or not interface.valid then
        return nil, nil, nil
    end
    
    local force_name = interface.force and interface.force.name
    if not force_name then
        return nil, nil, nil
    end
    
    local per_force = storage[STORAGE_KEY][force_name]
    if not per_force then
        return nil, nil, nil
    end
    
    for composite_id, diode_data in pairs(per_force) do
        if diode_data.interface and diode_data.interface.valid 
           and diode_data.interface.unit_number == interface.unit_number then
            return diode_data, composite_id, force_name
        end
    end
    
    return nil, nil, nil
end


--- Sets the threshold for a diode
--- @param composite_id string The composite ID
--- @param threshold number The new threshold
function thermal_diode.set_threshold(composite_id, threshold)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            diode_data.threshold = math.max(100, math.min(1000, threshold))
            -- Update combinator state to reflect new threshold value
            update_combinator_state(diode_data)
            return
        end
    end
end


--- Gets the threshold for a diode
--- @param composite_id string The composite ID
--- @return number threshold
function thermal_diode.get_threshold(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data.threshold or DEFAULT_THRESHOLD
        end
    end
    return DEFAULT_THRESHOLD
end


--- Sets the temperature signal for a diode (display signal for temperature input)
--- @param composite_id string The composite ID
--- @param signal SignalID|nil The signal to display for temperature
function thermal_diode.set_temperature_signal(composite_id, signal)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            diode_data.temperature_signal = signal
            update_combinator_state(diode_data)
            return
        end
    end
end


--- Gets the temperature signal for a diode
--- @param composite_id string The composite ID
--- @return SignalID|nil signal
function thermal_diode.get_temperature_signal(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data.temperature_signal
        end
    end
    return nil
end


--- Sets the threshold signal for a diode (circuit network override)
--- @param composite_id string The composite ID
--- @param signal SignalID|nil The signal to use for threshold, or nil to disable
function thermal_diode.set_threshold_signal(composite_id, signal)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            diode_data.threshold_signal = signal
            -- Update combinator state to reflect new threshold signal
            update_combinator_state(diode_data)
            return
        end
    end
end


--- Gets the threshold signal for a diode
--- @param composite_id string The composite ID
--- @return SignalID|nil signal
function thermal_diode.get_threshold_signal(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data.threshold_signal
        end
    end
    return nil
end


--- Sets the output signal for a diode
--- @param composite_id string The composite ID
--- @param signal SignalID|nil The signal to output when open, or nil to disable
function thermal_diode.set_output_signal(composite_id, signal)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            diode_data.output_signal = signal
            -- Update combinator state to reflect new output config
            update_combinator_state(diode_data)
            return
        end
    end
end


--- Gets the output signal for a diode
--- @param composite_id string The composite ID
--- @return SignalID|nil signal
function thermal_diode.get_output_signal(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data.output_signal
        end
    end
    return nil
end


--- Sets the output constant for a diode
--- @param composite_id string The composite ID
--- @param constant number The constant value to output when open
function thermal_diode.set_output_constant(composite_id, constant)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            diode_data.output_constant = constant or 1
            update_combinator_state(diode_data)
            return
        end
    end
end


--- Gets the output constant for a diode
--- @param composite_id string The composite ID
--- @return number constant
function thermal_diode.get_output_constant(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data.output_constant or 1
        end
    end
    return 1
end


--- Gets diode data by composite ID
--- @param composite_id string The composite ID
--- @return table|nil diode_data
function thermal_diode.get_by_composite_id(composite_id)
    ensure_storage()
    
    for _, per_force in pairs(storage[STORAGE_KEY]) do
        local diode_data = per_force[composite_id]
        if diode_data then
            return diode_data
        end
    end
    return nil
end


--- Gets the threshold value from circuit network (if any)
--- @param diode_data table The diode tracking data
--- @return number|nil circuit_threshold The circuit value, or nil if not connected
local function get_circuit_threshold(diode_data)
    if not diode_data.threshold_signal or not diode_data.interface or not diode_data.interface.valid then
        return nil
    end
    
    local signal_value = 0
    
    -- Read from red wire input
    local red_network = diode_data.interface.get_circuit_network(defines.wire_connector_id.combinator_input_red)
    if red_network then
        signal_value = signal_value + (red_network.get_signal(diode_data.threshold_signal) or 0)
    end
    
    -- Read from green wire input
    local green_network = diode_data.interface.get_circuit_network(defines.wire_connector_id.combinator_input_green)
    if green_network then
        signal_value = signal_value + (green_network.get_signal(diode_data.threshold_signal) or 0)
    end
    
    if signal_value ~= 0 then
        return signal_value
    end
    
    return nil
end


--- Reads the threshold value, checking circuit signal override
--- @param diode_data table The diode tracking data
--- @return number threshold
local function get_effective_threshold(diode_data)
    local circuit_threshold = get_circuit_threshold(diode_data)
    if circuit_threshold then
        return circuit_threshold
    end
    return diode_data.threshold or DEFAULT_THRESHOLD
end


--- Gets the circuit threshold value for a diode (public)
--- @param composite_id string The composite ID
--- @return number|nil circuit_threshold The circuit value, or nil if not connected
function thermal_diode.get_circuit_threshold(composite_id)
    local diode_data = thermal_diode.get_by_composite_id(composite_id)
    if not diode_data then
        return nil
    end
    return get_circuit_threshold(diode_data)
end


--- Updates all thermal diodes - called every CHECK_INTERVAL ticks
local function update_diodes()
    ensure_storage()
    
    for force_name, per_force in pairs(storage[STORAGE_KEY]) do
        for composite_id, diode_data in pairs(per_force) do
            -- Validate entities still exist
            if not diode_data.interface or not diode_data.interface.valid then
                per_force[composite_id] = nil
            elseif diode_data.input and diode_data.input.valid then
                local threshold = get_effective_threshold(diode_data)
                local input_temp = diode_data.input.temperature or 0
                
                if input_temp >= threshold then
                    open_diode(diode_data, composite_id)
                else
                    close_diode(diode_data, composite_id)
                end
            end
        end
    end
end


-- Register nth_tick handler for periodic updates
local event_manager = tenebris.event_manager

event_manager.subscribe_nth_tick(CHECK_INTERVAL, "thermal_diode_update", function(event)
    update_diodes()
end, tenebris.PRIORITY.NORMAL)


-- Initialize storage on load
event_manager.subscribe(tenebris.EVENTS.ON_INIT, "thermal_diode_init", function()
    ensure_storage()
end, tenebris.PRIORITY.NORMAL)

event_manager.subscribe(tenebris.EVENTS.ON_LOAD, "thermal_diode_load", function()
    -- Storage already loaded by game
end, tenebris.PRIORITY.NORMAL)


-- Debug command: /c remote.call("thermal_diode", "debug")
remote.add_interface("thermal_diode", {
    debug = function()
        ensure_storage()
        for force_name, per_force in pairs(storage[STORAGE_KEY]) do
            for composite_id, diode_data in pairs(per_force) do
                local input_pos = diode_data.input and diode_data.input.valid and diode_data.input.position or "invalid"
                local output_pos = diode_data.output and diode_data.output.valid and diode_data.output.position or "invalid"
                local input_temp = diode_data.input and diode_data.input.valid and diode_data.input.temperature or 0
                local output_temp = diode_data.output and diode_data.output.valid and diode_data.output.temperature or 0
                
                game.print(string.format("[Diode %s] Force: %s", composite_id, force_name))
                game.print(string.format("  Input: %s, Temp: %.1f°C", serpent.line(input_pos), input_temp))
                game.print(string.format("  Output: %s, Temp: %.1f°C", serpent.line(output_pos), output_temp))
                game.print(string.format("  State: %s, Threshold: %d°C", diode_data.is_open and "OPEN" or "CLOSED", diode_data.threshold or 500))
            end
        end
    end
})


-- Helper to check if an entity is a thermal diode interface
local function is_thermal_diode(entity)
    if not entity or not entity.valid then return false end
    return entity.name == "tenebris-steel-thermal-diode" or entity.name == "tenebris-ceramic-thermal-diode"
end

-- Handle copy/paste of settings between diodes
event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_SETTINGS_PASTED, "thermal_diode_settings_pasted", function(event)
    local source = event.source
    local destination = event.destination
    
    -- Only handle thermal diode interfaces (allow cross-variant copy/paste)
    if not is_thermal_diode(source) or not is_thermal_diode(destination) then
        return
    end
    
    -- Get diode data for both
    local source_data, source_id = thermal_diode.get_by_interface(source)
    local dest_data, dest_id = thermal_diode.get_by_interface(destination)
    
    if not source_data or not dest_data then
        return
    end
    
    -- Copy settings (signals are simple tables: {type=, name=})
    dest_data.threshold = source_data.threshold
    dest_data.temperature_signal = source_data.temperature_signal and {
        type = source_data.temperature_signal.type,
        name = source_data.temperature_signal.name,
    }
    dest_data.threshold_signal = source_data.threshold_signal and {
        type = source_data.threshold_signal.type,
        name = source_data.threshold_signal.name,
    }
    dest_data.output_signal = source_data.output_signal and {
        type = source_data.output_signal.type,
        name = source_data.output_signal.name,
    }
    dest_data.output_constant = source_data.output_constant
    
    -- Update the destination combinator display
    update_combinator_state(dest_data)
end, tenebris.PRIORITY.NORMAL)


return thermal_diode
