local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local lava_to_out_of_map_transition = space_age_tiles_util.lava_to_out_of_map_transition
space_age_tiles_util = space_age_tiles_util or {}
local tile_trigger_effects = require("__base__.prototypes.tile.tile-trigger-effects")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local ambience = require("__tenebris-prime__/prototypes/tile/ambience.lua")
local tenebris = require("lib.tenebris")
local constants = require("lib.constants")

-- Load tile effects first (they must be registered before tiles that use them)
require("__tenebris-prime__/prototypes/tile/tile-effects")

local ABSORPTION = tenebris.ABSORPTION
local TILE_COLOR = constants.TILE_COLOR

-- Mercury pools - shallow toxic liquid metal around mercury pool spots
-- Uses lava shader for flowing liquid metal appearance
local mercury_swamp = {
    type = "tile",
    name = "tenebris-mercury-tile",
    order = "t[tenebris]-a[tenebris-mercury-tile]",
    subgroup = "gleba-water-tiles",
    collision_mask = tile_collision_masks.shallow_water(),
    -- Base autoplace (overridden by property_expression_names in map_gen)
    autoplace = {probability_expression = "tenebris_tile_mercury"},
    lowland_fog = true,
    absorptions_per_second = ABSORPTION.NEUTRAL,
    particle_tints = tile_graphics.gleba_shallow_water_particle_tints,
    layer = 1,
    layer_group = "water-overlay",
    sprite_usage_surface = "gleba",  -- Group with Gleba atlas (uses wetland-water shader)
    -- Liquid metal effect (lava shader with silver colors)
    effect = "tenebris-mercury",
    effect_color = TILE_COLOR.MERCURY_EFFECT,
    effect_color_secondary = TILE_COLOR.MERCURY_EFFECT_SECONDARY,
    variants =
    {
        main =
        {
            {
                picture = "__tenebris-prime__/graphics/tile/mercury.png",
                count = 1,
                scale = 0.5,
                size = 1
            }
        },
        empty_transitions=true,
    },
    transitions = {lava_to_out_of_map_transition},
    transitions_between_transitions = data.raw.tile["water"].transitions_between_transitions,
    walking_sound = tile_sounds.walking.warm_stone,  -- Metallic feel
    landing_steps_sound = tile_sounds.landing.rock,
    driving_sound = wetland_driving_sound,
    map_color = {140, 140, 148},
    walking_speed_modifier = 0.6,
    vehicle_friction_modifier = 12.0,
    default_cover_tile = "landfill",
    fluid = "tenebris-mercury",
    ambient_sounds = tile_sounds.ambient.lava  -- Bubbling liquid metal
}

