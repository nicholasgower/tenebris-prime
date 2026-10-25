-- The bioluminescent copies are made in the data stage (prototypes/bioluminescent.lua), so they miss what other mods
-- change in their bases later. Three things are fixed here:
--
-- 1. A copy keeps the crafting categories, fixed recipe and fluid boxes its base had when it was copied. Every copy
--    takes the ones its base has now, so it can still make what the base makes. Heat Management, for example, clears
--    the fixed recipe of TFMG Thermal's radiators and changes their categories and fluid boxes in data-updates; a copy
--    that missed that kept a fixed recipe its new categories no longer allowed and the game refused to load it.
--
-- 2. A copy runs at the pressure of Tenebris even when its base is bound to another place (#10): a machine that its mod
--    allows only on its own planet or in space, by pressure, gravity, dust and so on. Its copy would take it to
--    Tenebris anyway. The bioinfusion recipe of such a copy is hidden and loses its unlock, so the copy can no longer be
--    had. Recipes written by hand for a copy (bio-agricultural-tower: the agricultural tower that grows the plants of
--    Tenebris) are left alone, they are meant to be. The item and the entity stay: other mods build recycling and
--    similar recipes that name the item, and a copy built before keeps working.
--
-- 3. An upgrade of a copy points to the copy of the machine it upgrades to. That copy does not always exist: the
--    crusher and Carna's spire are left out of the copies, and a base machine may have no copy of its own. The chain of
--    a copy ends at the last copy that exists, so the game does not reject a missing name (#39).

require("__tenebris-prime__.util")

local tenebris = data.raw["planet"]["tenebris"]
if not tenebris then return end

local function property_value(property)
    local own = tenebris.surface_properties and tenebris.surface_properties[property]
    if own ~= nil then
        return own
    end

    local prototype = data.raw["surface-property"][property]
    return prototype and prototype.default_value or 0
end

local function allowed_on_tenebris(conditions)
    for _, condition in pairs(conditions or {}) do
        local value = property_value(condition.property)
        if (condition.min and value < condition.min) or (condition.max and value > condition.max) then
            return false
        end
    end

    return true
end

local hidden_recipes = {}

for _, entries in pairs(data.raw) do
    for name, copy in pairs(entries) do
        local base_name = type(copy) == "table" and copy.bioluminescent and name:match("^bioluminescent%-(.+)$")
        local base = base_name and entries[base_name]

        if base then
            if base.crafting_categories and copy.crafting_categories then
                copy.crafting_categories = table.deepcopy(base.crafting_categories)
            end

            -- A fixed recipe has to use one of the categories of its machine. Heat Management, for example, clears
            -- the fixed heat-radiation recipe of TFMG Thermal's radiators and moves them to a coolant category in
            -- data-updates, after the copies were made. Taking both from the base now keeps the copy loadable instead
            -- of failing with "fixed_recipe=... cannot be used on this machine. Reason=DifferentCategory".
            copy.fixed_recipe = base.fixed_recipe
            if base.fluid_boxes then
                copy.fluid_boxes = table.deepcopy(base.fluid_boxes)
            end

            -- The bioinfusion recipe has the name of the copy (prototypes/bioluminescent.lua).
            local recipe = data.raw["recipe"][name]
            if recipe and not recipe.hidden and contains(recipe.categories or {}, "bioinfusion")
                and not allowed_on_tenebris(base.surface_conditions) then
                recipe.hidden = true
                recipe.enabled = false
                hidden_recipes[name] = true
            end
        end
    end
end

for _, technology in pairs(data.raw["technology"]) do
    local effects = technology.effects or {}
    for index = #effects, 1, -1 do
        local effect = effects[index]
        if effect.type == "unlock-recipe" and hidden_recipes[effect.recipe] then
            table.remove(effects, index)
        end
    end
end

-- Muluna's steam crusher, for example, upgrades to the crusher, whose copy is left out on purpose: without this the
-- game fails to load with "entity with name 'bioluminescent-crusher' does not exist" (#39).
for _, entries in pairs(data.raw) do
    for _, copy in pairs(entries) do
        if type(copy) == "table" and copy.bioluminescent and copy.next_upgrade and not entries[copy.next_upgrade] then
            copy.next_upgrade = nil
        end
    end
end
