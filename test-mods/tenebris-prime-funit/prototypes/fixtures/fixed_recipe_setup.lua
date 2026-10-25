-- Reproduces the prototype shape of the Heat Management conflict.
--
-- TFMG Thermal's "ground-radiator" is an assembling machine with the fixed
-- recipe "TFMG-heat-radiation" in the "radiator" category. Heat Management, in
-- its data-updates stage, turns the radiator into a coolant machine: it clears
-- fixed_recipe and moves the machine to the "radiator-coolant" category.
--
-- Tenebris Prime copies the radiator in data.lua, before that update, and its
-- data-final-fixes took only the new crafting categories from the base. The
-- copy kept the old fixed recipe, whose category the copy no longer allowed,
-- and the game refused to load:
--
--   fixed_recipe="TFMG-heat-radiation" cannot be used on this machine.
--   Reason=DifferentCategory
--
-- This fixture imitates that shape without requiring either mod: the setup is
-- made in data.lua, so Tenebris Prime's data-updates pass copies it, and the
-- update fixture then changes the base the way Heat Management does.

local crusher = data.raw["assembling-machine"]["crusher"]
local crusher_item = data.raw["item"]["crusher"]

assert(crusher, "tenebris-prime-funit needs the Space Age crusher prototype")
assert(crusher_item, "tenebris-prime-funit needs the Space Age crusher item")

data:extend({
    { type = "recipe-category", name = "funit-radiator" },
    {
        type = "recipe",
        name = "funit-heat-radiation",
        icon = "__base__/graphics/icons/signal/signal-fire.png",
        categories = { "funit-radiator" },
        enabled = false,
        hidden = true,
        ingredients = {},
        results = {},
    },
})

local entity = table.deepcopy(crusher)
entity.name = "funit-radiator"
entity.localised_name = { "entity-name.crusher" }
entity.minable = { mining_time = 0.2, result = "funit-radiator" }
entity.crafting_categories = { "funit-radiator" }
entity.fixed_recipe = "funit-heat-radiation"
entity.fluid_boxes = nil

local item = table.deepcopy(crusher_item)
item.name = "funit-radiator"
item.localised_name = { "item-name.crusher" }
item.place_result = "funit-radiator"
item.order = "z[funit-funit-radiator]"

data:extend({ entity, item })
