local _TENEBRIS = "tenebris"


local function on_post_entity_died(event)
    local ghost = event.ghost
    if ghost == nil then
        return
    end

    planet = ghost.surface.planet
    if planet == nil or planet.name ~= _TENEBRIS then
        return
    end

    if ghost.ghost_prototype.type ~= "electric-pole" then
        game.print(ghost.type)
        return
    end

    ghost.destroy()
end

script.on_event(defines.events.on_post_entity_died, on_post_entity_died)