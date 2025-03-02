TENEBRIS = "tenebris"

script.on_init(function()
    if game.surfaces[TENEBRIS] then
        game.forces["enemy"].set_evolution_factor(0.99, game.surfaces.tenebris)
    end
  end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    if surface.name == TENEBRIS then
        surface.freeze_daytime = true
        surface.daytime = 0.35
        game.forces["enemy"].set_evolution_factor(0.99, surface)
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

-- script.on_event(defines.events.on_script_trigger_effect, function(event)
--     if event.effect_id == "cargo-pod-spawned" then
--         if event.cause_entity == nil then return end
--         if event.cause_entity.force.technologies["planetslib-tenebris-cargo-drops"].researched then return end

--         if event.cause_entity.surface.name == TENEBRIS and event.cause_entity.has_items_inside() then
--             local source_inventory = event.cause_entity.get_inventory(defines.inventory.cargo_landing_pad_main)

--             local distance = math.random(2000, 2500)
--             local angle = math.random() * math.pi * 2

--             local x = math.sin(angle) * distance
--             local y = math.cos(angle) * distance

--             local pod = event.cause_entity.surface.create_entity {
--                 name = "cargo-pod-container", force = event.cause_entity.force, position = { x, y }
--             }
--             local target_inventory = pod.get_inventory(defines.inventory.cargo_landing_pad_main)

--             event.cause_entity.force.chart(event.cause_entity.surface, { { x - 10, y - 10 }, { x + 10, y + 10 } })
--             game.print("Cargo pod navigation failure, crash landed at " .. pod.gps_tag)

--             if source_inventory and target_inventory then
--                 for i = 1, #source_inventory do
--                     local stack = source_inventory[i]

--                     if stack.valid_for_read then
--                         target_inventory.insert(stack)
--                     end
--                 end

--                 event.cause_entity.destroy()
--             end
--         end
--     end
-- end)
