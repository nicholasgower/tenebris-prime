--- Tenebris Decoratives
--- Decorative entities for Tenebris surface biomes
--- References space-age graphics directly (no copying needed)

local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")
local base_tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local constants = require("__tenebris-prime__.lib.constants")
local TINT = constants.TINT

-- Tile layer constants
local decal_tile_layer = 255

-- Collision mask helper
local function dec_default_collision()
	return { layers = { doodad = true }, colliding_with_tiles_only = true }
end

-- Helper to create picture arrays from numbered files
local function make_pictures(base_path, suffix, width, height, count, scale, shift)
	local pics = {}
	for i = 1, count do
		local idx = string.format("%02d", i)
		table.insert(pics, {
			filename = base_path .. idx .. suffix,
			width = width,
			height = height,
			scale = scale or 0.5,
			shift = shift or { 0, 0 },
		})
	end
	return pics
end

-- Use tints from constants
local CYAN_TINT = TINT.HIGHLAND_CYAN
local MERCURY_TINT = TINT.MERCURY_SHORE
local PURPLE_TINT = TINT.LOWLAND_PURPLE
local CINNABAR_TINT = TINT.CINNABAR

-- =============================================================================
-- LOWLAND DECORATIVES (near lichen deposits, wet areas)
-- =============================================================================

-- Nerve roots - organic veiny patterns for lowlands
local tenebris_nerve_roots = {
	name = "tenebris-nerve-roots",
	type = "optimized-decorative",
	order = "t[tenebris]-a[lowland]-a[nerve-roots]",
	collision_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
	collision_mask = dec_default_collision(),
	walking_sound = base_tile_sounds.walking.plant,
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	autoplace = {
		tile_restriction = {
			"tenebris-lowland-cauliflower",
			"tenebris-lowland-dead-skin",
			"tenebris-lowland-infection",
			"tenebris-lowland-vein-bulges",
			"tenebris-lowland-vein-dead",
		},
		probability_expression = "trpi(0.02)",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-01.png",
			width = 1536,
			height = 990,
			shift = { 0, -0.25 },
			scale = 0.5,
			tint = PURPLE_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-02.png",
			width = 1536,
			height = 990,
			shift = { 0, -0.25 },
			scale = 0.5,
			tint = PURPLE_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-03.png",
			width = 1536,
			height = 990,
			shift = { 0, -0.25 },
			scale = 0.5,
			tint = PURPLE_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-04.png",
			width = 1536,
			height = 990,
			shift = { 0, -0.25 },
			scale = 0.5,
			tint = PURPLE_TINT,
		},
	},
}

-- =============================================================================
-- MERCURY SHORE DECORATIVES (around mercury pools)
-- =============================================================================

-- Calcite-like mineral stains around mercury (lowlands and mercury pool edges only)
local tenebris_mercury_stain = {
	name = "tenebris-mercury-stain",
	type = "optimized-decorative",
	order = "t[tenebris]-b[mercury]-a[stain]",
	collision_box = { { -3, -3 }, { 3, 3 } },
	collision_mask = dec_default_collision(),
	render_layer = "decals",
	tile_layer = decal_tile_layer - 6,
	autoplace = {
		tile_restriction = {
			"tenebris-lowland-cauliflower",
			"tenebris-lowland-dead-skin",
			"tenebris-lowland-infection",
			"tenebris-lowland-vein-bulges",
			"tenebris-lowland-vein-dead",
			"tenebris-mercury-tile",
		},
		probability_expression = "tenebris_subbiome_mercury_shore * 0.1",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-01.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-02.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-03.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-04.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = MERCURY_TINT,
		},
	},
}

-- Stunted coral around mercury (already grey, minimal tint)
local tenebris_mercury_coral = {
	name = "tenebris-mercury-coral",
	type = "optimized-decorative",
	order = "t[tenebris]-b[mercury]-b[coral]",
	collision_box = { { -3.375, -2.3125 }, { 3.25, 2.3125 } },
	collision_mask = dec_default_collision(),
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	autoplace = {
		tile_restriction = { "tenebris-mercury-tile" },
		probability_expression = "trpi(0.04)",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-00.png",
			width = 400,
			height = 299,
			shift = util.by_pixel(4.5, -2.25),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-01.png",
			width = 419,
			height = 320,
			shift = util.by_pixel(-0.75, 2),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-02.png",
			width = 417,
			height = 287,
			shift = util.by_pixel(-1.25, 1.25),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-03.png",
			width = 421,
			height = 298,
			shift = util.by_pixel(-0.25, 5.5),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-04.png",
			width = 396,
			height = 302,
			shift = util.by_pixel(6, 4),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
		{
			filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-05.png",
			width = 408,
			height = 295,
			shift = util.by_pixel(-2.5, 7.75),
			scale = 0.5,
			tint = MERCURY_TINT,
		},
	},
}

