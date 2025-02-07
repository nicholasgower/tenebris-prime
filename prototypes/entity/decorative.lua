local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

data:extend({
    {
        name = "quartz-node",
        type = "simple-entity",
        flags = {"placeable-neutral", "placeable-off-grid"},
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        subgroup = "grass",
        order = "b[decorative]-l[rock]-j[quartz-node]",
        collision_box = {{-1.0, -1.0}, {1.0, 1.0}},
        selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
        damaged_trigger_effect = hit_effects.rock(),
        render_layer = "object",
        max_health = 500,
        autoplace = {
          order = "a[landscape]-c[rock]-b[big]",
          probability_expression = "noise_layer_noise(25) - 0.95"
        },
        dying_trigger_effect = decorative_trigger_effects.big_rock(),
        minable =
        {
          mining_particle = "stone-particle",
          mining_time = 2,
          results =
          {
            {type = "item", name = "quartz-ore", amount_min = 12, amount_max = 36}
          }
        },
        resistances =
        {
          {
            type = "fire",
            percent = 100
          }
        },
        map_color = {195, 195, 195},
        count_as_rock_for_filtered_deconstruction = true,
        mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
        impact_category = "stone",
        pictures = {
          {
            filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-1.png",
            width =  256,
            height =  256,
            scale = 0.3,
          },
          {
            filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
            width =  256,
            height =  256,
            scale = 0.3,
          },
          {
            filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-3.png",
            width =  256,
            height =  256,
            scale = 0.3,
          },
          {
            filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-4.png",
            width =  256,
            height =  256,
            scale = 0.3,
          },
        }
      }
})