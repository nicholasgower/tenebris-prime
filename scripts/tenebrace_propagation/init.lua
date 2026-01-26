--- Tenebrace Propagation System
--- When tenebrace dies, it spawns new plants nearby - unless it was killed by fire.
--- Uses the tenebris event manager for decoupled event handling.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

local TENEBRACE_SPAWN_COUNT_MIN = 2
local TENEBRACE_SPAWN_COUNT_MAX = 3
local TENEBRACE_SPAWN_RADIUS = 6  -- Tiles

local function is_valid_tile_for_tenebrace(surface, position)
    local tile = surface.get_tile(position.x, position.y)
    -- Check if tile name matches tenebrace's tile_restriction
    return tile and tile.name == "tenebris-debug-lowlands"
end

local function spawn_tenebrace_near(surface, position, force)
    local spawn_count = math.random(TENEBRACE_SPAWN_COUNT_MIN, TENEBRACE_SPAWN_COUNT_MAX)
    
    for i = 1, spawn_count do
        -- Pick a random direction and distance
        local angle = math.random() * 2 * math.pi
        local distance = math.random() * TENEBRACE_SPAWN_RADIUS + 1
        
        local target_x = position.x + math.cos(angle) * distance
        local target_y = position.y + math.sin(angle) * distance
        
        -- Find a valid non-colliding position near the target
        local spawn_position = surface.find_non_colliding_position(
            "tenebrace",
            {target_x, target_y},
            TENEBRACE_SPAWN_RADIUS,
            0.5  -- precision
        )
        
        -- Check if position is valid and on correct tile type
        if spawn_position and is_valid_tile_for_tenebrace(surface, spawn_position) then
            surface.create_entity({
                name = "tenebrace",
                position = spawn_position,
                spawn_decorations = true,
                force = force
            })
        end
    end
end

local function on_entity_died(event)
    local entity = event.entity

    if not entity or not entity.valid or entity.name ~= "tenebrace" then
        return
    end

    -- Check if killed by fire damage
    if event.damage_type and event.damage_type.name == "fire" then
        -- Killed by fire, don't propagate
        return
    end

    -- Spawn new tenebrace nearby
    spawn_tenebrace_near(entity.surface, entity.position, entity.force)
end

local function on_entity_mined(event)
    local entity = event.entity

    if not entity or not entity.valid or entity.name ~= "tenebrace" then
        return
    end

    -- Spawn new tenebrace nearby
    spawn_tenebrace_near(entity.surface, entity.position, entity.force)
end

event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "tenebrace_propagation", on_entity_died, tenebris.PRIORITY.GAMEPLAY)
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_MINED_ENTITY, "tenebrace_propagation_mined", on_entity_mined, tenebris.PRIORITY.GAMEPLAY)
event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_MINED_ENTITY, "tenebrace_propagation_robot_mined", on_entity_mined, tenebris.PRIORITY.GAMEPLAY)