-- =============================================================================
-- HIGHLAND DECORATIVES (lucifunnel habitat, elevated terrain)
-- =============================================================================

-- Curly roots with cyan tint (matches lucifunnel glow)
local tenebris_highland_roots = {
	name = "tenebris-highland-roots",
	type = "optimized-decorative",
	order = "t[tenebris]-c[highland]-a[roots]",
	collision_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
	collision_mask = dec_default_collision(),
	walking_sound = base_tile_sounds.walking.plant,
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	autoplace = {
		tile_restriction = {
			"tenebris-blue-highlands",
			"tenebris-grey-highlands",
		},
		probability_expression = "tenebris_highland_roots_probability",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-01.png",
			width = 1257,
			height = 1257,
			scale = 0.45,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-02.png",
			width = 1257,
			height = 1257,
			scale = 0.45,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-03.png",
			width = 1257,
			height = 1257,
			scale = 0.45,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-04.png",
			width = 1257,
			height = 1257,
			scale = 0.45,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-05.png",
			width = 1257,
			height = 1257,
			scale = 0.45,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
	},
}

-- Mycelium network with cyan tint
local tenebris_mycelium = {
	name = "tenebris-mycelium",
	type = "optimized-decorative",
	order = "t[tenebris]-c[highland]-b[mycelium]",
	collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
	collision_mask = dec_default_collision(),
	walking_sound = base_tile_sounds.walking.plant,
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	autoplace = {
		tile_restriction = {
			"tenebris-blue-highlands",
			"tenebris-grey-highlands",
		},
		probability_expression = "tenebris_mycelium_probability",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/mycelium/mycelium-01.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/mycelium/mycelium-02.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/mycelium/mycelium-03.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
		{
			filename = "__space-age__/graphics/decorative/mycelium/mycelium-04.png",
			width = 512,
			height = 512,
			scale = 0.5,
			tint = CYAN_TINT,
			draw_as_glow = true,
		},
	},
}

-- =============================================================================
-- WASTES DECORATIVES (barren, dusty terrain)
-- =============================================================================

-- Base game sand-dune-decal picture dimensions (00-29) for desaturated copy
local SAN_DUNE_DECAL_SPECS = {
	{ 212, 168, -8, 0 },
	{ 211, 148, 5.75, -3.5 },
	{ 260, 184, 3, 1 },
	{ 129, 181, 0.75, 1.75 },
	{ 196, 184, -3.5, -1.5 },
	{ 215, 184, -1.25, -1 },
	{ 218, 179, 6.5, 4.25 },
	{ 250, 183, 17.5, 3.25 },
	{ 260, 176, 5, 0.5 },
	{ 260, 184, -5.5, -1 },
	{ 233, 183, -13.75, 1.25 },
	{ 172, 184, -9.5, 2 },
	{ 260, 166, 2.5, -6.5 },
	{ 259, 172, 4.75, -1 },
	{ 199, 184, -2.25, -2 },
	{ 214, 184, 8.5, -3 },
	{ 162, 182, -8, -4.5 },
	{ 222, 153, -3, -0.25 },
	{ 247, 184, 4.25, -2.5 },
	{ 211, 184, -5.75, -3 },
	{ 248, 183, -1.5, 2.25 },
	{ 176, 184, 6.5, 1.5 },
	{ 208, 185, 9, -1.75 },
	{ 227, 184, -3.75, -1.5 },
	{ 158, 186, 4.5, -1 },
	{ 260, 184, 1.5, -1.5 },
	{ 134, 184, -0.5, -1 },
	{ 127, 165, 26.25, 1.25 },
	{ 258, 158, -2.5, -4.5 },
	{ 180, 184, -3.5, -2 },
}

-- Sand-dune decals (80% desaturated via ImageMagick, in mod graphics) on wastes dunes only
local tenebris_sand_dune_decal = {
	name = "tenebris-sand-dune-decal",
	type = "optimized-decorative",
	order = "t[tenebris]-d[wastes]-a[dune-decal]",
	collision_box = { { -1.78125, -1.34375 }, { 1.78125, 1.34375 } },
	collision_mask = { layers = { doodad = true, water_tile = true }, not_colliding_with_itself = true },
	render_layer = "decals",
	tile_layer = decal_tile_layer,
	autoplace = {
		tile_restriction = {
			"tenebris-wastes-flats",
			"tenebris-wastes-dunes",
			"tenebris-wastes-lumpy",
			"tenebris-wastes-patchy",
		},
		probability_expression = "tenebris_sand_dune_decal_probability",
	},
	pictures = (function()
		local pics = {}
		for i, spec in ipairs(SAN_DUNE_DECAL_SPECS) do
			local idx = string.format("%02d", i - 1)
			pics[i] = {
				filename = "__tenebris-prime__/graphics/decorative/sand-dune-decal/sand-dune-decal-" .. idx .. ".png",
				width = spec[1],
				height = spec[2],
				shift = util.by_pixel(spec[3], spec[4]),
				scale = 0.5,
			}
		end
		return pics
	end)(),
}

