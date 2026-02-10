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
require("scripts.tenebrace_propagation.init")
require("scripts.shield_disabler.init")
require("scripts.displacer_robot_death.init")

-- Cargo corrosion and other systems
require("scripts.cargo_corrosion.events")
require("scripts.lightning_furnace.energy")
require("scripts.lightning_furnace.gui")
require("scripts.thermal_diode.init")
require("scripts.thermal_battery.gui")
require("scripts.piezoelectric_inserter.gui")

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
if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

-- Tenebris-specific surface events
event_manager.subscribe(tenebris.EVENTS.ON_SURFACE_CREATED, "tenebris_surface_setup", function(event)
	local surface = game.surfaces[event.surface_index]
	if surface.name == tenebris.PLANET.TENEBRIS then
		surface.freeze_daytime = true
		surface.daytime = 0.35
	end
end)

event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CHANGED_SURFACE, "tenebris_player_surface_change", function(event)
	if not event.surface_index then
		return
	end

	local surface = game.surfaces[event.surface_index]

	if surface.name == tenebris.PLANET.TENEBRIS then
		surface.freeze_daytime = true
		surface.daytime = 0.35
		game.players[event.player_index].enable_flashlight()
	end
end)
