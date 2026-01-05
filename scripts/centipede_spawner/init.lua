--- Centipede Spawner System
--- Handles spawning centipedes when egg raft asteroids are destroyed in space.
--- The centipedes spawn at a distance from the egg, acting as a "lure" mechanic.

local tenebris = require("lib.tenebris")
local centipede_constants = require("lib.centipede_constants")

local centipede_spawner = {}

-- Storage key for tracking spawned centipedes
local STORAGE_KEY = "centipede_tracker"

-- Lifespan in ticks (2 minutes = 7200 ticks)
local CENTIPEDE_LIFESPAN = 2 * 60 * 60

-- Check interval in ticks (10 seconds)
local CHECK_INTERVAL = 10 * 60

--- Ensure storage is initialized
local function ensure_storage()
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}
    end
end

--- Track a spawned centipede
--- @param centipede LuaEntity The centipede head entity
local function track_centipede(centipede)
    ensure_storage()
    storage[STORAGE_KEY][centipede.unit_number] = {
        entity = centipede,
        spawn_tick = game.tick,
    }
end

--- Remove tracking for a centipede
--- @param unit_number number The centipede's unit number
local function untrack_centipede(unit_number)
    ensure_storage()
    storage[STORAGE_KEY][unit_number] = nil
end

--- Check and kill old centipedes
-- Distance from platform center within which centipedes are considered "engaged"
local ENGAGED_RADIUS = 150

local function check_old_centipedes()
    ensure_storage()
    
    local current_tick = game.tick
    local to_remove = {}
    
    for unit_number, data in pairs(storage[STORAGE_KEY]) do
        local entity = data.entity
        local spawn_tick = data.spawn_tick
        
        -- Check if entity is still valid
        if not entity or not entity.valid then
            table.insert(to_remove, unit_number)
        -- Check if lifespan exceeded
        elseif (current_tick - spawn_tick) >= CENTIPEDE_LIFESPAN then
            -- Only destroy if the centipede is far from the platform center
            -- If it's close, it's probably engaged in combat
            local pos = entity.position
            local distance = math.sqrt(pos.x * pos.x + pos.y * pos.y)
            
            if distance > ENGAGED_RADIUS then
                -- Far from platform - probably wandered off, destroy it
                entity.destroy()
                table.insert(to_remove, unit_number)
            end
            -- If close to center, keep it alive (actively engaged)
        end
    end
    
    -- Clean up tracking
    for _, unit_number in pairs(to_remove) do
        storage[STORAGE_KEY][unit_number] = nil
    end
end

--- Maps egg raft size suffix to centipede head entity name
local SIZE_TO_CENTIPEDE = {
    ["small"] = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. "small",
    ["medium"] = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. "medium",
    ["large"] = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. "large",
    ["giant"] = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. "giant",
    ["leviathan"] = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. "leviathan",
}

