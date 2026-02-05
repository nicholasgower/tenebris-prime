--- Quartz Ortet Death Handler
--- Handles the death of quartz forest ortets:
--- 1. Creates a nuclear explosion at the ortet's position
--- 2. Unlocks the luciferin-explosives technology for the killing force

local tenebris = require("lib.tenebris")
local quartz_forest_constants = require("__tenebris-prime__.lib.quartz_forest_constants")
local event_manager = tenebris.event_manager

local ORTET_ENTITY = quartz_forest_constants.ENTITIES.ORTET
local ORTET_BUD_COUNT_KEY = "quartz_forest_ortet_bud_counts"

--- Ensure the storage is initialized for a force
--- @param force_name string The force name
local function ensure_storage(force_name)
    if not force_name or not storage[ORTET_BUD_COUNT_KEY] then
        return
    end
    if not storage[ORTET_BUD_COUNT_KEY][force_name] then
        storage[ORTET_BUD_COUNT_KEY][force_name] = 0
    end
end

--- Increment the ortet bud count for a force
--- @param force_name string The force name
local function increment_ortet_bud_count(force_name)
    if not force_name or not storage[ORTET_BUD_COUNT_KEY] then
        return
    end
    storage[ORTET_BUD_COUNT_KEY][force_name] = storage[ORTET_BUD_COUNT_KEY][force_name] + 1
end

--- Unlock the luciferin-explosives technology for the killing force
--- @param force Force? (optional)
local function unlock_technology(force, tech_name)
    if not force or not force.valid then
        return
    end

    -- Unlock the technology for the killing force (only if prerequisites are met)
    if force and force.technologies[tech_name] then
        local tech = force.technologies[tech_name]
        if not tech.researched then
            -- Check if all prerequisites are researched
            local prerequisites_met = true
            for _, prereq in pairs(tech.prerequisites) do
                if not prereq.researched then
                    prerequisites_met = false
                    break
                end
            end
            
            if prerequisites_met then
                tech.researched = true
                game.print({"", "[color=yellow]", {"technology-name." .. tech_name}, " has been unlocked![/color]"})
            end
        end
    end
end

--- Create the immediate apocalypse effect for an ortet
--- @param ortet LuaEntity The ortet entity
local function immediate_apocalypse_effect(ortet)
    local surface = ortet.surface
    local position = ortet.position
    local ortet_force = ortet.force
    
    -- Create nuclear explosion at the ortet's position
    surface.create_entity({
        name = "atomic-rocket",
        position = position,
        target = position,
        speed = 0.1,
        force = ortet_force
    })

    for i = 1, 200 do
        local random_position = {
            x = position.x + math.random(-100, 100),
            y = position.y + math.random(-100, 100),
        }

        surface.create_entity({
            name = "lightning",
            position = random_position,
            force = ortet_force,
        })
    end
end

--- Spawn the apocalypse wave for a killer
--- @param killer LuaEntity The killer entity
local function spawn_apocalypse_wave(killer)
    if not killer or not killer.valid then
        return
    end
    
    local surface = killer.surface
    local position = killer.position
    local killing_force = killer.force

    for variant, count in pairs(quartz_forest_constants.ORTET_DEATH_APOCALYPSE_WAVE_MEMBERSHIP[wave_number]) do
        local unit_name = "centipede-head-" .. variant

        local random_position = {
            x = position.x + math.random(-100, 100),
            y = position.y + math.random(-100, 100),
        }

        for i = 1, count do
            surface.create_unit({
                name = variant,
                position = position,
                force = killing_force,
            })
        end
    end
end

--- Handler for ortet death events
--- @param event EventData.on_entity_died
local function on_ortet_died(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Only handle ortet deaths
    if entity.name ~= ORTET_ENTITY then
        return
    end
    
    immediate_apocalypse_effect(entity)

    -- Determine which force killed the ortet
    local killer = event.cause
    local killing_force = nil
    
    if killer and killer.valid then
        killing_force = killer.force
    elseif event.force then
        killing_force = event.force
    end
    
    ensure_storage(killing_force.name)
    increment_ortet_bud_count(killing_force.name)

    for tech_name, counter in pairs(quartz_forest_constants.ORTET_DEATH_TO_TECHNOLOGY_UNLOCK_COUNTER_MAP) do
        if storage[ORTET_BUD_COUNT_KEY][killing_force.name] >= counter then
            unlock_technology(killing_force, tech_name)
        end
    end

    killing_force.print(
        "Screams echo around you...",
        {
            color = {r = 1, g = 0, b = 0},
            sound = defines.print_sound.use_player_settings,
            sound_path = "tenebris-ortet-death-apocalypse-screams"
        }
    )
    
    spawn_apocalypse_wave(killer)
end

--- Subscribe to entity death events
event_manager.subscribe(
    tenebris.EVENTS.ON_ENTITY_DIED,
    "quartz_ortet_death",
    on_ortet_died,
    tenebris.PRIORITY.GAMEPLAY
)

