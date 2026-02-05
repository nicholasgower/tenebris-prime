local sounds = require("__base__.prototypes.entity.sounds")
local resource_autoplace = require("resource-autoplace")
local constants = require("__tenebris-prime__.lib.constants")

resource_autoplace.initialize_patch_set("tenebris-exposed-lichen-deposit", true)

data:extend({
	{
		type = "resource",
		name = "tenebris-exposed-lichen-deposit",
		icons = constants.LICHEN_DEPOSIT_ICONS,
		flags = { "placeable-neutral" },
		subgroup = "tenebris-minerals",
		order = "t[tenebris]-a[tenebris-exposed-lichen-deposit]",
		hidden = true,
		hidden_in_factoriopedia = false,
		infinite = false,
		minimum = 2000,
		normal = 10000,
		highlight = false,
		tree_removal_probability = 0.8,
		tree_removal_max_distance = 32 * 32,

		minable = {
			mining_particle = "stone-particle",
			mining_time = 1,
			results = {
				{
					type = "item",
					name = "tenecap-spore",
					amount = 1,
					probability = 29.9 / 100,
				},
				{
					type = "item",
					name = "spoilage",
					amount = 2,
					probability = 33.998 / 100,
				},
				{
					type = "item",
					name = "tenebris-chitin",
					amount = 10,
					probability = 0.002 / 100,
				},
				{
					type = "item",
					name = "stone",
					amount = 1,
					probability = 22 / 100,
				},
				{
					type = "item",
					name = "carbon",
					amount = 1,
					probability = 14 / 100,
				},
				{
					type = "item",
					name = "calcite",
					amount = 2,
					probability = 0.1 / 100,
				},
			},
		},
		category = "basic-solid",
		walking_sound = sounds.ore,
		collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
		selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
		randomize_visual_position = true,
		-- Use resource_autoplace for proper ore patch clustering
		autoplace = resource_autoplace.resource_autoplace_settings({
			name = "tenebris-exposed-lichen-deposit",
			order = "t[tenebris]-a",
			base_density = 8,
			base_spots_per_km2 = 2.5,
			has_starting_area_placement = true,
			regular_rq_factor_multiplier = 1.2,
			starting_rq_factor_multiplier = 1.5,
			-- Restrict to highlands and wastes using spot_favorability
			-- This makes patches favor these biomes
			ideal_aux = 0.5,
			aux_range = 0.5,
		}),
		stage_counts = { 0 },
		stages = {
			sheet = {
				filename = "__tenebris-prime__/graphics/entity/lichen-deposit/lichen-deposit.png",
				priority = "extra-high",
				size = 128,
				frame_count = 8,
				variation_count = 1,
				scale = 0.5,
			},
		},
		map_color = { r = 170, g = 51, b = 229, a = 255 },
		mining_visualisation_tint = { r = 180, g = 120, b = 190, a = 255 },
		map_grid = true,
	},
})
