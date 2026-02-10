--- Quartz Bud Capture Handler
--- Handles the capture of quartz ortet buds, converting them to piezoelectric generators.
--- The tier of the generator is determined by the bud's growth progress (maturity).
---
--- Maturity is tracked manually by storing the tick when each bud spawns and
--- calculating elapsed time relative to the plant's growth_ticks (5 minutes).
---
--- @module quartz_bud_capture

local tenebris = require("lib.tenebris")
local piezo_constants = require("lib.piezoelectric_constants")
local qf_constants = require("lib.quartz_forest_constants")

local capture = {}

-- Use centralized constants
local QF = tenebris.QUARTZ_FOREST
local BUD_ENTITY_NAME = QF.BUD_ENTITY
local BUD_SPAWNER_ENTITY_NAME = QF.BUD_SPAWNER_ENTITY
local SPAWNER_ENTITY_NAME = QF.ORTET_ENTITY
local GROWTH_TICKS = QF.GROWTH_TICKS
local STORAGE_KEY = QF.STORAGE_BUD_SPAWN_TIMES
local COMPOSITE_BY_POS_KEY = QF.STORAGE_BUD_BY_POS


-- Storage key for tracking ortet -> bud count
local ORTET_BUD_COUNT_KEY = "quartz_forest_ortet_bud_counts"
-- Storage key for tracking bud -> parent ortet (for decrement on destruction)
local BUD_ORTET_MAP_KEY = "quartz_forest_bud_ortet_map"

--- Ensure storage is initialized for a force
--- @param force_name string The force name
local function ensure_storage(force_name)
    if not force_name or not STORAGE_KEY or not COMPOSITE_BY_POS_KEY then
        return
    end
    
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}
    end
    if not storage[STORAGE_KEY][force_name] then
        storage[STORAGE_KEY][force_name] = {}
    end
    if not storage[COMPOSITE_BY_POS_KEY] then
        storage[COMPOSITE_BY_POS_KEY] = {}
    end
    if not storage[COMPOSITE_BY_POS_KEY][force_name] then
        storage[COMPOSITE_BY_POS_KEY][force_name] = {}
    end
    if not storage[ORTET_BUD_COUNT_KEY] then
        storage[ORTET_BUD_COUNT_KEY] = {}
    end
end

-- =============================================================================
-- ORTET BUD COUNT TRACKING
-- Captures don't free bud slots, only destruction does
-- =============================================================================

--- Get the bud count for an ortet
--- @param ortet_id number The ortet's unit_number
--- @return number The current bud count
local function get_ortet_bud_count(ortet_id)
    if not ortet_id or not storage[ORTET_BUD_COUNT_KEY] then
        return 0
    end
    return storage[ORTET_BUD_COUNT_KEY][ortet_id] or 0
end

--- Increment the bud count for an ortet
--- @param ortet_id number The ortet's unit_number
local function increment_ortet_bud_count(ortet_id)
    if not ortet_id then return end
    ensure_storage("enemy")
    storage[ORTET_BUD_COUNT_KEY][ortet_id] = get_ortet_bud_count(ortet_id) + 1
end

--- Decrement the bud count for an ortet (only on destruction, not capture)
--- @param ortet_id number The ortet's unit_number
local function decrement_ortet_bud_count(ortet_id)
    if not ortet_id then return end
    if not storage[ORTET_BUD_COUNT_KEY] then return end
    local count = storage[ORTET_BUD_COUNT_KEY][ortet_id] or 0
    storage[ORTET_BUD_COUNT_KEY][ortet_id] = math.max(0, count - 1)
end

--- Find the nearest ortet to a position
--- @param surface LuaSurface
--- @param position MapPosition
--- @return LuaEntity|nil The nearest ortet, or nil
local function find_nearest_ortet(surface, position)
    local ortets = surface.find_entities_filtered{
        name = SPAWNER_ENTITY_NAME,
        position = position,
        radius = qf_constants.BUD.ORTET_SEARCH_RADIUS
    }
    if #ortets == 0 then return nil end
    
    -- Find closest
    local closest = nil
    local closest_dist = math.huge
    for _, ortet in pairs(ortets) do
        local dx = ortet.position.x - position.x
        local dy = ortet.position.y - position.y
        local dist = dx*dx + dy*dy
        if dist < closest_dist then
            closest = ortet
            closest_dist = dist
        end
    end
    return closest
