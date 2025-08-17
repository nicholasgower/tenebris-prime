_TENEBRIS = "tenebris"


local function on_power_poles_built_on_tenebris(event)
    local entity = event.entity

    if entity == nil then
        return
    end

    if entity.surface.planet.name ~= _TENEBRIS then
        return
    end

    if entity.type ~= "electric-pole" then
        return
    end

    entity.die()
end

local function on_power_pole_death_on_tenebris(event)
    local ghost = event.ghost
    
    if ghost == nil then
        return
    end

    if ghost.surface.planet.name ~= _TENEBRIS then
        return
    end

    if ghost.ghost_prototype.type ~= "electric-pole" then
        game.print(ghost.type)
        return
    end

    ghost.destroy()
end

script.on_event(defines.events.on_built_entity , on_power_poles_built_on_tenebris)
script.on_event(defines.events.on_post_entity_died, on_power_pole_death_on_tenebris)