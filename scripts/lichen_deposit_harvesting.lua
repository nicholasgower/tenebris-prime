--- Lichen Deposit Harvesting Technology Trigger
--- Handles scripted research trigger for mining exposed lichen deposits.
---
--- @module lichen_deposit_harvesting

local tenebris = require("lib.tenebris")

local ENTITY_NAME = "tenebris-exposed-lichen-deposit"
local TECH_NAME = "lichen-deposit-harvesting"

--- Handle player mining an entity
--- @param event EventData.on_player_mined_entity
local function on_player_mined_entity(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end

    -- Only trigger for the specific entity
    if entity.name ~= ENTITY_NAME then
        return
    end

    -- Get the player's force
    local player = game.players[event.player_index]
    if not player then
        return
    end

    local force = player.force
    local tech = force.technologies[TECH_NAME]

    -- Check if tech exists and isn't already researched
    if not tech or tech.researched then
        return
    end

    -- Check if all prerequisites are met
    for _, prereq in pairs(tech.prerequisites) do
        if not prereq.researched then
            return
        end
    end

    -- Unlock the technology
    tech.researched = true
end

-- Register with the event manager
tenebris.event_manager.subscribe(
    tenebris.EVENTS.ON_PLAYER_MINED_ENTITY,
    "lichen_deposit_harvesting",
    on_player_mined_entity,
    tenebris.PRIORITY.GAMEPLAY
)

return {}