end

--- Check if an ortet can spawn more buds
--- @param ortet_id number The ortet's unit_number
--- @return boolean True if the ortet can spawn more buds
local function can_ortet_spawn_bud(ortet_id)
    if not ortet_id then return true end  -- If we can't find ortet, allow spawn
    return get_ortet_bud_count(ortet_id) < qf_constants.BUD.MAX_PER_ORTET
end

--- Track which ortet owns a bud (for decrement on destruction)
--- @param composite_id string The bud's composite ID
--- @param ortet_id number The ortet's unit_number
local function track_bud_ortet(composite_id, ortet_id)
    if not composite_id or not ortet_id then return end
    if not storage[BUD_ORTET_MAP_KEY] then
        storage[BUD_ORTET_MAP_KEY] = {}
    end
    storage[BUD_ORTET_MAP_KEY][composite_id] = ortet_id
end

--- Get the parent ortet ID for a bud
--- @param composite_id string The bud's composite ID
--- @return number|nil The ortet's unit_number, or nil
local function get_bud_parent_ortet(composite_id)
    if not composite_id or not storage[BUD_ORTET_MAP_KEY] then
        return nil
    end
    return storage[BUD_ORTET_MAP_KEY][composite_id]
end

--- Clean up bud -> ortet tracking
--- @param composite_id string The bud's composite ID
local function cleanup_bud_ortet_tracking(composite_id)
    if not composite_id or not storage[BUD_ORTET_MAP_KEY] then return end
    storage[BUD_ORTET_MAP_KEY][composite_id] = nil
end

--- Get a position key for storage lookup
local function pos_key(position)
    return string.format("%.1f,%.1f", position.x, position.y)
end


--- Track a newly spawned bud by composite_id
--- @param composite_id string The composite ID
--- @param position MapPosition The bud position
--- @param force_name string The force name
local function track_bud_spawn(composite_id, position, force_name)
    if not composite_id or not force_name then
        return
    end
    
    ensure_storage(force_name)
    
    -- Verify storage was initialized
    if not storage[STORAGE_KEY] or not storage[STORAGE_KEY][force_name] then return end
    if not storage[COMPOSITE_BY_POS_KEY] or not storage[COMPOSITE_BY_POS_KEY][force_name] then return end
    
    -- Track spawn time by composite_id (for maturity calculation)
    storage[STORAGE_KEY][force_name][composite_id] = game.tick
    
    -- Track composite_id by position (for capture proxy lookup)
    local pkey = pos_key(position)
    storage[COMPOSITE_BY_POS_KEY][force_name][pkey] = composite_id
end


--- Get the composite_id for a bud by position
--- @param position MapPosition The position to look up
--- @param force_name string The force name
--- @return string|nil composite_id
local function get_composite_id_by_position(position, force_name)
    if not force_name then
        return nil
    end
    
    ensure_storage(force_name)
    
    if not storage[COMPOSITE_BY_POS_KEY] or not storage[COMPOSITE_BY_POS_KEY][force_name] then
        return nil
    end
    
    local pkey = pos_key(position)
    return storage[COMPOSITE_BY_POS_KEY][force_name][pkey]
end


--- Get the maturity of a bud by composite_id (0 to 1)
--- @param composite_id string The composite ID
--- @param force_name string The force name
--- @return number maturity Growth progress from 0 (just spawned) to 1 (fully grown)
local function get_bud_maturity_by_composite(composite_id, force_name)
    if not composite_id or not force_name then
        return 0.1  -- Default to immature if we can't determine
    end
    
    if not storage[STORAGE_KEY] or not storage[STORAGE_KEY][force_name] then
        return 0.1
    end
    
    local spawn_tick = storage[STORAGE_KEY][force_name][composite_id]
    if not spawn_tick then
        return 0.1
    end
    
    local elapsed = game.tick - spawn_tick
    return math.min(1, elapsed / GROWTH_TICKS)
end


