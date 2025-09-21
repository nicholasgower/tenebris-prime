local hit_effects = require("__base__.prototypes.entity.hit-effects")
local meld = require("meld")
local sounds = require("__base__.prototypes.entity.sounds")


local tenebris_bioluminescent_beacon = meld(table.deepcopy(data.raw["beacon"]["beacon"]), {
    name = "tenebris-biobeacon",
    bioluminescent = true,
    allowed_effects = meld.overwrite { "consumption", "speed", "pollution", "productivity" },
    minable = {
        mining_time = 0.2,
        result = "tenebris-biobeacon"
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
                    shift = {0,-0.5},
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

local tenebris_bioinfuser = {
    type = "furnace",
    name = "tenebris-bioinfusor",
    icon = "__tenebris-prime__/graphics/icons/tenebris-bioinfusor.png",
    bioluminescent = true,
    working_sound = {
        sound = { filename = "__tenebris-prime__/sound/bioinfusor.ogg", volume = 0.5 },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    crafting_categories = { "bioinfusion" },
    crafting_speed = 2.0,
    energy_usage = "300kW",
    source_inventory_size = 1,
    result_inventory_size = 1,
    module_slots = 2,
    allowed_effects = { "speed", "consumption" },
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2, -2}, {2, 2}},
    minable = {
        mining_time = 0.2,
        result = "tenebris-bioinfusor"
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
        light_flicker = require("__space-age__.prototypes.entity.biochamber-pictures").light_flicker
    },
}

local tenebris_air_scrubber = meld(table.deepcopy(data.raw["furnace"]["atan-air-scrubber"]), {
    name = "tenebris-heated-air-scrubber",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 0.2, result = "tenebris-heated-air-scrubber" },
    fast_replaceable_group = nil,
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "big-explosion",
    resistances = { { type = "fire", percent = 70 } },
    collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
    selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    module_slots = 0,
    allowed_effects = { "consumption", "speed" },
    crafting_categories = { "atmospheric-filtration" },
    crafting_speed = 2,
    source_inventory_size = 1,
    result_inventory_size = 1,
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    energy_source = {
      type = "heat",
      max_temperature = 2000,
      specific_heat = "2MJ",
      max_transfer = "2GW",
      min_working_temperature = 600,
      minimum_glow_temperature = 850,
      emissions_per_minute = {
        tenecap_spore_clearance = 100,
      },
      connections =
      {
        {
          position = {0, 1.2},
          direction = defines.direction.south
        },
        {
          position = {0, -1.2},
          direction = defines.direction.north
        },
        {
          position = {1.2, 0},
          direction = defines.direction.east
        },
        {
          position = {-1.2, 0},
          direction = defines.direction.west
        },
      },
      pipe_covers =
        make_4way_animation_from_spritesheet(
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
      heat_pipe_covers =
        make_4way_animation_from_spritesheet(
        apply_heat_pipe_glow{
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
      heat_picture =
      {
        north = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-N-heated.png",
          priority = "extra-high",
          width = 44,
          height = 96,
          shift = util.by_pixel(-0.5, 8.5),
          scale = 0.5
        },
        east = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-E-heated.png",
          priority = "extra-high",
          width = 80,
          height = 80,
          shift = util.by_pixel(-21, -13),
          scale = 0.5
        },
        south = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-S-heated.png",
          priority = "extra-high",
          width = 28,
          height = 40,
          shift = util.by_pixel(-1, -30),
          scale = 0.5
        },
        west = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-W-heated.png",
          priority = "extra-high",
          width = 64,
          height = 76,
          shift = util.by_pixel(23, -13),
          scale = 0.5
        }
      }
    },
    energy_usage = "5MW",
})


data:extend({
    tenebris_bioluminescent_beacon,
    tenebris_bioinfuser,
    tenebris_air_scrubber
})