-- Waves decal (Space Age waves-relief, no desaturation) on wastes dunes only
local tenebris_waves_decal = {
	name = "tenebris-waves-decal",
	type = "optimized-decorative",
	order = "t[tenebris]-d[wastes]-b[waves-decal]",
	collision_box = { { -8, -8 }, { 8, 8 } },
	collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true },
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	autoplace = {
		tile_restriction = {
			"tenebris-wastes-flats",
			"tenebris-wastes-dunes",
			"tenebris-wastes-lumpy",
			"tenebris-wastes-patchy",
		},
		probability_expression = "tenebris_waves_decal_probability",
	},
	pictures = (function()
		local pics = {}
		for i = 1, 8 do
			local idx = string.format("%02d", i)
			pics[i] = {
				filename = "__space-age__/graphics/decorative/waves-relief/waves-" .. idx .. ".png",
				width = 1387,
				height = 1387,
				scale = 0.5,
			}
		end
		return pics
	end)(),
}

-- Tenebrace spore cup - tinted brown-cup for tenebrace spawns
local tenebrace_cup = {
	name = "tenebrace-cup",
	type = "optimized-decorative",
	order = "t[tenebris]-a[lowland]-c[tenebrace-cup]",
	collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
	collision_mask = dec_default_collision(),
	walking_sound = base_tile_sounds.walking.mud,
	render_layer = "decorative",
	tile_restriction = {
		"tenebris-lowland-cauliflower",
		"tenebris-lowland-dead-skin",
		"tenebris-lowland-infection",
		"tenebris-lowland-vein-bulges",
		"tenebris-lowland-vein-dead",
	},
	pictures = (function()
		local pics = {}
		for i = 1, 13 do
			local idx = string.format("%02d", i)
			table.insert(pics, {
				filename = "__space-age__/graphics/decorative/brown-cup/brown-cup-" .. idx .. ".png",
				width = 220,
				height = 220,
				scale = 0.5,
				tint = TINT.TENEBRACE,
			})
		end
		return pics
	end)(),
}

-- Tenebrace mycelium - tinted mycelium for tenebrace spawns
local tenebrace_mycelium = {
	name = "tenebrace-mycelium",
	type = "optimized-decorative",
	order = "t[tenebris]-a[lowland]-d[tenebrace-mycelium]",
	collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
	collision_mask = dec_default_collision(),
	walking_sound = base_tile_sounds.walking.plant,
	render_layer = "decals",
	tile_layer = decal_tile_layer - 1,
	tile_restriction = {
		"tenebris-lowland-cauliflower",
		"tenebris-lowland-dead-skin",
		"tenebris-lowland-infection",
		"tenebris-lowland-vein-bulges",
		"tenebris-lowland-vein-dead",
	},
	pictures = (function()
		local pics = {}
		for i = 1, 16 do
			local idx = string.format("%02d", i)
			table.insert(pics, {
				filename = "__space-age__/graphics/decorative/mycelium/mycelium-" .. idx .. ".png",
				width = 512,
				height = 512,
				scale = 0.5,
				tint = TINT.TENEBRACE,
			})
		end
		return pics
	end)(),
}

-- =============================================================================
-- SULFUR PIT DECORATIVES (volcanic sulfur areas)
-- =============================================================================

-- Sulfur tint from constants (kept for reference)
local SULFUR_TINT = TINT.SULFUR
-- Use cinnabar for sulfur pit rocks to match the cinnabar theme
local SULFUR_ROCK_TINT = TINT.CINNABAR

-- Chimney gas animation helper
-- Gas multipliers from constants
local GAS = constants.GAS_MULTIPLIER

-- Cinnabar/red tinted gas animation for Tenebris chimneys
local function chimney_gas_animation(position)
	return {
		{
			count = 1,
			render_layer = "smoke",
			offset_x = position[1],
			offset_y = position[2],
			animation = {
				filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-outer.png",
				frame_count = 47,
				line_length = 16,
				width = 90,
				height = 188,
				animation_speed = 0.3,
				shift = util.by_pixel(-6, -89),
				scale = 1,
				tint = util.multiply_color(TINT.CINNABAR_GAS_OUTER, GAS.CHIMNEY_OUTER),
			},
		},
		{
			count = 1,
			render_layer = "smoke",
			offset_x = position[1],
			offset_y = position[2],
			animation = {
				filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-inner.png",
				frame_count = 47,
				line_length = 16,
				width = 40,
				height = 84,
				animation_speed = 0.4,
				shift = util.by_pixel(-4, -30),
				scale = 1,
				tint = util.multiply_color(TINT.CINNABAR_GAS_INNER, GAS.CHIMNEY_INNER),
			},
		},
	}
end

