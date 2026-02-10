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
	autoplace = { probability_expression = "tenebris_tile_mercury" },
	lowland_fog = true,
	absorptions_per_second = ABSORPTION.NEUTRAL,
	particle_tints = tile_graphics.gleba_shallow_water_particle_tints,
	layer = 1,
	layer_group = "water-overlay",
	sprite_usage_surface = "gleba", -- Group with Gleba atlas (uses wetland-water shader)
	-- Liquid metal effect (lava shader with silver colors)
	effect = "tenebris-mercury",
	effect_color = TILE_COLOR.MERCURY_EFFECT,
	effect_color_secondary = TILE_COLOR.MERCURY_EFFECT_SECONDARY,
	variants = {
		main = {
			{
				picture = "__tenebris-prime__/graphics/tile/mercury.png",
				count = 1,
				scale = 0.5,
				size = 1,
			},
		},
		empty_transitions = true,
	},
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["water"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.warm_stone, -- Metallic feel
	landing_steps_sound = tile_sounds.landing.rock,
	driving_sound = wetland_driving_sound,
	map_color = { 140, 140, 148 },
	walking_speed_modifier = 0.6,
	vehicle_friction_modifier = 12.0,
	default_cover_tile = "landfill",
	fluid = "tenebris-mercury",
	ambient_sounds = tile_sounds.ambient.lava, -- Bubbling liquid metal
}

-- Abyssal gashes - deep impassable trenches that wind through the terrain
-- These are dark, foreboding chasms that block player movement
local abyssal_water = {
	type = "tile",
	name = "tenebris-abyssal-water",
	order = "t[tenebris]-b[tenebris-abyssal-water]",
	subgroup = "gleba-water-tiles",
	collision_mask = tile_collision_masks.water(), -- Full water collision (impassable)
	-- Autoplace with high priority order (z- prefix ensures it's placed last/on top)
	autoplace = {
		probability_expression = "tenebris_tile_abyssal",
		order = "z[tenebris]-a[abyssal]",
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
				size = 1,
			},
		},
		empty_transitions = true, -- No wispy transitions
	},
	transitions = { lava_to_out_of_map_transition }, -- Simple clean transition
	walking_sound = data.raw.tile["deepwater"].walking_sound,
	map_color = { 15, 15, 25 }, -- Very dark, almost black
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	effect = "water",
	effect_color = { 15, 15, 30 }, -- Dark murky water effect
	effect_color_secondary = { 5, 5, 15 },
	ambient_sounds = ambience.lake_ambience,
	absorptions_per_second = ABSORPTION.EXTREME,
}

-- Debug visualization tiles with distinct colors
-- These are temporary for biome debugging

-- Highlands - Bright Cyan
local blue_highlands = {
	type = "tile",
	name = "tenebris-blue-highlands",
	order = "t[tenebris]-b[blue-highlands]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_blue_highlands" },
	layer = 10,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__space-age__/graphics/terrain/gleba/highland-dark-rock.png",
		{
			max_size = 4,
			[1] = {
				weights = {
					0.085,
					0.085,
					0.085,
					0.085,
					0.087,
					0.085,
					0.065,
					0.085,
					0.045,
					0.045,
					0.045,
					0.045,
					0.005,
					0.025,
					0.045,
					0.045,
				},
			},
			[2] = {
				probability = 1,
				weights = {
					0.018,
					0.020,
					0.015,
					0.025,
					0.015,
					0.020,
					0.025,
					0.015,
					0.025,
					0.025,
					0.010,
					0.025,
					0.020,
					0.025,
					0.025,
					0.010,
				},
			},
			[4] = {
				probability = 0.1,
				weights = {
					0.018,
					0.020,
					0.015,
					0.025,
					0.015,
					0.020,
					0.025,
					0.015,
					0.025,
					0.025,
					0.010,
					0.025,
					0.020,
					0.025,
					0.025,
					0.010,
				},
			},
		}
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 50, 50, 84 },
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.NEUTRAL,
}

