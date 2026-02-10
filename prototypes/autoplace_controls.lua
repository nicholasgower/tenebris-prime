data:extend({
	{
		type = "autoplace-control",
		name = "tenebris_plants",
		order = "c-z-c",
		category = "terrain",
		can_be_disabled = false,
	},
	{
		type = "autoplace-control",
		name = "tenebris_exposed_lichen_deposit",
		localised_name = {
			"",
			"[entity=tenebris-exposed-lichen-deposit] ",
			{ "entity-name.tenebris-exposed-lichen-deposit" },
		},
		richness = true,
		order = "z-c",
		category = "resource",
	},
	{
		type = "autoplace-control",
		name = "tenebris_cinnabar_geyser",
		localised_name = { "", "[entity=tenebris-cinnabar-geyser] ", { "entity-name.tenebris-cinnabar-geyser" } },
		richness = true,
		order = "z-d",
		category = "resource",
	},
})
