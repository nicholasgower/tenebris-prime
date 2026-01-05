--- Deep Space Sensing Event Subscriptions
--- Handles research completion and cargo pod events for deep space sensing.
---
--- @module deep_space_sensing.events

local tenebris = require("lib.tenebris")
local deep_space_sensing = require("scripts.deep_space_sensing.init")
local constants = require("scripts.deep_space_sensing.constants")
local planetary_discovery_gui = require("scripts.deep_space_sensing.planetary_discovery_gui")

--- Priority for deep space sensing (gameplay mechanics)
local SENSING_PRIORITY = tenebris.PRIORITY.GAMEPLAY

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_RESEARCH_FINISHED, "deep_space_sensing", function(event)
    if event.research.name ~= constants.UNLOCK_TECHNOLOGY then
        return
    end

    deep_space_sensing.setup_satellites_counter()
    deep_space_sensing.setup_planetary_contribution(true)
end, SENSING_PRIORITY)

-- Rebuild maps on init/config change so distance weights reflect current constants
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_INIT, "deep_space_sensing_init", function(_)
    deep_space_sensing.setup_satellites_counter()
    deep_space_sensing.setup_planetary_contribution(true)
end, SENSING_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "deep_space_sensing_config", function(_)
    deep_space_sensing.setup_satellites_counter()
    deep_space_sensing.setup_planetary_contribution(true)
end, SENSING_PRIORITY)

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CARGO_POD_FINISHED_ASCENDING, "deep_space_sensing", function(event)
    local cargo_pod = event.cargo_pod 

    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if not inventory then
        return
    end

    if inventory.find_item_stack(constants.OBSERVATION_SATELLITE_ITEM) then
        deep_space_sensing.on_satellite_launched(cargo_pod)
    end
end, SENSING_PRIORITY)

-- Deep space sensing progress (every 60 seconds)
tenebris.event_manager.subscribe_nth_tick(60 * tenebris.TICKS.PER_SECOND, "deep_space_sensing_progress", function(event)
    deep_space_sensing.on_progress_deep_space_sensing_tick(event)
end, SENSING_PRIORITY)

-- Deep space sensing GUI progress bar update (every tick for smooth animation)
tenebris.event_manager.subscribe_nth_tick(1, "deep_space_sensing_gui_update", function(_)
    planetary_discovery_gui.update_progress_bars()
end, tenebris.PRIORITY.UI)

return {}