--- Clean up tracking after capture
--- @param composite_id string The composite ID
--- @param position MapPosition The position to clean up
--- @param force_name string The force name
local function cleanup_tracking(composite_id, position, force_name)
    if not force_name then return end
    
    -- Clean up composite_id -> spawn_tick
    if composite_id and storage[STORAGE_KEY] and storage[STORAGE_KEY][force_name] then
        storage[STORAGE_KEY][force_name][composite_id] = nil
    end
    
    -- Clean up position -> composite_id
    if position and storage[COMPOSITE_BY_POS_KEY] and storage[COMPOSITE_BY_POS_KEY][force_name] then
        local pkey = pos_key(position)
        storage[COMPOSITE_BY_POS_KEY][force_name][pkey] = nil
    end
end


-- =============================================================================
-- EVENT SUBSCRIPTIONS
-- =============================================================================

local event_manager = tenebris.event_manager
local CAPTURE_PRIORITY = tenebris.PRIORITY.GAMEPLAY


-- =============================================================================
-- Handle capture proxy death and hidden spawn unit death
-- The proxy auto-dies in 1 tick due to healing_per_tick = -1
-- =============================================================================

local SPAWNER_CAPTURE_PROXY_NAME = QF.ORTET_CAPTURE_PROXY
local BUD_CAPTURE_PROXY_NAME = QF.BUD_CAPTURE_PROXY
local HIDDEN_SPAWN_UNIT_NAME = QF.HIDDEN_SPAWN_UNIT
local BUD_SPAWN_MIN_RADIUS = QF.BUD_SPAWN_MIN_RADIUS
local BUD_SPAWN_MAX_RADIUS = QF.BUD_SPAWN_MAX_RADIUS

--- Calculate a random position within a ring around a center point
--- @param center MapPosition The center position
--- @param min_radius number Minimum distance from center
--- @param max_radius number Maximum distance from center
--- @return MapPosition
local function random_ring_position(center, min_radius, max_radius)
    local angle = math.random() * 2 * math.pi
    local distance = min_radius + math.random() * (max_radius - min_radius)
    return {
        x = center.x + math.cos(angle) * distance,
        y = center.y + math.sin(angle) * distance
    }
end

