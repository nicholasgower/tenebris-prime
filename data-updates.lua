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