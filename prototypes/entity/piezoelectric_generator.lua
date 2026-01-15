--- Piezoelectric Generator Composite Entity Prototypes
--- A composite entity that converts heat into electricity distributed over an isolated area.
--- Created when quartz forest ortets or buds are captured.
---
--- Composite structure:
--- 1. Heat Interface (main, visible) - Has heat pipe connections, converts heat → tenebris-heat fluid
--- 2. Hidden Generator - Consumes tenebris-heat fluid, produces electricity
--- 3. Hidden Electric Pole - Distributes power over isolated network

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local piezo_constants = require("__tenebris-prime__.lib.piezoelectric_constants")

-- Use shared tier definitions from lib
local TIERS = piezo_constants.TIERS

local heat_interfaces = {}
local hidden_generators = {}
local hidden_poles = {}

for _, tier in ipairs(TIERS) do
    -- =========================================================================
    -- HEAT INTERFACE (Main visible entity)
    -- Player sees this, connects heat pipes to it
    -- Converts heat energy → tenebris-heat fluid (internally)
    -- =========================================================================
    local heat_interface = {
        type = "assembling-machine",
        name = "tenebris-piezoelectric-interface" .. tier.suffix,
        icon = "__base__/graphics/icons/heat-boiler.png",
        icon_size = 64,
        subgroup = "tenebris-machines",
        order = "z[piezoelectric]-" .. tier.suffix,
        custom_tooltip_fields = {
            {
                name = {"tooltip.power-output"},
                value = tier.power_output,
                order = 1,
                show_in_tooltip = true,
                show_in_factoriopedia = true
            },
            {
                name = {"tooltip.supply-radius"},
                value = tostring(tier.supply_radius) .. " tiles",
                order = 2,
                show_in_tooltip = true,
                show_in_factoriopedia = true
            },
            {
                name = {"tooltip.heat-consumption"},
                value = tier.heat_consumption,
                order = 3,
                show_in_tooltip = true,
                show_in_factoriopedia = true
            },
            {
                name = {"tooltip.min-operating-temp"},
                value = tostring(tier.min_working_temp) .. "°C",
                order = 4,
                show_in_tooltip = true,
                show_in_factoriopedia = true
            },
        },
        flags = {"placeable-neutral", "player-creation"},
        minable = nil, -- Cannot be mined once placed (captured entity)
        max_health = 500,
        corpse = "heat-exchanger-remnants",
        dying_explosion = "heat-exchanger-explosion",
        
        -- 5x5 collision box
        collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
        selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
        damaged_trigger_effect = hit_effects.entity(),
        
        -- Crafting settings
        crafting_speed = 1,
        crafting_categories = {"tenebris-heating"},
        fixed_recipe = "tenebris-piezoelectric-heating",
        fixed_quality = "normal",
        show_recipe_icon = false,
        module_slots = 0,
        
        resistances = {
            { type = "fire", percent = 90 },
            { type = "explosion", percent = 50 },
            { type = "physical", decrease = 10 }
        },
        
        -- Internal fluid output (hidden from player, connects to hidden generator)
        -- Position {0, 0} is the center of the entity
        fluid_boxes = {
            {
                volume = 500,
                pipe_covers = pipecoverspictures(),
                pipe_picture = nil, -- No visible pipes
                pipe_connections = {
                    -- Internal output at center - will connect to hidden generator
                    { flow_direction = "output", position = {0, 0}, direction = defines.direction.north },
                },
                production_type = "output",
                filter = piezo_constants.FLUID.name,
                hide_connection_info = true,
            },
        },
        
        -- Heat energy source with visible heat pipe connections
        energy_source = {
            type = "heat",
            max_temperature = 2000,
            specific_heat = "10MJ",
            max_transfer = "2GW",
            min_working_temperature = tier.min_working_temp,
            minimum_glow_temperature = tier.min_working_temp + 50,
            emissions_per_minute = {
                tenecap_spore_clearance = 150,
            },
            -- Heat pipe connections on all 4 sides (visible to player)
            connections = {
                { position = {0, -2}, direction = defines.direction.north },
                { position = {0, 2}, direction = defines.direction.south },
                { position = {2, 0}, direction = defines.direction.east },
                { position = {-2, 0}, direction = defines.direction.west },
            },
            pipe_covers = make_4way_animation_from_spritesheet({
                filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
                width = 64,
                height = 64,
                direction_count = 4,
                scale = 0.5
            }),
            heat_pipe_covers = make_4way_animation_from_spritesheet(
                apply_heat_pipe_glow({
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
                    width = 64,
                    height = 64,
                    direction_count = 4,
                    scale = 0.5
                })
            ),
        },
        energy_usage = tier.energy_usage,
        
        -- Graphics - use heat exchanger as placeholder, scaled up
        graphics_set = {
            animation = {
                north = {
                    layers = {
                        {
                            filename = "__base__/graphics/entity/heat-exchanger/heatex-N-idle.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(0, 0),
                            scale = 1.6
                        }
                    }
                },
                east = {
                    layers = {
                        {
                            filename = "__base__/graphics/entity/heat-exchanger/heatex-E-idle.png",
                            priority = "extra-high",
                            width = 211,
                            height = 301,
                            shift = util.by_pixel(0, 0),
                            scale = 1.6
                        }
                    }
                },
                south = {
                    layers = {
                        {
                            filename = "__base__/graphics/entity/heat-exchanger/heatex-S-idle.png",
                            priority = "extra-high",
                            width = 260,
                            height = 201,
                            shift = util.by_pixel(0, 0),
                            scale = 1.6
                        }
                    }
                },
                west = {
                    layers = {
                        {
                            filename = "__base__/graphics/entity/heat-exchanger/heatex-W-idle.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(0, 0),
                            scale = 1.6
                        }
                    }
                },
            },
        },
        
        impact_category = "metal-large",
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        working_sound = {
            sound = {
                filename = "__base__/sound/heat-exchanger.ogg",
                volume = 0.65,
                audible_distance_modifier = 0.5,
            },
            fade_in_ticks = 4,
            fade_out_ticks = 20
        }
    }
    table.insert(heat_interfaces, heat_interface)
    
    -- =========================================================================
    -- HIDDEN GENERATOR
    -- Consumes tenebris-heat fluid from the interface, produces electricity
    -- Overlaid at the same position as the interface
    -- =========================================================================
    local hidden_generator = {
        type = "generator",
        name = "tenebris-piezoelectric-generator-hidden" .. tier.suffix,
        icon = "__base__/graphics/icons/steam-turbine.png",
        icon_size = 64,
        flags = {"placeable-off-grid", "not-on-map", "not-selectable-in-game", "not-blueprintable", "not-deconstructable"},
        hidden = true,
        hidden_in_factoriopedia = true,
        
        selectable_in_game = false,
        minable = nil,
        max_health = 1,
        collision_mask = {layers = {}},
        collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
        selection_box = {{0, 0}, {0, 0}},
        
        effectivity = 1,
        fluid_usage_per_tick = tier.fluid_per_tick,
        maximum_temperature = 1000,
        burns_fluid = false,
        
        -- Fluid input at center (connects to interface's output)
        fluid_box = {
            volume = 500,
            pipe_connections = {
                { flow_direction = "input", position = {0, 0}, direction = defines.direction.south },
            },
            production_type = "input",
            filter = piezo_constants.FLUID.name,
            minimum_temperature = piezo_constants.FLUID.min_temperature,
            hide_connection_info = true,
        },
        
        -- Electric output
        energy_source = {
            type = "electric",
            usage_priority = "secondary-output",
        },
        
        -- Invisible graphics
        horizontal_animation = {
            filename = "__core__/graphics/empty.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
        vertical_animation = {
            filename = "__core__/graphics/empty.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
    }
    table.insert(hidden_generators, hidden_generator)
    
    -- =========================================================================
    -- HIDDEN ELECTRIC POLE
    -- Distributes power from the generator over an isolated area
    -- No wire connections - completely isolated network
    -- =========================================================================
    local hidden_pole = {
        type = "electric-pole",
        name = "tenebris-piezoelectric-pole-hidden" .. tier.suffix,
        icon = "__base__/graphics/icons/small-electric-pole.png",
        icon_size = 64,
        flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable"},
        hidden = true,
        hidden_in_factoriopedia = true,
        
        -- Selectable to show power coverage and network info
        selectable_in_game = true,
        minable = nil,
        collision_mask = {layers = {}},
        
        max_health = 1,
        collision_box = {{0, 0}, {0, 0}},
        -- Selection box slightly offset to not overlap with main interface
        selection_box = {{-3, -3}, {-2.5, -2.5}},
        
        -- Large supply area based on tier (max 64 tiles)
        supply_area_distance = tier.supply_radius,
        
        -- No wire connections - isolated network
        maximum_wire_distance = 0,
        auto_connect_up_to_n_wires = 0,
        draw_copper_wires = false,
        draw_circuit_wires = false,
        
        -- Invisible graphics
        pictures = {
            filename = "__core__/graphics/empty.png",
            width = 1,
            height = 1,
            direction_count = 1
        },
        
        connection_points = {
            {
                shadow = { copper = {0, 0}, green = {0, 0}, red = {0, 0} },
                wire = { copper = {0, 0}, green = {0, 0}, red = {0, 0} }
            }
        },
        
        radius_visualisation_picture = {
            filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
            width = 12,
            height = 12,
            priority = "extra-high-no-scale"
        }
    }
    table.insert(hidden_poles, hidden_pole)
end

data:extend(heat_interfaces)
data:extend(hidden_generators)
data:extend(hidden_poles)
