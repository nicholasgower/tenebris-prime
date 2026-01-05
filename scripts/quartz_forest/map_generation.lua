--- Quartz Forest Map Generation
--- Handles post-generation setup for autoplaced quartz forest entities:
--- 1. Spawns buds around ortets (1-10, increasing with distance from spawn) via composite API
--- 2. Tracks bud->ortet relationship for spawning limits
--- 3. Sets buds to enemy force for capture

local tenebris = require("lib.tenebris")
local qf_constants = require("lib.quartz_forest_constants")

local map_gen = {}

-- Local references to constants for convenience
local BUD = qf_constants.BUD
local ENTITIES = qf_constants.ENTITIES
local TILES = qf_constants.TILES

-- Storage keys
local STORAGE_KEY = "quartz_forest_processed_ortets"
local ORTET_BUD_COUNT_KEY = "quartz_forest_ortet_bud_counts"
local BUD_ORTET_MAP_KEY = "quartz_forest_bud_ortet_map"
-- Use same keys as capture.lua for spawn time tracking
local QF = tenebris.QUARTZ_FOREST
local BUD_SPAWN_TIMES_KEY = QF.STORAGE_BUD_SPAWN_TIMES
local BUD_BY_POS_KEY = QF.STORAGE_BUD_BY_POS

--- Increment the bud count for an ortet
--- @param ortet_id number The ortet's unit_number
local function increment_ortet_bud_count(ortet_id)
    if not ortet_id then return end
    if not storage[ORTET_BUD_COUNT_KEY] then
        storage[ORTET_BUD_COUNT_KEY] = {}
    end
    storage[ORTET_BUD_COUNT_KEY][ortet_id] = (storage[ORTET_BUD_COUNT_KEY][ortet_id] or 0) + 1
end

--- Track which ortet owns a bud
--- @param composite_id string The bud's composite ID
--- @param ortet_id number The ortet's unit_number
local function track_bud_ortet(composite_id, ortet_id)
    if not composite_id or not ortet_id then return end
    if not storage[BUD_ORTET_MAP_KEY] then
        storage[BUD_ORTET_MAP_KEY] = {}
    end
    storage[BUD_ORTET_MAP_KEY][composite_id] = ortet_id
end

--- Get a position key for storage lookup
--- @param position MapPosition
--- @return string
local function pos_key(position)
    return string.format("%.1f,%.1f", position.x, position.y)
end

--- Track spawn time for maturity calculation
--- @param composite_id string The bud's composite ID
--- @param position MapPosition The bud's position
--- @param force_name string The force name
--- @param spawn_tick number|nil The spawn tick (defaults to 0 for fully grown)
local function track_bud_spawn(composite_id, position, force_name, spawn_tick)
    if not composite_id or not force_name then return end
    
    -- Initialize storage
    if not storage[BUD_SPAWN_TIMES_KEY] then
        storage[BUD_SPAWN_TIMES_KEY] = {}
    end
    if not storage[BUD_SPAWN_TIMES_KEY][force_name] then
        storage[BUD_SPAWN_TIMES_KEY][force_name] = {}
    end
    if not storage[BUD_BY_POS_KEY] then
        storage[BUD_BY_POS_KEY] = {}
    end
    if not storage[BUD_BY_POS_KEY][force_name] then
        storage[BUD_BY_POS_KEY][force_name] = {}
    end
    
    -- Use spawn_tick = 0 for fully grown buds (spawned at map gen)
    storage[BUD_SPAWN_TIMES_KEY][force_name][composite_id] = spawn_tick or 0
    storage[BUD_BY_POS_KEY][force_name][pos_key(position)] = composite_id
end

--- Initialize storage for this system
local function init_storage()
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}
    end
end

--- Check if an ortet has already been processed
--- @param ortet LuaEntity
--- @return boolean
local function is_ortet_processed(ortet)
    init_storage()
    local key = ortet.surface.name .. "_" .. ortet.position.x .. "_" .. ortet.position.y
    return storage[STORAGE_KEY][key] == true
end

--- Mark an ortet as processed
--- @param ortet LuaEntity
local function mark_ortet_processed(ortet)
    init_storage()
    local key = ortet.surface.name .. "_" .. ortet.position.x .. "_" .. ortet.position.y
    storage[STORAGE_KEY][key] = true
end

--- Calculate how many buds to spawn based on distance from spawn
--- @param distance number Distance from spawn (0,0)
--- @return number Number of buds to spawn (MIN_COUNT to MAX_COUNT)
local function calculate_bud_count(distance)
    return qf_constants.calculate_bud_count(distance)
end

