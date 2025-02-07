local sounds = require("__base__.prototypes.entity.sounds")
local resource_autoplace = require("resource-autoplace")

resource_autoplace.initialize_patch_set("quartz-ore", true)

local stone_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-stone.ogg", volume = 0.8,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}

local function resource(resource_parameters, autoplace_parameters)
    return
    {
      type = "resource",
      name = resource_parameters.name,
      icon = "__tenebris-prime__/graphics/icons/" .. resource_parameters.name .. ".png",
      flags = {"placeable-neutral"},
      order="a-b-"..resource_parameters.order,
      tree_removal_probability = 0.8,
      tree_removal_max_distance = 32 * 32,
      minable = resource_parameters.minable or
      {
        -- mining_particle = resource_parameters.name .. "-particle",
        mining_time = resource_parameters.mining_time,
        result = resource_parameters.name
      },
      category = resource_parameters.category,
      subgroup = resource_parameters.subgroup,
      walking_sound = resource_parameters.walking_sound,
      driving_sound = resource_parameters.driving_sound,
      collision_mask = resource_parameters.collision_mask,
      collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      autoplace = resource_autoplace.resource_autoplace_settings
      {
        name = resource_parameters.name,
        order = resource_parameters.order,
        base_density = autoplace_parameters.base_density,
        base_spots_per_km = autoplace_parameters.base_spots_per_km2,
        has_starting_area_placement = true,
        regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
        starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
        candidate_spot_count = autoplace_parameters.candidate_spot_count,
        tile_restriction = autoplace_parameters.tile_restriction
      },
      stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
      stages =
      {
        sheet =
        {
          filename = "__tenebris-prime__/graphics/entity/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
          priority = "extra-high",
          size = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5
        }
      },
      map_color = resource_parameters.map_color,
      mining_visualisation_tint = resource_parameters.mining_visualisation_tint,
      factoriopedia_simulation = resource_parameters.factoriopedia_simulation
    }
  end

  data:extend({
    resource(
        {
          name = "quartz-ore",
          order = "b",
          map_color = {0.715, 0.725, 0.780},
          mining_time = 1,
          walking_sound = sounds.ore,
          driving_sound = stone_driving_sound,
          mining_visualisation_tint = {r = 0.895, g = 0.965, b = 1.000, a = 1.000}, -- #e4f6ffff
        },
        {
          base_density = 10,
          regular_rq_factor_multiplier = 1.10,
          starting_rq_factor_multiplier = 1.5,
          candidate_spot_count = 22, -- To match 0.17.50 placement
        }
      )
  })
