require("__tenebris-prime__.scripts.hooks.on_built_entity")
require("__tenebris-prime__.scripts.hooks.on_cargo_pod_finished_ascending")
require("__tenebris-prime__.scripts.hooks.on_cargo_pod_finished_descending")
require("__tenebris-prime__.scripts.hooks.on_init")
require("__tenebris-prime__.scripts.hooks.on_nth_tick")
require("__tenebris-prime__.scripts.hooks.on_player_mined_entity")
require("__tenebris-prime__.scripts.hooks.on_post_entity_died")
require("__tenebris-prime__.scripts.hooks.on_research_finished")
require("__tenebris-prime__.scripts.hooks.on_robot_built_entity")
require("__tenebris-prime__.scripts.hooks.on_robot_mined_entity")


local _TENEBRIS = "tenebris"


if script.active_mods["gvv"] then require("__gvv__.gvv")() end

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    if surface.name == _TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
    end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    if not event.surface_index then return end

    local surface = game.surfaces[event.surface_index]

    if surface.name == _TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
        game.players[event.player_index].enable_flashlight()
    end
end)