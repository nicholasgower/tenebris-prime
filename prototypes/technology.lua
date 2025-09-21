data:extend({
    -- Rocket launch trigger tech
    {
        type = "technology",
        name = "deep-space-sensing",
        icon = "__base__/graphics/icons/satellite.png",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "observation-satellite"
            },
            {
                type = "nothing",
                use_icon_overlay_constant = true,
                icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/technology/tenebris.png"),
                icon_size = 256,
                effect_description = "Launch satellites to locate celestial bodies in deep space."
            },
        },
        unit =
        {
            count = 5000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 },
            },
            time = 60
        },
        prerequisites = { "low-density-structure-productivity", "electromagnetic-science-pack" },
    },
    {
        type = "technology",
        name = "planet-discovery-tenebris",
        icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/technology/tenebris.png"),
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "tenebris",
                use_icon_overlay_constant = true
            }
        },
        localised_description = {"space-location-description.tenebris"},
        prerequisites = { "deep-space-sensing", "railgun", "overgrowth-soil"},
        unit =
        {
            count = 4000,
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
        name = "lucifunnel-processing",
        icon = "__tenebris-prime__/graphics/icons/lucifunnel.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "lucifunnel-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "lucifunnel-burning"
            },
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
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenecap-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "chitin-burning"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-heated-air-scrubber"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-scrubbing"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-filtration"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-filtration-cleaning"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere"
            },
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
        name = "quartz-ore",
        icon = "__tenebris-prime__/graphics/icons/quartz-ore.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenebris-stone-centrifuging"
            },
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "quartz-node"
        },
        prerequisites = { "tenecap-processing" },
    },
    {
        type = "technology",
        name = "quartz-crystal",
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "quartz-ore-washing"
            },
        },
        research_trigger =
        {
            type = "craft-item",
            item = "quartz-ore"
        },
        prerequisites = { "quartz-ore" },
    },
    {
        type = "technology",
        name = "tenebris-atmosphere-separation",
        icon = "__tenebris-prime__/graphics/icons/chitin.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-separation"
            },
            {
                type = "unlock-recipe",
                recipe = "tenecap-spore-purification"
            },
            {
                type = "unlock-recipe",
                recipe = "luciferin-solid-fuel"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan"
            },
        },
        research_trigger = {
            type = "craft-fluid",
            fluid = "tenebris-atmosphere"
        },
        prerequisites = { "tenecap-processing", "lucifunnel-processing" },
    },
    {
        type = "technology",
        name = "chitin-processing",
        icon = "__tenebris-prime__/graphics/icons/chitin.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "chitin-concrete"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan-lubricant"
            },
            {
                type = "unlock-recipe",
                recipe = "chitin-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan-advanced-circuit"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan-carbon-fiber"
            },
        },
        research_trigger = {
            type = "craft-item",
            item = "chitosan",
            count = 10
        },
        prerequisites = { "tenebris-atmosphere-separation" },
    },
    {
        type = "technology",
        name = "lightless-science-pack",
        icon = "__tenebris-prime__/graphics/technology/lightless-science-pack.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "photonic-crystal"
            },
            {
                type = "unlock-recipe",
                recipe = "lightless-science-pack"
            }
        },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "agricultural-science-pack",    1 },
                { "cryogenic-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "chitin-processing", "quartz-crystal" },
    },
    {
        type = "technology",
        name = "deep-space-discovery-iridescent-river",
        icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/technology/tenebris.png"),
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "iridescent-river",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-recipe",
                recipe = "bismuth-asteroid-crushing"
            },
            {
                type = "unlock-recipe",
                recipe = "bismuth-ore-melting"
            },
            {
                type = "unlock-recipe",
                recipe = "bioluminescent-crystal-forging",
            },
        },
        unit =
        {
            count = 3000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "electromagnetic-science-pack", 1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "lightless-beacons",
        icon = "__base__/graphics/technology/lamp.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "lightless-beacon"
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
                { "military-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "luciferin-explosives",
        icon = "__base__/graphics/technology/explosive-rocketry.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "luciferin-explosives"
            },
            {
                type = "unlock-recipe",
                recipe = "luciferin-rocket-fuel"
            }
        },
        unit =
        {
            count = 6000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack", "explosive-rocketry" },
    },
    {
        type = "technology",
        name = "luciferin-rocketry-speed",
        icon = "__base__/graphics/technology/explosive-rocketry.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "gun-speed",
                ammo_category = "rocket",
                modifier = 1
            },
        },
        unit =
        {
            count_formula = "3.5^(L-1) * 20000",
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        max_level = 4,
        upgrade = true,
        prerequisites = { "weapon-shooting-speed-6", "luciferin-explosives" },
    },
    {
        type = "technology",
        name = "quartz-crystal-reduction",
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "quartz-crystal-reduction"
            },
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
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "tenebris-soil-enrichment",
        icon = "__space-age__/graphics/technology/overgrowth-soil.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
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
                { "agricultural-science-pack",    1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "ammonic-acidification",
        icon = "__space-age__/graphics/icons/fluid/ammonia.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "ammonic-acidification"
            }
        },
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
                { "agricultural-science-pack",    1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "sulfuric-ketones",
        icon = "__space-age__/graphics/technology/cryogenic-plant.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "sulfuric-fluoroketone"
            }
        },
        unit =
        {
            count = 4000,
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
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "lightless-science-pack" },
    },
    {
        type = "technology",
        name = "bioluminescent-crystal",
        icon = "__tenebris-prime__/graphics/icons/bioluminescent-crystal.png",
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bioluminescent-crystal-organics",
            },
        },
        research_trigger = {
            type = "craft-item",
            item = "quartz-crystal"
        },
        prerequisites = { "quartz-crystal", "lucifunnel-processing" },
    },
    {
        type = "technology",
        name = "tenebris-bioinfusor",
        icon = "__tenebris-prime__/graphics/technology/bioinfusor.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenebris-bioinfusor"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "bioluminescent-crystal"
        },
        prerequisites = { "bioluminescent-crystal" },
    },
    {
        type = "technology",
        name = "bioluminescent-science-pack",
        icon = "__tenebris-prime__/graphics/technology/bioluminescent-science-pack.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "bioluminescent-science-pack"
            }
        },
        research_trigger = {
            type = "craft-item",
            item = "tenebris-bioinfusor"
        },
        prerequisites = { "lightless-science-pack", "tenebris-bioinfusor" },
    },
    {
        type = "technology",
        name = "photonic-derangement",
        icon = "__base__/graphics/technology/rocket-silo.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "tenebris-rocket-part"
            },
        },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 30
        },
        prerequisites = { "bioluminescent-science-pack" },
    },
    {
        type = "technology",
        name = "bismuthal-alloys",
        icon = "__base__/graphics/technology/steel-processing.png",
        icon_size = 256,
        visible_when_disabled = false,
        research_trigger =   
        {
            type = "craft-item",
            item = "quartziferous-bismuthal-plate",
            count = 100
        },
        prerequisites = { "deep-space-discovery-iridescent-river", "photonic-derangement" },
    },
    {
        type = "technology",
        name = "tenebris-biobeacon",
        icon = "__tenebris-prime__/graphics/technology/biobeacon.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =   
        {
            {
                type = "unlock-recipe",
                recipe = "tenebris-biobeacon"
            }
        },
        unit =
        {
            count = 10000,
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "bismuthal-alloys" },
    },
    {
        type = "technology",
        name = "tenebris-laser-cannon",
        icon = "__base__/graphics/technology/laser-turret.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =   
        {
        },
        unit =
        {
            count = 10000,
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "bismuthal-alloys" },
    },
    {
        type = "technology",
        name = "tenebris-laser-shooting-speed",
        icon = "__base__/graphics/technology/laser-turret.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects = {
            {
                type = "gun-speed",
                ammo_category = "laser",
                modifier = 0.75
            },
        },
        unit =
        {
            count_formula = "4^(L-1) * 20000",
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "lightless-science-pack",       1 },
                { "bioluminescent-science-pack",  1 },
            },
            time = 60
        },
        max_level = 4,
        upgrade = true,
        prerequisites = { "laser-shooting-speed-7", "tenebris-laser-cannon" },
    },
    {
        type = "technology",
        name = "tenebris-beacon-distribution-efficiency",
        icon = "__tenebris-prime__/graphics/technology/biobeacon.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =   
        {
            {
                type = "beacon-distribution",
                modifier = 0.02
            }
        },
        unit =
        {
            count_formula = "5^(L-1)*12000",
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        max_level = "infinite",
        upgrade = true,
        prerequisites = { "tenebris-biobeacon" },
    },
    {
        type = "technology",
        name = "cloaking",
        icon = "__space-age__/graphics/technology/overgrowth-soil.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
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
                { "agricultural-science-pack",    1 },
                { "cryogenic-science-pack",       1 },
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "photonic-derangement" },
    },
    {
        type = "technology",
        name = "bioluminescent-robots",
        icon = "__base__/graphics/technology/robotics.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
        },
        unit =
        {
            count = 10000,
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "photonic-derangement" },
    },
    {
        type = "technology",
        name = "worker-robot-battery-capacity",
        icon = "__base__/graphics/technology/robotics.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "worker-robot-battery",
                modifier = 0.1
            },
        },
        unit =
        {
            count_formula = "1.4^L*1000",
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        max_level = "infinite",
        upgrade = true,
        prerequisites = { "bioluminescent-robots" },
    },
    {
        type = "technology",
        name = "bioluminescent-lamps",
        icon = "__base__/graphics/technology/lamp.png",
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
        },
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
                { "cryogenic-science-pack",       1 },
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "photonic-derangement" },
    },
    {
        type = "technology",
        name = "deep-space-discovery-lightless-abyss",
        icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/technology/tenebris.png"),
        icon_size = 256,
        visible_when_disabled = false,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "lightless-gateway",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-space-location",
                space_location = "lightless-abyss",
                use_icon_overlay_constant = true
            },
        },
        unit =
        {
            count = 30000,
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
                { "bioluminescent-science-pack",  1 },
                { "lightless-science-pack",       1 }
            },
            time = 60
        },
        prerequisites = { "photonic-derangement" },
    },
})