event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "quartz_capture_proxy_died", function(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    local surface = entity.surface
    local position = entity.position
    local force = entity.force
    
    -- Handle hidden spawn unit death (ortet spawned a bud - create bud composite)
    if entity.name == HIDDEN_SPAWN_UNIT_NAME then
        -- Check spawn probability
        if math.random() > qf_constants.BUD.SPAWN_PROBABILITY then
            return  -- Failed probability check, no bud spawns
        end
        
        -- Find the parent ortet that spawned this unit
        local parent_ortet = find_nearest_ortet(surface, position)
        local ortet_id = parent_ortet and parent_ortet.unit_number or nil
        
        -- Check if this ortet can spawn more buds
        if ortet_id and not can_ortet_spawn_bud(ortet_id) then
            return  -- Ortet already has max buds
        end
        
        -- Pick a random position in a ring around where the hidden unit died (near the ortet)
        local target_pos = random_ring_position(position, BUD_SPAWN_MIN_RADIUS, BUD_SPAWN_MAX_RADIUS)
        
        -- Find non-colliding position near that target
        local spawn_pos = surface.find_non_colliding_position(BUD_SPAWNER_ENTITY_NAME, target_pos, 10, 0.5)
        if not spawn_pos then
            return
        end
        
        -- Create the bud composite on ENEMY force (required for capture rockets to target)
        local enemy_force = game.forces["enemy"]
        local composite_id = tenebris.composite_entity.lifecycle.create(
            surface,
            spawn_pos,
            "tenebris-quartz-ortet-bud",
            enemy_force
        )
        
        if not composite_id then
            game.print("[Tenebris] Failed to create bud composite")
            return
        end
        
        -- Get the actual interface entity position (may differ from spawn_pos due to snapping)
        local actual_pos = tenebris.composite_entity.lifecycle.get_interface_position(composite_id) or spawn_pos
        
        -- Track spawn time for maturity calculation (use actual position for accurate lookup)
        track_bud_spawn(composite_id, actual_pos, enemy_force.name)
        
        -- Increment the ortet's bud count
        if ortet_id then
            increment_ortet_bud_count(ortet_id)
            -- Track which ortet owns this bud for decrement on destruction
            track_bud_ortet(composite_id, ortet_id)
        end
        return
    end
    
    -- Handle spawner capture proxy (tier 4)
    if entity.name == SPAWNER_CAPTURE_PROXY_NAME then
        local tier = piezo_constants.get_tier(4)
        local composite_id = tenebris.composite_entity.lifecycle.create(
            surface,
            position,
            tier.composite_name,
            force
        )
        
        if composite_id then
            if force then force.print({"tenebris.spawner-captured", tier.power_output}) end
        else
            game.print("[Tenebris] ERROR: Failed to create piezoelectric generator from spawner capture proxy")
        end
        return
    end
    
    -- Handle bud capture proxy (tier based on maturity)
    if entity.name == BUD_CAPTURE_PROXY_NAME then
        -- Look up the bud composite by position (buds are always on enemy force)
        local bud_composite_id = get_composite_id_by_position(position, "enemy")
        
        -- Get spawn tick for debug
        local spawn_tick = nil
        if bud_composite_id and storage[STORAGE_KEY] and storage[STORAGE_KEY]["enemy"] then
            spawn_tick = storage[STORAGE_KEY]["enemy"][bud_composite_id]
        end
        
        -- Get maturity from composite tracking
        local maturity = get_bud_maturity_by_composite(bud_composite_id, "enemy")
        local tier = piezo_constants.get_tier_by_maturity(maturity)
        
        -- Debug output
        local elapsed = spawn_tick and (game.tick - spawn_tick) or 0
        game.print(string.format("[Bud Capture] spawn_tick=%s, current_tick=%d, elapsed=%d, GROWTH_TICKS=%d, maturity=%.2f, tier=%d",
            tostring(spawn_tick), game.tick, elapsed, GROWTH_TICKS, maturity, tier.tier))
        
        -- Clean up tracking (but do NOT decrement ortet count - capture doesn't free the slot)
        cleanup_tracking(bud_composite_id, position, "enemy")
        cleanup_bud_ortet_tracking(bud_composite_id)
        
        -- Destroy the bud composite (plant + spawner) via lifecycle if it exists
        if bud_composite_id then
            tenebris.composite_entity.lifecycle.destroy(bud_composite_id)
        end
        
        -- Also find and destroy any orphaned plant/spawner at this position
        -- (handles buds created by map_generation that aren't composites)
        local nearby_plants = surface.find_entities_filtered{
            name = BUD_ENTITY_NAME,
            position = position,
            radius = 1
        }
        for _, plant in pairs(nearby_plants) do
            if plant.valid then plant.destroy() end
        end
        
        local nearby_spawners = surface.find_entities_filtered{
            name = BUD_SPAWNER_ENTITY_NAME,
            position = position,
            radius = 1
        }
        for _, spawner in pairs(nearby_spawners) do
            if spawner.valid then spawner.destroy() end
        end
        
        -- Create the piezoelectric generator composite
        local piezo_composite_id = tenebris.composite_entity.lifecycle.create(
            surface,
            position,
            tier.composite_name,
            force
        )
        
        if piezo_composite_id then
            if force then force.print({"tenebris.bud-captured", tier.tier, tier.power_output}) end
        else
            game.print("[Tenebris] ERROR: Failed to create piezoelectric generator from bud capture proxy")
        end
        return
    end
end, CAPTURE_PRIORITY)


-- =============================================================================
-- Handle bud destruction (killed, not captured)
-- When a bud is destroyed, decrement the ortet's bud count so it can spawn more
-- =============================================================================

event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "quartz_bud_destroyed", function(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    
    -- Only handle bud plant or spawner deaths
    if entity.name ~= BUD_ENTITY_NAME and entity.name ~= BUD_SPAWNER_ENTITY_NAME then
        return
    end
    
    local position = entity.position
    
    -- Try to find the composite_id for this bud by position
    local composite_id = get_composite_id_by_position(position, "enemy")
    
    if composite_id then
        -- Get the parent ortet and decrement its count
        local parent_ortet_id = get_bud_parent_ortet(composite_id)
        if parent_ortet_id then
            decrement_ortet_bud_count(parent_ortet_id)
        end
        
        -- Clean up all tracking for this bud
        cleanup_tracking(composite_id, position, "enemy")
        cleanup_bud_ortet_tracking(composite_id)
    end
end, CAPTURE_PRIORITY)


return capture
