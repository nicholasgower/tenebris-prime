-- Data-updates stage of the fixed-recipe fixture, imitating Heat Management.
--
-- The base radiator stops using its fixed heat-radiation recipe and becomes a
-- coolant machine with its own fluid boxes. The bioluminescent copy still has
-- the categories and the fixed recipe it was made with at that point.

data:extend({
    { type = "recipe-category", name = "funit-radiator-coolant" },
    {
        type = "recipe",
        name = "funit-heat-radiation-water",
        icon = "__base__/graphics/icons/signal/signal-fire.png",
        categories = { "funit-radiator-coolant" },
        enabled = true,
        hidden = true,
        energy_required = 1,
        ingredients = { { type = "fluid", name = "water", amount = 1 } },
        results = {},
    },
})

local radiator = data.raw["assembling-machine"]["funit-radiator"]
assert(radiator, "funit-radiator is missing; fixed_recipe_setup.lua must run in data.lua")

radiator.fixed_recipe = nil
radiator.crafting_categories = { "funit-radiator-coolant" }
radiator.fluid_boxes = {
    {
        production_type = "input",
        volume = 100,
        pipe_connections = {
            { flow_direction = "input-output", direction = defines.direction.north, position = { 0, -0.5 } },
        },
    },
}
