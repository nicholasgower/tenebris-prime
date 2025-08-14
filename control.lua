TENEBRIS = "tenebris"

require("__tenebris-prime__.scripts.deep_space_sensing")

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    if surface.name == TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
    end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    if not event.surface_index then return end

    local surface = game.surfaces[event.surface_index]

    if surface.name == TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
        game.players[event.player_index].enable_flashlight()
    end
end)