-- Abyssal gashes - deep impassable trenches that wind through the terrain
-- These are dark, foreboding chasms that block player movement
local abyssal_water = {
    type = "tile",
    name = "tenebris-abyssal-water",
    order = "t[tenebris]-b[tenebris-abyssal-water]",
    subgroup = "gleba-water-tiles",
    collision_mask = tile_collision_masks.water(),  -- Full water collision (impassable)
    -- Autoplace with high priority order (z- prefix ensures it's placed last/on top)
    autoplace = {
        probability_expression = "tenebris_tile_abyssal",
        order = "z[tenebris]-a[abyssal]"
    },
    layer = 2,
    layer_group = "water",
    sprite_usage_surface = "nauvis",
    variants = {
        main = {
            {
                picture = "__base__/graphics/terrain/deepwater/deepwater1.png",
                count = 1,
                scale = 0.5,
                size = 1
            }
        },
        empty_transitions = true  -- No wispy transitions
    },
    transitions = {lava_to_out_of_map_transition},  -- Simple clean transition
    walking_sound = data.raw.tile["deepwater"].walking_sound,
    map_color = {15, 15, 25},  -- Very dark, almost black
    walking_speed_modifier = 1,
    vehicle_friction_modifier = 1,
    effect = "water",
    effect_color = {15, 15, 30},  -- Dark murky water effect
    effect_color_secondary = {5, 5, 15},
    ambient_sounds = ambience.lake_ambience,
    absorptions_per_second = ABSORPTION.EXTREME,
}

-- Debug visualization tiles with distinct colors
-- These are temporary for biome debugging

-- Highlands - Bright Cyan
local debug_highlands = table.deepcopy(data.raw.tile["highland-dark-rock"])
debug_highlands.name = "tenebris-debug-highlands"
debug_highlands.order = "t[tenebris]-d[debug]-a[highlands]"
debug_highlands.autoplace = {probability_expression = "tenebris_tile_highlands"}
debug_highlands.map_color = {0, 200, 255}  -- Bright cyan
debug_highlands.absorptions_per_second = ABSORPTION.NEUTRAL

-- Lowlands - Dark murky with violet fog
local debug_lowlands = table.deepcopy(data.raw.tile["lowland-cream-cauliflower"])
debug_lowlands.name = "tenebris-debug-lowlands"
debug_lowlands.order = "t[tenebris]-d[debug]-b[lowlands]"
debug_lowlands.autoplace = {probability_expression = "tenebris_tile_lowlands"}
debug_lowlands.map_color = {0, 255, 100}  -- Bright green (debug)
debug_lowlands.absorptions_per_second = ABSORPTION.HIGH
debug_lowlands.walking_speed_modifier = 0.85  -- Slight slowdown in murky lowlands
debug_lowlands.vehicle_friction_modifier = 1.5  -- Vehicles struggle slightly
-- Lowland fog/puddle effect
debug_lowlands.lowland_fog = true
debug_lowlands.effect = "tenebris-murky-puddle"
debug_lowlands.effect_is_opaque = false
debug_lowlands.effect_color = TILE_COLOR.LOWLAND_FOG
debug_lowlands.effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY

-- Wastes - Bright Yellow/Orange
local debug_wastes = table.deepcopy(data.raw.tile["dust-lumpy"])
debug_wastes.name = "tenebris-debug-wastes"
debug_wastes.order = "t[tenebris]-d[debug]-c[wastes]"
debug_wastes.autoplace = {probability_expression = "tenebris_tile_wastes"}
debug_wastes.map_color = {255, 200, 0}  -- Bright yellow/orange
debug_wastes.absorptions_per_second = ABSORPTION.LOW

-- Sulfur geysers - Bright Red
local debug_sulfur = table.deepcopy(data.raw.tile["pit-rock"])
debug_sulfur.name = "tenebris-debug-sulfur"
debug_sulfur.order = "t[tenebris]-d[debug]-d[sulfur]"
debug_sulfur.autoplace = {probability_expression = "tenebris_tile_sulfur"}
debug_sulfur.map_color = {255, 50, 50}  -- Bright red
debug_sulfur.absorptions_per_second = ABSORPTION.NEUTRAL

-- Quartz forests - Violet
local debug_quartz = table.deepcopy(data.raw.tile["dust-lumpy"])
debug_quartz.name = "tenebris-debug-quartz"
debug_quartz.order = "t[tenebris]-d[debug]-e[quartz]"
debug_quartz.autoplace = {probability_expression = "tenebris_biome_quartz"}
debug_quartz.map_color = {138, 43, 226}  -- Violet
debug_quartz.absorptions_per_second = ABSORPTION.NEUTRAL

-- Overgrowth Luciferin Soil - for growing lucifunnels
local base_overgrowth_yumako = data.raw["tile"]["overgrowth-yumako-soil"]
local overgrowth_luciferin_soil = table.deepcopy(base_overgrowth_yumako)
overgrowth_luciferin_soil.name = "overgrowth-luciferin-soil"
overgrowth_luciferin_soil.order = "t[tenebris]-e[overgrowth-luciferin-soil]"
overgrowth_luciferin_soil.subgroup = "tenebris-artificial-terrain"
overgrowth_luciferin_soil.minable = {mining_time = 0.5, result = "overgrowth-luciferin-soil"}
overgrowth_luciferin_soil.map_color = {100, 200, 150}  -- Greenish tint for luciferin

-- Overgrowth Tenecap Soil - for growing tenecaps
local base_overgrowth_jellynut = data.raw["tile"]["overgrowth-jellynut-soil"]
local overgrowth_tenecap_soil = table.deepcopy(base_overgrowth_jellynut)
overgrowth_tenecap_soil.name = "overgrowth-tenecap-soil"
overgrowth_tenecap_soil.order = "t[tenebris]-f[overgrowth-tenecap-soil]"
overgrowth_tenecap_soil.subgroup = "tenebris-artificial-terrain"
overgrowth_tenecap_soil.minable = {mining_time = 0.5, result = "overgrowth-tenecap-soil"}
overgrowth_tenecap_soil.map_color = {150, 100, 180}  -- Purplish tint for tenecap

data:extend({
    mercury_swamp,
    abyssal_water,
    debug_highlands,
    debug_lowlands,
    debug_wastes,
    debug_sulfur,
    debug_quartz,
    overgrowth_luciferin_soil,
    overgrowth_tenecap_soil,
})
