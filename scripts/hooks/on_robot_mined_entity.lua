local resonate_ortet_buds = require("scripts.resonate_ortet_buds")
local spore_clearance = require("scripts.spore_clearance")

local _TENEBRIS = "tenebris"


local function on_robot_mined_entity(event)
    if event.entity == nil then
        return
    end

    local surface = event.entity.surface
    if surface == nil or surface.planet == nil or surface.planet.name ~= _TENEBRIS then
        return
    end

    if event.entity.name == "tenebris-quartz-ortet-bud" then
        resonate_ortet_buds.on_mined_quartz_ortet_bud_by_player(event, event.entity.force)
        return
    end

    spore_clearance.on_entity_destroyed(event.entity)
end


script.on_event(defines.events.on_robot_mined_entity, on_robot_mined_entity)