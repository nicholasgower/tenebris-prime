--- Displacer Robot Death Script
--- Handles the death of displacer robots when they are killed by their own beam.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

--- @param event EventData.on_script_trigger_effect
function on_script_trigger_effect(event)
	local effect_id = event.effect_id
	if effect_id ~= "displacer-robot-kill-on-firing" then
		return
	end

	local entity = event.target_entity
	if not entity or not entity.valid then
		return
	end

	if entity.name ~= "displacer" then
		return
	end

	game.print("Displacer robot killed", {
		skip = defines.print_skip.never,
	})

	entity.die()
end

event_manager.subscribe(
	tenebris.EVENTS.ON_SCRIPT_TRIGGER_EFFECT,
	"displacer_robot_death",
	on_script_trigger_effect,
	tenebris.PRIORITY.GAMEPLAY
)

return
