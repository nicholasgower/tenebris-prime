local hit_effects = require("__base__.prototypes.entity.hit-effects")
local tenebris = require("lib.tenebris")
local roboport_constants = require("lib.quartz_roboport_constants")

-- Quartz Roboport Interface
-- A 3x3 heated roboport that extends logistics/construction range
-- No robot or material storage, just 2 charging ports
-- Uses electric mining drill frame graphics with roboport charging elements

local heat_tint = tenebris.TINT.HEAT_LIGHT

-- Base entities for reference values
local base_roboport = data.raw["roboport"]["roboport"]

-- Helper to apply tint to a layer (skip shadows)
local function tint_layer(layer)
    if layer and not layer.draw_as_shadow then
        layer.tint = heat_tint
    end
    return layer
end

-- Helper to deep copy and tint graphics
local function tinted_copy(source)
    if not source then return nil end
    local copy = table.deepcopy(source)
    if copy.layers then
        for _, layer in pairs(copy.layers) do
            tint_layer(layer)
        end
    elseif copy.filename then
        tint_layer(copy)
    end
    return copy
end

-- Create the entity
local quartz_roboport = {
    type = "roboport",
    name = "tenebris-quartz-ortet-robo-interface",
    icon = "__base__/graphics/icons/roboport.png",  -- TODO: Custom icon
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "tenebris-quartz-ortet-robo-interface"},
    max_health = 400,
    corpse = "roboport-remnants",
    dying_explosion = "roboport-explosion",
    
    -- 3x3 size
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    
    resistances = {
        {type = "fire", percent = 70},
        {type = "impact", percent = 30}
    },
    
    -- Only placeable on Tenebris (requires innate energy luminosity)
    surface_conditions = {
        {
            property = "innate-energy-luminosity",
            min = 1
        }
    },
    
    -- No storage capacity
    robot_slots_count = 0,
    material_slots_count = 0,
    
    -- Extended range (base roboport is 25 logistics, 55 construction)
    logistics_radius = roboport_constants.LOGISTICS_RADIUS,
    construction_radius = roboport_constants.CONSTRUCTION_RADIUS,
    
    -- Charging ports
    charging_station_count = roboport_constants.CHARGING_STATION_COUNT,
    charging_energy = roboport_constants.CHARGING_ENERGY,
    charging_distance = roboport_constants.CHARGING_DISTANCE,
    charging_station_shift = roboport_constants.CHARGING_STATION_SHIFT,
    charging_threshold_distance = roboport_constants.CHARGING_THRESHOLD_DISTANCE,
    charge_approach_distance = 2.6,
    
    -- Robot limits
    robot_limit = 0,  -- No internal robots
    robots_shrink_when_entering_and_exiting_log_radius = true,
    
    -- Void energy source (roboports don't support heat buffers)
    energy_source = {
        type = "void"
    },
    
    -- Energy buffer for charging robots
    energy_usage = roboport_constants.ENERGY_USAGE,
    recharge_minimum = roboport_constants.RECHARGE_MINIMUM,
    
    -- Circuit connection (from base roboport)
    circuit_connector = table.deepcopy(base_roboport.circuit_connector),
    circuit_wire_max_distance = base_roboport.circuit_wire_max_distance,
    default_available_logistic_output_signal = base_roboport.default_available_logistic_output_signal,
    default_total_logistic_output_signal = base_roboport.default_total_logistic_output_signal,
    default_available_construction_output_signal = base_roboport.default_available_construction_output_signal,
    default_total_construction_output_signal = base_roboport.default_total_construction_output_signal,
    
    -- Request slots for calling robots
    request_to_open_door_timeout = 0,
    spawn_and_station_height = 0.3,
    
    -- Open door when robots are charging (from base)
    open_door_trigger_effect = base_roboport.open_door_trigger_effect,
    close_door_trigger_effect = base_roboport.close_door_trigger_effect,
    
    -- Graphics: Mining drill frame on bottom, roboport on top
    -- Scale factor for 3x3 size (base roboport is 4x4)
    base = {
        layers = {
            -- Layer 1: Mining drill frame (bottom foundation)
            {
                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N.png",
                width = 190,
                height = 208,
                shift = util.by_pixel(0, 0),
                scale = 0.4,
                tint = heat_tint,
            },
            -- Layer 2: Mining drill shadow
            {
                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-shadow.png",
                width = 212,
                height = 204,
                shift = util.by_pixel(16, 4),
                scale = 0.4,
                draw_as_shadow = true,
            },
            -- Layer 3: Roboport base (on top of drill frame)
            {
                filename = "__base__/graphics/entity/roboport/roboport-base.png",
                width = 228,
                height = 277,
                shift = util.by_pixel(2, -2.25),
                scale = 0.3,
                tint = heat_tint,
            },
            {
                filename = "__base__/graphics/entity/roboport/roboport-shadow.png",
                width = 294,
                height = 201,
                draw_as_shadow = true,
                shift = util.by_pixel(28.5, 9.25),
                scale = 0.3
            }
        }
    },
    
    base_animation =
    {
      filename = "__base__/graphics/entity/roboport/roboport-base-animation.png",
      priority = "medium",
      width = 83,
      height = 59,
      frame_count = 8,
      animation_speed = 2,
      shift = util.by_pixel(0, -20),
      scale = 0.6,
      tint = heat_tint,
    },

    -- Working sound
    working_sound = {
        sound = {filename = "__base__/sound/roboport-working.ogg", volume = 0.4},
        max_sounds_per_type = 3,
        audible_distance_modifier = 0.5,
    },
    
    -- Logistics connection
    logistics_connection_distance = roboport_constants.LOGISTICS_CONNECTION_DISTANCE,
    
    -- Radar for logistics visibility
    radar_range = roboport_constants.RADAR_RANGE,
}

data:extend({quartz_roboport})

