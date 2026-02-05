local tenebris = require("lib.tenebris")

-- Helper to apply tint to sprite layers
local function apply_tint_to_sprite(sprite, tint)
	if sprite.layers then
		for _, layer in pairs(sprite.layers) do
			if not layer.draw_as_shadow then
				layer.tint = tint
			end
		end
	else
		sprite.tint = tint
	end
	return sprite
end

-- Create tinted base sprite
local base_sprite = util.sprite_load("__space-age__/graphics/entity/capture-robot-rocket/capture-robot", {
	direction_count = 32,
	scale = 0.5,
	priority = "high",
})
base_sprite.tint = tenebris.TINT.DARK_ORANGE

-- Create tinted mask sprite
local mask_sprite = util.sprite_load("__space-age__/graphics/entity/capture-robot-rocket/capture-robot-mask", {
	direction_count = 32,
	scale = 0.5,
	priority = "high",
})
mask_sprite.tint = tenebris.TINT.DARK_ORANGE

-- Shadow sprite (no tint)
local shadow_sprite = util.sprite_load("__space-age__/graphics/entity/capture-robot-rocket/capture-robot-shadow", {
	direction_count = 32,
	scale = 0.5,
	priority = "high",
	draw_as_shadow = true,
})

data:extend({
	{
		type = "projectile",
		name = "piezoelectric-capture-robot-rocket",
		flags = { "not-on-map" },
		hidden = true,
		acceleration = 0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					type = "create-entity",
					show_in_tooltip = true,
					entity_name = "capture-robot",
					offsets = { { 0, 0 } },
				},
			},
		},
		enable_drawing_with_mask = true,
		animation = {
			layers = {
				base_sprite,
				mask_sprite,
				shadow_sprite,
			},
		},
		rotatable = false,
		smoke = {
			{
				name = "smoke-train-stop",
				deviation = { 0.15, 0.15 },
				frequency = 1,
				position = { 0, 0.5 },
				starting_frame = 3,
				starting_frame_deviation = 5,
				height = 2,
				starting_vertical_speed = -0.1,
				starting_vertical_speed_deviation = 0.05,
			},
		},
	},
	{
		type = "projectile",
		name = "tenebris-flare-projectile",
		flags = { "not-on-map" },
		acceleration = -0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "explosion",
						only_when_visible = true,
					},
					{
						type = "damage",
						damage = { amount = 10, type = "fire" },
					},
					{
						type = "invoke-tile-trigger",
						repeat_count = 1,
					},
					{
						type = "create-entity",
						entity_name = "luciferin-flare",
						check_buildability = true,
					},
				},
			},
		},
		animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({ 1, 0.8, 0.3 }),
		shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
		smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
	},
	{
		type = "projectile",
		name = "displacer-capsule",
		flags = { "not-on-map" },
		hidden = true,
		acceleration = 0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					type = "create-entity",
					show_in_tooltip = true,
					entity_name = "displacer",
					offsets = { { -0.7, -0.7 }, { -0.7, 0.7 }, { 0.7, -0.7 }, { 0.7, 0.7 } },
				},
			},
		},
		light = { intensity = 0.5, size = 4, color = tenebris.TINT.BIOLUMINESCENT_LIGHT },
		enable_drawing_with_mask = true,
		animation = {
			layers = {
				{
					filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule.png",
					flags = { "no-crop" },
					width = 42,
					height = 34,
					priority = "high",
					tint = tenebris.TINT.BIOLUMINESCENT_LIGHT,
				},
				{
					filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-mask.png",
					flags = { "no-crop" },
					width = 42,
					height = 34,
					priority = "high",
					apply_runtime_tint = true,
					tint = tenebris.TINT.BIOLUMINESCENT_LIGHT,
				},
			},
		},
		shadow = {
			filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-shadow.png",
			flags = { "no-crop" },
			width = 48,
			height = 32,
			priority = "high",
		},
		smoke = capsule_smoke,
	},
})
