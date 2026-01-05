--- Quartz Ortet Death Handler
--- Handles the death of quartz forest ortets:
--- 1. Creates a nuclear explosion at the ortet's position
--- 2. Unlocks the luciferin-explosives technology for the killing force

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local ORTET_ENTITY = tenebris.QUARTZ_FOREST.ORTET_ENTITY
local TECH_TO_UNLOCK = "luciferin-explosives"

--- Handler for ortet death events
--- @param event EventData.on_entity_died
local function on_ortet_died(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Only handle ortet deaths (not captures - those create a capture proxy instead)
    if entity.name ~= ORTET_ENTITY then
        return
    end
    
    local surface = entity.surface
    local position = entity.position
    
    -- Create nuclear explosion at the ortet's position
    surface.create_entity({
        name = "atomic-rocket",
        position = position,
        target = position,
        speed = 0.1,
        force = "neutral"
    })
    
    -- Determine which force killed the ortet
    local cause = event.cause
    local force = nil
    
    if cause and cause.valid then
        force = cause.force
    elseif event.force then
        force = event.force
    end
    
    -- Unlock the technology for the killing force (only if prerequisites are met)
    if force and force.technologies[TECH_TO_UNLOCK] then
        local tech = force.technologies[TECH_TO_UNLOCK]
        if not tech.researched then
            -- Check if all prerequisites are researched
            local prerequisites_met = true
            for _, prereq in pairs(tech.prerequisites) do
                if not prereq.researched then
                    prerequisites_met = false
                    break
                end
            end
            
            if prerequisites_met then
                tech.researched = true
                game.print({"", "[color=yellow]", {"technology-name." .. TECH_TO_UNLOCK}, " has been unlocked![/color]"})
            end
        end
    end
end

--- Subscribe to entity death events
event_manager.subscribe(
    tenebris.EVENTS.ON_ENTITY_DIED,
    "quartz_ortet_death",
    on_ortet_died,
    tenebris.PRIORITY.GAMEPLAY
)