local grey_highlands = {
	type = "tile",
	name = "tenebris-grey-highlands",
	order = "t[tenebris]-g[grey-highlands]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_grey_highlands" },
	layer = 10,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__space-age__/graphics/terrain/gleba/highland-dark-rock.png",
		{
			max_size = 4,
			[1] = {
				weights = {
					0.085,
					0.085,
					0.085,
					0.085,
					0.087,
					0.085,
					0.065,
					0.085,
					0.045,
					0.045,
					0.045,
					0.045,
					0.005,
					0.025,
					0.045,
					0.045,
				},
			},
			[2] = {
				probability = 1,
				weights = {
					0.018,
					0.020,
					0.015,
					0.025,
					0.015,
					0.020,
					0.025,
					0.015,
					0.025,
					0.025,
					0.010,
					0.025,
					0.020,
					0.025,
					0.025,
					0.010,
				},
			},
			[4] = {
				probability = 0.1,
				weights = {
					0.018,
					0.020,
					0.015,
					0.025,
					0.015,
					0.020,
					0.025,
					0.015,
					0.025,
					0.025,
					0.010,
					0.025,
					0.020,
					0.025,
					0.025,
					0.010,
				},
			},
		}
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 50, 50, 50 }, -- Grey
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.NEUTRAL,
}

-- Lowland Cauliflower - base lowland tile with aux mixing
local lowland_cauliflower = {
	type = "tile",
	name = "tenebris-lowland-cauliflower",
	order = "t[tenebris]-l[lowland]-a[cauliflower]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_lowland_cauliflower_range" },
	layer_group = "water-overlay",
	layer = 40,
	lowland_fog = true,
	effect = "tenebris-murky-puddle",
	effect_is_opaque = false,
	effect_color = TILE_COLOR.LOWLAND_FOG,
	effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions("__space-age__/graphics/terrain/gleba/cauliflower-mold.png", {
		max_size = 4,
		[1] = {
			weights = {
				0.085,
				0.085,
				0.085,
				0.085,
				0.087,
				0.085,
				0.065,
				0.085,
				0.045,
				0.045,
				0.045,
				0.045,
				0.005,
				0.025,
				0.045,
				0.045,
			},
		},
		[2] = {
			probability = 1,
			weights = {
				0.018,
				0.020,
				0.015,
				0.025,
				0.015,
				0.020,
				0.025,
				0.015,
				0.025,
				0.025,
				0.010,
				0.025,
				0.020,
				0.025,
				0.025,
				0.010,
			},
		},
		[4] = {
			probability = 0.1,
			weights = {
				0.018,
				0.020,
				0.015,
				0.025,
				0.015,
				0.020,
				0.025,
				0.015,
				0.025,
				0.025,
				0.010,
				0.025,
				0.020,
				0.025,
				0.025,
				0.010,
			},
		},
	}),
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["landfill"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.semi_wet,
	landing_steps_sound = tile_sounds.landing.semi_wet,
	map_color = { 70, 60, 65 },
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 1.5,
	absorptions_per_second = ABSORPTION.HIGH,
}

-- =============================================================================
-- Wastes Subbiome Tiles
-- 5 subbiomes: Dust Flats (25%), Dust Dunes (20%), Lumpy Wastes (20%),
--              Rocky Badlands (20%), Brash Fields (15%)
-- Standalone definitions (no deepcopy) so you can update tilesets independently.
-- =============================================================================

-- Shared variant weights for wastes tiles (same structure as dust tiles)
local wastes_tile_weights = {
	max_size = 4,
	[1] = {
		weights = {
			0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085,
			0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045,
		},
	},
	[2] = {
		probability = 1,
		weights = {
			0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015,
			0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010,
		},
	},
	[4] = {
		probability = 0.1,
		weights = {
			0.018, 0.020, 0.015, 0.025, 0.015,
		},
	},
}

-- Dust Flats (25%) - smooth flat expanses, easy to traverse
local wastes_flats = {
	type = "tile",
	name = "tenebris-wastes-flats",
	order = "t[tenebris]-w[wastes]-a[flats]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_wastes_flats" },
	layer = 20,
	sprite_usage_surface = nil,
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/wastes/tenebris-dregs-flat.png",
		wastes_tile_weights
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 180, 160, 120 }, -- Sandy tan
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.LOW,
}

