local meld = require("meld")

local bioluminescent_beacon = meld(table.deepcopy(data.raw["beacon"]["beacon"]), {
    name = "biobeacon",
    bioluminescent = true,
    allowed_effects = meld.overwrite { "consumption", "speed", "pollution", "quality", "productivity" },
    minable = {
        mining_time = 0.2,
        result = "biobeacon"
    },
    energy_source = meld.overwrite {
        type = "void"
    },
    integration_patch_render_layer = "light-effect",
    integration_patch = meld.overwrite {
        filename = "__tenebris-prime__/graphics/icons/item-glow.png",
        size = 64,
        scale = 6,
        draw_as_light = true,
    },
    graphics_set = meld.overwrite {
        animation_list = {
            {
                animation = {
                    animation_speed = 0.2,
                    frame_count = 9,
                    scale = 0.3,
                    size = 512,
                    shift = util.by_pixel(0, -8),
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/biobeacon.png",
                            width_in_frames = 10,
                            height_in_frames = 1,
                        }
                    }
                },
            }
        }
    }
})


data:extend({
    bioluminescent_beacon,
    {
        type = "furnace",
        name = "bioinfusor",
        icon = "__tenebris-prime__/graphics/icons/bioinfusor.png",
        bioluminescent = true,
        working_sound = {
            sound = { filename = "__tenebris-prime__/sound/bioinfusor.ogg", volume = 0.5 },
            audible_distance_modifier = 0.5,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        crafting_categories = { "bioinfusion" },
        crafting_speed = 4.0,
        energy_usage = "180kW",
        source_inventory_size = 1,
        result_inventory_size = 1,
        module_slots = 4,
        allowed_effects = { "speed", "productivity", "quality", "consumption" },
        collision_box = { { -2, -2 }, { 2, 2 } },
        selection_box = { { -2, -2 }, { 2, 2 } },
        minable = {
            mining_time = 0.2,
            result = "bioinfusor"
        },
        integration_patch_render_layer = "light-effect",
        integration_patch = {
            filename = "__tenebris-prime__/graphics/icons/item-glow.png",
            size = 64,
            scale = 8,
            draw_as_light = true,
        },
        graphics_set = {
            animation = {
                animation_speed = 0.2,
                frame_count = 16,
                scale = 0.3,
                size = 512,
                shift = util.by_pixel(0, -7),
                stripes = {
                    {
                        filename = "__tenebris-prime__/graphics/entity/bioinfusor.png",
                        width_in_frames = 4,
                        height_in_frames = 4,
                    }
                }
            }
        },
        energy_source =
        {
            type = "burner",
            fuel_categories = { "bioluminescent" },
            effectivity = 1,
            burner_usage = "bioluminescent-crystals",
            fuel_inventory_size = 1,
            emissions_per_minute = { pollution = -1 },
            light_flicker = require("__space-age__.prototypes.entity.biochamber-pictures").light_flicker
        },
    }
})
