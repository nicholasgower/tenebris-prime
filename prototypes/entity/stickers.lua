--- Tenebris Stickers
--- Status effect stickers applied to entities
--- Note: Stickers can only attach to Unit, Character, Car, and SpiderVehicle prototypes

local constants = require("__tenebris-prime__.lib.constants")
local TINT = constants.TINT

data:extend({
	-- Mercury poisoning - applied when walking through mercury pools
	{
		type = "sticker",
		name = "tenebris-mercury-poisoning-sticker",
		flags = { "not-on-map" },
		hidden = true,
		animation = {
			-- Dark toxic vapor effect (smoke-based)
			filename = "__base__/graphics/entity/smoke/smoke.png",
			width = 152,
			height = 120,
			line_length = 5,
			frame_count = 60,
			animation_speed = 0.4,
			tint = { r = 0.25, g = 0.22, b = 0.30, a = 0.4 }, -- Dark purple-grey vapor
			shift = { 0, -0.4 },
			priority = "high",
			scale = 0.35,
		},
		-- Short duration - will be reapplied while on mercury
		duration_in_ticks = 90, -- 1.5 seconds

		-- Poison damage
		damage_interval = 30, -- Every 0.5 seconds
		damage_per_tick = { amount = 5, type = "poison" },

		-- Slight movement penalty (heavy metal poisoning)
		target_movement_modifier = 0.9,
	},

	-- Tenebrace spores - acid damage from proximity to tenebrace plants
	{
		type = "sticker",
		name = "tenebris-tenebrace-spore-sticker",
		flags = { "not-on-map" },
		hidden = true,
		animation = {
			-- Green-tinged toxic spore effect
			filename = "__base__/graphics/entity/smoke/smoke.png",
			width = 152,
			height = 120,
			line_length = 5,
			frame_count = 60,
			animation_speed = 0.5,
			tint = TINT.TENEBRACE_SMOKE,
			shift = { 0, -0.5 },
			priority = "high",
			scale = 0.4,
		},
		duration_in_ticks = 120, -- 2 seconds
		damage_interval = 30, -- Every 0.5 seconds
		damage_per_tick = { amount = 20, type = "acid" },
	},

	-- Atmospheric pressure - applied to players on Tenebris until mech-adaptation tech is researched
	-- Prevents mech armor from hovering/flying via ground_target property
	{
		type = "sticker",
		name = "tenebris-atmospheric-pressure-sticker",
		hidden = true,
		render_layer = "smoke",
		flags = { "not-on-map" },
		order = "z-tenebris-flight-restriction",
		animation = {
			-- Dark atmospheric effect with purple tint (matching Tenebris theme)
			filename = "__base__/graphics/entity/smoke/smoke.png",
			width = 152,
			height = 120,
			line_length = 5,
			frame_count = 60,
			animation_speed = 0.15,
			tint = { 0.3, 0.2, 0.4, 0.6 },
			shift = { 0, -0.4375 },
			priority = "high",
			scale = 0.5,
		},
		-- Very long duration - will be removed by script when tech is researched
		duration_in_ticks = 999999999,

		-- Movement penalties (oppressive atmosphere)
		target_movement_max = 0.15,
		target_movement_modifier = 0.95, -- Slight movement penalty
		vehicle_speed_modifier = 0.9, -- Slight vehicle speed penalty
		vehicle_friction_modifier = 2, -- Increased friction

		ground_target = true,

		working_sound = {
			sound = {
				filename = "__space-age__/sound/stickers/ash-cloud-disruption.ogg",
				volume = 0.3,
				advanced_volume_control = {
					fades = {
						fade_in = {
							curve_type = "cosine",
							from = { control = 0.5, volume_percentage = 0.0 },
							to = { control = 1.0, volume_percentage = 100.0 },
						},
					},
				},
				audible_distance_modifier = 0.4,
			},
			fade_in_ticks = 30,
			fade_out_ticks = 30,
			max_sounds_per_prototype = 2,
		},
	},
})