-- Dust Dunes (20%) - wind-formed ridge patterns
local wastes_dunes = {
	type = "tile",
	name = "tenebris-wastes-dunes",
	order = "t[tenebris]-w[wastes]-b[dunes]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_wastes_dunes" },
	layer = 21,
	sprite_usage_surface = nil,
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/wastes/tenebris-dregs-crests.png",
		wastes_tile_weights
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 160, 140, 100 }, -- Darker tan
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.LOW,
}

-- Lumpy Wastes - uneven, eroded terrain (part of Dunes subbiome)
local wastes_lumpy = {
	type = "tile",
	name = "tenebris-wastes-lumpy",
	order = "t[tenebris]-w[wastes]-c[lumpy]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_wastes_lumpy" },
	layer = 22,
	sprite_usage_surface = nil,
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/wastes/tenebris-dregs-lumpy.png",
		wastes_tile_weights
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 140, 120, 90 }, -- Brownish tan
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.LOW,
}

-- Patchy Wastes - varied patchy terrain (part of Dunes subbiome)
local wastes_patchy = {
	type = "tile",
	name = "tenebris-wastes-patchy",
	order = "t[tenebris]-w[wastes]-d[patchy]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_wastes_patchy" },
	layer = 23,
	sprite_usage_surface = nil,
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/wastes/tenebris-dregs-patchy.png",
		wastes_tile_weights
	),
	transitions = lava_to_out_of_map_transition and { lava_to_out_of_map_transition } or nil,
	walking_sound = tile_sounds.walking.dry_rock,
	landing_steps_sound = tile_sounds.landing.rock,
	map_color = { 150, 130, 100 }, -- Mixed tan
	walking_speed_modifier = 1,
	vehicle_friction_modifier = 1,
	absorptions_per_second = ABSORPTION.LOW,
}

-- Helper: replace picture path in variants (recursive) for custom graphics
local function replace_tile_picture_path(tbl, old_path, new_path)
	if type(tbl) ~= "table" then
		return
	end
	for k, v in pairs(tbl) do
		if type(v) == "string" and (k == "picture" or k == "filename" or k == "spritesheet") and v == old_path then
			tbl[k] = new_path
		elseif type(v) == "table" then
			replace_tile_picture_path(v, old_path, new_path)
		end
	end
end

-- Exposed Quartz (25%) - 12 tilesets from desaturated ice-rough/ice-smooth, hue 60° steps, varied by aux
-- Mid-light grey base (~195) with subtle hue shift per angle for minimap variation
local EXPOSED_QUARTZ_ANGLES = { 0, 60, 120, 180, 240, 300 }
local EXPOSED_QUARTZ_MAP_COLORS = {
	{ 200, 195, 190 }, -- 0°   slight warm
	{ 195, 200, 190 }, -- 60°  slight yellow-green
	{ 190, 200, 195 }, -- 120° slight green
	{ 190, 195, 200 }, -- 180° slight blue
	{ 195, 190, 200 }, -- 240° slight purple
	{ 200, 190, 195 }, -- 300° slight pink
}
local wastes_exposed_quartz_tiles = {}
for i, angle in ipairs(EXPOSED_QUARTZ_ANGLES) do
	-- Rough (1-6)
	local rough = table.deepcopy(data.raw.tile["ice-rough"])
	rough.name = "tenebris-wastes-exposed-quartz-" .. string.format("%02d", i)
	rough.order = "t[tenebris]-w[wastes]-e[exposed-quartz]-" .. string.format("%02d", i)
	rough.subgroup = "tenebris-tiles"
	rough.autoplace = { probability_expression = "tenebris_tile_wastes_exposed_quartz_" .. string.format("%02d", i) }
	rough.layer = 24
	rough.map_color = EXPOSED_QUARTZ_MAP_COLORS[i]
	rough.absorptions_per_second = ABSORPTION.LOW
	rough.sprite_usage_surface = nil
	rough.collision_mask = tile_collision_masks.ground()
	rough.walking_sound = tile_sounds.walking.smooth_ice
	replace_tile_picture_path(
		rough.variants,
		"__space-age__/graphics/terrain/aquilo/ice-rough.png",
		"__tenebris-prime__/graphics/tile/exposed-quartz/exposed-quartz-rough-" .. angle .. ".png"
	)
	wastes_exposed_quartz_tiles[i] = rough
