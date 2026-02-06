-- =============================================================================
-- QUARTZ FOREST ENTITIES
-- =============================================================================
--
-- ENTITY FLOW DIAGRAM:
--
--   ┌─────────────────────────────────────────────────────────────────────────┐
--   │                    QUARTZ FOREST ORTET (Parent Spawner)                 │
--   │                                                                         │
--   │  ┌─────────────┐         ┌──────────────────────┐                       │
--   │  │   SPAWNS    │────────▶│ hidden-spawn-unit    │                       │
--   │  └─────────────┘         │ (dies immediately)   │                       │
--   │                          └──────────┬───────────┘                       │
--   │                                     │ on_entity_died                    │
--   │                                     ▼                                   │
--   │                          ┌──────────────────────┐                       │
--   │                          │ QUARTZ ORTET BUD     │                       │
--   │                          │ (plant + hidden      │                       │
--   │                          │  spawner composite)  │                       │
--   │                          └──────────────────────┘                       │
--   │                                                                         │
--   │  ┌─────────────┐         ┌──────────────────────┐                       │
--   │  │   CAPTURE   │────────▶│ ortet-capture-proxy  │                       │
--   │  └─────────────┘         │ (dies immediately)   │                       │
--   │                          └──────────┬───────────┘                       │
--   │                                     │ on_entity_died                    │
--   │                                     ▼                                   │
--   │                          ┌──────────────────────┐                       │
--   │                          │ PIEZOELECTRIC        │                       │
--   │                          │ GENERATOR (Tier 4)   │                       │
--   │                          └──────────────────────┘                       │
--   └─────────────────────────────────────────────────────────────────────────┘
--
--   ┌─────────────────────────────────────────────────────────────────────────┐
--   │                         QUARTZ ORTET BUD (Composite)                    │
--   │                                                                         │
--   │  Main: plant (visible, shows growth animation)                          │
--   │  Hidden: spawner (handles capture rocket targeting)                     │
--   │                                                                         │
--   │  ┌─────────────┐         ┌──────────────────────┐                       │
--   │  │   CAPTURE   │────────▶│ bud-capture-proxy    │                       │
--   │  └─────────────┘         │ (dies immediately)   │                       │
--   │                          └──────────┬───────────┘                       │
--   │                                     │ on_entity_died                    │
--   │                                     ▼                                   │
--   │                          ┌──────────────────────┐                       │
--   │                          │ PIEZOELECTRIC        │                       │
--   │                          │ GENERATOR            │                       │
--   │                          │ (Tier based on       │                       │
--   │                          │  bud maturity)       │                       │
--   │                          └──────────────────────┘                       │
--   └─────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================

require("__base__.prototypes.entity.enemy-constants")
require("__base__.prototypes.entity.biter-animations")
require("__base__.prototypes.entity.spitter-animations")
require("__base__.prototypes.entity.spawner-animation")

local enemy_autoplace = require("__base__.prototypes.entity.enemy-autoplace-utils")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local constants = require("lib.constants")

-- =============================================================================
-- CAPTURE ROCKET TARGETING
-- =============================================================================
-- Target filter modifications are in data-updates.lua to ensure space-age is loaded

-- =============================================================================
-- HELPER: Auto-dying proxy unit template
-- =============================================================================
-- These proxies exist only to trigger on_entity_died events.
-- They die in 1 tick due to healing_per_tick = -1.
local function create_capture_proxy(name)
	return {
		type = "unit",
		name = name,
		icon = "__base__/graphics/icons/small-electric-pole.png",
		icon_size = 64,
		flags = {
			"placeable-neutral",
			"not-on-map",
			"not-blueprintable",
			"not-deconstructable",
			"not-in-kill-statistics",
		},
		max_health = 1,
		healing_per_tick = -1, -- Dies in 1 tick
		collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
		collision_mask = { layers = {} },
		selection_box = { { 0, 0 }, { 0, 0 } },
		selectable_in_game = false,
		hidden = true,
		hidden_in_factoriopedia = true,
		movement_speed = 0,
		distance_per_frame = 0,
		distraction_cooldown = 0,
		vision_distance = 0,
		run_animation = {
			filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
			width = 1,
			height = 1,
		},
		attack_parameters = {
			type = "beam",
			range = 0,
			cooldown = 0,
			ammo_type = { target_type = "entity" },
			ammo_category = "melee",
			animation = {
				filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
				width = 1,
				height = 1,
			},
		},
	}
