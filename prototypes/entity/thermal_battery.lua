-- Thermal Battery - A 3x3 heat storage block with high thermal mass
-- Quality affects specific heat: higher quality = more energy storage
-- Uses reactor type for proper heat_buffer rendering

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local tenebris = require("lib.tenebris")

-- Quality multipliers for specific heat
local quality_multipliers = {
    normal = 1.0,
    uncommon = 1.3,
    rare = 1.6,
    epic = 2.0,
    legendary = 2.5
}

-- Base specific heat in MJ (100MJ = 100x regular heat pipe)
local base_specific_heat = 100

-- Create reactor variants for each quality level
local thermal_battery_variants = {}

for quality_name, multiplier in pairs(quality_multipliers) do
    local suffix = (quality_name == "normal") and "" or ("-" .. quality_name)
    local specific_heat = math.floor(base_specific_heat * multiplier)
    local is_normal = quality_name == "normal"
    
    local reactor = {
        type = "reactor",
        name = "tenebris-thermal-battery" .. suffix,
        icons = {
            {
                icon = "__tenebris-prime__/graphics/icons/thermal-battery.png",
                icon_size = 64,
                tint = tenebris.TINT.HEAT_LIGHT,
            }
        },
        flags = {"placeable-neutral", "player-creation", "not-rotatable"},
        hidden = not is_normal,  -- Hide non-normal variants
        hidden_in_factoriopedia = not is_normal,  -- Hide from factoriopedia
        custom_tooltip_fields = {
            {
                name = {"description.thermal-battery-specific-heat"},
                value = {"", tostring(specific_heat), " MJ/°C"},
                quality_values = is_normal and {
                    ["uncommon"] = {"", "130", " MJ/°C"},
                    ["rare"] = {"", "160", " MJ/°C"},
                    ["epic"] = {"", "200", " MJ/°C"},
                    ["legendary"] = {"", "250", " MJ/°C"},
                } or nil,
            }
        },
        minable = { mining_time = 0.5, result = "tenebris-thermal-battery" },
        max_health = 600,
        corpse = "heat-pipe-remnants",
        dying_explosion = "heat-pipe-explosion",
        collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        damaged_trigger_effect = hit_effects.entity(),
        impact_category = "metal",
        resistances = {
            { type = "fire", percent = 90 },
            { type = "explosion", percent = 30 },
            { type = "impact", percent = 30 }
        },
        
        -- Minimal consumption - reactor requires > 0
        consumption = "1W",
        neighbour_bonus = 0,
        
        -- Void energy source - doesn't need fuel
        energy_source = {
            type = "void",
        },
        
        -- Thermal battery picture
        picture = {
            filename = "__tenebris-prime__/graphics/entity/thermal-battery/thermal-battery.png",
            width = 141,
            height = 120,
            scale = 0.75,
            shift = {0.2, 0},
            tint = tenebris.TINT.HEAT_LIGHT
        },
        
        heat_buffer = {
            max_temperature = 1000,
            specific_heat = specific_heat .. "MJ",
            max_transfer = "1GW",
            minimum_glow_temperature = 350,
            -- Order must match heating tower: north, east, south, west
            connections = {
                { position = {0, -1}, direction = defines.direction.north },
                { position = {1, 0}, direction = defines.direction.east },
                { position = {0, 1}, direction = defines.direction.south },
                { position = {-1, 0}, direction = defines.direction.west },
            },
        },
        
        -- Connection patches from heating tower (designed for 4 connections, 1 per edge)
        connection_patches_connected = {
            sheet = {
                filename = "__space-age__/graphics/entity/heating-tower/heating-tower-pipes.png",
                width = 64,
                height = 64,
                variation_count = 4,
                scale = 0.5
            }
        },
        connection_patches_disconnected = {
            sheet = {
                filename = "__space-age__/graphics/entity/heating-tower/heating-tower-pipes-disconnected.png",
                width = 88,
                height = 90,
                variation_count = 4,
                shift = util.by_pixel(2, 2),
                scale = 0.5
            }
        },
        heat_connection_patches_connected = {
            sheet = apply_heat_pipe_glow{
                filename = "__space-age__/graphics/entity/heating-tower/heating-tower-pipes-heat.png",
                width = 64,
                height = 64,
                variation_count = 4,
                scale = 0.5
            }
        },
        heat_connection_patches_disconnected = {
            sheet = apply_heat_pipe_glow{
                filename = "__space-age__/graphics/entity/heating-tower/heating-tower-pipes-heat-disconnected.png",
                width = 80,
                height = 72,
                variation_count = 4,
                shift = util.by_pixel(-1.5, 2),
                scale = 0.5
            }
        },
        
        -- Circuit wire support
        default_temperature_signal = {type = "virtual", name = "signal-T"},
        circuit_wire_max_distance = 9,
        circuit_connector = circuit_connector_definitions.create_single(
            universal_connector_template,
            {
                variation = 26,
                main_offset = util.by_pixel(-17, 38),
                shadow_offset = util.by_pixel(-17, 38),
                show_shadow = false
            }
        ),
        
        -- Sounds
        open_sound = {filename = "__base__/sound/open-close/nuclear-open.ogg", volume = 0.8},
        close_sound = {filename = "__base__/sound/open-close/nuclear-close.ogg", volume = 0.8},
    }
    
    table.insert(thermal_battery_variants, reactor)
end

data:extend(thermal_battery_variants)