-- Fire visualisation helper for chimney base (surrounds the chimney with fire)
local function chimney_fire_visualisation(position)
	return {
		min_count = 4,
		max_count = 8,
		-- Spread fires across the base of the chimney (~2.4 tile wide)
		offset_x = { -1.0, 1.0 },
		offset_y = { -0.8, 0.8 },
		render_layer = "object",
		adjust_animation_speed_by_base_scale = true,
		scale = { 0.8, 1.2 },
		light = {
			intensity = 0.4,
			size = 4,
			color = TINT.CINNABAR_FIRE_LIGHT,
			flicker_interval = 24,
			flicker_min_modifier = 0.7,
			flicker_max_modifier = 1.3,
			offset_flicker = true,
		},
		animation = {
			{
				filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
				line_length = 10,
				width = 84,
				height = 130,
				frame_count = 90,
				animation_speed = 0.25,
				scale = 0.5,
				tint = TINT.CINNABAR_FIRE,
				shift = { 0, -0.5 },
				draw_as_glow = true,
			},
			{
				filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png",
				line_length = 10,
				width = 82,
				height = 106,
				frame_count = 90,
				animation_speed = 0.25,
				scale = 0.5,
				tint = TINT.CINNABAR_FIRE,
				shift = { 0, -0.5 },
				draw_as_glow = true,
			},
			{
				filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png",
				line_length = 10,
				width = 84,
				height = 124,
				frame_count = 90,
				animation_speed = 0.25,
				scale = 0.5,
				tint = TINT.CINNABAR_FIRE,
				shift = { 0, -0.5 },
				draw_as_glow = true,
			},
		},
	}
end

-- Combined gas + fire animation for active chimneys
-- Each variation needs both gas emissions AND fire visualizations
local function chimney_gas_and_fire_animation(gas_position, fire_position)
	local result = chimney_gas_animation(gas_position) -- Returns {outer_gas, inner_gas}
	table.insert(result, chimney_fire_visualisation(fire_position))
	return result
end

-- Tenebris sulfur chimney vent
local tenebris_sulfur_chimney = {
	name = "tenebris-sulfur-chimney",
	type = "simple-entity",
	flags = { "placeable-neutral", "placeable-off-grid" },
	icon = "__space-age__/graphics/icons/vulcanus-chimney.png",
	subgroup = "grass",
	order = "t[tenebris]-e[sulfur]-h[chimney]",
	collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
	selection_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
	drawing_box_vertical_extension = 2,
	render_layer = "object",
	collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
	max_health = 500,
	autoplace = {
		order = "a[landscape]-c[chimney]-t[tenebris]",
		probability_expression = "tenebris_sulfur_chimney_probability",
	},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 2,
		results = {
			{ type = "item", name = "stone", amount_min = 9, amount_max = 15 },
			{ type = "item", name = "tenebris-cinnabar", amount_min = 2, amount_max = 5 },
		},
	},
	resistances = {
		{ type = "fire", percent = 100 },
	},
	map_color = { 129, 105, 78 },
	count_as_rock_for_filtered_deconstruction = true,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	-- Spawn fire when destroyed or mined (like ash trees)
	remains_when_mined = "tenebris-chimney-fire",
	dying_trigger_effect = {
		type = "create-fire",
		entity_name = "tenebris-chimney-fire",
		initial_ground_flame_count = 2,
	},
	working_sound = {
		sound = {
			category = "world-ambient",
			variations = sound_variations("__space-age__/sound/world/decoratives/chimney-vent", 1, 0.3),
			advanced_volume_control = {
				fades = {
					fade_in = {
						curve_type = "S-curve",
						from = { control = 0.4, volume_percentage = 0 },
						to = { 1.2, 100.0 },
					},
				},
			},
			audible_distance_modifier = 0.7,
		},
		max_sounds_per_prototype = 2,
	},
	impact_category = "stone",
	pictures = {
		layers = {
			util.sprite_load(
				"__tenebris-prime__/graphics/entity/chimney/cinnabar-chimney-upper",
				{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, shift = { 5, 0 } }
			),
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-shadow",
				{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, draw_as_shadow = true, shift = { 5, 0 } }
			),
		},
	},
	lower_render_layer = "floor",
	lower_pictures = util.sprite_load(
		"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-lower",
		{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, shift = { 5, 0 } }
	),
	stateless_visualisation_variations = {
		-- Each variation has gas emissions + fire at the base (ground level)
		chimney_gas_and_fire_animation({ 0, -3 }, { -0.2, -0.2 }),
		chimney_gas_and_fire_animation({ -0.75, -2.75 }, { -0.9, -0.7 }),
		chimney_gas_and_fire_animation({ 0.55, -3.1 }, { 0.4, -1.7 }),
	},
}