end
for i, angle in ipairs(EXPOSED_QUARTZ_ANGLES) do
	-- Smooth (7-12)
	local smooth = table.deepcopy(data.raw.tile["ice-smooth"])
	smooth.name = "tenebris-wastes-exposed-quartz-" .. string.format("%02d", i + 6)
	smooth.order = "t[tenebris]-w[wastes]-e[exposed-quartz]-" .. string.format("%02d", i + 6)
	smooth.subgroup = "tenebris-tiles"
	smooth.autoplace =
		{ probability_expression = "tenebris_tile_wastes_exposed_quartz_" .. string.format("%02d", i + 6) }
	smooth.layer = 24
	smooth.map_color = EXPOSED_QUARTZ_MAP_COLORS[i]
	smooth.absorptions_per_second = ABSORPTION.LOW
	smooth.sprite_usage_surface = nil
	smooth.collision_mask = tile_collision_masks.ground()
	smooth.walking_sound = tile_sounds.walking.smooth_ice
	replace_tile_picture_path(
		smooth.variants,
		"__space-age__/graphics/terrain/aquilo/ice-smooth.png",
		"__tenebris-prime__/graphics/tile/exposed-quartz/exposed-quartz-smooth-" .. angle .. ".png"
	)
	wastes_exposed_quartz_tiles[i + 6] = smooth
end

-- Shattered Quartz (15%) - broken quartz rubble with shader effect
local wastes_shattered_quartz_effect = {
	type = "tile-effect",
	name = "tenebris-wastes-shattered-quartz-effect",
	shader = "water",
	water = {
		shader_variation = "wetland-water",
		textures = {
			{
				filename = "__space-age__/graphics/terrain/gleba/watercaustics.png",
				width = 512,
				height = 512,
			},
			{
				filename = "__tenebris-prime__/graphics/tile/exposed-quartz/shattered-quartz.png",
				width = 512 * 4,
				height = 512 * 2,
			},
		},
		texture_variations_columns = 1,
		texture_variations_rows = 1,
		secondary_texture_variations_columns = 4,
		secondary_texture_variations_rows = 2,
		animation_speed = 0.3,
		animation_scale = { 0.40, 0.68 },
		tick_scale = 6,
		specular_lightness = { 2, 5, 1 },
		foam_color = { 8, 2, 2 },
		foam_color_multiplier = 0.5,
		dark_threshold = { 0.0, 0.2 },
		reflection_threshold = { 3, 2 },
		specular_threshold = { 0.0, 0.0 },
	},
}

local wastes_shattered_quartz = {
	type = "tile",
	name = "tenebris-wastes-shattered-quartz",
	order = "t[tenebris]-w[wastes]-g[shattered-quartz]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_tile_wastes_shattered_quartz" },
	variants = {
		main = {
			{
				picture = "__base__/graphics/terrain/deepwater/deepwater1.png",
				count = 1,
				scale = 0.5,
				size = 1,
			},
		},
		transition = tile_graphics.generic_masked_tile_transitions1,
	},
	effect = "tenebris-wastes-shattered-quartz-effect",
	effect_color = { 60, 60, 60 },
	effect_color_secondary = { 45, 45, 45 },
	default_cover_tile = "landfill",
	layer = 0,
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 0.9,
	map_color = { 90, 80, 100 },
	sprite_usage_surface = nil,
	walking_sound = tile_sounds.walking.smooth_ice,
}

-- =============================================================================
-- Sulfur Pit Tiles
-- Three-tier tiling: pit-rock (outer), volcanic-cracks (middle), volcanic-cracks-warm (inner)
-- =============================================================================

