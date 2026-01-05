--- Crystal Resonance Chamber Entity
--- A specialized building for piezoelectric processing and crystal manipulation

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "assembling-machine",
        name = "tenebris-crystal-resonance-chamber",
        icon = "__tenebris-prime__/graphics/icons/crystal-resonance-chamber.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "tenebris-crystal-resonance-chamber"},
        fast_replaceable_group = "assembling-machine",
        max_health = 500,
        corpse = "assembling-machine-3-remnants",
        dying_explosion = "assembling-machine-3-explosion",
        alert_icon_shift = util.by_pixel(0, -12),
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
        selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
        damaged_trigger_effect = hit_effects.entity(),
        drawing_box_vertical_extension = 0.3,
        module_slots = 4,
        icon_draw_specification = {scale = 2, shift = {0, -0.3}},
        icons_positioning = {
            {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 0.8}}
        },
        allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
        effect_receiver = {
            base_effect = { productivity = 0.25 }
        },
        crafting_categories = {"crystal-resonance"},
        crafting_speed = 2.0,
        energy_source = {
            type = "heat",
            max_temperature = 1000,
            specific_heat = "1MJ",
            max_transfer = "2GW",
            min_working_temperature = 500,
            minimum_glow_temperature = 350,
            connections = {
                -- Northwest corner
                {
                    position = {-1.5, -1.5},
                    direction = defines.direction.north
                },
                -- Northeast corner
                {
                    position = {1.5, -1.5},
                    direction = defines.direction.north
                },
                -- Southwest corner
                {
                    position = {-1.5, 1.5},
                    direction = defines.direction.south
                },
                -- Southeast corner
                {
                    position = {1.5, 1.5},
                    direction = defines.direction.south
                }
            },
            heat_buffer_capacity = "10MJ",
            burns_fluid = false,
            scale_fluid_usage = false,
            fluid_usage_per_tick = 0,
            smoke = {
                {
                    name = "smoke",
                    frequency = 10,
                    position = {0.0, -2.0},
                    starting_vertical_speed = 0.08,
                    starting_frame_deviation = 60
                }
            }
        },
        energy_usage = "500kW",
        graphics_set = {
            animation = {
                north = {
                    filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-north.png",
                    priority = "high",
                    width = 159,
                    height = 169,
                    frame_count = 1,
                    shift = util.by_pixel(0, -10),
                    scale = 0.85
                },
                east = {
                    filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-south.png",
                    priority = "high",
                    width = 159,
                    height = 178,
                    frame_count = 1,
                    shift = util.by_pixel(0, -10),
                    scale = 0.85
                },
                south = {
                    filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-west.png",
                    priority = "high",
                    width = 162,
                    height = 188,
                    frame_count = 1,
                    shift = util.by_pixel(0, -10),
                    scale = 0.85
                },
                west = {
                    filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-east.png",
                    priority = "high",
                    width = 167,
                    height = 169,
                    frame_count = 1,
                    shift = util.by_pixel(0, -10),
                    scale = 0.85
                }
            }
        },
        fluid_boxes_off_when_no_fluid_recipe = true,
        fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                pipe_connections = {{flow_direction="input", direction = defines.direction.north, position = {1.5, -1.5}}},
                secondary_draw_orders = {north = -1}
            }
        },
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        impact_category = "metal",
        working_sound = {
            sound = {
                filename = "__base__/sound/assembling-machine-t3-1.ogg",
                volume = 0.7
            },
            fade_in_ticks = 4,
            fade_out_ticks = 20
        }
    }
})