-- Tenebris truncated sulfur chimney (no gas, broken rock formation)
local tenebris_sulfur_chimney_truncated = {
	name = "tenebris-sulfur-chimney-truncated",
	type = "simple-entity",
	flags = { "placeable-neutral", "placeable-off-grid" },
	icon = "__space-age__/graphics/icons/vulcanus-chimney-truncated.png",
	subgroup = "grass",
	order = "t[tenebris]-e[sulfur]-i[chimney-truncated]",
	collision_box = { { -0.9, -0.7 }, { 0.9, 0.7 } },
	selection_box = { { -1, -0.8 }, { 1, 0.8 } },
	collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
	render_layer = "object",
	max_health = 300,
	autoplace = {
		order = "a[landscape]-c[chimney]-t[tenebris]-b[truncated]",
		probability_expression = "tenebris_sulfur_chimney_truncated_probability",
	},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 2,
		results = {
			{ type = "item", name = "stone", amount_min = 6, amount_max = 12 },
			{ type = "item", name = "tenebris-cinnabar", amount_min = 2, amount_max = 3 },
		},
	},
	resistances = {
		{ type = "fire", percent = 100 },
	},
	map_color = { 129, 105, 78 },
	count_as_rock_for_filtered_deconstruction = true,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	impact_category = "stone",
	pictures = {
		layers = {
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-truncated-upper",
				{ scale = 0.5, variation_count = 6, multiply_shift = 0.5 }
			),
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-truncated-shadow",
				{ scale = 0.5, variation_count = 6, multiply_shift = 0.5, draw_as_shadow = true }
			),
		},
	},
	lower_pictures = util.sprite_load(
		"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-truncated-lower",
		{ scale = 0.5, variation_count = 6, multiply_shift = 0.5 }
	),
	lower_render_layer = "floor",
}

-- Faded gas animation (weaker than main chimney)
local function chimney_gas_animation_faded(position)
	return {
		{
			count = 1,
			render_layer = "smoke",
			offset_x = position[1],
			offset_y = position[2],
			animation = {
				filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-outer.png",
				frame_count = 47,
				line_length = 16,
				width = 90,
				height = 188,
				animation_speed = 0.3,
				shift = util.by_pixel(-6, -89),
				scale = 1,
				tint = util.multiply_color(TINT.CINNABAR_GAS_OUTER, GAS.CHIMNEY_OUTER * 0.5),
			},
		},
		{
			count = 1,
			render_layer = "smoke",
			offset_x = position[1],
			offset_y = position[2],
			animation = {
				filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-inner.png",
				frame_count = 47,
				line_length = 16,
				width = 40,
				height = 84,
				animation_speed = 0.4,
				shift = util.by_pixel(-4, -30),
				scale = 1,
				tint = util.multiply_color(TINT.CINNABAR_GAS_INNER, GAS.CHIMNEY_INNER * 0.5),
			},
		},
	}
end

-- Tenebris faded sulfur chimney (weaker gas emission)
local tenebris_sulfur_chimney_faded = {
	name = "tenebris-sulfur-chimney-faded",
	type = "simple-entity",
	flags = { "placeable-neutral", "placeable-off-grid" },
	icon = "__space-age__/graphics/icons/vulcanus-chimney-faded.png",
	subgroup = "grass",
	order = "t[tenebris]-e[sulfur]-h[chimney-faded]",
	collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
	selection_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
	drawing_box_vertical_extension = 2,
	render_layer = "object",
	collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
	max_health = 500,
	autoplace = {
		order = "a[landscape]-c[chimney]-t[tenebris]-c[faded]",
		probability_expression = "tenebris_sulfur_chimney_faded_probability",
	},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 2,
		results = {
			{ type = "item", name = "stone", amount_min = 9, amount_max = 15 },
			{ type = "item", name = "sulfur", amount_min = 0, amount_max = 3 },
		},
	},
	resistances = {
		{ type = "fire", percent = 100 },
	},
	map_color = { 129, 105, 78 },
	count_as_rock_for_filtered_deconstruction = true,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	-- Spawn fire when destroyed (weaker than active chimney)
	remains_when_mined = "tenebris-chimney-fire",
	dying_trigger_effect = {
		type = "create-fire",
		entity_name = "tenebris-chimney-fire",
		initial_ground_flame_count = 1, -- Smaller fire than active chimney
	},
	impact_category = "stone",
	pictures = {
		layers = {
			util.sprite_load(
				"__tenebris-prime__/graphics/entity/chimney/cinnabar-chimney-faded-upper",
				{ scale = 0.5, variation_count = 5, multiply_shift = 0.5, shift = { 5, 0 } }
			),
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-faded-shadow",
				{ scale = 0.5, variation_count = 5, multiply_shift = 0.5, draw_as_shadow = true, shift = { 5, 0 } }
			),
		},
	},
	lower_render_layer = "floor",
	lower_pictures = util.sprite_load(
		"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-faded-lower",
		{ scale = 0.5, variation_count = 5, multiply_shift = 0.5, shift = { 5, 0 } }
	),
	stateless_visualisation_variations = {
		chimney_gas_animation_faded({ 0.3, -3.5 }),
		chimney_gas_animation_faded({ -0.3, -2.3 }),
		chimney_gas_animation_faded({ -0.5, -1.4 }),
		chimney_gas_animation_faded({ 0.2, -3.8 }),
		chimney_gas_animation_faded({ 0.2, -2 }),
	},
}

