local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local lava_to_out_of_map_transition = space_age_tiles_util.lava_to_out_of_map_transition
space_age_tiles_util = space_age_tiles_util or {}
local tile_trigger_effects = require("__base__.prototypes.tile.tile-trigger-effects")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local lake_ambience =
{
  {
    sound =
    {
      variations = sound_variations("__base__/sound/world/water/waterlap", 10, 0.4),
      advanced_volume_control =
      {
        fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0}}}
      }
    },
    radius = 7.5,
    min_entity_count = 10,
    max_entity_count = 30,
    entity_to_sound_ratio = 0.1,
    average_pause_seconds = 8
  },
  {
    sound =
      {
        variations = sound_variations("__space-age__/sound/world/tiles/rain-on-water", 10, 0.2),
        advanced_volume_control =
        {
          fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0}}},
        }
      },
      min_entity_count = 10,
      max_entity_count = 25,
      entity_to_sound_ratio = 0.1,
      average_pause_seconds = 5,
  }
}

data:extend({
    {
        type = "tile",
        name = "sulfuric-acid-tile",
        order = "b[tenebris]-a[sulfuric-acid]",
        subgroup = "gleba-water-tiles",
        collision_mask = tile_collision_masks.shallow_water(),
        autoplace = {probability_expression = "noise_layer_noise(1) - 0.4"},
        lowland_fog = true,
        particle_tints = tile_graphics.gleba_shallow_water_particle_tints,
        layer = 1,
        layer_group = "water-overlay",
        sprite_usage_surface = "gleba",
        variants =
        {
          main =
          {
            {
              picture = "__tenebris-prime__/graphics/tile/sulfuric-acid.png",
              count = 1,
              scale = 0.5,
              size = 1
            }
          },
          empty_transitions=true,
        },
        transitions = {lava_to_out_of_map_transition},
        transitions_between_transitions = data.raw.tile["water"].transitions_between_transitions,
        walking_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1),
        landing_steps_sound = tile_sounds.landing.wet,
        driving_sound = wetland_driving_sound,
        map_color = {155,142,58},
        walking_speed_modifier = 0.4,
        vehicle_friction_modifier = 12.0,
        -- trigger_effect = tile_trigger_effects.shallow_water_trigger_effect(),
        default_cover_tile = "landfill",
        fluid = "sulfuric-acid",
        ambient_sounds = lake_ambience
      }
})