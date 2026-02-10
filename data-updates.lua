local constants = require("lib.constants")

require("__tenebris-prime__.compat.maraxsis")
require("__tenebris-prime__.compat.muluna")

if data.raw.lab["lab"] then
  table.insert(data.raw.lab["lab"].inputs, "piezoelectric-science-pack")
  table.insert(data.raw.lab["lab"].inputs, "bioluminescent-science-pack")
end

-- Assign custom rocket part recipe to Tenebris planet using PlanetsLib
if PlanetsLib then
  PlanetsLib.assign_rocket_part_recipe(constants.PLANET.TENEBRIS, "tenebris-rocket-part", true)
end

-- Allow landfill to be placed on mercury tiles
if data.raw.item["landfill"] and data.raw.item["landfill"].place_as_tile then
  table.insert(data.raw.item["landfill"].place_as_tile.condition, "tenebris-mercury-tile")
end

-- Create Tenebris cinnabar geyser (copy of sulfuric-acid-geyser with cinnabar tints)
local base_geyser = data.raw.resource["sulfuric-acid-geyser"]
if base_geyser then
  local TINT = constants.TINT
  local GAS = constants.GAS_MULTIPLIER
  local cinnabar_geyser = table.deepcopy(base_geyser)
  cinnabar_geyser.name = "tenebris-cinnabar-geyser"
  cinnabar_geyser.localised_name = {"entity-name.tenebris-cinnabar-geyser"}

  -- Set autoplace control
  cinnabar_geyser.autoplace.control = "tenebris_cinnabar_geyser"

  -- Update stateless_visualisation with cinnabar tints
  cinnabar_geyser.stateless_visualisation = {
    {
      count = 1,
      render_layer = "smoke",
      animation = {
        filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-outer.png",
        frame_count = 47,
        line_length = 16,
        width = 90,
        height = 188,
        animation_speed = 0.3,
        shift = util.by_pixel(-6, -89),
        scale = 1,
        tint = util.multiply_color(TINT.CINNABAR_GAS_OUTER, GAS.GEYSER_OUTER)
      }
    },
    {
      count = 1,
      render_layer = "smoke",
      animation = {
        filename = "__space-age__/graphics/entity/sulfuric-acid-geyser/sulfuric-acid-geyser-gas-inner.png",
        frame_count = 47,
        line_length = 16,
        width = 40,
        height = 84,
        animation_speed = 0.4,
        shift = util.by_pixel(-4, -30),
        scale = 1,
        tint = util.multiply_color(TINT.CINNABAR_GAS_INNER, GAS.GEYSER_INNER)
      }
    }
  }

  -- Tint the base sprite too
  if cinnabar_geyser.stages and cinnabar_geyser.stages.layers then
    for _, layer in ipairs(cinnabar_geyser.stages.layers) do
      layer.tint = TINT.CINNABAR
    end
  end

  data:extend({cinnabar_geyser})
end