-- Data-stage checks for the fixed recipe of a bioluminescent copy.
--
-- The setup fixture gives a machine a fixed recipe; the update fixture then
-- clears that recipe and changes the base machine's crafting categories, as
-- Heat Management does to TFMG Thermal's radiators. Tenebris Prime's
-- data-final-fixes must make the copy follow its base, or the game aborts the
-- data stage with "fixed_recipe=... cannot be used on this machine.
-- Reason=DifferentCategory". Without the fix these checks never run, so a
-- successful load is already part of the regression test.

local results = require("lib.results")

local SUITE = "bioluminescent"

local function contains(list, value)
    for _, entry in pairs(list or {}) do
        if entry == value then
            return true
        end
    end
    return false
end

results.check(SUITE, "fixture-shape-matches-heat-managment-conflict", function()
    local base = data.raw["assembling-machine"]["funit-radiator"]
    assert(base, "funit-radiator is missing")
    assert(base.fixed_recipe == nil, "the fixture base should no longer have a fixed recipe")
    assert(
        contains(base.crafting_categories, "funit-radiator-coolant"),
        "the fixture base should use the coolant category"
    )
end)

results.check(SUITE, "copy-drops-a-fixed-recipe-its-base-dropped", function()
    local copy = data.raw["assembling-machine"]["bioluminescent-funit-radiator"]
    assert(copy, "bioluminescent-funit-radiator was not created")
    assert(
        copy.fixed_recipe == nil,
        "copy still uses fixed recipe " .. tostring(copy.fixed_recipe) ..
        " after its base dropped it (Heat Management conflict)"
    )
    assert(
        contains(copy.crafting_categories, "funit-radiator-coolant"),
        "copy did not take the coolant category of its base"
    )
end)

results.check(SUITE, "copy-takes-the-fluid-boxes-of-its-base", function()
    local base = data.raw["assembling-machine"]["funit-radiator"]
    local copy = data.raw["assembling-machine"]["bioluminescent-funit-radiator"]
    assert(copy, "bioluminescent-funit-radiator was not created")
    assert(base.fluid_boxes and #base.fluid_boxes == 1, "the fixture base should have one fluid box")
    assert(copy.fluid_boxes and #copy.fluid_boxes == 1, "copy did not take the fluid boxes of its base")
end)

results.check(SUITE, "every-fixed-recipe-uses-a-category-of-its-machine", function()
    for type_name, entries in pairs(data.raw) do
        if type(entries) == "table" then
            for name, prototype in pairs(entries) do
                if type(prototype) == "table" and prototype.bioluminescent and prototype.fixed_recipe then
                    local recipe = data.raw["recipe"][prototype.fixed_recipe]
                    assert(recipe, type_name .. "." .. name .. " uses missing recipe " .. prototype.fixed_recipe)
                    for _, category in pairs(recipe.categories or {}) do
                        assert(
                            contains(prototype.crafting_categories, category),
                            type_name .. "." .. name .. " uses fixed recipe " .. prototype.fixed_recipe ..
                            " in category " .. category .. ", which the machine does not allow"
                        )
                    end
                end
            end
        end
    end
end)
