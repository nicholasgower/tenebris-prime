--- Lightning Furnace Entity Prototypes
--- A composite entity that uses lightning strikes on Fulgora for ultra-fast smelting.

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

-- Main furnace entity (player interacts with this)
local lightning_furnace = {
    type = "furnace",
    name = "tenebris-lightning-furnace",
    icon = "__base__/graphics/icons/electric-furnace.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {
        mining_time = 0.5,
        result = "tenebris-lightning-furnace"
    },
    max_health = 350,
    corpse = "electric-furnace-remnants",
    dying_explosion = "electric-furnace-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    
    -- Prevent lightning from striking the furnace directly (only collector gets struck)
    immune_to_lightning = true,
    
    crafting_categories = {"lightning-smelting", "smelting"},  -- Added smelting for testing
    result_inventory_size = 1,
    crafting_speed = 80,  -- 50x faster than normal furnace
    source_inventory_size = 1,
    
    energy_usage = "10MW",  -- Very high power draw when active
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 1},
        drain = "1MW",  -- Minimum 1MW idle drain
        buffer_capacity = "500MJ",  -- Larger buffer for stability
        input_flow_limit = "0W",  -- Cannot accept power from external grids
        output_flow_limit = "0W",  -- Does NOT output to grid
    },
    
    -- Don't show power warnings since this is powered by lightning
    alert_when_damaged = true,
    create_ghost_on_death = true,
    
    -- Use electric furnace graphics as placeholder
    graphics_set = table.deepcopy(data.raw["furnace"]["electric-furnace"].graphics_set),
    
    -- Copy working sound from electric furnace
    working_sound = table.deepcopy(data.raw["furnace"]["electric-furnace"].working_sound),
    
    module_slots = 4,
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    
    -- Show lightning collection radius when hovering (copied from lightning collector)
    radius_visualisation_picture = table.deepcopy(data.raw["lightning-attractor"]["lightning-collector"].radius_visualisation_picture)
}

-- Hidden lightning collector component (receives lightning strikes)
-- Base definition
local lightning_collector_base = {
    type = "lightning-attractor",
    icon = "__space-age__/graphics/icons/lightning-collector.png",
    icon_size = 64,
    flags = {"placeable-off-grid", "not-on-map", "not-selectable-in-game"},
    hidden = true,
    hidden_in_factoriopedia = true,
    
    minable = nil,
    rotatable = false,
    selectable_in_game = false,
    collision_mask = {layers = {}},
    max_health = 200,
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{0, 0}, {0, 0}},
    
    range_elongation = 8,
    efficiency = 0.8,
    lightning_strike_offset = {0, -3},
    
    chargable_graphics = data.raw["lightning-attractor"]["lightning-collector"].chargable_graphics,
    discharge_cooldown = 20,
    energy_discharge_rate = 24000000,
    
    graphics_set = table.deepcopy(data.raw["lightning-attractor"]["lightning-collector"].graphics_set),
    
    radius_visualisation_picture = {
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1
    }
}

-- Create quality variants
local quality_variants = {
    {suffix = "", multiplier = 1.0},
    {suffix = "-uncommon", multiplier = 1.3},
    {suffix = "-rare", multiplier = 1.5},
    {suffix = "-epic", multiplier = 1.8},
    {suffix = "-legendary", multiplier = 2.5}
}

local collector_variants = {}
for _, quality in ipairs(quality_variants) do
    local variant = table.deepcopy(lightning_collector_base)
    variant.name = "tenebris-lightning-collector-hidden" .. quality.suffix
    variant.energy_source = {
        type = "electric",
        usage_priority = "primary-output",
        buffer_capacity = (200 * quality.multiplier) .. "MJ",
        input_flow_limit = "0W",
        output_flow_limit = "24MW",
        drain = "24MW"
    }
    table.insert(collector_variants, variant)
end

-- Hidden electric pole to connect collector and furnace
local hidden_pole = {
    type = "electric-pole",
    name = "tenebris-lightning-furnace-pole-hidden",
    icon = "__base__/graphics/icons/small-electric-pole.png",
    icon_size = 64,
    flags = {"placeable-off-grid", "not-on-map", "not-selectable-in-game"},
    hidden = true,
    hidden_in_factoriopedia = true,
    
    selectable_in_game = false,
    minable = nil,
    collision_mask = {layers = {}},
    
    max_health = 1,
    collision_box = {{0, 0}, {0, 0}},  -- Zero-size to prevent mouse-over
    selection_box = {{0, 0}, {0, 0}},  -- Zero-size to prevent mouse-over
    
    -- Supply area large enough to cover both collector and furnace
    supply_area_distance = 1,
    
    -- No wire connections
    maximum_wire_distance = 0,
    
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
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1
    }
}

data:extend({lightning_furnace, hidden_pole})
data:extend(collector_variants)

