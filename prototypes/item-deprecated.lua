local item_sounds = require("__base__.prototypes.item_sounds")
local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local meld = require("meld")

local ticks_per_minute = 60 * 60


local lightless_science_pack = meld(
    table.deepcopy(data.raw["tool"]["automation-science-pack"]), {
        name = "lightless-science-pack",
        icon = "__space-age__/graphics/icons/promethium-science-pack.png",
        subgroup = "science-pack",
        order = "t[tenebris]-a[lightless_science_pack]",
        pictures = meld.overwrite {
            scale = 0.5,
            size = 64,
            filename = "__space-age__/graphics/icons/promethium-science-pack.png",
            draw_as_glow = true,
        }
    })

local bioluminescent_science_pack = meld(
    table.deepcopy(data.raw["tool"]["automation-science-pack"]), {
        name = "bioluminescent-science-pack",
        icon = "__tenebris-prime__/graphics/icons/bioluminescent-science-pack.png",
        subgroup = "science-pack",
        order = "t[tenebris]-b[bioluminescent_science_pack]",
        pictures = meld.overwrite {
            scale = 0.5,
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/bioluminescent-science-pack.png",
            draw_as_glow = true,
        },
        spoil_result = "lightless-science-pack",
        spoil_ticks = ticks_per_minute * 120
    })