-- Sulfur Pit Outer Ring - pit-rock at the borders
local sulfur_pit_rock = table.deepcopy(data.raw.tile["pit-rock"])
sulfur_pit_rock.name = "tenebris-sulfur-pit-rock"
sulfur_pit_rock.order = "t[tenebris]-s[sulfur]-a[pit-rock]"
sulfur_pit_rock.subgroup = "tenebris-tiles"
sulfur_pit_rock.autoplace = {
	probability_expression = "tenebris_sulfur_pit_rock_range",
}
sulfur_pit_rock.layer = 30 -- Base layer for sulfur tiles
sulfur_pit_rock.map_color = { r = 35, g = 30, b = 28 } -- Darker to match Tenebris
sulfur_pit_rock.absorptions_per_second = ABSORPTION.NEUTRAL

-- Sulfur Pit Middle Ring - volcanic cracks
local sulfur_volcanic_cracks = table.deepcopy(data.raw.tile["volcanic-cracks"])
sulfur_volcanic_cracks.name = "tenebris-sulfur-volcanic-cracks"
sulfur_volcanic_cracks.order = "t[tenebris]-s[sulfur]-b[volcanic-cracks]"
sulfur_volcanic_cracks.subgroup = "tenebris-tiles"
sulfur_volcanic_cracks.autoplace = {
	probability_expression = "tenebris_sulfur_volcanic_cracks_range",
}
sulfur_volcanic_cracks.layer = 31 -- Above pit-rock
sulfur_volcanic_cracks.map_color = { r = 40, g = 35, b = 32 } -- Slightly warmer
sulfur_volcanic_cracks.absorptions_per_second = ABSORPTION.NEUTRAL

-- Sulfur Pit Inner Ring - warm volcanic cracks (hue-shifted for Tenebris)
local sulfur_volcanic_cracks_warm = table.deepcopy(data.raw.tile["volcanic-cracks-warm"])
sulfur_volcanic_cracks_warm.name = "tenebris-sulfur-volcanic-cracks-warm"
sulfur_volcanic_cracks_warm.order = "t[tenebris]-s[sulfur]-c[volcanic-cracks-warm]"
sulfur_volcanic_cracks_warm.subgroup = "tenebris-tiles"
sulfur_volcanic_cracks_warm.autoplace = {
	probability_expression = "tenebris_sulfur_volcanic_cracks_warm_range",
}
sulfur_volcanic_cracks_warm.layer = 32 -- Above volcanic-cracks
sulfur_volcanic_cracks_warm.map_color = { r = 50, g = 35, b = 30 } -- Warmest tint
sulfur_volcanic_cracks_warm.absorptions_per_second = ABSORPTION.NEUTRAL
-- Use custom hue-shifted graphics (hue -10, saturation -30)
sulfur_volcanic_cracks_warm.variants = tile_variations_template_with_transitions_and_light(
	"__tenebris-prime__/graphics/tile/volcanic-cracks-warm/volcanic-cracks-warm.png",
	"__tenebris-prime__/graphics/tile/volcanic-cracks-warm/volcanic-cracks-warm-lightmap1.png",
	{
		max_size = 4,
		[1] = {
			weights = {
				0.085,
				0.085,
				0.085,
				0.085,
				0.087,
				0.085,
				0.065,
				0.085,
				0.045,
				0.045,
				0.045,
				0.045,
				0.005,
				0.025,
				0.045,
				0.045,
			},
		},
		[2] = {
			probability = 1,
			weights = {
				0.018,
				0.020,
				0.015,
				0.025,
				0.015,
				0.020,
				0.025,
				0.015,
				0.025,
				0.025,
				0.010,
				0.025,
				0.020,
				0.025,
				0.025,
				0.010,
			},
		},
		[4] = {
			probability = 0.1,
			weights = {
				0.018,
				0.020,
				0.015,
				0.025,
				0.015,
				0.020,
				0.025,
				0.015,
				0.025,
				0.025,
				0.010,
				0.025,
				0.020,
				0.025,
				0.025,
				0.010,
			},
		},
	}
)

