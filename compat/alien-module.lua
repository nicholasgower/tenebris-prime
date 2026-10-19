-- Alien Loot Economy (internal mod name "alien-module") compatibility.
--
-- Its alien hyper modules use the "alien-module" module category, so mods such as
-- "module-category-defaults" that fill in a beacon's allowed_module_categories would
-- keep them out. They also carry pollution and, unless disabled, quality effects; a
-- module can only be inserted when every one of its effects is in the machine's
-- allowed_effects. Collect both from the mod's own modules so this keeps working if
-- the mod changes them.

require("__tenebris-prime__.util")

if not mods["alien-module"] then return end

local bioluminescent_beacon = data.raw["beacon"] and data.raw["beacon"]["biobeacon"]
if not bioluminescent_beacon then return end

local module_categories = {}
local module_effects = {}
for _, module in pairs(data.raw["module"]) do
    if module.category == "alien-module" then
        module_categories[module.category] = true
        for effect in pairs(module.effect or {}) do
            module_effects[effect] = true
        end
    end
end

if bioluminescent_beacon.allowed_module_categories then
    for category in pairs(module_categories) do
        if not contains(bioluminescent_beacon.allowed_module_categories, category) then
            table.insert(bioluminescent_beacon.allowed_module_categories, category)
        end
    end
end

-- A beacon always uses a table of effects, but an EffectTypeLimitation may be a string.
if type(bioluminescent_beacon.allowed_effects) == "string" then
    bioluminescent_beacon.allowed_effects = { bioluminescent_beacon.allowed_effects }
end

for effect in pairs(module_effects) do
    if not contains(bioluminescent_beacon.allowed_effects, effect) then
        table.insert(bioluminescent_beacon.allowed_effects, effect)
    end
end
