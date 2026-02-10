local plant_flags = { "placeable-neutral", "placeable-off-grid", "breaths-air" }
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")
local sounds = require("__base__.prototypes.entity.sounds")
local constants = require("lib.constants")
local bioluminescent = require("lib.bioluminescent")
local TINT = constants.TINT

local seconds = 60
local minutes = 60 * seconds

-- Convenience aliases
local make_bioluminescent_particle = bioluminescent.make_particle
local make_bioluminescent_light = bioluminescent.make_light

data:extend({
	{
		type = "plant",
		name = "glowdentale",
		icon = "__space-age__/graphics/icons/stingfrond.png",
		flags = plant_flags,
		growth_ticks = 2 * minutes,
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 0.5,
			results = {
				{ name = "luciferin", type = "item", amount_min = 0, amount_max = 2 },
			},
		},
		mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-funneltrunk", 5, 0.5),
		mined_sound = sound_variations("__space-age__/sound/mining/mined-funneltrunk", 5, 0.4),
		max_health = 50,
		collision_box = { { -0.1, -0.2 }, { 0.1, 0.1 } },
		selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
		drawing_box_vertical_extension = 0.8,
		subgroup = "trees",
		order = "t[tenebris]-a[glowdentale]",
		impact_category = "tree",
		-- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

		pictures = {
			{
				size = 500,
				scale = 0.15,
				filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-1.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.15,
				filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-2.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.15,
				filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-3.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.15,
				filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-4.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
		},

		-- Separate visualisations with irrational periods so they never sync
		-- Using stateless_visualisation (not _variations) so ALL entries render simultaneously
		stateless_visualisation = {
			make_bioluminescent_light(8, 0.3), -- Static ambient glow on plant
			make_bioluminescent_particle({ 0, -0.2 }, 100 * math.pi, { 0.1, 0.3 }, 0.6, 1),
			make_bioluminescent_particle({ -0.4, -0.5 }, 100 * math.exp(1), { 0.1, 0.3 }, 0.6, 1),
			make_bioluminescent_particle({ 0.4, -0.4 }, 100 * math.sqrt(13), { 0.1, 0.3 }, 0.6, 1),
		},

		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-a",
			-- Glowdentale grows in highlands, with 2.5x density boost in hollows
			probability_expression = "tenebris_glowdentale_probability * control:tenebris_plants:size",
			richness_expression = "random_penalty_at(3, 1)",
			tile_restriction = {
				"tenebris-blue-highlands",
				"tenebris-grey-highlands",
			},
		},
	},
	{
		type = "plant",
		name = "lucifunnel",
		icon = "__space-age__/graphics/icons/stingfrond.png",
		flags = plant_flags,
		growth_ticks = 5 * minutes,
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 0.5,
			results = {
				{ name = "lucifunnel", type = "item", amount_min = 10, amount_max = 30 },
			},
		},
		mining_sound = sound_variations("__space-age__/sound/mining/mining-cuttlepop", 6, 0.5),
		mined_sound = sound_variations("__space-age__/sound/mining/mined-cuttlepop", 5, 0.4),
		max_health = 50,
		collision_box = { { -0.6, -0.8 }, { 0.6, 0.8 } },
		selection_box = { { -0.6, -0.8 }, { 0.6, 0.8 } },
		drawing_box_vertical_extension = 0.8,
		subgroup = "trees",
		order = "t[tenebris]-b[lucifunnel]",
		impact_category = "tree",
		-- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

		pictures = {
			{
				size = 500,
				scale = 0.3,
				filename = "__tenebris-prime__/graphics/entity/lucifunnel-1.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.3,
				filename = "__tenebris-prime__/graphics/entity/lucifunnel-2.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.3,
				filename = "__tenebris-prime__/graphics/entity/lucifunnel-3.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
			{
				size = 500,
				scale = 0.3,
				filename = "__tenebris-prime__/graphics/entity/lucifunnel-4.png",
				draw_as_glow = true,
				shift = { 0, -0.5 },
			},
		},

		-- Separate visualisations with irrational periods so they never sync
		-- Using stateless_visualisation (not _variations) so ALL entries render simultaneously
		stateless_visualisation = {
			make_bioluminescent_light(12, 0.4), -- Static ambient glow on plant (larger for lucifunnel)
			make_bioluminescent_particle({ 0, -0.3 }, 150 * math.pi, { 0.15, 0.4 }, 1.0, 1.25, 0.2),
			make_bioluminescent_particle({ -0.6, -0.8 }, 150 * math.exp(1), { 0.15, 0.4 }, 1.0, 1.25, 0.2),
			make_bioluminescent_particle({ 0.6, -0.7 }, 150 * math.sqrt(13), { 0.15, 0.4 }, 1.0, 1.25, 0.2),
			make_bioluminescent_particle({ -0.5, 0.2 }, 200 * (1 + math.sqrt(5)) / 2, { 0.15, 0.4 }, 1.0, 1.25, 0.2),
		},

		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-b",
			-- Lucifunnels only grow in highlands
			probability_expression = "tenebris_lucifunnel_probability * control:tenebris_plants:size",
			richness_expression = "random_penalty_at(3, 1)",
			tile_restriction = {
				"tenebris-blue-highlands",
				"tenebris-grey-highlands",
				"overgrowth-luciferin-soil",
			},
		},
	},
	{
		type = "plant",
		name = "tenecap",
		icon = "__space-age__/graphics/icons/stingfrond.png",
		flags = plant_flags,
		growth_ticks = 2 * minutes,
		healing_per_tick = 0.01,
		harvest_emissions = {
			tenecap_spore_clearance = -20,
		},
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 0.5,
			results = {
				{ name = "tenecap", type = "item", amount_min = 1, amount_max = 4 },
			},
			mining_trigger = {
				{
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							-- Large smoke puff when mined
							{
								type = "create-trivial-smoke",
								smoke_name = "smoke-explosion-particle",
								repeat_count = 8,
								starting_frame_deviation = 5,
								offset_deviation = { { -0.8, -0.8 }, { 0.8, 0.8 } },
								speed_from_center = 0.03,
							},
						},
					},
				},
				-- Area poison effect
				{
					type = "area",
					radius = 3,
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "create-sticker",
								sticker = "tenebris-tenebrace-spore-sticker",
							},
						},
					},
				},
			},
		},
		mining_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1),
		mined_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1),
		max_health = 50,
		resistances = {
			{ type = "acid", percent = 100 },
		},
		selection_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
		collision_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
		drawing_box_vertical_extension = 0.8,
		subgroup = "trees",
		order = "t[tenebris]-c[tenecap]",
		impact_category = "tree",
		-- factoriopedia_simulation = simulations.factoriopedia_stingfrond,
		dying_explosion = "tenecap-spore-explosion",
		remains_when_mined = "tenecap-spore-explosion",

		pictures = {
			{
				width = 256,
				height = 259,
				scale = 0.25,
				filename = "__tenebris-prime__/graphics/entity/tenecap-1.png",
				shift = { 0, -0.3 },
			},
			{
				width = 256,
				height = 259,
				scale = 0.25,
				filename = "__tenebris-prime__/graphics/entity/tenecap-2.png",
				shift = { 0, -0.3 },
			},
			{
				width = 256,
				height = 259,
				scale = 0.25,
				filename = "__tenebris-prime__/graphics/entity/tenecap-3.png",
				shift = { 0, -0.3 },
			},
			{
				width = 256,
				height = 259,
				scale = 0.25,
				filename = "__tenebris-prime__/graphics/entity/tenecap-4.png",
				shift = { 0, -0.3 },
			},
		},

		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-c",
			-- Tenecaps only in lowlands
			probability_expression = "tenebris_tenecap_probability * control:tenebris_plants:size",
			richness_expression = "random_penalty_at(3, 1)",
			tile_restriction = {
				"tenebris-lowland-cauliflower",
				"tenebris-lowland-dead-skin",
				"tenebris-lowland-infection",
				"tenebris-lowland-vein-bulges",
				"tenebris-lowland-vein-dead",
				"overgrowth-tenecap-soil",
			},
		},
		created_effect = {
			type = "direct",
			action_delivery = {
				type = "instant",
				source_effects = {
					{
						type = "create-decorative",
						decorative = "tenebrace-cup",
						spawn_min = 1,
						spawn_max = 3,
						spawn_min_radius = 0,
						spawn_max_radius = 2,
					},
					{
						type = "create-decorative",
						decorative = "tenebrace-mycelium",
						spawn_min = 0,
						spawn_max = 2,
						spawn_min_radius = 0,
						spawn_max_radius = 3,
					},
				},
			},
		},
	},
	-- Tenebrace - volatile fungal growths that periodically explode, releasing spores and propagating
	{
		type = "plant",
		name = "tenebrace",
		icons = {
			{ icon = "__space-age__/graphics/icons/sunnycomb.png", tint = TINT.TENEBRACE },
		},
		flags = plant_flags,
		healing_per_tick = 0.05,
		growth_ticks = 10 * minutes, -- Time to regrow if harvested by agricultural tower
		max_health = 200,
		resistances = {
			{ type = "acid", percent = 100 }, -- Immune to own spore damage
		},
		harvest_emissions = {
			tenecap_spore_clearance = -130,
		},
		collision_box = { { -0.6, -0.4 }, { 0.6, 0.4 } }, -- Similar to sunnycomb, slightly smaller for 0.3 scale
		selection_box = { { -0.7, -2.5 }, { 0.7, 0.5 } }, -- Tall selection for the mushroom shape
		subgroup = "trees",
		order = "t[tenebris]-e[tenebrace]",
		impact_category = "organic",
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 2,
			results = {
				{ type = "item", name = "tenecap-spore", amount_min = 4, amount_max = 24 },
				{ type = "item", name = "spoilage", amount_min = 20, amount_max = 30 },
			},
		},
		mining_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1),
		mined_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1),
		dying_explosion = "tenebrace-spore-explosion",
		remains_when_mined = "tenebrace-spore-explosion",
		dying_trigger_effect = {
			-- Spore cloud damages nearby entities
			{
				type = "nested-result",
				action = {
					type = "area",
					radius = 6,
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "create-sticker",
								sticker = "tenebris-mercury-poisoning-sticker",
							},
							{
								type = "damage",
								damage = { amount = 40, type = "acid" },
							},
						},
					},
				},
			},
			-- Propagation handled by scripts/tenebrace_propagation/init.lua
			-- This allows fire to prevent spawning
		},
		ambient_sounds = {
			sound = {
				variations = sound_variations("__space-age__/sound/world/plants/sunnycomb", 8, 0.7),
				advanced_volume_control = {
					fades = {
						fade_in = {
							curve_type = "cosine",
							from = { control = 0.5, volume_percentage = 0.0 },
							to = { 1.5, 100.0 },
						},
					},
				},
			},
			radius = 7.5,
			min_entity_count = 2,
			max_entity_count = 10,
			entity_to_sound_ratio = 0.3,
			average_pause_seconds = 10,
		},
		-- Sunnycomb spritesheet: 5 columns x 2 rows, 640x560 per frame
		-- Original uses shift util.by_pixel(52, -60), same as sunnycomb
		pictures = (function()
			local pics = {}
			local cols, rows = 5, 2
			local w, h = 640, 560
			local img_scale = 0.3
			for row = 0, rows - 1 do
				for col = 0, cols - 1 do
					table.insert(pics, {
						filename = "__space-age__/graphics/entity/plant/sunnycomb/sunnycomb-trunk.png",
						width = w,
						height = h,
						x = col * w,
						y = row * h,
						scale = img_scale,
						shift = util.by_pixel(52, -60), -- Shift is in world coords, not scaled
						tint = TINT.TENEBRACE,
					})
				end
			end
			return pics
		end)(),
		-- Ambient spore/smoke effect floating around the plant
		stateless_visualisation_variations = (function()
			local variations = {}
			local period_1 = math.random(360, 440) * math.pi
			local period_2 = math.random(100, 250) * math.pi
			local fade_in_progress_duration_1 = math.min(40, period_1) / period_1
			local fade_out_progress_duration_1 = math.min(40, period_1) / period_1
			local fade_in_progress_duration_2 = math.min(40, period_2) / period_2
			local fade_out_progress_duration_2 = math.min(40, period_2) / period_2
			for i = 1, 10 do -- One per picture variation
				table.insert(variations, {
					{
						min_count = 1,
						max_count = 3,
						offset_x = { -0.2, 0.2 },
						offset_y = { -0.2, 0.2 },
						positions = { { 0, -1.5 }, { -0.15, -1.4 }, { 0.15, -1.6 } }, -- Tight cluster above plant
						render_layer = "smoke",
						adjust_animation_speed_by_base_scale = true,
						scale = { 0.8, 1.2 },
						animation = {
							{
								filename = "__base__/graphics/entity/smoke/smoke.png",
								width = 152,
								height = 120,
								line_length = 5,
								frame_count = 60,
								animation_speed = 0.12,
								scale = 2.0,
								tint = TINT.TENEBRACE_SMOKE,
								shift = { 0, -1.8 },
								draw_as_glow = true,
							},
						},
						fade_in_progress_duration = fade_in_progress_duration_1,
						fade_out_progress_duration = fade_out_progress_duration_1,
						period = period_1,
					},
					{
						min_count = 1,
						max_count = 3,
						offset_x = { -0.2, 0.2 },
						offset_y = { -0.2, 0.2 },
						positions = { { 0, -1.5 }, { -0.15, -1.4 }, { 0.15, -1.6 } }, -- Tight cluster above plant
						render_layer = "smoke",
						adjust_animation_speed_by_base_scale = true,
						scale = { 0.8, 1.2 },
						animation = {
							{
								filename = "__base__/graphics/entity/smoke/smoke.png",
								width = 152,
								height = 120,
								line_length = 5,
								frame_count = 60,
								animation_speed = 0.12,
								scale = 2.0,
								tint = TINT.TENEBRACE_SMOKE,
								shift = { 0, -1.8 },
								draw_as_glow = true,
							},
						},
						fade_in_progress_duration = fade_in_progress_duration_2,
						fade_out_progress_duration = fade_out_progress_duration_2,
						period = period_2,
					},
				})
			end
			return variations
		end)(),
		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-e",
			probability_expression = "0.01 * tenebris_biome_lowlands",
			tile_restriction = {
				"tenebris-lowland-cauliflower",
				"tenebris-lowland-dead-skin",
				"tenebris-lowland-infection",
				"tenebris-lowland-vein-bulges",
				"tenebris-lowland-vein-dead",
			},
		},
		created_effect = {
			type = "direct",
			action_delivery = {
				type = "instant",
				source_effects = {
					{
						type = "create-decorative",
						decorative = "tenebrace-cup",
						spawn_min = 2,
						spawn_max = 8,
						spawn_min_radius = 0,
						spawn_max_radius = 6,
					},
					{
						type = "create-decorative",
						decorative = "tenebrace-mycelium",
						spawn_min = 1,
						spawn_max = 5,
						spawn_min_radius = 0,
						spawn_max_radius = 8,
					},
				},
			},
		},
	},
	{
		name = "quartz-node",
		type = "plant",
		flags = plant_flags,
		icon = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
		icon_size = 256,
		subgroup = "trees",
		order = "t[tenebris]-d[quartz-node]",
		collision_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		damaged_trigger_effect = hit_effects.rock(),
		max_health = 500,
		growth_ticks = 20 * minutes,
		autoplace = {
			control = "tenebris_plants",
			order = "a[landscape]-c[rock]-b[big]",
			-- Quartz nodes (geodes) only in quartz subbiomes
			probability_expression = "tenebris_quartz_node_probability * control:tenebris_plants:size",
			tile_restriction = {
				"tenebris-wastes-exposed-quartz-01",
				"tenebris-wastes-exposed-quartz-02",
				"tenebris-wastes-exposed-quartz-03",
				"tenebris-wastes-exposed-quartz-04",
				"tenebris-wastes-exposed-quartz-05",
				"tenebris-wastes-exposed-quartz-06",
				"tenebris-wastes-exposed-quartz-07",
				"tenebris-wastes-exposed-quartz-08",
				"tenebris-wastes-exposed-quartz-09",
				"tenebris-wastes-exposed-quartz-10",
				"tenebris-wastes-exposed-quartz-11",
				"tenebris-wastes-exposed-quartz-12",
				"tenebris-wastes-shattered-quartz",
			},
		},
		dying_trigger_effect = decorative_trigger_effects.big_rock(),
		minable = {
			mining_particle = "stone-particle",
			mining_time = 4,
			results = {
				{ type = "item", name = "tenebris-quartz-geode", amount_min = 2, amount_max = 5 },
			},
		},
		mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-iceberg", 7, 0.6),
		mined_sound = sound_variations("__space-age__/sound/mining/mined-iceberg", 4, 0.6),
		resistances = {
			{
				type = "fire",
				percent = 100,
			},
			{
				type = "acid",
				percent = 100,
			},
		},
		map_color = { 195, 195, 195 },
		count_as_rock_for_filtered_deconstruction = true,
		impact_category = "stone",
		pictures = {
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-1.png",
				width = 256,
				height = 256,
				scale = 0.4,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
				width = 256,
				height = 256,
				scale = 0.4,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-3.png",
				width = 256,
				height = 256,
				scale = 0.4,
			},
			{
				filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-4.png",
				width = 256,
				height = 256,
				scale = 0.4,
			},
		},
	},
	{
		type = "plant",
		name = "mercurial-stromatolite",
		icon = "__tenebris-prime__/graphics/icons/mercurial-stromatolite.png",
		icon_size = 64,
		flags = plant_flags,
		growth_ticks = 5 * minutes,
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 0.5,
			results = {
				{ name = "mercurial-archaea", type = "item", amount_min = 10, amount_max = 60 },
				{ name = "tenebris-bismuth-ore", type = "item", amount_min = 1, amount_max = 2, probability = 0.2 },
			},
		},
		mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-stingfrond", 5, 0.5),
		mined_sound = sound_variations("__space-age__/sound/mining/mined-stingfrond", 5, 0.4),
		max_health = 50,
		selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
		collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
		-- Custom collision mask - allows placement on shallow water (mercury tiles)
		collision_mask = {
			layers = { player = true, ground_tile = true, train = true, is_object = true, is_lower_object = true },
		},
		drawing_box_vertical_extension = 0.8,
		subgroup = "trees",
		order = "t[tenebris]-d[mercurial-stromatolite]",
		impact_category = "tree",

		-- Uses pre-colorized mercurial stromatolite graphics with calcite base layer
		pictures = (function()
			local gfx_path = "__tenebris-prime__/graphics/entity/mercurial-stromatolite/"
			local stromatolites = {
				{
					filename = gfx_path .. "stromatolite-01.png",
					width = 209,
					height = 138,
					shift = { 0.304688, -0.4 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-02.png",
					width = 165,
					height = 129,
					shift = { 0.0, 0.0390625 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-03.png",
					width = 151,
					height = 139,
					shift = { 0.151562, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-04.png",
					width = 216,
					height = 110,
					shift = { 0.30625, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-05.png",
					width = 154,
					height = 147,
					shift = { 0.328125, 0.0703125 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-06.png",
					width = 154,
					height = 132,
					shift = { 0.16875, -0.1 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-07.png",
					width = 193,
					height = 130,
					shift = { 0.3, -0.2 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-08.png",
					width = 136,
					height = 117,
					shift = { 0.0, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-09.png",
					width = 157,
					height = 115,
					shift = { 0.1, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-10.png",
					width = 198,
					height = 153,
					shift = { 0.325, -0.1 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-11.png",
					width = 190,
					height = 115,
					shift = { 0.453125, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-12.png",
					width = 229,
					height = 126,
					shift = { 0.539062, -0.015625 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-13.png",
					width = 151,
					height = 125,
					shift = { 0.0703125, 0.179688 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-14.png",
					width = 137,
					height = 117,
					shift = { 0.160938, 0.0 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-15.png",
					width = 201,
					height = 141,
					shift = { 0.242188, -0.195312 },
					scale = 0.4,
				},
				{
					filename = gfx_path .. "stromatolite-16.png",
					width = 209,
					height = 154,
					shift = { 0.351562, -0.1 },
					scale = 0.4,
				},
			}
			local result = {}
			for i, strom in ipairs(stromatolites) do
				-- Pick calcite variation from spritesheet (cycling through first 16)
				local calcite_x = ((i - 1) % 8) * 128
				local calcite_y = math.floor((i - 1) / 8) * 128
				table.insert(result, {
					layers = {
						{
							filename = gfx_path .. "calcite-base.png",
							width = 128,
							height = 128,
							x = calcite_x,
							y = calcite_y,
							scale = 0.7,
						},
						{
							filename = strom.filename,
							width = strom.width,
							height = strom.height,
							shift = strom.shift,
							scale = strom.scale,
						},
					},
				})
			end
			return result
		end)(),
		water_reflection = {
			pictures = {
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-01-effect-map.png",
					width = 96,
					height = 92,
					shift = { 0.304688, -0.3 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-02-effect-map.png",
					width = 78,
					height = 92,
					shift = { 0.0, 0.3 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-03-effect-map.png",
					width = 70,
					height = 91,
					shift = { 0.151562, 0.1 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-04-effect-map.png",
					width = 88,
					height = 94,
					shift = { 0.390625, 0.3 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-05-effect-map.png",
					width = 77,
					height = 92,
					shift = { 0.328125, 0.0703125 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-06-effect-map.png",
					width = 77,
					height = 92,
					shift = { 0.16875, 0.1 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-07-effect-map.png",
					width = 94,
					height = 93,
					shift = { 0.3, 0.0 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-08-effect-map.png",
					width = 63,
					height = 93,
					shift = { 0.0, 0.2 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-09-effect-map.png",
					width = 79,
					height = 93,
					shift = { 0.1, 0.2 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-10-effect-map.png",
					width = 93,
					height = 93,
					shift = { 0.325, -0.1 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-11-effect-map.png",
					width = 95,
					height = 93,
					shift = { 0.453125, 0.2 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-12-effect-map.png",
					width = 92,
					height = 92,
					shift = { 0.3, 0.1 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-13-effect-map.png",
					width = 76,
					height = 93,
					shift = { 0.0703125, 0.3 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-14-effect-map.png",
					width = 63,
					height = 93,
					shift = { 0.160938, 0.2 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-15-effect-map.png",
					width = 101,
					height = 92,
					shift = { 0.242188, -0.1 },
					scale = 0.8,
				},
				{
					filename = "__space-age__/graphics/entity/stromatolite/copper/stromatolite-16-effect-map.png",
					width = 88,
					height = 92,
					shift = { 0.1, -0.1 },
					scale = 0.8,
				},
			},
		},
		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-d",
			-- Stromatolites grow IN and AROUND mercury pools
			probability_expression = "tenebris_stromatolite_probability * control:tenebris_plants:size",
			richness_expression = "random_penalty_at(3, 1)",
			-- Can spawn on mercury tiles and lowland tiles only (not wastes)
			tile_restriction = {
				"tenebris-mercury-tile",
				"tenebris-lowland-cauliflower",
				"tenebris-lowland-dead-skin",
				"tenebris-lowland-infection",
				"tenebris-lowland-vein-bulges",
				"tenebris-lowland-vein-dead",
			},
		},
	},
})

-- Mercurial Stingfrond - desaturated stingfrond that grows in mercury pools
local mercurial_stingfrond_gfx = "__tenebris-prime__/graphics/entity/mercurial-stingfrond/"

data:extend({
	{
		type = "tree",
		name = "mercurial-stingfrond",
		icon = "__tenebris-prime__/graphics/icons/mercurial-stingfrond.png",
		icon_size = 64,
		flags = { "placeable-neutral", "placeable-off-grid" },
		minable = {
			mining_particle = "wooden-particle",
			mining_time = 0.5,
			results = {
				{ type = "item", name = "tenebris-chitin", amount = 2 },
				{ type = "item", name = "mercurial-archaea", amount_min = 15, amount_max = 80 },
			},
		},
		max_health = 50,
		collision_box = { { -0.6, -0.4 }, { 0.6, 0.6 } },
		selection_box = { { -1, -3 }, { 1, 0.6 } },
		drawing_box_vertical_extension = 0.8,
		collision_mask = { layers = { player = true, train = true, is_object = true, is_lower_object = true } },
		subgroup = "trees",
		order = "t[tenebris]-e[mercurial-stingfrond]",
		impact_category = "tree",
		autoplace = {
			control = "tenebris_plants",
			order = "a[tree]-b[forest]-f",
			probability_expression = "0.005 * tenebris_biome_mercury",
			richness_expression = "random_penalty_at(3, 1)",
			tile_restriction = { "tenebris-mercury-tile" },
		},
		variations = {
			{
				trunk = {
					filename = mercurial_stingfrond_gfx .. "stingfrond-trunk.png",
					flags = { "mipmap" },
					width = 640,
					height = 560,
					frame_count = 1,
					shift = util.by_pixel(52, -60),
					scale = 0.33 * 1.1,
				},
				leaves = {
					filename = mercurial_stingfrond_gfx .. "stingfrond-harvest.png",
					flags = { "mipmap" },
					width = 640,
					height = 560,
					frame_count = 1,
					shift = util.by_pixel(52, -60),
					scale = 0.33 * 1.1,
				},
				normal = {
					filename = mercurial_stingfrond_gfx .. "stingfrond-normal.png",
					width = 640,
					height = 560,
					frame_count = 1,
					shift = util.by_pixel(52, -60),
					scale = 0.33 * 1.1,
				},
				shadow = {
					frame_count = 2,
					lines_per_file = 1,
					line_length = 1,
					flags = { "mipmap", "shadow" },
					filenames = {
						mercurial_stingfrond_gfx .. "stingfrond-shadow.png",
						mercurial_stingfrond_gfx .. "stingfrond-shadow.png",
					},
					width = 640,
					height = 560,
					shift = util.by_pixel(52, -60),
					scale = 0.33 * 1.1,
				},
			},
		},
		colors = {
			{ r = 255, g = 255, b = 255 },
			{ r = 240, g = 255, b = 255 },
			{ r = 255, g = 240, b = 255 },
			{ r = 240, g = 240, b = 255 },
			{ r = 240, g = 255, b = 240 },
		},
	},
})
