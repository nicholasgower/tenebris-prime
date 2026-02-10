require("util")

-- Mod compatibility: Maraxsis / Paracelsin space connections
-- Must run in data-final-fixes because these mods load after us
log("[Tenebris Prime] data-final-fixes: maraxsis=" .. tostring(mods["maraxsis"]) .. ", Paracelsin=" .. tostring(mods["Paracelsin"]))
if mods["maraxsis"] or mods["Paracelsin"] then
    log("[Tenebris Prime] Loading tenespace-connections.lua")
    require("prototypes.compat.tenespace-connections")
else
    log("[Tenebris Prime] Skipping tenespace-connections (no compatible mods detected)")
end

-- Remove any external connections to Tenebris locations added by other mods
require("prototypes.compat.tenespace-connections-cleanup")

-- AsteroidBelt compatibility: add dense asteroid zone on routes passing through the belt
require("prototypes.compat.asteroid-belt")

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

-- Force Tenebris back to its intended position (other mods may move it)
if data.raw["planet"]["tenebris"] then
    data.raw["planet"]["tenebris"].distance = 45
    data.raw["planet"]["tenebris"].orientation = 0.60
end

-- Add spore clearance to base game heat-emitting buildings
-- Nuclear reactors emit spores (heat-based pollution reduction)
if data.raw["reactor"]["nuclear-reactor"] then
    local reactor = data.raw["reactor"]["nuclear-reactor"]
    if reactor.energy_source and reactor.energy_source.type == "heat" then
        if not reactor.energy_source.emissions_per_minute then
            reactor.energy_source.emissions_per_minute = {}
        end
        reactor.energy_source.emissions_per_minute.tenecap_spore_clearance = 40
    end
end

-- Heating towers also emit spores
if data.raw["assembling-machine"]["heating-tower"] then
    local heating_tower = data.raw["assembling-machine"]["heating-tower"]
    if heating_tower.energy_source and heating_tower.energy_source.type == "heat" then
        if not heating_tower.energy_source.emissions_per_minute then
            heating_tower.energy_source.emissions_per_minute = {}
        end
        heating_tower.energy_source.emissions_per_minute.tenecap_spore_clearance = 60
    end
end

-- Ambient sounds from soundtracks mod (if available)
if mods["tenebris-prime-soundtracks"] then
    log("[Tenebris Prime] Soundtracks mod detected - adding ambient sounds")
    data:extend({
        {
            type = "ambient-sound",
            name = "tenebris-neptune-plasma",
            track_type = "main-track",
            planet = "tenebris",
            sound = "__tenebris-prime-soundtracks__/sound/ambient/neptune-plasma-waves.ogg",
            weight = 15,
        },
    })
end

-- DEBUG: Verify space connections at end of data-final-fixes
log("[Tenebris Prime] END OF DATA-FINAL-FIXES - Verifying space connections:")
for name, connection in pairs(data.raw["space-connection"]) do
    if string.find(name, "tenebris") or string.find(name, "maraxsis") or string.find(name, "paracelsin") then
        log(string.format("  %s: from=%s, to=%s", name, connection.from, connection.to))
    end
end