-- Overgrowth Luciferin Soil - for growing lucifunnels
local base_overgrowth_yumako = data.raw["tile"]["overgrowth-yumako-soil"]
local overgrowth_luciferin_soil = table.deepcopy(base_overgrowth_yumako)
overgrowth_luciferin_soil.name = "overgrowth-luciferin-soil"
overgrowth_luciferin_soil.order = "t[tenebris]-e[overgrowth-luciferin-soil]"
overgrowth_luciferin_soil.subgroup = "tenebris-artificial-terrain"
overgrowth_luciferin_soil.minable = { mining_time = 0.5, result = "overgrowth-luciferin-soil" }
overgrowth_luciferin_soil.map_color = { 100, 200, 150 } -- Greenish tint for luciferin

-- Overgrowth Tenecap Soil - for growing tenecaps
local base_overgrowth_jellynut = data.raw["tile"]["overgrowth-jellynut-soil"]
local overgrowth_tenecap_soil = table.deepcopy(base_overgrowth_jellynut)
overgrowth_tenecap_soil.name = "overgrowth-tenecap-soil"
overgrowth_tenecap_soil.order = "t[tenebris]-f[overgrowth-tenecap-soil]"
overgrowth_tenecap_soil.subgroup = "tenebris-artificial-terrain"
overgrowth_tenecap_soil.minable = { mining_time = 0.5, result = "overgrowth-tenecap-soil" }
overgrowth_tenecap_soil.map_color = { 150, 100, 180 } -- Purplish tint for tenecap

-- =============================================================================
-- Lowland Tiles
-- Five-tile system with aux-based mixing for natural variation
-- All tiles use murky purple puddle effect for Tenebris atmosphere
-- =============================================================================

-- Standard tile variant weights
local lowland_weights = {
	max_size = 4,
	[1] = {
		weights = {
			0.085,
			0.085,
			0.085,
			0.085,
			0.087,
			0.085,
			0.065,
			0.085,
			0.045,
			0.045,
			0.045,
			0.045,
			0.005,
			0.025,
			0.045,
			0.045,
		},
	},
	[2] = {
		probability = 1,
		weights = {
			0.018,
			0.020,
			0.015,
			0.025,
			0.015,
			0.020,
			0.025,
			0.015,
			0.025,
			0.025,
			0.010,
			0.025,
			0.020,
			0.025,
			0.025,
			0.010,
		},
	},
	[4] = {
		probability = 0.1,
		weights = {
			0.018,
			0.020,
			0.015,
			0.025,
			0.015,
			0.020,
			0.025,
			0.015,
			0.025,
			0.025,
			0.010,
			0.025,
			0.020,
			0.025,
			0.025,
			0.010,
		},
	},
}

-- Lowland Dead Skin
local lowland_dead_skin = {
	type = "tile",
	name = "tenebris-lowland-dead-skin",
	order = "t[tenebris]-l[lowland]-b[dead-skin]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_lowland_dead_skin_range" },
	layer_group = "water-overlay",
	layer = 41,
	lowland_fog = true,
	effect = "tenebris-murky-puddle",
	effect_is_opaque = false,
	effect_color = TILE_COLOR.LOWLAND_FOG,
	effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__space-age__/graphics/terrain/gleba/lowland-dead-skin.png",
		lowland_weights
	),
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["landfill"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.semi_wet,
	landing_steps_sound = tile_sounds.landing.semi_wet,
	map_color = { 60, 50, 55 },
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 1.5,
	absorptions_per_second = ABSORPTION.HIGH,
}

-- Lowland Infection (desaturated pink graphics)
local lowland_infection = {
	type = "tile",
	name = "tenebris-lowland-infection",
	order = "t[tenebris]-l[lowland]-c[infection]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_lowland_infection_range" },
	layer_group = "water-overlay",
	layer = 42,
	lowland_fog = true,
	effect = "tenebris-murky-puddle",
	effect_is_opaque = false,
	effect_color = TILE_COLOR.LOWLAND_FOG,
	effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/lowland/lowland-red-infection.png",
		lowland_weights
	),
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["landfill"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.semi_wet,
	landing_steps_sound = tile_sounds.landing.semi_wet,
	map_color = { 80, 55, 70 },
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 1.5,
	absorptions_per_second = ABSORPTION.HIGH,
}

