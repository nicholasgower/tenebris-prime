--- Crystal Resonance Chamber Entity
--- A specialized building for piezoelectric processing and crystal manipulation

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tenebris = require("__tenebris-prime__.lib.tenebris")

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
        corpse = "tenebris-crystal-resonance-chamber-remnants",
        dying_explosion = "big-explosion",
        alert_icon_shift = util.by_pixel(0, -12),
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-3.375, -3.375}, {3.375, 3.375}},
        selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
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
            emissions_per_minute = {
                tenecap_spore_clearance = 100,
            },
            connections = {
                -- Northwest corner
                {
                    position = {-2.85, -2.85},
                    direction = defines.direction.north
                },
                {
                    position = {-2.85, -2.85},
                    direction = defines.direction.west
                },
                -- Northeast corner
                {
                    position = {2.85, -2.85},
                    direction = defines.direction.north
                },
                {
                    position = {2.85, -2.85},
                    direction = defines.direction.east
                },
                -- Southwest corner
                {
                    position = {-2.85, 2.85},
                    direction = defines.direction.south
                },
                {
                    position = {-2.85, 2.85},
                    direction = defines.direction.west
                },
                -- Southeast corner
                {
                    position = {2.85, 2.85},
                    direction = defines.direction.south
                },
                {
                    position = {2.85, 2.85},
                    direction = defines.direction.east
                },
            },
            pipe_covers =
                make_4way_animation_from_spritesheet(
                {
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
                    width = 64,
                    height = 64,
                    direction_count = 4,
                    scale = 0.5
                }),
            heat_pipe_covers =
                make_4way_animation_from_spritesheet(
                apply_heat_pipe_glow{
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
                    width = 64,
                    height = 64,
                    direction_count = 4,
                    scale = 0.5
                }),
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
                    layers = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-north.png",
                            priority = "high",
                            width = 460,
                            height = 520,
                            frame_count = 1,
                            shift = {0, -0.2},
                            scale = 0.5,
                            tint = tenebris.TINT.HEAT_LIGHT
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-sh.png",
                            priority = "high",
                            width = 498,
                            height = 438,
                            shift = {0.33, 0.32},
                            frame_count = 1,
                            scale = 0.5,
                            draw_as_shadow = true
                        }
                    }
                },
                east = {
                    layers = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-east.png",
                            priority = "high",
                            width = 460,
                            height = 520,
                            frame_count = 1,
                            shift = {0, -0.2},
                            scale = 0.5,
                            tint = tenebris.TINT.HEAT_LIGHT
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-sh.png",
                            priority = "high",
                            width = 498,
                            height = 438,
                            shift = {0.33, 0.32},
                            frame_count = 1,
                            scale = 0.5,
                            draw_as_shadow = true
                        }
                    }
                },
                south = {
                    layers = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-south.png",
                            priority = "high",
                            width = 460,
                            height = 520,
                            frame_count = 1,
                            shift = {0, -0.2},
                            scale = 0.5,
                            tint = tenebris.TINT.HEAT_LIGHT
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-sh.png",
                            priority = "high",
                            width = 498,
                            height = 438,
                            shift = {0.33, 0.32},
                            frame_count = 1,
                            scale = 0.5,
                            draw_as_shadow = true
                        }
                    }
                },
                west = {
                    layers = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-west.png",
                            priority = "high",
                            width = 460,
                            height = 520,
                            frame_count = 1,
                            shift = {0, -0.2},
                            scale = 0.5,
                            tint = tenebris.TINT.HEAT_LIGHT
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-sh.png",
                            priority = "high",
                            width = 498,
                            height = 438,
                            shift = {0.33, 0.32},
                            frame_count = 1,
                            scale = 0.5,
                            draw_as_shadow = true
                        }
                    }
                }
            },
            working_visualisations = {
                {
                    animation = {
                        filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-working.png",
                        priority = "high",
                        width = 340,
                        height = 370,
                        shift = {0.3, -0.59},
                        frame_count = 30,
                        line_length = 6,
                        animation_speed = 0.6,
                        scale = 0.5
                    }
                },
                {
                    apply_recipe_tint = "primary",
                    animation = {
                        filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-dirty-mask.png",
                        width = 156,
                        height = 120,
                        scale = 0.5,
                        frame_count = 30,
                        line_length = 6,
                        animation_speed = 0.6,
                        shift = {1.61, -1.02}
                    }
                },
                {
                    apply_recipe_tint = "secondary",
                    animation = {
                        filename = "__tenebris-prime__/graphics/entity/crystal-resonance-chamber/crystal-resonance-chamber-clear-mask.png",
                        width = 156,
                        height = 120,
                        scale = 0.5,
                        frame_count = 30,
                        line_length = 6,
                        animation_speed = 0.6,
                        shift = {1.61, 1.31}
                    }
                }
            }
        },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                pipe_connections = {{flow_direction="input", direction = defines.direction.north, position = {0, -3.08}}},
                secondary_draw_orders = {north = -1}
            },
            {
                production_type = "input",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                pipe_connections = {{flow_direction="input", direction = defines.direction.south, position = {0, 3.08}}},
                secondary_draw_orders = {south = -1}
            },
            {
                production_type = "input",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                pipe_connections = {{flow_direction="input", direction = defines.direction.west, position = {-3.08, 0}}},
                secondary_draw_orders = {west = -1}
            },
            {
                production_type = "input",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                pipe_connections = {{flow_direction="input", direction = defines.direction.east, position = {3.08, 0}}},
                secondary_draw_orders = {east = -1}
            }
        },
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        impact_category = "metal",
        working_sound = {
            sound = {
                filename = "__tenebris-prime__/sounds/buildings/crystal-resonance-chamber.ogg",
                volume = 0.5
            },
            idle_sound = { filename = "__base__/sound/idle1.ogg" },
        }
    }
})

