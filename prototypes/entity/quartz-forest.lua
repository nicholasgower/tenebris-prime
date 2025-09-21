require("__base__.prototypes.entity.enemy-constants")
require("__base__.prototypes.entity.biter-animations")
require("__base__.prototypes.entity.spitter-animations")
require("__base__.prototypes.entity.spawner-animation")

local enemy_autoplace = require ("__base__.prototypes.entity.enemy-autoplace-utils")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local ticks_per_second = 60
local ticks_per_minute = 60 * ticks_per_second

table.insert(data.raw["ammo"]["capture-robot-rocket"].ammo_type.target_filter, "tenebris-quartz-forest-ortet")

data.extend({
    {
        type = "unit-spawner",
        name = "tenebris-quartz-forest-ortet",
        icon = "__base__/graphics/icons/biter-spawner.png",
        flags = {"placeable-enemy", "not-repairable"},
        max_health = 3200,
        order="t[tenebris]-ortet-spawner",
        subgroup="enemies",
        resistances =
        {
          {
            type = "physical",
            decrease = 20,
          },
          {
            type = "explosion",
            decrease = 5,
            percent = -60
          },
          {
            type = "fire",
            percent = 100
          }
        },
        working_sound =
        {
          sound = {category = "enemy", filename = "__base__/sound/creatures/spawner.ogg", volume = 0.6, modifiers = volume_multiplier("main-menu", 0.7) },
          max_sounds_per_prototype = 3
        },
        dying_sound =
        {
          variations = sound_variations("__base__/sound/creatures/spawner-death", 5, 0.7, volume_multiplier("main-menu", 0.55) ),
          aggregation = { max_count = 2, remove = true, count_already_playing = true }
        },
        collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
        map_generator_bounding_box = {{-3.7, -3.2}, {3.7, 3.2}},
        selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
        damaged_trigger_effect = hit_effects.biter(),
        impact_category = "stone",
        -- in ticks per 1 pu
        absorptions_per_second = { pollution = { absolute = 20, proportional = 0.01 } },
        corpse = "biter-spawner-corpse",
        dying_explosion = "biter-spawner-die",
        graphics_set =
        {
          animations =
          {
            spawner_idle_animation(0, biter_spawner_tint),
            spawner_idle_animation(1, biter_spawner_tint),
            spawner_idle_animation(2, biter_spawner_tint),
            spawner_idle_animation(3, biter_spawner_tint)
          }
        },
        result_units = {
            {
                unit = "tenebris-quartz-ortet-bud-hidden-spawn-unit",
                spawn_points = {
                    {
                        evolution_factor = 0,
                        spawn_weight = 1
                    }
                }
            }
        },
        max_count_of_owned_units = 7,
        max_friends_around_to_spawn = 5,
        spawning_cooldown = {2000, 4000},
        spawning_radius = 1,
        spawning_spacing = 8,
        max_spawn_shift = 0,
        max_richness_for_spawn_shift = 100,
        autoplace = enemy_autoplace.enemy_spawner_autoplace("enemy_autoplace_base(0, 6)"),
        call_for_help_radius = 0,
        time_to_capture = 60 * 80,
        spawn_decorations_on_expansion = true,
        spawn_decoration = {},
        captured_spawner_entity = "tenebris-piezoelectric-quartz-generator"
    },
    {
      type = "unit",
      name = "tenebris-quartz-ortet-bud-hidden-spawn-unit",
      icon = "__base__/graphics/icons/small-biter.png",
      flags = {"placeable-neutral", "not-on-map", "not-repairable", "not-flammable", "not-in-kill-statistics"},
      max_health = 1,
      run_animation = {
        filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
        width = 1,
        height = 1,
      },
      attack_parameters =
      {
        type = "beam",
        range = 0,
        cooldown = 0,
        ammo_type = {
          target_type = "entity",
        },
        ammo_category = "melee",
        animation = {
          filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
          width = 1,
          height = 1,
        },
      },
      movement_speed = 0,
      distance_per_frame = 0,
      distraction_cooldown = 0,
      vision_distance = 0,
      hidden = true,
      healing_per_tick = -1,
      dying_trigger_effect = {
        type = "create-entity",
        entity_name = "tenebris-quartz-ortet-bud",
        find_non_colliding_position = true,
        offset_deviation = {{-40, -40}, {40, 40}},
        non_colliding_search_precision = 4,
      }
    },
    {
      type = "assembling-machine",
      name = "tenebris-piezoelectric-interface",
      icon = "__base__/graphics/icons/heat-boiler.png",
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.1, result = "heat-exchanger"},
      fast_replaceable_group = "heat-exchanger",
      max_health = 200,
      crafting_speed = 1,
      crafting_categories = {
        "tenebris-heating"
      },
      fixed_recipe = "tenebris-heating",
      fixed_quality = "normal",
      module_slots = 2,
      allowed_effects = {
        "speed", "consumption"
      },
      allowed_module_categories = {
        "speed", "efficiency"
      },
      show_recipe_icon = false,
      corpse = "heat-exchanger-remnants",
      dying_explosion = "heat-exchanger-explosion",
      impact_category = "metal",
      resistances =
      {
        {
          type = "fire",
          percent = 90
        },
        {
          type = "explosion",
          percent = 30
        },
        {
          type = "impact",
          percent = 30
        }
      },
      collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
      selection_box = {{-1.5, -1}, {1.5, 1}},
      damaged_trigger_effect = hit_effects.entity(),
      target_temperature = 800,
      fluid_boxes = { 
        {
          volume  = 20,
          pipe_covers = pipecoverspictures(),
          pipe_connections =
          {
            {flow_direction = "output", direction = defines.direction.north, position = {0, -0.5}}
          },
          production_type = "output",
          filter = "tenebris-heat"
        },
      },
      working_sound =
      {
        sound =
        {
          filename = "__base__/sound/heat-exchanger.ogg",
          volume = 0.65,
          modifiers = volume_multiplier("main-menu", 0.7),
          audible_distance_modifier = 0.5,
        },
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      open_sound = sounds.steam_open,
      close_sound = sounds.steam_close,
  
      energy_source =
      {
        type = "heat",
        max_temperature = 2000,
        specific_heat = "1MJ",
        max_transfer = "2GW",
        min_working_temperature = 800,
        minimum_glow_temperature = 850,
        connections =
        {
          {
            position = {0, 0.5},
            direction = defines.direction.south
          }
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
      energy_usage = "60MW",
      graphics_set =
      {
        animation = {
          north =
          {
            layers =
            {
              {
                filename = "__base__/graphics/entity/heat-exchanger/heatex-N-idle.png",
                priority = "extra-high",
                width = 269,
                height = 221,
                shift = util.by_pixel(-1.25, 5.25),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
                priority = "extra-high",
                width = 274,
                height = 164,
                scale = 0.5,
                shift = util.by_pixel(20.5, 9),
                draw_as_shadow = true
              }
            }
          },
          east =
          {
            layers =
            {
              {
                filename = "__base__/graphics/entity/heat-exchanger/heatex-E-idle.png",
                priority = "extra-high",
                width = 211,
                height = 301,
                shift = util.by_pixel(-1.75, 1.25),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
                priority = "extra-high",
                width = 184,
                height = 194,
                scale = 0.5,
                shift = util.by_pixel(30, 9.5),
                draw_as_shadow = true
              }
            }
          },
          south =
          {
            layers =
            {
              {
                filename = "__base__/graphics/entity/heat-exchanger/heatex-S-idle.png",
                priority = "extra-high",
                width = 260,
                height = 201,
                shift = util.by_pixel(4, 10.75),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
                priority = "extra-high",
                width = 311,
                height = 131,
                scale = 0.5,
                shift = util.by_pixel(29.75, 15.75),
                draw_as_shadow = true
              }
            }
          },
          west =
          {
            layers =
            {
              {
                filename = "__base__/graphics/entity/heat-exchanger/heatex-W-idle.png",
                priority = "extra-high",
                width = 196,
                height = 273,
                shift = util.by_pixel(1.5, 7.75),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
                priority = "extra-high",
                width = 206,
                height = 218,
                scale = 0.5,
                shift = util.by_pixel(19.5, 6.5),
                draw_as_shadow = true
              }
            }
          },
        },
      },
      water_reflection = boiler_reflection()
    },
    {
      type = "generator",
      name = "tenebris-piezoelectric-quartz-generator",
      icon = "__base__/graphics/icons/steam-turbine.png",
      flags = {"placeable-neutral","player-creation"},
      -- minable = {mining_time = 0.3, result = "tenebris-piezoelectric-quartz-generator"},
      max_health = 300,
      corpse = "steam-turbine-remnants",
      dying_explosion = "steam-turbine-explosion",
      alert_icon_shift = util.by_pixel(0, -12),
      effectivity = 1,
      fluid_usage_per_tick = 1,
      maximum_temperature = 1000,
      burns_fluid = false,
      resistances =
      {
        {
          type = "fire",
          percent = 70
        }
      },
      fast_replaceable_group = "steam-engine",
      collision_box = {{-2.35, -2.35}, {2.35, 2.35}},
      selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
      damaged_trigger_effect = hit_effects.entity(),
      fluid_box =
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections =
        {
          { flow_direction = "input", direction = defines.direction.south, position = {0, 2} },
          { flow_direction = "input", direction = defines.direction.north, position = {0, -2} },
          { flow_direction = "input", direction = defines.direction.west, position = {-2, 0} },
          { flow_direction = "input", direction = defines.direction.east, position = {2, 0} }
        },
        production_type = "input",
        filter = "tenebris-heat",
        minimum_temperature = 100.0
      },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-output"
      },
      horizontal_animation =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
            width = 320,
            height = 245,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(0, -2.75),
            run_mode = "backward",
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
            width = 435,
            height = 150,
            repeat_count = 8,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(28.5, 18),
            run_mode = "backward",
            scale = 0.5
          }
        }
      },
      vertical_animation =
      {
       layers =
       {
          {
            filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
            width = 217,
            height = 374,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(4.75, 0.0),
            run_mode = "backward",
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
            width = 302,
            height = 260,
            repeat_count = 8,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.5, 24.5),
            run_mode = "backward",
            scale = 0.5
          }
        }
      },
      smoke =
      {
        {
          name = "turbine-smoke",
          north_position = {0.0, -1.0},
          east_position = {0.75, -0.75},
          frequency = 10 / 32,
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      },
      impact_category = "metal-large",
      open_sound = sounds.machine_open,
      close_sound = sounds.machine_close,
      working_sound =
      {
        sound =
        {
          filename = "__base__/sound/steam-turbine.ogg",
          volume = 0.49,
          modifiers = volume_multiplier("main-menu", 0.7),
          speed_smoothing_window_size = 60,
          advanced_volume_control = {attenuation = "exponential"},
          audible_distance_modifier = 0.8,
        },
        match_speed_to_activity = true,
        max_sounds_per_prototype = 3,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      perceived_performance = {minimum = 0.25, performance_to_activity_rate = 2.0},
      water_reflection =
      {
        pictures =
        {
          filename = "__base__/graphics/entity/steam-turbine/steam-turbine-reflection.png",
          priority = "extra-high",
          width = 40,
          height = 36,
          shift = util.by_pixel(0, 50),
          variation_count = 2,
          repeat_count = 2,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = true
      }
    },
    {
      type = "plant",
      name = "tenebris-quartz-ortet-bud",
      icon = "__space-age__/graphics/icons/yumako-tree.png",
      flags = {"placeable-neutral"},
      minable =
      {
        mining_particle = "yumako-mining-particle",
        mining_time = 2.0,
      },
      mining_sound = sound_variations("__space-age__/sound/mining/axe-mining-yumako-tree", 5, 0.6),
      mined_sound = sound_variations("__space-age__/sound/mining/mined-yumako-tree", 6, 0.3),
      growth_ticks = 5 * ticks_per_minute,
      harvest_emissions = {},
      emissions_per_second = {},
      max_health = 50,
      collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
      --collision_mask = {layers={player=true, ground_tile=true, train=true}},
      selection_box = {{-1, -3}, {1, 0.8}},
      drawing_box_vertical_extension = 0.8,
      subgroup = "trees",
      order = "a[tree]-c[gleba]-a[seedable]-a[yumako-tree]",
      impact_category = "tree",
      pictures =
      {
        filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
        priority = "extra-high",
        width = 84,
        height = 252,
        direction_count = 4,
        shift = util.by_pixel(3.5, -44),
        scale = 0.5
      },
      map_color = {200, 200, 20},
    },
    {
      type = "electric-pole",
      name = "tenebris-ortet-conductor",
      icon = "__base__/graphics/icons/medium-electric-pole.png",
      quality_indicator_scale = 0.75,
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.1, result = "medium-electric-pole"},
      max_health = 100,
      corpse = "medium-electric-pole-remnants",
      dying_explosion = "medium-electric-pole-explosion",
      fast_replaceable_group = "electric-pole",
      connection_points =
      {
        {
          shadow =
          {
            copper = util.by_pixel_hr(229, -13),
            red = util.by_pixel_hr(246, -2),
            green = util.by_pixel_hr(201, -2)
          },
          wire =
          {
            copper = util.by_pixel_hr(15, -199),
            red = util.by_pixel_hr(43, -179),
            green = util.by_pixel_hr(-15, -185)
          }
        },
        {
          shadow =
          {
            copper = util.by_pixel_hr(229, -13),
            red = util.by_pixel_hr(230, 10),
            green = util.by_pixel_hr(196, -23)
          },
          wire =
          {
            copper = util.by_pixel_hr(15, -199),
            red = util.by_pixel_hr(27, -167),
            green = util.by_pixel_hr(-9, -200)
          }
        },
        {
          shadow =
          {
            copper = util.by_pixel_hr(229, -13),
            red = util.by_pixel_hr(208, 12),
            green = util.by_pixel_hr(217, -30)
          },
          wire =
          {
            copper = util.by_pixel_hr(15, -199),
            red = util.by_pixel_hr(5, -166),
            green = util.by_pixel_hr(13, -206)
          }
        },
        {
          shadow =
          {
            copper = util.by_pixel_hr(229, -13),
            red = util.by_pixel_hr(195, 1),
            green = util.by_pixel_hr(238, -23)
          },
          wire =
          {
            copper = util.by_pixel_hr(15, -199),
            red = util.by_pixel_hr(-12, -175),
            green = util.by_pixel_hr(36, -199)
          }
        }
      },
      resistances =
      {
        {
          type = "fire",
          percent = 100
        }
      },
      collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      damaged_trigger_effect = hit_effects.entity({{-0.2, -2.2},{0.2, 0.2}}),
      drawing_box_vertical_extension = 2.3,
      draw_copper_wires = false,
      draw_circuit_wires = false,
      auto_connect_up_to_n_wires = 0,
      maximum_wire_distance = 0,
      supply_area_distance = 42,
      impact_category = "metal",
      open_sound = sounds.electric_network_open,
      close_sound = sounds.electric_network_close,
      pictures =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
            priority = "extra-high",
            width = 84,
            height = 252,
            direction_count = 4,
            shift = util.by_pixel(3.5, -44),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
            priority = "extra-high",
            width = 280,
            height = 64,
            direction_count = 4,
            shift = util.by_pixel(56.5, -1),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      radius_visualisation_picture =
      {
        filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
        width = 12,
        height = 12,
        priority = "extra-high-no-scale"
      },
      water_reflection =
      {
        pictures =
        {
          filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-reflection.png",
          priority = "extra-high",
          width = 12,
          height = 28,
          shift = util.by_pixel(0, 55),
          variation_count = 1,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = false
      }
    },
})