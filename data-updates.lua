require("__tenebris-prime__.prototypes.bioluminescent")
require("__tenebris-prime__.compat.maraxsis")

if data.raw.lab["lab"] then
  table.insert(data.raw.lab["lab"].inputs, "lightless-science-pack")
  table.insert(data.raw.lab["lab"].inputs, "bioluminescent-science-pack")
end

PlanetsLib.assign_rocket_part_recipe("tenebris", "tenebris-rocket-part")