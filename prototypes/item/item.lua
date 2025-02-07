local item_sounds = require("__base__.prototypes.item_sounds")
local meld = require("meld")

---Creates a basic item
---@param name string name of the item
---@param stack_size integer? The stack size of the item
---@param weight integer? The weight of the item
---@param glow boolean? Does this item glow?
---@param size int? The size of the icon image
---@param extra table? Extra parameters to set?
---@return table
local function quick_item(name, stack_size, weight, glow, extra)
    return meld({
        type = "item",
        name = name,
        subgroup = "intermediate-product",
        stack_size = stack_size or 100,
        icon = "__tenebris-prime__/graphics/icons/" .. name .. ".png",
        pictures = {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/" .. name .. ".png",
            scale = 0.5,
            draw_as_glow = glow or false,
        },
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        weight = weight or (2 * kg)
    }, extra or {})
end

local bioluminescent_science_pack = meld(
    table.deepcopy(data.raw["tool"]["automation-science-pack"]), {
        name = "bioluminescent-science-pack",
        icon = "__tenebris-prime__/graphics/icons/bioluminescent-science-pack.png",
        order = "k[bioluminescent_science_pack]",
        pictures = meld.overwrite {
            scale = 0.5,
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/bioluminescent-science-pack.png",
            draw_as_glow = true,
        }
    })

data:extend({
    {
        type = "item",
        name = "luciferin",
        subgroup = "intermediate-recipe",
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
        }
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
        subgroup = "agriculture-processes",
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
        name = "quartz-ore",
        group = "intermediate-products",
        icon = "__tenebris-prime__/graphics/icons/quartz-ore.png",
        pictures =
        {
            size = 64,
            filename = "__tenebris-prime__/graphics/icons/quartz-ore.png",
            scale = 0.5,
            mipmap_count = 4,
        },
        subgroup = "raw-resource",
        color_hint = { text = "I" },
        order = "e[quartz-ore]",
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 50,
        weight = 2 * kg
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
        subgroup = "agriculture-processes",
        inventory_move_sound = item_sounds.wood_inventory_move,
        plant_result = "tenecap",
        place_result = "tenecap",
        stack_size = 20,
        default_import_location = "tenebris",
        fuel_category = "chemical",
        fuel_value = "100kJ",
        weight = 5 * kg,
    },
    quick_item("quartz-crystal", 100, 2 * kg),
    quick_item("bioluminescent-crystal", 100, 2 * kg, true, { fuel_category = "bioluminescent", fuel_value = "500kJ", }),
    quick_item("lucifunnel", 50, 2 * kg, true, { fuel_category = "chemical", fuel_value = "4MJ" }),
    quick_item("chitin", 50, 2 * kg, false),
    quick_item("tenecap", 50, 2 * kg, false),
    quick_item("chitosan", 50, 2 * kg, false),
    quick_item("bioinfusor", 10, 100 * kg, false, { subgroup = "bioluminescent-production-machine", place_result = "bioinfusor" }),
    quick_item("biobeacon", 10, 100 * kg, false,{ subgroup = "bioluminescent-production-machine", place_result = "biobeacon" }),
    bioluminescent_science_pack
})
