data:extend({
    {
        type = "burner-usage",
        name = "bioluminescent-crystals",
        empty_slot_sprite =
        {
            filename = "__tenebris-prime__/graphics/icons/bioluminescent-crystal.png",
            priority = "extra-high-no-scale",
            size = 64,
            mipmap_count = 2,
            flags = { "gui-icon" },
        },
        empty_slot_caption = { "item-name.bioluminescent-crystal" },
        empty_slot_description = { "gui.bio-crystal-description" },

        no_fuel_status = { "entity-status.no-crystals" },

        icon =
        {
            filename = "__core__/graphics/icons/alerts/fuel-icon-red.png",
            priority = "extra-high-no-scale",
            width = 64,
            height = 64,
            flags = { "icon" }
        },

        accepted_fuel_key = "item-name.bioluminescent-crystal",
        burned_in_key = "eaten-by",
    }
})
