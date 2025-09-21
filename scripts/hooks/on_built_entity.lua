local spore_clearance = require("scripts.spore_clearance")

local _TENEBRIS = "tenebris"


local function on_built_entity(event)
    local entity = event.entity
    if entity == nil or not entity.valid or entity.surface == nil then
        return
    end

    planet = entity.surface.planet
    if planet == nil or planet.name ~= _TENEBRIS then
        return
    end

    if entity.type == "electric-pole" then
        entity.die()
        return
    end

    spore_clearance.on_built_entity(entity)
end


script.on_event(defines.events.on_built_entity, on_built_entity)