-- Tenebris short chimney (small rock formation, no gas)
local tenebris_sulfur_chimney_short = {
	name = "tenebris-sulfur-chimney-short",
	type = "simple-entity",
	flags = { "placeable-neutral", "placeable-off-grid" },
	icon = "__space-age__/graphics/icons/vulcanus-chimney-short.png",
	subgroup = "grass",
	order = "t[tenebris]-e[sulfur]-j[chimney-short]",
	collision_box = { { -0.9, -0.7 }, { 0.9, 0.7 } },
	selection_box = { { -1, -0.8 }, { 1, 0.8 } },
	collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
	render_layer = "object",
	max_health = 300,
	autoplace = {
		order = "a[landscape]-c[chimney]-t[tenebris]-e[short]",
		probability_expression = "tenebris_sulfur_chimney_short_probability",
	},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 2,
		results = {
			{ type = "item", name = "stone", amount_min = 6, amount_max = 12 },
		},
	},
	resistances = {
		{ type = "fire", percent = 100 },
	},
	map_color = { 129, 105, 78 },
	count_as_rock_for_filtered_deconstruction = true,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	impact_category = "stone",
	pictures = {
		layers = {
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-short-upper",
				{ scale = 0.5, variation_count = 7, multiply_shift = 0.5 }
			),
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-short-shadow",
				{ scale = 0.5, variation_count = 7, multiply_shift = 0.5, draw_as_shadow = true }
			),
		},
	},
	lower_render_layer = "floor",
	lower_pictures = util.sprite_load(
		"__space-age__/graphics/decorative/vulcanus-chimney/sulfuric-chimney-short-lower",
		{ scale = 0.5, variation_count = 7, multiply_shift = 0.5 }
	),
}

-- Tenebris chimney fire (spawned when active chimneys are destroyed)
-- Long-lasting fire that damages players - like ash tree fire but longer duration
local fireutil = require("__base__.prototypes.fire-util")

local tenebris_chimney_fire = fireutil.add_basic_fire_graphics_and_effects_definitions({
	type = "fire",
	name = "tenebris-chimney-fire",
	localised_name = { "entity-name.fire-flame" },
	flags = { "placeable-off-grid", "not-on-map" },
	hidden = true,

	-- Damage configuration
	damage_per_tick = { amount = 20 / 60, type = "fire" }, -- 20 damage per second (dangerous!)
	maximum_damage_multiplier = 4,
	damage_multiplier_increase_per_added_fuel = 0.5,
	damage_multiplier_decrease_per_tick = 0.002,

	-- Self-replicate to keep fire going
	spawn_entity = "tenebris-chimney-fire",
	maximum_spread_count = 30, -- Limited spreading

	-- Slow spreading
	spread_delay = 600, -- 10 seconds between spread attempts
	spread_delay_deviation = 300,

	-- Long-lasting fire (5 minutes base, can grow to 15 minutes)
	initial_lifetime = 60 * 60 * 5, -- 5 minutes
	lifetime_increase_by = 60 * 60 * 2, -- +2 minutes per fuel
	lifetime_increase_cooldown = 10,
	maximum_lifetime = 60 * 60 * 15, -- 15 minutes max

	emissions_per_second = { pollution = 0.01 },

	fade_in_duration = 60,
	fade_out_duration = 120,
	smoke_fade_in_duration = 60,
	smoke_fade_out_duration = 120,
	delay_between_initial_flames = 15,

	-- Tint the fire with cinnabar/volcanic colors
	flame_alpha = 0.6,
	flame_alpha_deviation = 0.1,

	tree_dying_factor = 0.5,
})

