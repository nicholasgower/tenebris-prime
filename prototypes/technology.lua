data:extend({
    {
        type = "technology",
        name = "planet-discovery-tenebris",
        icons = util.technology_icon_constant_planet("__tenebris-prime__/graphics/icons/technology/tenebris.png"),
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "tenebris",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-recipe",
                recipe = "sulfur-from-acid"
            },
        },
        localised_description = {"space-location-description.tenebris"},
        prerequisites = { "rocket-turret", "advanced-asteroid-processing",
            "heating-tower", "asteroid-reprocessing",
            "electromagnetic-science-pack", "cryogenic-science-pack" },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 }
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "quartz-crystal",
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "quartz-crystal"
            }
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "quartz-node"
        },
        prerequisites = { "planet-discovery-tenebris" },
    },
    {
        type = "technology",
        name = "lucifunnel-processing",
        icon = "__tenebris-prime__/graphics/icons/lucifunnel.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "lucifunnel-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "luciferin-rocket-fuel"
            }
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "lucifunnel"
        },
        prerequisites = { "planet-discovery-tenebris" },
    },
    {
        type = "technology",
        name = "tenecap-processing",
        icon = "__tenebris-prime__/graphics/icons/tenecap.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenecap-processing"
            }
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "tenecap"
        },
        prerequisites = { "planet-discovery-tenebris" },
    },
    {
        type = "technology",
        name = "bioluminescent-crystal",
        icon = "__tenebris-prime__/graphics/icons/bioluminescent-crystal.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bioluminescent-crystal"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "quartz-crystal"
        },
        prerequisites = { "planet-discovery-tenebris", "quartz-crystal", "lucifunnel-processing" },
    },
    {
        type = "technology",
        name = "chitin-processing",
        icon = "__tenebris-prime__/graphics/icons/chitin.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "chitosan"
            },
            {
                type = "unlock-recipe",
                recipe = "biopolymer"
            },
            {
                type = "unlock-recipe",
                recipe = "bio-biochamber"
            },
            {
                type = "unlock-recipe",
                recipe = "chitin-concrete"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan-lubricant"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "chitin"
        },
        prerequisites = { "planet-discovery-tenebris", "tenecap-processing" },
    },
    {
        type = "technology",
        name = "bioinfusor",
        icon = "__tenebris-prime__/graphics/technology/bioinfusor.png",
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bioinfusor"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "bioluminescent-crystal"
        },
        prerequisites = { "planet-discovery-tenebris", "bioluminescent-crystal" },
    },
    {
        type = "technology",
        name = "bioluminescent-science-pack",
        icon = "__tenebris-prime__/graphics/technology/bioluminescent-science-pack.png",
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bioluminescent-science-pack"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "bioinfusor"
        },
        prerequisites = { "planet-discovery-tenebris", "bioinfusor", "chitin-processing" },
    },
    {
        type = "technology",
        name = "bioluminescent-agricultural-tower",
        icon = "__space-age__/graphics/technology/agriculture.png",
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bio-agricultural-tower"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "lucifunnel-seed"
        },
        prerequisites = { "planet-discovery-tenebris", "lucifunnel-processing", "tenecap-processing" },
    },
    
    {
        type = "technology",
        name = "biobeacon",
        icon = "__tenebris-prime__/graphics/technology/biobeacon.png",
        icon_size = 256,
        essential = true,
        effects =   
        {
            {
                type = "unlock-recipe",
                recipe = "biobeacon"
            }
        },
        unit =
        {
            count = 2000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "bioluminescent-science-pack",  1 }
            },
            time = 60
        },
        prerequisites = { "bioluminescent-science-pack" },
    }
})

-- local cargo_drops = util.merge{PlanetsLib.cargo_drops_technology_base("tenebris","__tenebris-prime__/graphics/icons/technology/tenebris.png", 256),
--         {
--         --type = "technology",
--         --name = "bioluminescent-navigation",
--         --icon = "__tenebris-prime__/graphics/technology/navigation-upgrade.png",
--         --icon_size = 256,
--         essential = true,
--         -- effects =
--         -- {
--         --     {
--         --         type = "nothing",
--         --         effect_description = { "research-effect.improved-navigation" },
--         --         icon = "__core__/graphics/icons/technology/effect/cargo-pod.png"
--         --     }
--         -- },
--         unit =
--         {
--             count = 500,
--             ingredients =
--             {
--                 { "automation-science-pack",      1 },
--                 { "logistic-science-pack",        1 },
--                 { "chemical-science-pack",        1 },
--                 { "production-science-pack",      1 },
--                 { "utility-science-pack",         1 },
--                 { "bioluminescent-science-pack",  1 }
--             },
--             time = 60
--         },
--         prerequisites = { "bioluminescent-science-pack" },
--     }}

-- data:extend{cargo_drops}
