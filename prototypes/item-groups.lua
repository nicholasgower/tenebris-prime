data:extend({
    -- deep-space-sensing subgroup moved to deep-space-sensing mod
    {
        type = "item-subgroup",
        name = "tenebris-inserter",
        group = "logistics",
        order = "c-t[tenebris]-a[inserter]"
    },
    {
        type = "item-subgroup",
        name = "tenebris-fluid-logistics",
        group = "logistics",
        order = "d-t[tenebris]-a[fluid-logistics]"
    },
    {
        type = "item-subgroup",
        name = "tenebris-minerals",
        group = "intermediate-products",
        order = "s"
    },
    {
        type = "item-subgroup",
        name = "tenebris-organic-products",
        group = "intermediate-products",
        order = "t-a"
    },
    {
        type = "item-subgroup",
        name = "tenebris-waste-products",
        group = "intermediate-products",
        order = "t-b"
    },
    {
        type = "item-subgroup",
        name = "tenebris-ceramic-products",
        group = "intermediate-products",
        order = "t-c"
    },
    {
        type = "item-subgroup",
        name = "tenebris-piezoelectric-products",
        group = "intermediate-products",
        order = "t-d"
    },
    {
        type = "item-subgroup",
        name = "tenebris-luciferin-fuels",
        group = "intermediate-products",
        order = "t-d-a"
    },
    {
        type = "item-subgroup",
        name = "tenebris-mercury-products",
        group = "intermediate-products",
        order = "t-d-b"
    },
    {
        type = "item-subgroup",
        name = "tenebris-metallurgy",
        group = "intermediate-products",
        order = "t-d-b"
    },
    {
        type = "item-subgroup",
        name = "tenebris-filters",
        group = "intermediate-products",
        order = "t-d-c"
    },
    {
        type = "item-subgroup",
        name = "tenebris-atmosphere-processing",
        group = "intermediate-products",
        order = "t-e"
    },
    {
        type = "item-subgroup",
        name = "tenebris-atmosphere-filtration",
        group = "intermediate-products",
        order = "t-e-a"
    },
    {
        type = "item-subgroup",
        name = "tenebris-crystal-processing",
        group = "intermediate-products",
        order = "t-f"
    },
    {
        type = "item-subgroup",
        name = "tenebris-cr-reprocess",
        group = "intermediate-products",
        order = "t-f-b"
    },
    {
        type = "item-subgroup",
        name = "tenebris-cr-seedlings",
        group = "intermediate-products",
        order = "t-f-c"
    },
    {
        type = "item-subgroup",
        name = "tenebris-cr-oscillators",
        group = "intermediate-products",
        order = "t-f-d"
    },
    {
        type = "item-subgroup",
        name = "tenebris-cr-motors",
        group = "intermediate-products",
        order = "t-f-e"
    },
    {
        type = "item-subgroup",
        name = "tenebris-cr-science",
        group = "intermediate-products",
        order = "t-f-f"
    },
    {
        type = "item-subgroup",
        name = "tenebris-piezoelectric-science-pack",
        group = "intermediate-products",
        order = "y-a"
    },
    {
        type = "item-subgroup",
        name = "tenebris-thermal-energy",
        group = "production",
        -- order set in ordering.lua
    },
    {
        type = "item-subgroup",
        name = "tenebris-heated-agriculture",
        group = "production",
        order = "db"  -- Right after agriculture (da)
    },
    {
        type = "item-subgroup",
        name = "tenebris-machines",
        group = "production",
        order = "t"
    },
    {
        type = "item-subgroup",
        name = "tenebris-tiles",
        group = "tiles",
        order = "t[tenebris]"
    },
    {
        type = "item-subgroup",
        name = "tenebris-artificial-terrain",
        group = "logistics",
        order = "c[landfill]-z[tenebris]"  -- After vanilla tiles
    },
    {
        type = "item-subgroup",
        name = "tenebris-fluids",
        group = "fluids",
        order = "t[tenebris]"
    },
    {
        type = "item-group",
        name = "bioluminescent",
        order = "e",
        icon = "__tenebris-prime__/graphics/icons/item-group/bioluminescent.png",
        icon_size = 128,
    }
})