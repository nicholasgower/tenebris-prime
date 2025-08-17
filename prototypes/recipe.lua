local meld = require("meld")

data:extend({
  {
    type = "recipe",
    name = "observation-satellite",
    energy_required = 80,
    enabled = false,
    category = "electromagnetics",
    ingredients =
    {
        {type = "item", name = "low-density-structure", amount = 100},
        {type = "item", name = "solar-panel", amount = 100},
        {type = "item", name = "accumulator", amount = 100},
        {type = "item", name = "radar", amount = 5},
        {type = "item", name = "processing-unit", amount = 100},
        {type = "item", name = "rocket-fuel", amount = 50},
        {type = "item", name = "superconductor", amount = 50}
    },
    results = {{type="item", name="observation-satellite", amount=1}},
  },
  {
    type = "recipe",
    name = "lucifunnel-processing",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/lucifunnel-processing.png",
    category = "organic-or-assembling",
    ingredients = { { type = "item", name = "lucifunnel", amount = 1 } },
    results = {
      { type = "item", name = "lucifunnel-seed", amount = 1, probability = 0.1 },
      { type = "item", name = "luciferin",       amount = 1 },
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "tenecap-processing",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/tenecap-processing.png",
    category = "organic-or-assembling",
    ingredients = { { type = "item", name = "tenecap", amount = 1 } },
    results = {
      { type = "item", name = "tenecap-spore", amount = 1 },
      { type = "item", name = "chitin",        amount = 1 },
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "lucifunnel-burning",
    category = "smelting",
    auto_recycle = false,
    energy_required = 1,
    ingredients = {{type = "item", name = "lucifunnel", amount = 2}},
    results = {{type="item", name="carbon", amount=1}},
    allow_productivity = true,
    main_product = "carbon"
  },
  {
    type = "recipe",
    name = "chitin-burning",
    category = "smelting",
    auto_recycle = false,
    energy_required = 1,
    ingredients = {{type = "item", name = "chitin", amount = 1}},
    results = {{type="item", name="carbon", amount=1}},
    allow_productivity = true,
    main_product = "carbon"
  },
  {
    type = "recipe",
    name = "tenebris-atmosphere",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__muluna-graphics__/graphics/icons/atmosphere.png",
    category = "chemistry",
    energy_required = 20,
    ingredients = {},
    results = {
        {type = "fluid", name = "tenebris-atmosphere", amount = 100, temperature = 30}
    },
    main_product = "tenebris-atmosphere"
  },
  {
    type = "recipe",
    name = "tenebris-atmosphere-separation",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__base__/graphics/icons/fluid/advanced-oil-processing.png",
    category = "oil-processing",
    energy_required = 4,
    ingredients = { 
      {type = "fluid", name = "tenebris-atmosphere", amount = 100},
      {type = "fluid", name = "sulfuric-acid", amount = 50},
    },
    results = {
        {type = "fluid", name = "ammonia", amount = 25},
        {type = "fluid", name = "fluorine", amount = 2},
        {type = "fluid", name = "nitric-acid", amount = 5},
        {type = "item", name = "sulfuric-waste-spores", amount = 12},
    },
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "tenecap-spore-purification",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/tenecap.png",
    category = "centrifuging",
    energy_required = 2,
    ingredients = { 
      {type = "item", name = "sulfuric-waste-spores", amount = 6},
    },
    results = {
      {type = "item", name = "tenecap-spore", amount = 4},
      {type = "item", name = "sulfur", amount = 1},
    },
    auto_recycle = false,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "chitin-processing",
    subgroup = "tenebris-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/tenecap-processing.png",
    category = "organic-or-hand-crafting",
    ingredients = { { type = "item", name = "chitin", amount = 1 } },
    results = {
      { type = "item", name = "nutrients", amount = 12 },
    },
    energy_required = 1,
    allow_productivity = true,
    main_product = "nutrients"
  },
  {
    type = "recipe",
    name = "chitosan",
    enabled = false,
    category = "chemistry",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "chitin",        amount = 8 },
      { type = "fluid", name = "nitric-acid",   amount = 50 }
    },
    results = {
      { type = "item", name = "chitosan", amount = 4 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 4,
    allow_productivity = true,
    main_product = "chitosan"
  },
  {
    type = "recipe",
    name = "chitosan-advanced-circuit",
    enabled = false,
    category = "chemistry",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "chitosan", amount = 2 },
      { type = "item",  name = "electronic-circuit", amount = 2 },
      { type = "item",  name = "copper-cable", amount = 4 },
    },
    results = {
      { type = "item", name = "advanced-circuit", amount = 1 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 4,
    allow_productivity = true,
    main_product = "advanced-circuit"
  },
  {
    type = "recipe",
    name = "chitin-concrete",
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "stone-brick",   amount = 5 },
      { type = "item",  name = "carbon",        amount = 10 },
      { type = "item",  name = "chitin",        amount = 4 },
      { type = "fluid", name = "nitric-acid",   amount = 50 }
    },
    results = { { type = "item", name = "concrete", amount = 10 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 5.0,
    main_product = "concrete"
  },
  {
    type = "recipe",
    name = "chitosan-lubricant",
    enabled = false,
    icon = "__base__/graphics/icons/fluid/lubricant.png",
    category = "cryogenics",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "chitosan",          amount = 1 },
      { type = "fluid", name = "ammonia",           amount = 30 },
      { type = "fluid", name = "fluoroketone-cold", amount = 10 },
    },
    results = { 
      { type = "fluid", name = "lubricant",         amount = 10 },
      { type = "fluid", name = "fluoroketone-hot",  amount = 10 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 2.0,
    allow_productivity = false,
    main_product = "lubricant"
  },
  {
    type = "recipe",
    name = "chitosan-carbon-fiber",
    category = "organic",
    subgroup = "tenebris-processes",
    auto_recycle = false,
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "chitosan", amount = 4},
      {type = "item", name = "carbon", amount = 1},
      {type = "fluid", name = "nitric-acid", amount = 10},
    },
    results = {
      {type="item", name="carbon-fiber", amount=1},
      {type = "fluid", name = "ammonia", amount = 10},
    },
    allow_productivity = true,
    crafting_machine_tint =
    {
      primary = {r = 9, g = 0, b = 220, a = 1.000},
      secondary = {r = 0, g = 0, b = 0, a = 1.000},
    },
    main_product = "carbon-fiber"
  },
  {
    type = "recipe",
    name = "luciferin-solid-fuel",
    enabled = false,
    category = "chemistry-or-cryogenics",
    auto_recycle = false,
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "luciferin",     amount = 8 },
      { type = "item",  name = "carbon",        amount = 5 },
      { type = "fluid", name = "ammonia",       amount = 10 },
    },
    results = { { type = "item", name = "solid-fuel", amount = 2 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 5.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "luciferin-rocket-fuel",
    enabled = false,
    category = "cryogenics-or-assembling",
    auto_recycle = false,
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item",  name = "luciferin",     amount = 8 },
      { type = "item",  name = "solid-fuel",   amount = 2 },
      { type = "fluid", name = "nitric-acid",   amount = 50 },
    },
    results = { { type = "item", name = "rocket-fuel", amount = 2 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 5.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "tenebris-stone-centrifuging",
    category = "centrifuging",
    enabled = false,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "stone", amount = 10},
        {type = "fluid", name = "sulfuric-acid", amount = 25}
    },
    results = {
        {type = "item", name = "quartz-ore", amount = 120, probability = 0.0025},
    },
    crafting_machine_tint =
    {
      primary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
      secondary = {r = 0.914, g = 0.729, b = 0.537, a = 1.000}, -- #e9ba89ff
    },
    main_product = "quartz-ore",
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    subgroup = "tenebris-processes",
  },
  {
    type = "recipe",
    name = "quartz-ore-washing",
    category = "centrifuging",
    enabled = false,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "quartz-ore", amount = 10},
        {type = "fluid", name = "nitric-acid", amount = 10},
    },
    results = {
        { type = "item", name = "quartz-crystal-seedling", amount = 1, probability = 0.05 },
    },
    main_product = "quartz-crystal-seedling",
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    subgroup = "tenebris-processes",
  },
  -- {
  --   type = "recipe",
  --   name = "quartz-crystal",
  --   category = "cryogenics",
  --   enabled = false,
  --   energy_required = 2,
  --   ingredients = {
  --       {type = "item", name = "quartz-ore", amount = 1},
  --       {type = "item", name = "quartz-crystal-seedling", amount = 1},
  --       {type = "fluid", name = "fluoroketone-cold", amount = 10}
  --   },
  --   results = {
  --       { type = "item", name = "quartz-crystal", amount = 1, probability = 0.90 },
  --       { type = "fluid", name = "fluoroketone-hot",  amount = 10 },
  --   },
  --   icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
  --   icon_size = 64,
  --   main_product = "quartz-crystal",
  --   auto_recycle = false,
  --   allow_decomposition = false,
  --   allow_productivity = true,
  --   subgroup = "tenebris-processes",
  --   order = "t[tenebris]-r[quartz-crystal]"
  -- },
  {
    type = "recipe",
    name = "quartz-crystal-reduction",
    category = "centrifuging",
    enabled = false,
    energy_required = 6,
    ingredients = {
        { type = "item", name = "quartz-crystal", amount = 1},
        {type = "fluid", name = "nitric-acid", amount = 20}
    },
    results = {
        { type = "item", name = "quartz-crystal-seedling", amount = 1, probability = 0.2 },
    },
    main_product = "quartz-crystal-seedling",
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    subgroup = "tenebris-processes",
  },
  {
    type = "recipe",
    name = "photonic-crystal",
    category = "cryogenics",
    enabled = false,
    energy_required = 2,
    ingredients = {
        { type = "item", name = "quartz-crystal", amount = 1},
        {type = "item",  name = "carbon-fiber", amount = 2},
        {type = "fluid", name = "fluoroketone-cold", amount = 10},
    },
    results = {
        { type = "item", name = "photonic-crystal", amount = 2 },
    },
    icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
    icon_size = 64,
    main_product = "photonic-crystal",
    auto_recycle = false,
    allow_productivity = true,
    subgroup = "tenebris-processes",
  },
  {
    type = "recipe",
    name = "bioluminescent-crystal-organics",
    enabled = false,
    category = "organic",
    subgroup = "tenebris-processes",
    ingredients = { 
      { type = "item", name = "quartz-crystal", amount = 1 }, 
      { type = "item", name = "luciferin", amount = 80 },
    },
    results = { { type = "item", name = "bioluminescent-crystal", amount = 1 } },
    energy_required = 3.2,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bioluminescent-crystal-forging",
    enabled = false,
    category = "cryogenics",
    subgroup = "tenebris-processes",
    ingredients = { 
      { type = "item", name = "quartz-crystal", amount = 2 }, 
      { type = "item", name = "luciferin", amount = 30 },
      { type = "fluid", name = "molten-quartziferous-bismuth", amount = 200 },
    },
    results = { { type = "item", name = "bioluminescent-crystal", amount = 2 } },
    energy_required = 1.6,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bismuth-asteroid-crushing",
    icon = "__space-age__/graphics/icons/metallic-asteroid-crushing.png",
    category = "crushing",
    subgroup = "space-crushing",
    auto_recycle = false,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "bismuth-asteroid-chunk", amount = 1},
    },
    energy_required = 2,
    results =
    {
      {type = "item", name = "bismuth-ore", amount = 10},
      {type = "item", name = "bismuth-asteroid-chunk", amount = 1, probability = 0.2}
    },
    allow_productivity = true,
    allow_decomposition = false
  },
  {
    type = "recipe",
    name = "bismuth-ore-melting",
    icon = "__space-age__/graphics/icons/fluid/molten-copper.png",
    enabled = false,
    auto_recycle = false,
    category = "metallurgy",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item", name = "quartz-ore", amount = 10 },
      { type = "item", name = "bismuth-ore", amount = 50 },
      { type = "item", name = "calcite", amount = 1 },
    },
    results = {
      { type = "item", name = "stone", amount = 20 },
      { type = "fluid", name = "molten-quartziferous-bismuth", amount = 500 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 4000,
        max = 18000
      }
    },
    energy_required = 32,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "quartziferous-bismuthal-plate",
    enabled = false,
    auto_recycle = false,
    category = "metallurgy",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "fluid", name = "molten-quartziferous-bismuth", amount = 40 },
    },
    results = {
      { type = "item", name = "quartziferous-bismuthal-plate", amount = 2 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    main_product = "quartziferous-bismuthal-plate",
    energy_required = 3.2,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "sulfuric-fluoroketone",
    icon = "__space-age__/graphics/icons/fluid/fluoroketone-hot.png",
    enabled = false,
    auto_recycle = false,
    category = "cryogenics",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item", name = "solid-fuel", amount = 5 },
      { type = "item", name = "sulfur", amount = 10 },
      { type = "fluid", name = "ammonia", amount = 50 },
      { type = "fluid", name = "fluorine", amount = 50 },
    },
    results = {
      { type = "fluid", name = "fluoroketone-hot", amount = 50 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 10,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "luciferin-explosives",
    icon = "__base__/graphics/icons/explosives.png",
    enabled = false,
    auto_recycle = false,
    category = "cryogenics",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item", name = "luciferin", amount = 12 },
      { type = "item", name = "sulfur", amount = 1 },
      { type = "fluid", name = "ammonia", amount = 10 }
    },
    results = {
      { type = "item", name = "explosives", amount = 2 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 4,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "ammonic-acidification",
    icon = "__space-age__/graphics/icons/fluid/ammonia.png",
    enabled = false,
    auto_recycle = false,
    category = "cryogenics",
    subgroup = "tenebris-processes",
    ingredients = {
      { type = "item", name = "luciferin", amount = 20 },
      { type = "fluid", name = "ammonia", amount = 10 }
    },
    results = {
      { type = "fluid", name = "nitric-acid", amount = 10 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 6,
    allow_productivity = true
  },
  meld(table.deepcopy(data.raw["recipe"]["rocket-part"]), {
    name = "tenebris-rocket-part",
    enabled = false,
    auto_recycle = false,
    order = data.raw.item["rocket-part"].order .. "-t[tenebris-rocket-part]",
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    ingredients =
    {
      {type = "item", name = "processing-unit", amount = 10},
      {type = "item", name = "carbon-fiber", amount = 20},
      {type = "item", name = "rocket-fuel", amount = 10},
      {type = "item", name = "bioluminescent-crystal", amount = 10}
    },
  }),
  {
    type = "recipe",
    name = "lightless-science-pack",
    enabled = false,
    category = "cryogenics",
    ingredients = {
      { type = "item",  name = "tenecap-spore",         amount = 4 },
      { type = "item",  name = "chitosan",              amount = 1 },
      { type = "item",  name = "photonic-crystal",      amount = 1 },
    },
    results = { { type = "item", name = "lightless-science-pack", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 4,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "lightless-beacon",
    category = "crafting",
    subgroup = "agriculture-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
    ingredients = { { type = "item", name = "chitosan", amount = 1 } },
    results = {
      { type = "item", name = "lightless-beacon", amount = 1 },
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
      type = "recipe",
      name = "bioluminescent-science-pack",
      enabled = false,
      category = "bioinfusion",
      ingredients = {
          { type = "item", name = "lightless-science-pack", amount = 1 },
      },
      results = { { type = "item", name = "bioluminescent-science-pack", amount = 1 } },
      energy_required = 1.0,
      allow_productivity = true,
  },
  {
    type = "recipe",
    name = "tenebris-bioinfusor",
    enabled = false,
    category = "cryogenics",
    ingredients = {
      { type = "item", name = "bioluminescent-crystal", amount = 100 },
      { type = "item", name = "quantum-processor",      amount = 200 },
      { type = "item", name = "electromagnetic-plant",  amount = 1 },
      { type = "item", name = "chitosan",               amount = 100 }
    },
    results = { { type = "item", name = "tenebris-bioinfusor", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 5.0,
  },
  {
    type = "recipe",
    name = "tenebris-biobeacon",
    enabled = false,
    category = "cryogenics",
    ingredients = {
      { type = "fluid", name = "fluoroketone-cold",             amount = 200 },
      { type = "item",  name = "bioluminescent-crystal",        amount = 16 },
      { type = "item",  name = "quartziferous-bismuthal-plate", amount = 30 },
      { type = "item",  name = "beacon",                        amount = 2 },
      { type = "item",  name = "quantum-processor",             amount = 50 },
    },
    results = { { type = "item", name = "tenebris-biobeacon", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 18000,
        max = 18000
      }
    },
    energy_required = 10.0,
  }
})