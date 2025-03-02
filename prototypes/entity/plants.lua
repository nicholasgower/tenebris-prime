local plant_flags = { "placeable-neutral", "placeable-off-grid", "breaths-air" }

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
        order = "a[tree]-c[tenebris]-b[normal]-f[glowdentale]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-1.png",
                draw_as_glow = true,
                shift = {0,-0.5},
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-2.png",
                draw_as_glow = true,
                shift = {0,-0.5},
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-3.png",
                draw_as_glow = true,
                shift = {0,-0.5},
            },
            {
                size = 256,
                scale = 0.2,
                filename = "__tenebris-prime__/graphics/entity/glowdentale/glowdentale-4.png",
                draw_as_glow = true,
                shift = {0,-0.5},
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
            probability_expression = "clamp((gleba_plants_noise - 0.5) * control:tenebris_plants:size, 0.001, 0.5)",
            richness_expression = "random_penalty_at(3, 1)"
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
        order = "a[tree]-c[tenebris]-b[normal]-f[lucifunnel]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
            width = 1024,
            height = 1024,
            scale = 0.1,
            filename = "__tenebris-prime__/graphics/entity/lucifunnel.png",
            draw_as_glow = true,
            shift = {0,-0.5},
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
            probability_expression = "clamp((gleba_plants_noise - 0.5) * control:tenebris_plants:size, 0.001, 0.05)",
            richness_expression = "random_penalty_at(3, 1)"
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
                { name = "tenecap", type = "item", amount = 1 },
            }
        },
        mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-stingfrond", 5, 0.5),
        mined_sound = sound_variations("__space-age__/sound/mining/mined-stingfrond", 5, 0.4),
        max_health = 50,
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        drawing_box_vertical_extension = 0.8,
        subgroup = "trees",
        order = "a[tree]-c[tenebris]-b[normal]-f[tenecap]",
        impact_category = "tree",
        -- factoriopedia_simulation = simulations.factoriopedia_stingfrond,

        pictures = {
                layers = {
                    {
                        width = 256,
                        height = 259,
                        scale = 0.1,
                        filename = "__tenebris-prime__/graphics/entity/tenecap.png",
                        shift = {0,-0.25},
                    },
                    {
                        width = 512,
                        height = 256,
                        scale = 0.075,
                        filename = "__tenebris-prime__/graphics/entity/tenecap-shadow.png",
                        draw_as_shadow=true,
                        shift = {0.55,0}, 
                    }
                }
        },

        autoplace = {
            control = "tenebris_plants",
            order = "a[tree]-b[forest]-c",
            probability_expression = "clamp((gleba_plants_noise) * control:tenebris_plants:size, 0.001, 0.1)",
            richness_expression = "random_penalty_at(3, 1)"
        },
    }
})
