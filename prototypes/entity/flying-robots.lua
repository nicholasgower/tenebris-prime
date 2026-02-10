local tenebris = require("lib.tenebris")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local space_age_sounds = require("__space-age__.prototypes.entity.sounds")

local robot_animations = {}

robot_animations.displacer = {
	idle = {
		layers = {
			{
				filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
				priority = "high",
				line_length = 32,
				width = 88,
				height = 77,
				y = 77,
				direction_count = 32,
				shift = util.by_pixel(2.5, -1.25),
				scale = 0.5,
				tint = tenebris.TINT.BIOLUMINESCENT_LIGHT,
			},
			{
				filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
				priority = "high",
				line_length = 32,
				width = 52,
				height = 42,
				y = 42,
				direction_count = 32,
				shift = util.by_pixel(2.5, -7),
				apply_runtime_tint = true,
				scale = 0.5,
			},
		},
	},
	shadow_idle = {
		filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
		priority = "high",
		line_length = 32,
		width = 108,
		height = 66,
		direction_count = 32,
		shift = util.by_pixel(23.5, 19),
		scale = 0.5,
		draw_as_shadow = true,
	},
	in_motion = {
		layers = {
			{
				filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
				priority = "high",
				line_length = 32,
				width = 88,
				height = 77,
				direction_count = 32,
				shift = util.by_pixel(2.5, -1.25),
				scale = 0.5,
				tint = tenebris.TINT.BIOLUMINESCENT_LIGHT,
			},
			{
				filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
				priority = "high",
				line_length = 32,
				width = 52,
				height = 42,
				direction_count = 32,
				shift = util.by_pixel(2.5, -7),
				apply_runtime_tint = true,
				scale = 0.5,
			},
		},
	},
	shadow_in_motion = {
		filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
		priority = "high",
		line_length = 32,
		width = 108,
		height = 66,
		direction_count = 32,
		shift = util.by_pixel(23.5, 19),
		scale = 0.5,
		draw_as_shadow = true,
	},
}

data:extend({
	{
		type = "combat-robot",
		name = "displacer",
		icons = {
			{
				icon = "__tenebris-prime__/graphics/icons/displacer.png",
			},
		},
		flags = { "placeable-player", "player-creation", "placeable-off-grid", "not-on-map", "not-repairable" },
		resistances = {
			{
				type = "fire",
				percent = 95,
			},
			{
				type = "acid",
				decrease = 0,
				percent = 90,
			},
			{
				type = "poison",
				decrease = 0,
				percent = 90,
			},
		},
		subgroup = "capsule",
		order = "g[displacer]-a[robot]",
		max_health = 70,
		alert_when_damaged = false,
		collision_box = { { 0, 0 }, { 0, 0 } },
		selection_box = { { -0.5, -1.5 }, { 0.5, -0.5 } },
		hit_visualization_box = { { -0.1, -1.4 }, { 0.1, -1.3 } },
		damaged_trigger_effect = hit_effects.flying_robot(),
		dying_explosion = "destroyer-robot-explosion",
		time_to_live = 60 * 60 * 1,
		speed = 0.03,
		friction = 0.01,
		range_from_player = 10.0,
		follows_player = true,
		working_sound = {
			sound = { filename = "__base__/sound/fight/destroyer-robot-loop.ogg", volume = 0.7 },
			persistent = true,
		},
		destroy_action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				source_effects = {
					type = "create-entity",
					entity_name = "destroyer-robot-explosion",
				},
			},
		},
		attack_parameters = {
			type = "projectile",
			ammo_category = "railgun",
			cooldown = 120,
			range = 30,
			sound = space_age_sounds.railgun_gunshot,
			ammo_type = {
				target_type = "direction",
				clamp_position = true,
				action = {
					type = "line",
					range = 50,
					width = 1.2,
					range_effects = {
						type = "create-explosion",
						entity_name = "displacer-robot-beam",
						only_when_visible = true,
					},
					action_delivery = {
						{
							type = "instant",
							target_effects = {
								{
									type = "damage",
									damage = { amount = 12000, type = "physical" },
									affects_target = true,
								},
							},
							source_effects = {
								{
									type = "damage",
									damage = { amount = 12000, type = "physical" },
									vaporize = true,
									affects_target = true,
								},
								{
									type = "create-explosion",
									entity_name = "explosion-gunshot",
									only_when_visible = true,
								},
							},
						},
					},
				},
			},
		},
		light = { intensity = 0.6, size = 40, color = tenebris.TINT.BIOLUMINESCENT_LIGHT },
		water_reflection = robot_reflection(1.2),
		idle = robot_animations.displacer.idle,
		in_motion = robot_animations.displacer.in_motion,
		shadow_idle = robot_animations.displacer.shadow_idle,
		shadow_in_motion = robot_animations.displacer.shadow_in_motion,
	},
})
