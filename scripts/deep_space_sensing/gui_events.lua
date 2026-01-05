--- Deep Space Sensing GUI Event Subscriptions
--- Handles GUI button clicks and initialization for the planetary discovery system.
---
--- @module deep_space_sensing.gui_events

local tenebris = require("lib.tenebris")
local sensing_gui = require("scripts.deep_space_sensing.gui")
local discovery_gui = require("scripts.deep_space_sensing.planetary_discovery_gui")

--- Priority for GUI events
local GUI_PRIORITY = tenebris.PRIORITY.UI

-- Register the refresh callback now that all modules are loaded
discovery_gui.register_refresh_callback()

-- Subscribe to GUI click events
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLICK, "deep_space_sensing_gui_click", function(event)
    sensing_gui.on_gui_click(event)
    discovery_gui.on_gui_click(event)
end, GUI_PRIORITY)

-- Subscribe to GUI closed events
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_GUI_CLOSED, "planetary_discovery_gui_closed", function(event)
    discovery_gui.on_gui_closed(event)
end, GUI_PRIORITY)

-- Subscribe to player created events
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CREATED, "deep_space_sensing_gui_player_created", function(event)
    sensing_gui.on_player_created(event)
end, GUI_PRIORITY)

-- Subscribe to research finished events
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_RESEARCH_FINISHED, "deep_space_sensing_gui_research", function(event)
    sensing_gui.on_research_finished(event)
end, GUI_PRIORITY)

-- Subscribe to on_init to set up GUI for existing players
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_INIT, "deep_space_sensing_gui_init", function(event)
    sensing_gui.initialize_all_players()
end, GUI_PRIORITY)

-- Subscribe to on_configuration_changed to set up GUI for existing players
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "deep_space_sensing_gui_config", function(event)
    sensing_gui.initialize_all_players()
end, GUI_PRIORITY)

return {}

