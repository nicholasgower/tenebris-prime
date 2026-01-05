--- Cargo Pod Corrosion Event Subscriptions
--- Handles cargo pods descending to Tenebris - corrosive atmosphere destroys basic components.
---
--- @module cargo_corrosion_events

local tenebris = require("lib.tenebris")
local cargo_corrosion = require("scripts.cargo_corrosion.init")

--- Priority for cargo pod processing (gameplay mechanics)
local CARGO_PRIORITY = tenebris.PRIORITY.GAMEPLAY

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CARGO_POD_FINISHED_DESCENDING, "cargo_corrosion", function(event)
    local cargo_pod = event.cargo_pod 
    
    -- Use the cargo pod's own surface (where it landed)
    local surface = cargo_pod.surface
    if not surface or not surface.planet then
        return
    end

    if surface.planet.name ~= tenebris.PLANET.TENEBRIS then
        return
    end

    -- Process corrosion (may destroy the pod if batteries present)
    cargo_corrosion.process_cargo_pod(cargo_pod)
end, CARGO_PRIORITY)

return {}