-- Tenebris cold/extinct chimney (no gas, uses base game cold assets)
local tenebris_sulfur_chimney_cold = {
	name = "tenebris-sulfur-chimney-cold",
	type = "simple-entity",
	flags = { "placeable-neutral", "placeable-off-grid" },
	icon = "__space-age__/graphics/icons/vulcanus-chimney-cold.png",
	subgroup = "grass",
	order = "t[tenebris]-e[sulfur]-i[chimney-cold]",
	collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
	selection_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
	drawing_box_vertical_extension = 2,
	render_layer = "object",
	collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
	max_health = 500,
	autoplace = {
		order = "a[landscape]-c[chimney]-t[tenebris]-d[cold]",
		probability_expression = "tenebris_sulfur_chimney_cold_probability",
	},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 2,
		results = {
			{ type = "item", name = "stone", amount_min = 9, amount_max = 15 },
		},
	},
	resistances = {
		{ type = "fire", percent = 100 },
	},
	map_color = { 129, 105, 78 },
	count_as_rock_for_filtered_deconstruction = true,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	impact_category = "stone",
	pictures = {
		layers = {
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/cold-chimney-upper",
				{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, shift = { 5, 0 } }
			),
			util.sprite_load(
				"__space-age__/graphics/decorative/vulcanus-chimney/cold-chimney-shadow",
				{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, draw_as_shadow = true, shift = { 5, 0 } }
			),
		},
	},
	lower_render_layer = "floor",
	lower_pictures = util.sprite_load(
		"__space-age__/graphics/decorative/vulcanus-chimney/cold-chimney-lower",
		{ scale = 0.5, variation_count = 3, multiply_shift = 0.5, shift = { 5, 0 } }
	),
}

-- Helper to load decal pictures (from space-age)
local function get_decal_pictures(base_path, suffix, size, count, tint)
	local pics = {}
	for i = 1, count do
		local idx = string.format("%02d", i)
		table.insert(pics, {
			filename = base_path .. idx .. suffix .. ".png",
			width = size,
			height = size,
			scale = 0.5,
			tint = tint,
		})
	end
	return pics
end

-- Tenebris sulfur stain (large)
local tenebris_sulfur_stain = {
	name = "tenebris-sulfur-stain",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-a[stain]",
	collision_box = { { -3, -3 }, { 3, 3 } },
	collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true },
	render_layer = "decals",
	tile_layer = decal_tile_layer - 6,
	autoplace = {
		order = "d[ground-surface]-c[stain]-t[tenebris]-a[large]",
		probability_expression = "tenebris_sulfur_stain_probability",
	},
	pictures = get_decal_pictures(
		"__space-age__/graphics/decorative/sulfur-stain/sulfur-stain-",
		"",
		512,
		13,
		CINNABAR_TINT
	),
}

-- Tenebris sulfur stain small
local tenebris_sulfur_stain_small = {
	name = "tenebris-sulfur-stain-small",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-b[stain-small]",
	collision_box = { { -3, -3 }, { 3, 3 } },
	collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true },
	render_layer = "decals",
	tile_layer = decal_tile_layer - 6,
	autoplace = {
		order = "d[ground-surface]-c[stain]-t[tenebris]-b[small]",
		probability_expression = "tenebris_sulfur_stain_small_probability",
	},
	pictures = get_decal_pictures(
		"__space-age__/graphics/decorative/sulfur-stain/sulfur-stain-spotty-",
		"",
		512,
		21,
		CINNABAR_TINT
	),
}

-- Tenebris sulfuric acid puddle
local tenebris_sulfuric_puddle = {
	name = "tenebris-sulfuric-puddle",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-c[puddle]",
	collision_box = { { -2, -2 }, { 2, 2 } },
	collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true },
	render_layer = "decals",
	tile_layer = 254,
	walking_sound = base_tile_sounds.walking.oil({}),
	autoplace = {
		order = "d[ground-surface]-a[puddle]-t[tenebris]-a[large]",
		placement_density = 2,
		probability_expression = "tenebris_sulfuric_acid_puddle_probability",
	},
	pictures = get_decal_pictures(
		"__space-age__/graphics/decorative/sulfuric-acid-puddle/sulfuric-acid-puddle-",
		"",
		384,
		8,
		CINNABAR_TINT
	),
}

-- Tenebris sulfuric acid puddle small
local tenebris_sulfuric_puddle_small = {
	name = "tenebris-sulfuric-puddle-small",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-d[puddle-small]",
	collision_box = { { -1, -1 }, { 1, 1 } },
	collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true },
	render_layer = "decals",
	tile_layer = 254,
	walking_sound = base_tile_sounds.walking.oil({}),
	autoplace = {
		order = "d[ground-surface]-a[puddle]-t[tenebris]-b[small]",
		placement_density = 2,
		probability_expression = "tenebris_sulfuric_acid_puddle_small_probability",
	},
	pictures = get_decal_pictures(
		"__space-age__/graphics/decorative/sulfuric-acid-puddle/sulfuric-acid-puddle-small-",
		"",
		192,
		4,
		CINNABAR_TINT
	),
}

