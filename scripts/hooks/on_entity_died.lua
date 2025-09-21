local spore_clearance = require("scripts.spore_clearance")

local _TENEBRIS = "tenebris"


local function on_entity_died(event)
    if event.entity == nil then
        return
    end

    local surface = event.entity.surface
    if surface == nil or surface.planet == nil or surface.planet.name ~= _TENEBRIS then
        return
    end

    spore_clearance.on_entity_destroyed(event.entity)
end


script.on_event(defines.events.on_entity_died, on_entity_died)