end

data.extend({

	-- =============================================================================
	-- 1. QUARTZ FOREST ORTET (Parent Spawner)
	-- =============================================================================
	-- The main spawner entity. Spawns hidden units that die to create buds.
	-- When captured, creates a Tier 4 Piezoelectric Generator.
	{
		type = "unit-spawner",
		name = "tenebris-quartz-forest-ortet",
		icon = "__base__/graphics/icons/biter-spawner.png",
		flags = { "placeable-enemy", "not-repairable" },
		max_health = 3200,
		order = "t[tenebris]-ortet-spawner",
		subgroup = "enemies",
		resistances = {
			{ type = "physical", decrease = 50, percent = 50 },
			{ type = "explosion", decrease = 5, percent = -60 },  -- Weak to explosives
			{ type = "fire", percent = 100 },
			{ type = "laser", decrease = 30, percent = 70 },
			{ type = "electric", percent = 100 },
			{ type = "acid", percent = 100 },
			{ type = "poison", percent = 100 },
		},
		working_sound = {
			sound = {
				filename = "__base__/sound/express-transport-belt.ogg",
				volume = 0.35,
				audible_distance_modifier = 0.5,
			},
			fade_in_ticks = 4,
			fade_out_ticks = 20,
			max_sounds_per_prototype = 3,
		},
		dying_sound = {
			variations = sound_variations(
				"__base__/sound/fight/large-explosion",
				2,
				0.8
			),
			aggregation = { max_count = 2, remove = true, count_already_playing = true },
		},
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		map_generator_bounding_box = { { -3.7, -3.2 }, { 3.7, 3.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		damaged_trigger_effect = hit_effects.biter(),
		impact_category = "stone",
		absorptions_per_second = { pollution = { absolute = 20, proportional = 0.01 } },
		corpse = "biter-spawner-corpse",
		dying_explosion = "biter-spawner-die",
		-- Cyan crystal glow effect
		integration_patch_render_layer = "light-effect",
		integration_patch = {
			filename = "__tenebris-prime__/graphics/icons/item-glow.png",
			size = 64,
			scale = 30,
			draw_as_light = true,
			tint = { r = 0.4, g = 0.9, b = 1.0, a = 0.8 },
		},
		graphics_set = {
			animations = {
				{
					filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-1.png",
					width = 256,
					height = 256,
					frame_count = 1,
					scale = 1.5,
					tint = { 0.3, 0.9, 1.0, 0.9 },
					draw_as_glow = true,
				},
				{
					filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
					width = 256,
					height = 256,
					frame_count = 1,
					scale = 1.5,
					tint = { 0.3, 0.9, 1.0, 0.9 },
					draw_as_glow = true,
				},
				{
					filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-3.png",
					width = 256,
					height = 256,
					frame_count = 1,
					scale = 1.5,
					tint = { 0.3, 0.9, 1.0, 0.9 },
					draw_as_glow = true,
				},
				{
					filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-4.png",
					width = 256,
					height = 256,
					frame_count = 1,
					scale = 1.5,
					tint = { 0.3, 0.9, 1.0, 0.9 },
					draw_as_glow = true,
				},
			},
		},
		-- Spawns hidden units that die immediately to create buds
		result_units = {
			{
				unit = "tenebris-quartz-ortet-bud-hidden-spawn-unit",
				spawn_points = { { evolution_factor = 0, spawn_weight = 1 } },
			},
		},
		max_count_of_owned_units = 7,
		max_friends_around_to_spawn = 5,
		spawning_cooldown = { 2000, 4000 },
		spawning_radius = 25,
		spawning_spacing = 8,
		max_spawn_shift = 25, -- Must match spawning_radius for actual spread
		max_richness_for_spawn_shift = 100,
		-- No autoplace - spawned via script only
		call_for_help_radius = 0,
		time_to_capture = 60 * 80, -- 80 seconds
		spawn_decorations_on_expansion = true,
		spawn_decoration = {},
		-- Capture creates proxy → dies → on_entity_died → Tier 4 generator
		captured_spawner_entity = "tenebris-quartz-ortet-capture-proxy",
		-- Autoplace: sparse placement within highlands plateau subbiomes
		-- ~500 tiles apart, larger plateaus may get 2
		autoplace = {
			control = "tenebris_plants",
			order = "z[tenebris]-a[ortet]",
			probability_expression = "tenebris_ortet_probability",
			tile_restriction = {
				"tenebris-debug-highlands-plateaus",
			},
		},
		map_color = constants.TINT.CYAN,
	},

	-- =============================================================================
	-- 2. HIDDEN SPAWN UNIT (Bud Creation Trigger)
	-- =============================================================================
	-- Spawned by the ortet, dies immediately (healing_per_tick = -1).
	-- Death triggers on_entity_died → script creates bud composite.
	{
		type = "unit",
		name = "tenebris-quartz-ortet-bud-hidden-spawn-unit",
		icon = "__base__/graphics/icons/small-biter.png",
		flags = { "placeable-neutral", "not-on-map", "not-repairable", "not-flammable", "not-in-kill-statistics" },
		max_health = 1,
		healing_per_tick = -1, -- Dies in 1 tick → triggers on_entity_died
		hidden = true,
		hidden_in_factoriopedia = true,
		movement_speed = 0,
		distance_per_frame = 0,
		distraction_cooldown = 0,
		vision_distance = 0,
		run_animation = {
			filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
			width = 1,
			height = 1,
		},
		attack_parameters = {
			type = "beam",
			range = 0,
			cooldown = 0,
			ammo_type = { target_type = "entity" },
			ammo_category = "melee",
			animation = {
				filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
				width = 1,
				height = 1,
			},
		},
	},

	-- =============================================================================
	-- 3. QUARTZ ORTET BUD - COMPOSITE ENTITY
	-- =============================================================================
	-- Composite: Plant (visible) + Hidden Spawner (capture target)
	-- When captured, tier is based on bud maturity (tracked by spawn time).

	-- 3a. Plant (visible component, shows growth animation)
	{
		type = "plant",
		name = "tenebris-quartz-ortet-bud",
		icon = "__space-age__/graphics/icons/yumako-tree.png",
		icon_size = 64,
		flags = { "placeable-neutral", "not-repairable", "breaths-air", "not-selectable-in-game" },
		selectable_in_game = false, -- Spawner is the selectable interface
		minable = {
			mining_particle = "stone-particle",
			mining_time = 1.0,
			results = { { type = "item", name = "stone", amount = 2 } },
		},
		max_health = 50,
		collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
		selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
		subgroup = "trees",
		order = "z[tenebris]-a[quartz-bud]",
		growth_ticks = 5 * 60 * 60, -- 5 minutes to full maturity
		-- NOTE: Buds are spawned programmatically around ortets via scripts/quartz_forest/map_generation.lua
		-- This gives us control over spacing (50+ tiles) and count (1-10 based on distance from spawn)
		emissions_per_second = { spores = -0.001 },
		-- Visible graphics (spawner is invisible but selectable)
		-- Cyan crystal glow effect
		integration_patch_render_layer = "light-effect",
		integration_patch = {
			filename = "__tenebris-prime__/graphics/icons/item-glow.png",
			size = 64,
			scale = 7,
			draw_as_light = true,
			tint = { r = 0.4, g = 0.9, b = 1.0, a = 0.6 },
		},
		pictures = {
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-1.png",
				width = 256,
				height = 256,
				scale = 0.5,
				tint = { 0.3, 0.9, 1.0, 0.9 },
				draw_as_glow = true,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
				width = 256,
				height = 256,
				scale = 0.5,
				tint = { 0.3, 0.9, 1.0, 0.9 },
				draw_as_glow = true,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-3.png",
				width = 256,
				height = 256,
				scale = 0.5,
				tint = { 0.3, 0.9, 1.0, 0.9 },
				draw_as_glow = true,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-4.png",
				width = 256,
				height = 256,
				scale = 0.5,
				tint = { 0.3, 0.9, 1.0, 0.9 },
				draw_as_glow = true,
			},
		},
		map_color = constants.TINT.CYAN_DULL,
		colors = {
			{ r = 255, g = 255, b = 255 },
			{ r = 220, g = 255, b = 255 },
			{ r = 255, g = 220, b = 255 },
		},
		agricultural_tower_tint = {
			primary = { r = 0.7, g = 0.9, b = 0.3, a = 1 },
			secondary = { r = 0.5, g = 0.8, b = 0.2, a = 1 },
		},
	},

	-- 3b. Spawner (interface entity - handles capture rocket targeting)
	{
		type = "unit-spawner",
		name = "tenebris-quartz-ortet-bud-spawner",
		icon = "__space-age__/graphics/icons/yumako-tree.png",
		icon_size = 64,
		hidden_in_factoriopedia = true,
		flags = { "placeable-neutral", "not-repairable", "not-blueprintable", "not-deconstructable" },
		selectable_in_game = true, -- Interface entity - capture rockets target this
		max_health = 50,
		collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
		selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
		-- Spawner settings - never actually spawns (infinite cooldown)
		absorptions_per_second = { pollution = { absolute = 0, proportional = 0 } },
		corpse = nil,
		dying_explosion = nil,
		max_count_of_owned_units = 0,
		max_friends_around_to_spawn = 0,
		spawning_cooldown = { 999999, 999999 },
		spawning_radius = 0,
		spawning_spacing = 0,
		max_spawn_shift = 0,
		max_richness_for_spawn_shift = 100,
		result_units = {
			{
				unit = "tenebris-quartz-ortet-bud-dummy-unit",
				spawn_points = { { evolution_factor = 0, spawn_weight = 1 } },
			},
		},
		call_for_help_radius = 0,
		time_to_capture = 60 * 30, -- 30 seconds (faster than ortet)
		-- Capture creates proxy → dies → on_entity_died → generator based on maturity
		captured_spawner_entity = "tenebris-quartz-ortet-bud-capture-proxy",
		-- Invisible - plant provides the graphics, spawner handles selection/capture
		graphics_set = {},
		map_color = constants.TINT.CYAN_DULL,
	},

	-- =============================================================================
	-- 4. CAPTURE PROXIES (Auto-die to trigger on_entity_died)
	-- =============================================================================

	-- Ortet capture → Tier 4 generator
	create_capture_proxy("tenebris-quartz-ortet-capture-proxy"),

	-- Bud capture → Generator based on maturity
	create_capture_proxy("tenebris-quartz-ortet-bud-capture-proxy"),

	-- =============================================================================
	-- 5. DUMMY UNITS (Required by spawner prototypes, never used)
	-- =============================================================================

	-- Required by bud-spawner's result_units (never spawns due to infinite cooldown)
	{
		type = "unit",
		name = "tenebris-quartz-ortet-bud-dummy-unit",
		icon = "__base__/graphics/icons/small-biter.png",
		flags = { "placeable-neutral", "not-on-map", "not-repairable", "not-flammable", "not-in-kill-statistics" },
		max_health = 1,
		healing_per_tick = -1,
		hidden = true,
		hidden_in_factoriopedia = true,
		collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
		collision_mask = { layers = {} },
		movement_speed = 0,
		distance_per_frame = 0,
		distraction_cooldown = 0,
		vision_distance = 0,
		run_animation = {
			filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
			width = 1,
			height = 1,
		},
		attack_parameters = {
			type = "beam",
			range = 0,
			cooldown = 0,
			ammo_type = { target_type = "entity" },
			ammo_category = "melee",
			animation = {
				filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
				width = 1,
				height = 1,
			},
		},
	},
})
