--- Tenebris Prime Control Script
--- Main entry point for the mod's runtime logic.
--- Uses the event manager system for decoupled event handling.

-- Load central namespace (provides constants and system access)
local tenebris = require("lib.tenebris")


-- Initialize event manager (already loaded via tenebris)
local event_manager = tenebris.event_manager

-- Load composite entity library and register composites
require("scripts.lightning_furnace.composite")
require("scripts.quartz_forest.composite")
require("scripts.thermal_diode.composite")
require("scripts.thermal_battery.composite")

-- Load all event subscribers (they self-register)
require("lib.composite_entity.events")
require("scripts.entity_manager.init")
require("scripts.quartz_forest.capture")
require("scripts.quartz_forest.gui")
require("scripts.quartz_forest.fluid_transfer")
require("scripts.quartz_forest.ortet_death")
require("scripts.thermal_diode.gui")
require("scripts.deep_space_sensing.events")
require("scripts.deep_space_sensing.gui_events")
require("scripts.tenebrace_propagation.init")
require("scripts.shield_disabler.init")

-- Register Tenebris as a discoverable planet (decoupled from deep_space_sensing library)
require("scripts.tenebris_planet_registration").register()
require("scripts.cargo_corrosion.events")
require("scripts.lightning_furnace.energy")
require("scripts.lightning_furnace.gui")
require("scripts.thermal_diode.init")
require("scripts.thermal_battery.gui")
require("scripts.piezoelectric_inserter.gui")
require("scripts.apocalypse_effect.init")

-- Centipede spawning from egg rafts in space
require("scripts.centipede_spawner.init").register_events()

-- Quartz forest map generation (bud composites + maturity randomization)
require("scripts.quartz_forest.map_generation").register_events()

-- Tenespace ambient visual effects
require("scripts.tenespace_effects.init")

-- Flight restriction system (prevents mech hover until tech researched)
require("scripts.flight_restriction.init")

-- Mercury poisoning (damages players walking through mercury pools)
require("scripts.mercury_poisoning.init")

-- Lichen deposit harvesting scripted tech trigger
require("scripts.lichen_deposit_harvesting")

-- Optional: GVV debugger support
if script.active_mods["gvv"] then require("__gvv__.gvv")() end

-- Debug remote interface
local deep_space_sensing = require("scripts.deep_space_sensing.init")
remote.add_interface(tenebris.PLANET.TENEBRIS, {
    rebuild_sensing = function()
        deep_space_sensing.setup_satellites_counter()
        deep_space_sensing.setup_planetary_contribution(true)
        game.print("Rebuilt sensing contribution maps")
    end,
    debug_contributions = function()
        local force_name = game.player.force.name
        local probs = storage.deep_space_orbital_satellite_contribution_probabilities
        if not probs or not probs[force_name] then
            game.print("No contribution probabilities stored")
            return
        end
        for target, planets in pairs(probs[force_name]) do
            game.print("=== " .. target .. " ===")
            for planet, contrib in pairs(planets) do
                game.print("  " .. planet .. ": " .. string.format("%.6f (%.4f%%)", contrib, contrib * 100))
            end
        end
    end,
    debug_satellites = function()
        local force_name = game.player.force.name
        local sats = storage.deep_space_orbital_observation_satellites
        if not sats or not sats[force_name] then
            game.print("No satellites tracked")
            return
        end
        for planet, count in pairs(sats[force_name]) do
            game.print(planet .. ": " .. count)
        end
    end,
})

-- Tenebris-specific surface events
event_manager.subscribe(tenebris.EVENTS.ON_SURFACE_CREATED, "tenebris_surface_setup", function(event)
    local surface = game.surfaces[event.surface_index]
    if surface.name == tenebris.PLANET.TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
    end
end)

event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_SURFACE, "tenebris_player_surface_change", function(event)
    if not event.surface_index then return end

    local surface = game.surfaces[event.surface_index]

    if surface.name == tenebris.PLANET.TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
        game.players[event.player_index].enable_flashlight()
    end
end)