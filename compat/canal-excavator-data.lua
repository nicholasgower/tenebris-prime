if not mods["canal-excavator"] then return end

data:extend({{
  type = "mod-data",
  name = "canex-tenebris-config",
  data_type = "canex-surface-config",
  data = {
    surfaceName = "tenebris",
    localisation = {"space-location-name.tenebris"},
    oreStartingAmount = 10,
    mining_time = 4,
    tint = {r = 28, g = 223, b = 247},
    mineResult = {
      {type="item", name = "spoilage", probability = 0.95, amount = 1},
      {type="item", name = "luciferin", probability = 0.05, amount = 1},
      {type="item", name = "chitin", probability = 0.01, amount = 1},
      {type="item", name = "pentapod-egg", probability = 0.01, amount = 1},
    },
    custom_resource_category = "canex-rsc-cat-tenebris"
  },
}, {
  type = "mod-data",
  name = "canex-excavator-tenebris",
  data_type = "canex-excavator-config",
  data = {
    entity_name = "bioluminescent-canex-excavator",
    item_name = "bioluminescent-canex-excavator",
    custom_resource_category = "canex-rsc-cat-tenebris"
  }
}})