--- Spawn a single bud at the given position using the composite entity API
--- @param surface LuaSurface
--- @param position MapPosition
--- @param ortet_id number The parent ortet's unit_number
--- @return string|nil The composite ID, or nil if failed
local function spawn_bud(surface, position, ortet_id)
    -- Find a valid position (not colliding with other entities)
    local spawn_pos = surface.find_non_colliding_position(
        ENTITIES.BUD,
        position,
        10,  -- Search radius
        1    -- Precision
    )
    
    if not spawn_pos then
        return nil
    end
    
    -- Check if on valid tile (quartz forest tile)
    local tile = surface.get_tile(spawn_pos.x, spawn_pos.y)
    if tile and tile.name ~= TILES.QUARTZ_FOREST then
        return nil  -- Not on quartz forest tile
    end
    
    -- Create the bud composite on ENEMY force (required for capture)
    local enemy_force = game.forces["enemy"]
    local composite_id = tenebris.composite_entity.lifecycle.create(
        surface,
        spawn_pos,
        "tenebris-quartz-ortet-bud",
        enemy_force
    )
    
    if not composite_id then
        return nil
    end
    
    -- Get actual position from composite
    local actual_pos = tenebris.composite_entity.lifecycle.get_interface_position(composite_id) or spawn_pos
    
    -- Track spawn time for maturity calculation
    -- Randomize spawn_tick to give varying maturity (0% to 100% grown)
    -- spawn_tick in past = more mature, spawn_tick = game.tick = just spawned
    local maturity_fraction = math.random()  -- 0.0 to 1.0
    local elapsed_ticks = math.floor(maturity_fraction * QF.GROWTH_TICKS)
    local random_spawn_tick = game.tick - elapsed_ticks
    track_bud_spawn(composite_id, actual_pos, "enemy", random_spawn_tick)
    
    -- Track the bud->ortet relationship for spawn limiting
    if ortet_id then
        increment_ortet_bud_count(ortet_id)
        track_bud_ortet(composite_id, ortet_id)
    end
    
    return composite_id
end

--- Spawn buds around an ortet
--- @param ortet LuaEntity The ortet entity
local function spawn_buds_around_ortet(ortet)
    if not ortet.valid then return end
    
    local surface = ortet.surface
    local ortet_pos = ortet.position
    local ortet_id = ortet.unit_number
    
    -- Calculate distance from spawn
    local distance_from_spawn = math.sqrt(ortet_pos.x^2 + ortet_pos.y^2)
    
    -- Calculate how many buds to spawn
    local target_bud_count = calculate_bud_count(distance_from_spawn)
    
    -- Track spawned bud positions for spacing check
    local spawned_positions = {}
    local spawned_count = 0
    
    -- Try to spawn buds in a ring around the ortet
    -- Use multiple attempts with random angles
    local max_attempts = target_bud_count * 5
    local attempts = 0
    
    while spawned_count < target_bud_count and attempts < max_attempts do
        attempts = attempts + 1
        
        -- Random angle and distance
        local angle = math.random() * 2 * math.pi
        local distance = BUD.MIN_DISTANCE + math.random() * (BUD.MAX_DISTANCE - BUD.MIN_DISTANCE)
        
        -- Calculate position
        local target_pos = {
            x = ortet_pos.x + math.cos(angle) * distance,
            y = ortet_pos.y + math.sin(angle) * distance
        }
        
        -- Check spacing from other spawned buds
        local too_close = false
        for _, pos in pairs(spawned_positions) do
            local dx = target_pos.x - pos.x
            local dy = target_pos.y - pos.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < BUD.SPACING then
                too_close = true
                break
            end
        end
        
        if not too_close then
            -- Also check for existing buds in the area
            local existing = surface.find_entities_filtered{
                name = ENTITIES.BUD,
                position = target_pos,
                radius = BUD.SPACING
            }
            
            if #existing == 0 then
                local composite_id = spawn_bud(surface, target_pos, ortet_id)
                if composite_id then
                    -- Get actual position from composite or use target
                    local actual_pos = tenebris.composite_entity.lifecycle.get_interface_position(composite_id) or target_pos
                    table.insert(spawned_positions, actual_pos)
                    spawned_count = spawned_count + 1
                end
            end
        end
    end
end

--- Handler for on_chunk_generated event
--- Finds ortets and spawns buds around them
--- @param event EventData.on_chunk_generated
local function on_chunk_generated(event)
    local surface = event.surface
    
    -- Only process on Tenebris
    if not tenebris.is_tenebris_surface(surface) then
        return
    end
    
    local area = event.area
    
    -- Find all ortets in this chunk
    local ortets = surface.find_entities_filtered{
        name = ENTITIES.ORTET,
        area = area
    }
    
    for _, ortet in pairs(ortets) do
        if ortet.valid and not is_ortet_processed(ortet) then
            mark_ortet_processed(ortet)
            
            -- Autoplaced entities default to neutral - reassign to enemy for capture
            if ortet.force.name ~= "enemy" then
                ortet.force = "enemy"
            end
            
            spawn_buds_around_ortet(ortet)
        end
    end
end

--- Registers event handlers
function map_gen.register_events()
    tenebris.event_manager.subscribe(
        tenebris.EVENTS.ON_CHUNK_GENERATED,
        "quartz_forest_map_gen",
        on_chunk_generated,
        tenebris.PRIORITY.SETUP
    )
end

return map_gen
