local plant_flags = { "placeable-neutral", "placeable-off-grid", "breaths-air" }
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

local seconds = 60
local minutes = 60 * seconds

data:extend({
    {
        type = "plant",
        name = "glowdentale",
        icon = "__space-age__/graphics/icons/stingfrond.png",
        flags = plant_flags,
        growth_ticks = 2 * minutes,
        minable =
        {
            mining_particle = "wooden-particle",
            mining_time = 0.5,
            results = {
                { name = "luciferin", type = "item", amount_min = 0, amount_max = 2, },
            }
        },
        mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-stingfrond", 5, 0.5),
        mined_sound = sound_variations("__space-age__/sound/mining/mined-stingfrond", 5, 0.4),
        max_health = 50,
        collision_box = { { -0.1, -0.2 }, { 0.1, 0.1 } },
        selection_box = { { -.5, -.5 }, { .5, .5 } },
        drawing_box_vertical_extension = 0.8,
        subgroup = "trees",
        order = "t[tenebris]-a[glowdentale]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-1.png",
                draw_as_glow = true,
                shift = { 0, -0.5 },
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-2.png",
                draw_as_glow = true,
                shift = { 0, -0.5 },
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-3.png",
                draw_as_glow = true,
                shift = { 0, -0.5 },
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-4.png",
                draw_as_glow = true,
                shift = { 0, -0.5 },
            }
        },

        stateless_visualisation_variations = {
            {
                light = {
                    intensity = 0.1,
                    size = 16,
                    color = { 0.6, 0.9, 0.9 }
                }
            }
        },

        autoplace = {
            control = "tenebris_plants",
            order = "a[tree]-b[forest]-a",
            probability_expression = "clamp((gleba_plants_noise - 0.8) * control:tenebris_plants:size, 0.001, 0.07)",
            richness_expression = "random_penalty_at(3, 1)",
            tile_restriction = {
                "midland-cracked-lichen",
                "midland-cracked-lichen-dull",
                "midland-cracked-lichen-dark",
                "highland-dark-rock",
                "highland-dark-rock-2",
                "highland-yellow-rock"
            },
        },
    },
    {
        type = "plant",
        name = "lucifunnel",
        icon = "__space-age__/graphics/icons/stingfrond.png",
        flags = plant_flags,
        growth_ticks = 5 * minutes,
        minable =
        {
            mining_particle = "wooden-particle",
            mining_time = 0.5,
            results = {
                { name = "lucifunnel", type = "item", amount_min = 10, amount_max = 30 },
            }
        },
        mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-stingfrond", 5, 0.5),
        mined_sound = sound_variations("__space-age__/sound/mining/mined-stingfrond", 5, 0.4),
        max_health = 50,
        collision_box = { { -0.6, -0.8 }, { 0.6, 0.8 } },
        selection_box = { { -1, -1 }, { 1, 1 } },
        drawing_box_vertical_extension = 0.8,
        subgroup = "trees",
        order = "t[tenebris]-b[lucifunnel]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
            width = 1024,
            height = 1024,
            scale = 0.1,
            filename = "__tenebris-prime__/graphics/entity/lucifunnel.png",
            draw_as_glow = true,
            shift = { 0, -0.5 },
        },

        stateless_visualisation_variations = {
            {
                light = {
                    intensity = 0.1,
                    size = 32,
                    color = { 0.6, 0.9, 0.9 }
                }
            }
        },

        autoplace = {
            control = "tenebris_plants",
            order = "a[tree]-b[forest]-b",
            probability_expression = "clamp((gleba_plants_noise - 0.8) * control:tenebris_plants:size, 0.001, 0.02)",
            richness_expression = "random_penalty_at(3, 1)",
            tile_restriction = {
                "midland-cracked-lichen-dark",
                "highland-dark-rock",
                "highland-dark-rock-2",
            },
        },
    },
    {
        type = "plant",
        name = "tenecap",
        icon = "__space-age__/graphics/icons/stingfrond.png",
        flags = plant_flags,
        growth_ticks = 2 * minutes,
        minable =
        {
            mining_particle = "wooden-particle",
            mining_time = 0.5,
            results = {
                { name = "tenecap", type = "item", amount_min = 1, amount_max = 4 },
            }
        },
        mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-stingfrond", 5, 0.5),
        mined_sound = sound_variations("__space-age__/sound/mining/mined-stingfrond", 5, 0.4),
        max_health = 50,
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        drawing_box_vertical_extension = 0.8,
        subgroup = "trees",
        order = "t[tenebris]-c[tenecap]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
            layers = {
                {
                    width = 256,
                    height = 259,
                    scale = 0.1,
                    filename = "__tenebris-prime__/graphics/entity/tenecap.png",
                    shift = { 0, -0.25 },
                },
                {
                    width = 512,
                    height = 256,
                    scale = 0.075,
                    filename = "__tenebris-prime__/graphics/entity/tenecap-shadow.png",
                    draw_as_shadow = true,
                    shift = { 0.55, 0 },
                }
            }
        },

        autoplace = {
            control = "tenebris_plants",
            order = "a[tree]-b[forest]-c",
            probability_expression = "min(0.04, 0.03 * (1 - gleba_plants_noise) * control:tenebris_plants:size)",
            richness_expression = "random_penalty_at(3, 1)",
            tile_restriction = {
                "pit-rock",
                "lowland-dead-skin",
                "lowland-dead-skin-2"
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
        growth_ticks = 8 * minutes,
        autoplace = {
            order = "a[landscape]-c[rock]-b[big]",
            probability_expression = "noise_layer_noise(25) - 0.95",
            tile_restriction = {
                "pit-rock",
                "dust-lumpy",
                "sulfuric-acid-tile"
            },
        },
        dying_trigger_effect = decorative_trigger_effects.big_rock(),
        minable =
        {
            mining_particle = "stone-particle",
            mining_time = 4,
            results =
            {
                { type = "item", name = "quartz-crystal", amount_min = 2, amount_max = 5 }
            }
        },
        resistances =
        {
            {
                type = "fire",
                percent = 100
            }
        },
        map_color = { 195, 195, 195 },
        count_as_rock_for_filtered_deconstruction = true,
        mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
        impact_category = "stone",
        pictures = {
            {
                filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-1.png",
                width = 256,
                height = 256,
                scale = 0.3,
            },
            {
                filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
                width = 256,
                height = 256,
                scale = 0.3,
            },
            {
                filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-3.png",
                width = 256,
                height = 256,
                scale = 0.3,
            },
            {
                filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-4.png",
                width = 256,
                height = 256,
                scale = 0.3,
            },
        }
    }
})