-- Lowland Vein Bulges (desaturated pink graphics)
local lowland_vein_bulges = {
	type = "tile",
	name = "tenebris-lowland-vein-bulges",
	order = "t[tenebris]-l[lowland]-d[vein-bulges]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_lowland_vein_bulges_range" },
	layer_group = "water-overlay",
	layer = 43,
	lowland_fog = true,
	effect = "tenebris-murky-puddle",
	effect_is_opaque = false,
	effect_color = TILE_COLOR.LOWLAND_FOG,
	effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/lowland/lowland-red-vein-2.png",
		lowland_weights
	),
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["landfill"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.semi_wet,
	landing_steps_sound = tile_sounds.landing.semi_wet,
	map_color = { 75, 50, 65 },
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 1.5,
	absorptions_per_second = ABSORPTION.HIGH,
}

-- Lowland Vein Dead (desaturated pink graphics)
local lowland_vein_dead = {
	type = "tile",
	name = "tenebris-lowland-vein-dead",
	order = "t[tenebris]-l[lowland]-e[vein-dead]",
	subgroup = "tenebris-tiles",
	collision_mask = tile_collision_masks.ground(),
	autoplace = { probability_expression = "tenebris_lowland_vein_dead_range" },
	layer_group = "water-overlay",
	layer = 44,
	lowland_fog = true,
	effect = "tenebris-murky-puddle",
	effect_is_opaque = false,
	effect_color = TILE_COLOR.LOWLAND_FOG,
	effect_color_secondary = TILE_COLOR.LOWLAND_FOG_SECONDARY,
	sprite_usage_surface = "gleba",
	variants = tile_variations_template_with_transitions(
		"__tenebris-prime__/graphics/tile/lowland/lowland-red-vein-dead.png",
		lowland_weights
	),
	transitions = { lava_to_out_of_map_transition },
	transitions_between_transitions = data.raw.tile["landfill"].transitions_between_transitions,
	walking_sound = tile_sounds.walking.semi_wet,
	landing_steps_sound = tile_sounds.landing.semi_wet,
	map_color = { 55, 45, 50 },
	walking_speed_modifier = 0.85,
	vehicle_friction_modifier = 1.5,
	absorptions_per_second = ABSORPTION.HIGH,
}

data:extend({
	mercury_swamp,
	abyssal_water,
	blue_highlands,
	grey_highlands,
	lowland_cauliflower,
	-- Wastes subbiome tiles (Dunes: 4 dust tiles, Quartz: 2 tiles)
	wastes_flats,
	wastes_dunes,
	wastes_lumpy,
	wastes_patchy,
	-- 12 exposed-quartz tilesets (aux-varied desaturated rainbow)
	wastes_exposed_quartz_tiles[1],
	wastes_exposed_quartz_tiles[2],
	wastes_exposed_quartz_tiles[3],
	wastes_exposed_quartz_tiles[4],
	wastes_exposed_quartz_tiles[5],
	wastes_exposed_quartz_tiles[6],
	wastes_exposed_quartz_tiles[7],
	wastes_exposed_quartz_tiles[8],
	wastes_exposed_quartz_tiles[9],
	wastes_exposed_quartz_tiles[10],
	wastes_exposed_quartz_tiles[11],
	wastes_exposed_quartz_tiles[12],
	wastes_shattered_quartz_effect,
	wastes_shattered_quartz,
	sulfur_pit_rock,
	sulfur_volcanic_cracks,
	sulfur_volcanic_cracks_warm,
	overgrowth_luciferin_soil,
	overgrowth_tenecap_soil,
	-- Lowland tile variations
	lowland_dead_skin,
	lowland_infection,
	lowland_vein_bulges,
	lowland_vein_dead,
})