--- Gets centipede name from egg raft entity name
--- @param egg_name string The egg raft entity name
--- @return string|nil centipede_name The corresponding centipede head name, or nil if not an egg raft
local function get_centipede_for_egg(egg_name)
    local prefix = centipede_constants.ENTITY_NAMES.EGGROID_PREFIX
    if not egg_name:find(prefix, 1, true) then
        return nil
    end
    local size = egg_name:sub(#prefix + 1)
    return SIZE_TO_CENTIPEDE[size]
end

--- Gets the cardinal direction facing from spawn position toward center (0,0)
--- @param nx number Normalized x component of outward direction
--- @param ny number Normalized y component of outward direction
--- @return defines.direction direction Cardinal direction facing inward
local function get_inward_cardinal_direction(nx, ny)
    -- We want to face INWARD (opposite of outward direction nx, ny)
    -- So inward is (-nx, -ny)
    local inward_x = -nx
    local inward_y = -ny
    
    -- Pick cardinal direction based on which component is larger
    if math.abs(inward_x) > math.abs(inward_y) then
        -- Primarily horizontal
        if inward_x > 0 then
            return defines.direction.east
        else
            return defines.direction.west
        end
    else
        -- Primarily vertical
        if inward_y > 0 then
            return defines.direction.south
        else
            return defines.direction.north
        end
    end
end

--- Spawns a centipede at a distance from the egg raft death position
--- The centipede spawns further "outward" from the platform center
--- @param surface LuaSurface The surface to spawn on
--- @param egg_position MapPosition Where the egg raft was destroyed
--- @param centipede_name string The centipede head entity name to spawn
local function spawn_centipede(surface, egg_position, centipede_name)
    local spawn_distance = centipede_constants.SPAWN.DISTANCE
    
    -- Calculate direction away from center (0,0)
    -- Spawn the centipede further out so it charges toward the platform
    local dx = egg_position.x
    local dy = egg_position.y
    local distance_from_center = math.sqrt(dx * dx + dy * dy)
    
    local spawn_x, spawn_y, nx, ny
    if distance_from_center > 0.1 then
        -- Normalize and extend outward
        nx = dx / distance_from_center
        ny = dy / distance_from_center
        spawn_x = egg_position.x + nx * spawn_distance
        spawn_y = egg_position.y + ny * spawn_distance
    else
        -- Egg at center, pick random direction
        local angle = math.random() * 2 * math.pi
        nx = math.cos(angle)
        ny = math.sin(angle)
        spawn_x = egg_position.x + nx * spawn_distance
        spawn_y = egg_position.y + ny * spawn_distance
    end
    
    local spawn_position = { x = spawn_x, y = spawn_y }
    
    -- Calculate direction facing INWARD (toward platform center)
    local facing_direction = get_inward_cardinal_direction(nx, ny)
    
    -- Generate chunks at spawn position if needed
    surface.request_to_generate_chunks(spawn_position, 1)
    surface.force_generate_chunk_requests()
    
    -- Find non-colliding position
    local final_position = surface.find_non_colliding_position(
        centipede_name,
        spawn_position,
        50,
        0.5
    )
    
    if not final_position then
        final_position = spawn_position
    end
    
    local centipede = surface.create_entity({
        name = centipede_name,
        position = final_position,
        force = "enemy",
        direction = facing_direction,
    })
    
    if not centipede or not centipede.valid then
        return
    end
    
    -- Track the centipede for lifespan management
    track_centipede(centipede)
    
    -- Find the platform hub to attack
    local hubs = surface.find_entities_filtered({
        name = "space-platform-hub",
        limit = 1,
    })
    
    local target = hubs[1]
    
    -- If no hub, find any player structure near center
    if not target then
        local structures = surface.find_entities_filtered({
            position = {0, 0},
            radius = 100,
            force = {"player"},
            limit = 1,
        })
        target = structures[1]
    end
    
    -- Command the centipede to attack the target
    if centipede.commandable then
        if target and target.valid then
            centipede.commandable.set_command({
                type = defines.command.attack,
                target = target,
                distraction = defines.distraction.by_anything,
            })
        else
            -- Fallback: attack-move toward center
            centipede.commandable.set_command({
                type = defines.command.attack_area,
                destination = {x = 0, y = 0},
                radius = 50,
                distraction = defines.distraction.by_anything,
            })
        end
    end
end

--- Handler for entity death events
--- @param event EventData.on_entity_died
local function on_entity_died(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    local centipede_name = get_centipede_for_egg(entity.name)
    if not centipede_name then
        return
    end
    
    -- Spawn the centipede at a distance from the egg
    spawn_centipede(entity.surface, entity.position, centipede_name)
end

--- Handler for centipede death (clean up tracking)
--- @param event EventData.on_entity_died
local function on_centipede_died(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Check if it's a centipede head
    if entity.name:find(centipede_constants.ENTITY_NAMES.HEAD_PREFIX, 1, true) then
        untrack_centipede(entity.unit_number)
    end
end

--- Subscribe to events
function centipede_spawner.register_events()
    tenebris.event_manager.subscribe(
        tenebris.EVENTS.ON_ENTITY_DIED,
        "centipede_spawner",
        on_entity_died,
        tenebris.PRIORITY.GAMEPLAY
    )
    
    tenebris.event_manager.subscribe(
        tenebris.EVENTS.ON_ENTITY_DIED,
        "centipede_death_tracker",
        on_centipede_died,
        tenebris.PRIORITY.CLEANUP
    )
    
    -- Periodic check for old centipedes
    tenebris.event_manager.subscribe_nth_tick(CHECK_INTERVAL, "centipede_lifespan_check", function()
        check_old_centipedes()
    end, tenebris.PRIORITY.CLEANUP)
    
    -- Initialize storage
    tenebris.event_manager.subscribe(tenebris.EVENTS.ON_INIT, "centipede_tracker_init", function()
        ensure_storage()
    end, tenebris.PRIORITY.NORMAL)
end

return centipede_spawner