-- Tenebris small sulfur rock (dimensions from Vulcanus)
local tenebris_small_sulfur_rock = {
	name = "tenebris-small-sulfur-rock",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-e[rock-small]",
	collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
	render_layer = "decorative",
	walking_sound = base_tile_sounds.walking.pebble,
	autoplace = {
		order = "d[ground-surface]-b[sulfur-rock]-t[tenebris]-a[small]",
		placement_density = 2,
		probability_expression = "tenebris_small_sulfur_rock_probability",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-01.png",
			width = 51,
			height = 37,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0546875, 0.117188 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-02.png",
			width = 52,
			height = 35,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0390625, 0.078125 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-03.png",
			width = 46,
			height = 42,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.0078125, 0.148438 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-04.png",
			width = 53,
			height = 33,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0234375, 0.15625 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-05.png",
			width = 47,
			height = 46,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0390625, 0.140625 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-06.png",
			width = 62,
			height = 41,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.03125, 0.09375 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-07.png",
			width = 64,
			height = 36,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.015625, 0.0703125 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-08.png",
			width = 65,
			height = 31,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.71875, -0.164062 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-09.png",
			width = 46,
			height = 34,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.0859375, 0.101562 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-10.png",
			width = 48,
			height = 34,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0078125, 0.125 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-11.png",
			width = 51,
			height = 33,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { -0.0859375, 0.078125 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-12.png",
			width = 47,
			height = 39,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.078125, 0.117188 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-13.png",
			width = 43,
			height = 33,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0.09375 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-14.png",
			width = 43,
			height = 30,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.046875, 0.140625 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-15.png",
			width = 41,
			height = 37,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0.140625 },
		},
		{
			filename = "__space-age__/graphics/decorative/small-volcanic-rock/small-volcanic-rock-16.png",
			width = 46,
			height = 33,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0.0234375, 0.125 },
		},
	},
}

-- Tenebris tiny sulfur rock (dimensions from Vulcanus)
local tenebris_tiny_sulfur_rock = {
	name = "tenebris-tiny-sulfur-rock",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-f[rock-tiny]",
	collision_box = { { -0.8, -0.8 }, { 0.8, 0.8 } },
	render_layer = "decorative",
	walking_sound = base_tile_sounds.walking.pebble,
	autoplace = {
		order = "d[ground-surface]-b[sulfur-rock]-t[tenebris]-c[tiny]",
		placement_density = 5,
		probability_expression = "tenebris_tiny_sulfur_rock_probability",
	},
	pictures = {
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-01.png",
			width = 29,
			height = 21,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-02.png",
			width = 30,
			height = 19,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-03.png",
			width = 29,
			height = 24,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-04.png",
			width = 32,
			height = 20,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-05.png",
			width = 29,
			height = 25,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-06.png",
			width = 36,
			height = 24,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-07.png",
			width = 78,
			height = 34,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-08.png",
			width = 35,
			height = 19,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-09.png",
			width = 28,
			height = 20,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-10.png",
			width = 29,
			height = 20,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-11.png",
			width = 29,
			height = 20,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-12.png",
			width = 29,
			height = 22,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-13.png",
			width = 27,
			height = 19,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-14.png",
			width = 27,
			height = 19,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-15.png",
			width = 26,
			height = 22,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
		{
			filename = "__space-age__/graphics/decorative/tiny-volcanic-rock/tiny-volcanic-rock-16.png",
			width = 27,
			height = 20,
			tint_as_overlay = true,
			tint = SULFUR_ROCK_TINT,
			scale = 0.5,
			shift = { 0, 0 },
		},
	},
}

-- Tenebris sulfur rock cluster
local tenebris_sulfur_rock_cluster = {
	name = "tenebris-sulfur-rock-cluster",
	type = "optimized-decorative",
	order = "t[tenebris]-e[sulfur]-g[rock-cluster]",
	collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
	render_layer = "decorative",
	walking_sound = base_tile_sounds.walking.pebble,
	autoplace = {
		order = "d[ground-surface]-b[sulfur-rock]-t[tenebris]-b[cluster]",
		placement_density = 2,
		probability_expression = "tenebris_sulfur_rock_cluster_probability",
	},
	pictures = get_decal_pictures(
		"__space-age__/graphics/decorative/tiny-volcanic-rock-cluster/tiny-volcanic-rock-cluster-",
		"",
		128,
		8,
		SULFUR_TINT
	),
}

data:extend({
	-- Lowlands
	tenebris_nerve_roots,
	tenebrace_cup,
	tenebrace_mycelium,
	-- Mercury shores
	tenebris_mercury_stain,
	tenebris_mercury_coral,
	-- Wastes (dunes)
	tenebris_sand_dune_decal,
	tenebris_waves_decal,
	-- Highlands
	tenebris_highland_roots,
	tenebris_mycelium,
	-- Sulfur pits
	tenebris_sulfur_stain,
	tenebris_sulfur_stain_small,
	tenebris_sulfuric_puddle,
	tenebris_sulfuric_puddle_small,
	tenebris_small_sulfur_rock,
	tenebris_tiny_sulfur_rock,
	tenebris_sulfur_rock_cluster,
	tenebris_sulfur_chimney,
	tenebris_sulfur_chimney_faded,
	tenebris_sulfur_chimney_cold,
	tenebris_sulfur_chimney_short,
	tenebris_sulfur_chimney_truncated,
	tenebris_chimney_fire,
})
