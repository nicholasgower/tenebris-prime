local resonate_ortet_buds = {}


function resonate_ortet_buds.on_mined_quartz_ortet_bud_by_player(event, force)
    local surface = event.entity.surface

    surface.create_entity({
        name = "tenebris-ortet-conductor",
        position = event.entity.position,
        force = player.force
    })
end


return resonate_ortet_buds