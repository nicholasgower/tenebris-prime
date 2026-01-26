--- Apocalypse Effect
--- Handles the apocalypse effect when a quartz forest ortet dies.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local function on_apocalypse_effect(event)
    game.print("Apocalypse effect triggered")

    if event.effect_id ~= "tenebris-quartz-forest-ortet-dying-effect" then
        return
    end

    local source_entity = event.source_entity
    if not source_entity or not source_entity.valid then
        return
    end

    if source_entity.name ~= "tenebris-quartz-forest-ortet" then
        return
    end

    local position = source_entity.position
    local surface = source_entity.surface
    local force = source_entity.force

    for i = 1, 100 do
        local random_position = {
            x = position.x + math.random(-100, 100),
            y = position.y + math.random(-100, 100),
        }

        surface.create_entity({
            name = "lightning",
            position = random_position,
            force = force,
        })
    end
end

event_manager.subscribe(tenebris.EVENTS.ON_SCRIPT_TRIGGER_EFFECT, "apocalypse_effect", on_apocalypse_effect, tenebris.PRIORITY.GAMEPLAY)

return apocalypse_effect