data:extend({
    {
        type = "item",
        name = "observation-satellite",
        icon = "__base__/graphics/icons/satellite.png",
        subgroup = "deep-space-sensing",
        inventory_move_sound = item_sounds.mechanical_inventory_move,
        pick_sound = item_sounds.mechanical_inventory_pickup,
        drop_sound = item_sounds.mechanical_inventory_move,
        stack_size = 1,
        weight = 1 * tons,
        send_to_orbit_mode = "automated"
    },
    {
        type = "item",
        name = "lucifunnel",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/lucifunnel.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/lucifunnel.png",
            scale = 0.5,
            draw_as_glow = true,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
        fuel_category = "chemical", 
        fuel_value = "4MJ", 
        spoil_result = "spoilage", 
        spoil_ticks = ticks_per_minute * 15
    },
    {
        type = "item",
        name = "lucifunnel-seed",
        localised_name = { "item-name.lucifunnel-seed" },
        icon = "__tenebris-prime__/graphics/icons/lucifunnel-seed.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/lucifunnel-seed.png",
            scale = 0.5,
            mipmap_count = 4,
            draw_as_glow = true
        },
        subgroup = "tenebris-processes",
        inventory_move_sound = item_sounds.wood_inventory_move,
        plant_result = "lucifunnel",
        place_result = "lucifunnel",
        stack_size = 10,
        default_import_location = "tenebris",
        fuel_category = "chemical",
        fuel_value = "100kJ",
        weight = 10 * kg,
    },
    {
        type = "item",
        name = "tenecap",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/tenecap.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenecap.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        weight = weight or (2 * kg),
        default_import_location = "tenebris",
        spoil_result = "tenecap-spore", 
        spoil_ticks = ticks_per_minute * 20
    },
    {
        type = "item",
        name = "tenecap-spore",
        localised_name = { "item-name.tenecap-spore" },
        icon = "__tenebris-prime__/graphics/icons/tenecap-spore.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenecap-spore.png",
            scale = 0.5,
        },
        subgroup = "tenebris-processes",
        inventory_move_sound = item_sounds.wood_inventory_move,
        plant_result = "tenecap",
        place_result = "tenecap",
        stack_size = 20,
        default_import_location = "tenebris",
        fuel_category = "chemical",
        fuel_value = "100kJ",
        weight = 5 * kg,
    },
    {
        type = "item",
        name = "sulfuric-waste-spores",
        icon = "__tenebris-prime__/graphics/icons/tenecap-spore.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenecap-spore.png",
            scale = 0.5,
        },
        subgroup = "tenebris-processes",
        inventory_move_sound = item_sounds.wood_inventory_move,
        stack_size = 20,
        default_import_location = "tenebris",
        fuel_category = "chemical",
        fuel_value = "100kJ",
        weight = 5 * kg,
    },
    {
        type = "item",
        name = "quartz-ore",
        icon = "__tenebris-prime__/graphics/icons/quartz-ore.png",
        subgroup = "tenebris-processes",
        pictures =
        {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/quartz-ore.png",
            scale = 0.5,
            mipmap_count = 4,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        default_import_location = "tenebris",
        stack_size = 50,
        weight = 2 * kg
    },
    {
        type = "item",
        name = "luciferin",
        subgroup = "tenebris-processes",
        icon = "__tenebris-prime__/graphics/icons/luciferin.png",
        stack_size = 100,
        fuel_category = "chemical",
        fuel_value = "1MJ",
        pictures = {
            scale = 0.5,
            width = 64,
            height = 64,
            filename = "__tenebris-prime__/graphics/icons/luciferin.png",
            draw_as_glow = true,
        },
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "chitin",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/chitin.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/chitin.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "chitosan",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/chitosan.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/chitosan.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "quartz-crystal",
        subgroup = "tenebris-processes",
        stack_size = 100,
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.rock_inventory_move,
        pick_sound = item_sounds.rock_inventory_pickup,
        drop_sound = item_sounds.rock_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "quartz-crystal-seedling",
        subgroup = "tenebris-processes",
        stack_size = 5,
        icon = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
        icon_size = 256,
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/entity/quartz-node/quartz-node-2.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.rock_inventory_move,
        pick_sound = item_sounds.rock_inventory_pickup,
        drop_sound = item_sounds.rock_inventory_move,
        plant_result = "quartz-node",
        place_result = "quartz-node",
        weight = 0.5 * kg,
        default_import_location = "tenebris",
        spoil_result = "quartz-crystal", 
        spoil_ticks = ticks_per_minute * 6
    },
    {
        type = "item",
        name = "photonic-crystal",
        subgroup = "tenebris-processes",
        stack_size = 100,
        icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.rock_inventory_move,
        pick_sound = item_sounds.rock_inventory_pickup,
        drop_sound = item_sounds.rock_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "ferric-waste",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/ferric-waste.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/ferric-waste.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_drop,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "cupric-waste",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/cupric-waste.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/cupric-waste.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_drop,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "electronic-waste",
        subgroup = "tenebris-processes",
        stack_size = 50,
        icon = "__tenebris-prime__/graphics/icons/electronic-waste.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/electronic-waste.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.electric_small_inventory_move,
        pick_sound = item_sounds.electric_small_inventory_pickup,
        drop_sound = item_sounds.electric_small_inventory_drop,
        weight = 2 * kg,
        default_import_location = "tenebris",
    },
    {
        type = "item",
        name = "bioluminescent-crystal",
        subgroup = "tenebris-processes",
        stack_size = 100,
        icon = "__tenebris-prime__/graphics/icons/bioluminescent-crystal.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/bioluminescent-crystal.png",
            scale = 0.5,
            draw_as_glow = true,
        },
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
        weight = 2 * kg,
        default_import_location = "tenebris",
        fuel_category = "bioluminescent", 
        fuel_value = "100kJ"
    },
    {
        type = "item",
        name = "bismuth-ore",
        subgroup = "tenebris-processes",
        icon = "__base__/graphics/icons/copper-ore.png",
        pictures = {
            size = 64,
            filename = "__base__/graphics/icons/copper-ore.png",
            scale = 0.5,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 50,
        weight = 4 * kg
    },
    {
      type = "item",
      name = "quartziferous-bismuthal-plate",
      icon = "__base__/graphics/icons/copper-plate.png",
      subgroup = "tenebris-processes",
      inventory_move_sound = item_sounds.metal_small_inventory_move,
      pick_sound = item_sounds.metal_small_inventory_pickup,
      drop_sound = item_sounds.metal_small_inventory_move,
      stack_size = 100
    },
    {
        type = "item",
        name = "tenebris-bioinfusor",
        subgroup = "tenebris-machines",
        order = "t[tenebris]-a[tenebris-bioinfusor]",
        stack_size = 10,
        icon = "__tenebris-prime__/graphics/icons/tenebris-bioinfusor.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenebris-bioinfusor.png",
            scale = 0.5,
            draw_as_glow = true,
        },
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        weight = 100 * kg,
        default_import_location = "tenebris",
        place_result = "tenebris-bioinfusor"
    },
    {
        type = "item",
        name = "tenebris-biobeacon",
        subgroup = "tenebris-machines",
        order = "t[tenebris]-b[tenebris-biobeacon]",
        stack_size = 10,
        icon = "__tenebris-prime__/graphics/icons/tenebris-biobeacon.png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenebris-biobeacon.png",
            scale = 0.5,
            draw_as_glow = true,
        },
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        weight = 100 * kg,
        default_import_location = "tenebris",
        place_result = "tenebris-biobeacon"
    },
    {
        type = "module",
        name = "spore-removal-module",
        localised_description = {"item-description.speed-module"},
        icon = "__base__/graphics/icons/speed-module.png",
        subgroup = "module",
        color_hint = { text = "S" },
        category = "efficiency",
        tier = 3,
        order = "t[tenebris]-a[tenebris-spore-removal-module]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 20 * kg,
        effect = {pollution = 0.3, consumption = 0.5},
        beacon_tint =
        {
          primary = {0.423, 0.0, 0.632, 1.000}, -- #6C00A1FF
          secondary = {0.631, 0.137, 0.82, 1.000}, -- #A123D1FF
        },
        default_import_location = "tenebris",
        art_style = "vanilla",
        requires_beacon_alt_mode = false
    },
    {
        type = "item",
        name = "tenebris-heated-air-scrubber",
        subgroup = "tenebris-machines",
        icon = "__atan-air-scrubbing__/graphics/icons/air-scrubber.png",
        inventory_move_sound = item_sounds.mechanical_inventory_move,
        pick_sound = item_sounds.mechanical_inventory_pickup,
        drop_sound = item_sounds.mechanical_inventory_move,
        place_result = "tenebris-heated-air-scrubber",
        stack_size = 20,
        weight = 50 * kg,
    },
    {
        type = "item",
        name = "tenebris-spore-filter",
        subgroup = "atan-filters",
        icon = "__atan-air-scrubbing__/graphics/icons/pollution-filter.png",
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
        stack_size = 50,
        weight = 10 * kg,
    },
    {
        type = "item",
        name = "tenebris-used-spore-filter",
        subgroup = "atan-filters",
        icon = "__atan-air-scrubbing__/graphics/icons/used-pollution-filter.png",
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
        stack_size = 50,
        weight = 15 * kg,
    },
    {
        type = "item",
        name = "lightless-beacon",
        icon = "__tenebris-prime__/graphics/icons/tenebris-biobeacon.png",
        pictures =
        {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/tenebris-biobeacon.png",
            scale = 0.5,
            draw_as_glow = true,
        },
        subgroup = "tenebris-machines",
        order = "t[tenebris]-c[lightless-beacon]",
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        stack_size = 50,
        weight = 2 * kg
    },
    {
        type = "item",
        name = "bismuth-asteroid-chunk",
        icon = "__space-age__/graphics/icons/promethium-asteroid-chunk.png",
        subgroup = "space-material",
        order = "t[tenebris]-a[bismuth-asteroid-chunk]",
        inventory_move_sound = space_age_item_sounds.rock_inventory_move,
        pick_sound = space_age_item_sounds.rock_inventory_pickup,
        drop_sound = space_age_item_sounds.rock_inventory_move,
        stack_size = 1,
        weight = 100 * kg,
        random_tint_color = item_tints.iron_rust
    },
    bioluminescent_science_pack,
    lightless_science_pack,
    
    -- Chitosan chain
    {
        type = "item",
        name = "chitosan",
        icon = "__base__/graphics/icons/plastic-bar.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[chitosan]",
        stack_size = 100,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.plastic_inventory_move,
        pick_sound = item_sounds.plastic_inventory_pickup,
        drop_sound = item_sounds.plastic_inventory_move,
    },
    {
        type = "item",
        name = "chitin-barrel",
        icon = "__base__/graphics/icons/fluid/empty-barrel.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[chitin-barrel]",
        stack_size = 10,
        weight = 5 * kg,
        inventory_move_sound = item_sounds.metal_barrel_inventory_move,
        pick_sound = item_sounds.metal_barrel_inventory_pickup,
        drop_sound = item_sounds.metal_barrel_inventory_move,
    },
    
    -- Waste products
    {
        type = "item",
        name = "circuit-waste",
        icon = "__base__/graphics/icons/electronic-circuit.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-w[circuit-waste]",
        stack_size = 100,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.electric_small_inventory_move,
        pick_sound = item_sounds.electric_small_inventory_pickup,
        drop_sound = item_sounds.electric_small_inventory_move,
    },
    
    -- Mineral processing
    {
        type = "item",
        name = "cinnabar",
        icon = "__base__/graphics/icons/iron-ore.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-m[cinnabar]",
        stack_size = 50,
        weight = 2 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "quartz-geode",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-m[quartz-geode]",
        stack_size = 50,
        weight = 5 * kg,
        inventory_move_sound = space_age_item_sounds.rock_inventory_move,
        pick_sound = space_age_item_sounds.rock_inventory_pickup,
        drop_sound = space_age_item_sounds.rock_inventory_move,
    },
    
    -- Gemstones
    {
        type = "item",
        name = "onyx",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[onyx]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "citrine",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[citrine]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "praslolite",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[praslolite]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "amethyst",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[amethyst]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "ruby-agate",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[ruby-agate]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "sapphire-agate",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-g[sapphire-agate]",
        stack_size = 100,
        weight = 0.5 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    
    -- Ceramic products
    {
        type = "item",
        name = "ceramic-plate",
        icon = "__base__/graphics/icons/steel-plate.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[ceramic-plate]",
        stack_size = 100,
        weight = 2 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "ceramic-filter",
        icon = "__base__/graphics/icons/iron-stick.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[ceramic-filter]",
        stack_size = 50,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "used-ceramic-filter",
        icon = "__base__/graphics/icons/iron-stick.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[used-ceramic-filter]",
        stack_size = 50,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "carbon-spore-filter",
        icon = "__base__/graphics/icons/iron-stick.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[carbon-spore-filter]",
        stack_size = 50,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "used-carbon-spore-filter",
        icon = "__base__/graphics/icons/iron-stick.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[used-carbon-spore-filter]",
        stack_size = 50,
        weight = 1 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "crystal-seedling",
        icon = "__base__/graphics/icons/coal.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[crystal-seedling]",
        stack_size = 50,
        weight = 0.1 * kg,
        inventory_move_sound = space_age_item_sounds.calcite_inventory_move,
        pick_sound = space_age_item_sounds.calcite_inventory_pickup,
        drop_sound = space_age_item_sounds.calcite_inventory_move,
    },
    {
        type = "item",
        name = "ceramic-circuitry",
        icon = "__base__/graphics/icons/electronic-circuit.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[ceramic-circuitry]",
        stack_size = 200,
        weight = 0.5 * kg,
        inventory_move_sound = item_sounds.electric_small_inventory_move,
        pick_sound = item_sounds.electric_small_inventory_pickup,
        drop_sound = item_sounds.electric_small_inventory_move,
    },
    {
        type = "item",
        name = "ceramic-robot-frame",
        icon = "__base__/graphics/icons/flying-robot-frame.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-c[ceramic-robot-frame]",
        stack_size = 50,
        weight = 2 * kg,
        inventory_move_sound = item_sounds.robotic_inventory_move,
        pick_sound = item_sounds.robotic_inventory_pickup,
        drop_sound = item_sounds.robotic_inventory_move,
    },
    
    -- Mercury products
    {
        type = "item",
        name = "cupric-mercury-amalgam",
        icon = "__base__/graphics/icons/copper-plate.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-m[cupric-mercury-amalgam]",
        stack_size = 100,
        weight = 2 * kg,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    
    -- Piezoelectric products
    {
        type = "item",
        name = "piezoelectric-converter",
        icon = "__base__/graphics/icons/accumulator.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-p[piezoelectric-converter]",
        stack_size = 50,
        weight = 5 * kg,
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
    },
    {
        type = "item",
        name = "piezoelectric-motor",
        icon = "__base__/graphics/icons/engine-unit.png", -- Placeholder
        subgroup = "tenebris-processes",
        order = "t[tenebris]-p[piezoelectric-motor]",
        stack_size = 50,
        weight = 3 * kg,
        inventory_move_sound = item_sounds.mechanical_inventory_move,
        pick_sound = item_sounds.mechanical_inventory_pickup,
        drop_sound = item_sounds.mechanical_inventory_move,
    },
    
    -- Tools and equipment
    {
        type = "repair-tool",
        name = "tenebris-repair-pack",
        icon = "__base__/graphics/icons/repair-pack.png", -- Placeholder
        subgroup = "tool",
        order = "t[tenebris]-r[repair-pack]",
        stack_size = 100,
        weight = 0.5 * kg,
        durability = 300,
        inventory_move_sound = item_sounds.mechanical_inventory_move,
        pick_sound = item_sounds.mechanical_inventory_pickup,
        drop_sound = item_sounds.mechanical_inventory_move,
    },
    
    -- Machines and buildings (placing entities)
    {
        type = "item",
        name = "heated-atmosphere-scrubber",
        icon = "__base__/graphics/icons/chemical-plant.png", -- Placeholder
        subgroup = "tenebris-machines",
        order = "t[tenebris]-m[heated-atmosphere-scrubber]",
        stack_size = 50,
        weight = 20 * kg,
        place_result = "heated-atmosphere-scrubber",
        inventory_move_sound = item_sounds.mechanical_large_inventory_move,
        pick_sound = item_sounds.mechanical_large_inventory_pickup,
        drop_sound = item_sounds.mechanical_large_inventory_move,
    },
    {
        type = "item",
        name = "heated-agricultural-tower",
        icon = "__space-age__/graphics/icons/agricultural-tower.png", -- Placeholder
        subgroup = "tenebris-machines",
        order = "t[tenebris]-m[heated-agricultural-tower]",
        stack_size = 20,
        weight = 50 * kg,
        place_result = "heated-agricultural-tower",
        inventory_move_sound = item_sounds.mechanical_large_inventory_move,
        pick_sound = item_sounds.mechanical_large_inventory_pickup,
        drop_sound = item_sounds.mechanical_large_inventory_move,
    },
    {
        type = "item",
        name = "quartz-ortet-robo-interface",
        icon = "__base__/graphics/icons/roboport.png", -- Placeholder
        subgroup = "tenebris-machines",
        order = "t[tenebris]-m[quartz-ortet-robo-interface]",
        stack_size = 10,
        weight = 100 * kg,
        place_result = "quartz-ortet-robo-interface",
        inventory_move_sound = item_sounds.robotic_inventory_move,
        pick_sound = item_sounds.robotic_inventory_pickup,
        drop_sound = item_sounds.robotic_inventory_move,
    },
    
    -- Pipes
    {
        type = "item",
        name = "chitosan-pipe",
        icon = "__base__/graphics/icons/pipe.png", -- Placeholder
        subgroup = "energy-pipe-distribution",
        order = "t[tenebris]-p[chitosan-pipe]",
        stack_size = 100,
        weight = 1 * kg,
        place_result = "chitosan-pipe",
        inventory_move_sound = item_sounds.pipe_inventory_move,
        pick_sound = item_sounds.pipe_inventory_pickup,
        drop_sound = item_sounds.pipe_inventory_move,
    },
    {
        type = "item",
        name = "chitosan-underground-pipe",
        icon = "__base__/graphics/icons/pipe-to-ground.png", -- Placeholder
        subgroup = "energy-pipe-distribution",
        order = "t[tenebris]-p[chitosan-underground-pipe]",
        stack_size = 50,
        weight = 2 * kg,
        place_result = "chitosan-underground-pipe",
        inventory_move_sound = item_sounds.pipe_inventory_move,
        pick_sound = item_sounds.pipe_inventory_pickup,
        drop_sound = item_sounds.pipe_inventory_move,
    },
    {
        type = "item",
        name = "ceramic-plated-heat-pipe",
        icon = "__base__/graphics/icons/heat-pipe.png", -- Placeholder
        subgroup = "energy-pipe-distribution",
        order = "t[tenebris]-p[ceramic-plated-heat-pipe]",
        stack_size = 50,
        weight = 5 * kg,
        place_result = "ceramic-plated-heat-pipe",
        inventory_move_sound = item_sounds.pipe_inventory_move,
        pick_sound = item_sounds.pipe_inventory_pickup,
        drop_sound = item_sounds.pipe_inventory_move,
    },
    
    -- Inserters and logistics
    {
        type = "item",
        name = "piezoelectrical-inserter",
        icon = "__base__/graphics/icons/inserter.png", -- Placeholder
        subgroup = "inserter",
        order = "t[tenebris]-i[piezoelectrical-inserter]",
        stack_size = 50,
        weight = 2 * kg,
        place_result = "piezoelectrical-inserter",
        inventory_move_sound = item_sounds.inserter_inventory_move,
        pick_sound = item_sounds.inserter_inventory_pickup,
        drop_sound = item_sounds.inserter_inventory_move,
    },
    
    -- Robots
    {
        type = "item",
        name = "ceramic-construction-robot",
        icon = "__base__/graphics/icons/construction-robot.png", -- Placeholder
        subgroup = "logistic-network",
        order = "t[tenebris]-r[ceramic-construction-robot]",
        stack_size = 50,
        weight = 1 * kg,
        place_result = "ceramic-construction-robot",
        inventory_move_sound = item_sounds.robotic_inventory_move,
        pick_sound = item_sounds.robotic_inventory_pickup,
        drop_sound = item_sounds.robotic_inventory_move,
    },
    {
        type = "item",
        name = "ceramic-logistic-robot",
        icon = "__base__/graphics/icons/logistic-robot.png", -- Placeholder
        subgroup = "logistic-network",
        order = "t[tenebris]-r[ceramic-logistic-robot]",
        stack_size = 50,
        weight = 1 * kg,
        place_result = "ceramic-logistic-robot",
        inventory_move_sound = item_sounds.robotic_inventory_move,
        pick_sound = item_sounds.robotic_inventory_pickup,
        drop_sound = item_sounds.robotic_inventory_move,
    },
    
    -- Capsules
    {
        type = "capsule",
        name = "piezoelectric-converter-capture-bot-rocket",
        icon = "__base__/graphics/icons/defender-capsule.png", -- Placeholder
        subgroup = "capsule",
        order = "t[tenebris]-c[piezoelectric-converter-capture-bot-rocket]",
        stack_size = 100,
        weight = 0.5 * kg,
        capsule_action = {
            type = "throw",
            attack_parameters = {
                type = "projectile",
                activation_type = "throw",
                ammo_category = "capsule",
                cooldown = 30,
                projectile_creation_distance = 0.6,
                range = 20,
                ammo_type = {
                    category = "capsule",
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "projectile",
                            projectile = "defender-capsule", -- Placeholder, needs custom projectile
                            starting_speed = 0.3
                        }
                    }
                }
            }
        },
        inventory_move_sound = item_sounds.ammo_small_inventory_move,
        pick_sound = item_sounds.ammo_small_inventory_pickup,
        drop_sound = item_sounds.ammo_small_inventory_move,
    },
})
