data:extend({
  {
    type = "recipe",
    name = "quartz-crystal",
    enabled = false,
    category = "smelting",
    energy_required = 3.2,
    ingredients = { { type = "item", name = "quartz-ore", amount = 8 } },
    results = { { type = "item", name = "quartz-crystal", amount = 1 } },
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bioluminescent-crystal",
    enabled = false,
    category = "crafting",
    ingredients = { { type = "item", name = "quartz-crystal", amount = 1 }, { type = "item", name = "luciferin", amount = 16 } },
    results = { { type = "item", name = "bioluminescent-crystal", amount = 1 } },
    energy_required = 3.2,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "lucifunnel-processing",
    subgroup = "agriculture-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/lucifunnel-processing.png",
    category = "crafting",
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
    subgroup = "agriculture-processes",
    enabled = false,
    icon = "__tenebris-prime__/graphics/icons/tenecap-processing.png",
    category = "crafting",
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
    name = "bio-agricultural-tower",
    enabled = false,
    localised_name = { "entity-name.bioluminescent-entity", { "entity-name.agricultural-tower" } },
    group = "bioluminescent",
    ingredients = {
      { type = "item", name = "steel-plate",            amount = 10 },
      { type = "item", name = "electronic-circuit",     amount = 3 },
      { type = "item", name = "bioluminescent-crystal", amount = 4 }
    },
    results = {
      { type = "item", name = "bioluminescent-agricultural-tower", amount = 1 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bio-biochamber",
    enabled = false,
    localised_name = { "entity-name.bioluminescent-entity", { "entity-name.biochamber" } },
    group = "bioluminescent",
    ingredients = {
      { type = "item", name = "iron-plate",             amount = 20 },
      { type = "item", name = "electronic-circuit",     amount = 5 },
      { type = "item", name = "chitosan",               amount = 10 },
      { type = "item", name = "bioluminescent-crystal", amount = 4 }
    },
    results = {
      { type = "item", name = "bioluminescent-biochamber", amount = 1 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "biopolymer",
    enabled = false,
    category = "organic",
    ingredients = {
      { type = "item", name = "chitin", amount = 1 },
    },
    results = {
      { type = "item", name = "plastic-bar", amount = 4 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 1,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "chitosan",
    enabled = false,
    category = "chemistry",
    ingredients = {
      { type = "item",  name = "chitin",        amount = 8 },
      { type = "fluid", name = "sulfuric-acid", amount = 50 }
    },
    results = {
      { type = "item", name = "chitosan", amount = 4 },
    },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 2,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bioluminescent-science-pack",
    enabled = false,
    category = "crafting",
    ingredients = {
      { type = "item", name = "bioluminescent-crystal", amount = 1 },
      { type = "item", name = "chitosan",               amount = 1 }
    },
    results = { { type = "item", name = "bioluminescent-science-pack", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 15,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "bioinfusor",
    enabled = false,
    category = "crafting",
    ingredients = {
      { type = "item", name = "bioluminescent-crystal", amount = 4 },
      { type = "item", name = "steel-plate",            amount = 10 },
      { type = "item", name = "electronic-circuit",     amount = 3 },
    },
    results = { { type = "item", name = "bioinfusor", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 5.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "chitin-concrete",
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    ingredients = {
      { type = "item",  name = "stone-brick",   amount = 5 },
      { type = "item",  name = "iron-ore",      amount = 1 },
      { type = "item",  name = "chitin",        amount = 1 },
      { type = "fluid", name = "sulfuric-acid", amount = 15 }
    },
    results = { { type = "item", name = "concrete", amount = 10 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 5.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "chitosan-lubricant",
    enabled = false,
    category = "chemistry",
    subgroup = "fluid-recipes",
    ingredients = {
      { type = "item",  name = "chitosan",      amount = 1 },
      { type = "fluid", name = "sulfuric-acid", amount = 15 },
    },
    results = { { type = "fluid", name = "lubricant", amount = 15 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 2.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "luciferin-rocket-fuel",
    enabled = false,
    category = "crafting-with-fluid",
    auto_recycle = false,
    ingredients = {
      { type = "item",  name = "luciferin",     amount = 8 },
      { type = "fluid", name = "sulfuric-acid", amount = 15 },
    },
    results = { { type = "item", name = "rocket-fuel", amount = 15 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 5.0,
    allow_productivity = true
  },
  {
    type = "recipe",
    name = "biobeacon",
    enabled = false,
    category = "crafting",
    ingredients = {
      { type = "item", name = "bioluminescent-crystal", amount = 16 },
      { type = "item", name = "supercapacitor",         amount = 8 },
      { type = "item", name = "electronic-circuit",     amount = 20 },
      { type = "item", name = "advanced-circuit",       amount = 20 },
    },
    results = { { type = "item", name = "biobeacon", amount = 1 } },
    surface_conditions = {
      {
        property = "pressure",
        min = 3000,
        max = 3000
      }
    },
    energy_required = 10.0,
    allow_productivity = true
  },
})
