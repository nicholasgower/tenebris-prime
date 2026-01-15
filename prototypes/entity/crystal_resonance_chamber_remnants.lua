--- Crystal Resonance Chamber Remnants/Corpse
--- Based on Krastorio2's big-random-pipes-remnants

data:extend({
	{
		type = "corpse",
		name = "tenebris-crystal-resonance-chamber-remnants",
		icon = "__tenebris-prime__/graphics/icons/crystal-resonance-chamber.png",
		flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
		hidden_in_factoriopedia = true,
		subgroup = "remnants",
		order = "z[remnants]-a[generic]-b[big]",
		selection_box = { { -4, -4 }, { 4, 4 } },
		tile_width = 3,
		tile_height = 3,
		selectable_in_game = false,
		time_before_removed = 20 * minute,
		final_render_layer = "remnants",
		remove_on_tile_placement = false,
		animation = make_rotated_animation_variations_from_sheet(1, {
			filename = "__tenebris-prime__/graphics/remnants/crystal-resonance-chamber-remnants.png",
			line_length = 1,
			width = 500,
			height = 500,
			frame_count = 1,
			direction_count = 1,
			scale = 0.5,
		}),
	},
})
