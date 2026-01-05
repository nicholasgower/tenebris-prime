require("util")

-- Mod compatibility: Maraxsis / Paracelsin space connections
-- Must run in data-final-fixes because these mods load after us
if mods["maraxsis"] or mods["Paracelsin"] then
    require("prototypes.compat.tenespace-connections")
end

-- Remove any external connections to Tenebris locations added by other mods
require("prototypes.compat.tenespace-connections-cleanup")

data.raw["cargo-pod"]["cargo-pod"].created_effect = {
    {
        type = "direct",
        action_delivery = {
            type = "delayed",
            delayed_trigger = "cargo-pod-malfunction"
        }
    }
}

data:extend({
    {
        type = "delayed-active-trigger",
        name = "cargo-pod-malfunction",
        delay = 300,
        action =
        {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "script",
                        effect_id = "cargo-pod-spawned"
                    }
                }
            }
        }
    }
})

local science_to_update = {
    "research-productivity"
}

for _, tech in pairs(science_to_update) do
    table.insert(data.raw["technology"][tech].unit.ingredients, { "bioluminescent-science-pack", 1 })
    -- table.insert(data.raw["technology"][tech].prerequisites, "photonic-derangement") -- Removed - tech doesn't exist
end

-- Allow crusher on Tenebris surface
-- The crusher is a furnace in Space Age
if data.raw["furnace"]["crusher"] then
    local crusher = data.raw["furnace"]["crusher"]
    if crusher.surface_conditions then
        -- Add Tenebris surface condition (innate-energy-luminosity >= 1)
        local has_tenebris = false
        for _, condition in pairs(crusher.surface_conditions) do
            if condition.property == "innate-energy-luminosity" then
                has_tenebris = true
                break
            end
        end
    end
end

