--- Tenespace Ambient Effects
--- Spawns ambient visual effects on space platforms traveling in tenespace routes.
--- Creates glowing cyan particles and thick black spore clouds.
---
--- OPTIMIZATIONS:
--- 1. Chunk cache is built incrementally (20 chunks per tick) to avoid spikes
--- 2. Active tenespace platforms are tracked to avoid iterating all platforms
--- 3. Entity events trigger cache invalidation for affected platforms
--- 4. Corrosion is spread across ticks (1-2 chunks per tick instead of all at once)
---
--- @module tenespace_effects

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager
local banned = require("scripts.entity_manager.banned_entities")

-- Storage keys
local STORAGE_KEY = "tenespace_platform_cache"
local ACTIVE_PLATFORMS_KEY = "tenespace_active_platforms"

--- Get corrosion interval (uses same setting as ground-based spore damage)
--- @return number interval in ticks
local function get_corrosion_interval()
    return tenebris.get_spore_check_interval()
end

-- Tenespace locations (platforms at or traveling to/from these trigger effects)
-- Build from constants for consistency
local TENESPACE_LOCATIONS = {}
for _, loc in ipairs(tenebris.ALL_TENEBRIS_LOCATIONS) do
    TENESPACE_LOCATIONS[loc] = true
end

-- Effect configuration from shared constants
local CONFIG = require("lib.constants").TENESPACE

--- Ensure storage is initialized
local function ensure_storage()
    if not storage[STORAGE_KEY] then
        storage[STORAGE_KEY] = {}
    end
    if not storage[ACTIVE_PLATFORMS_KEY] then
        storage[ACTIVE_PLATFORMS_KEY] = {}
    end
end

--- Get or create platform cache entry
--- @param platform LuaSpacePlatform
--- @return table|nil cache entry, or nil if platform invalid
local function get_platform_cache(platform)
    if not platform or not platform.valid then
        return nil
    end
    
    ensure_storage()
    local platform_id = platform.index
    
    if not storage[STORAGE_KEY][platform_id] then
        storage[STORAGE_KEY][platform_id] = {
            -- Completed cache data
            chunks = {},           -- Chunks with player entities (for corrosion)
            chunk_count = 0,       -- Count of chunks with player entities
            total_chunks = 0,      -- Total rendered chunks
            last_rebuild = 0,
            bounds = {
                min_x = 0,
                max_x = 0,
                min_y = 0,
                max_y = 0,
            },
            -- Incremental rebuild state
            rebuilding = false,
            rebuild_chunks = {},    -- Chunks being built during rebuild
            rebuild_total = 0,      -- Total chunks found during rebuild
            rebuild_bounds = nil,   -- Bounds being calculated during rebuild
        }
    end
    
    return storage[STORAGE_KEY][platform_id]
end


--- Start an incremental cache rebuild for a platform
--- @param platform LuaSpacePlatform
--- @param cache table The platform's cache entry
local function start_cache_rebuild(platform, cache)
    local surface = platform.surface
    if not surface or not surface.valid then
        cache.chunks = {}
        cache.chunk_count = 0
        cache.total_chunks = 0
        cache.bounds = {min_x = 0, max_x = 0, min_y = 0, max_y = 0}
        cache.rebuilding = false
        return
    end
    
    -- Collect all chunk positions upfront (this is fast - just position data)
    local all_chunks = {}
    for chunk in surface.get_chunks() do
        table.insert(all_chunks, {x = chunk.x, y = chunk.y})
    end
    
    -- Initialize rebuild state
    cache.rebuilding = true
    cache.rebuild_chunks = {}
    cache.rebuild_total = #all_chunks
    cache.rebuild_index = 1
    cache.rebuild_all_chunks = all_chunks
    cache.rebuild_bounds = {min_cx = nil, max_cx = nil, min_cy = nil, max_cy = nil}
end

--- Process a batch of chunks during incremental rebuild
--- @param platform LuaSpacePlatform
--- @param cache table The platform's cache entry
--- @param current_tick number Current game tick
--- @return boolean true if rebuild completed
local function process_cache_rebuild_batch(platform, cache, current_tick)
    if not cache.rebuilding then
        return true
    end
    
    local surface = platform.surface
    if not surface or not surface.valid then
        cache.rebuilding = false
        return true
    end
    
    local all_chunks = cache.rebuild_all_chunks
    local start_index = cache.rebuild_index
    local end_index = math.min(start_index + CONFIG.CHUNKS_PER_REBUILD_TICK - 1, #all_chunks)
    
    for i = start_index, end_index do
        local chunk = all_chunks[i]
        
        -- Track bounds
        local bounds = cache.rebuild_bounds
        if not bounds.min_cx or chunk.x < bounds.min_cx then bounds.min_cx = chunk.x end
        if not bounds.max_cx or chunk.x > bounds.max_cx then bounds.max_cx = chunk.x end
        if not bounds.min_cy or chunk.y < bounds.min_cy then bounds.min_cy = chunk.y end
        if not bounds.max_cy or chunk.y > bounds.max_cy then bounds.max_cy = chunk.y end
        
        -- Check for player entities in this chunk
        local area = {
            {chunk.x * 32, chunk.y * 32},
            {(chunk.x + 1) * 32, (chunk.y + 1) * 32}
        }
        local entities = surface.find_entities_filtered({
            area = area,
            limit = 10,
        })
        local has_player_entities = false
        for _, entity in pairs(entities) do
            local force = entity.force
            if force and force.name ~= "neutral" and force.name ~= "enemy" then
                has_player_entities = true
                break
            end
        end
        if has_player_entities then
            table.insert(cache.rebuild_chunks, {x = chunk.x, y = chunk.y})
        end
    end
    
    cache.rebuild_index = end_index + 1
    
    -- Check if rebuild is complete
    if cache.rebuild_index > #all_chunks then
        -- Finalize: swap in the new data
        cache.chunks = cache.rebuild_chunks
        cache.chunk_count = #cache.rebuild_chunks
        cache.total_chunks = cache.rebuild_total
        cache.last_rebuild = current_tick
        
        -- Convert chunk bounds to tile coordinates
        local bounds = cache.rebuild_bounds
        if bounds.min_cx then
            cache.bounds = {
                min_x = bounds.min_cx * 32,
                max_x = (bounds.max_cx + 1) * 32,
                min_y = bounds.min_cy * 32,
                max_y = (bounds.max_cy + 1) * 32,
            }
        else
            cache.bounds = {min_x = 0, max_x = 0, min_y = 0, max_y = 0}
        end
        
        -- Clear rebuild state
        cache.rebuilding = false
        cache.rebuild_chunks = nil
        cache.rebuild_all_chunks = nil
        cache.rebuild_bounds = nil
        cache.rebuild_index = nil
        
        return true
    end
    
    return false
end

--- Check if cache needs rebuilding
--- @param cache table The platform's cache entry
--- @param current_tick number Current game tick
--- @return boolean
local function cache_needs_rebuild(cache, current_tick)
    -- Already rebuilding
    if cache.rebuilding then
        return false
    end
    -- First time (no chunks at all)
    if cache.chunk_count == 0 and cache.total_chunks == 0 then
        return true
    end
    -- Periodic refresh
    return (current_tick - (cache.last_rebuild or 0)) >= CONFIG.CACHE_REBUILD_INTERVAL
end

-- Routes that connect to Tenebris from outside tenespace
-- Effects scale based on travel progress on these routes
local TENEBRIS_APPROACH_ROUTES = {
    ["fulgora-tenebris"] = true,
    ["maraxsis-tenebris"] = true,
    ["paracelsin-tenebris"] = true,
}

--- Check if a platform is currently in tenespace
--- @param platform LuaSpacePlatform
--- @return boolean
local function is_platform_in_tenespace(platform)
    if not platform or not platform.valid then
        return false
    end
    
    -- Check current location (at a tenespace location)
    local location = platform.space_location
    if location and TENESPACE_LOCATIONS[location.name] then
        return true
    end
    
    -- Check space_connection (traveling on a tenespace route)
    local connection = platform.space_connection
    if connection then
        -- from/to are LuaSurface objects - access .name property
        local from_name = connection.from and connection.from.name
        local to_name = connection.to and connection.to.name
        
        if from_name and TENESPACE_LOCATIONS[from_name] then
            return true
        end
        if to_name and TENESPACE_LOCATIONS[to_name] then
            return true
        end
    end
    
    return false
end

--- Calculate the proximity to Tenebris for effect scaling
--- Returns 1.0 when at/near Tenebris, 0.0 when far from Tenebris
--- For approach routes, scales based on travel progress
--- @param platform LuaSpacePlatform
--- @return number proximity 0.0 to 1.0
local function get_tenebris_proximity(platform)
    if not platform or not platform.valid then
        return 0
    end
    
    -- If at a Tenebris location, full intensity
    local location = platform.space_location
    if location and TENESPACE_LOCATIONS[location.name] then
        return 1.0
    end
    
    -- Check if traveling on an approach route
    local connection = platform.space_connection
    if not connection then
        return 0
    end
    
    local connection_name = connection.name
    if not TENEBRIS_APPROACH_ROUTES[connection_name] then
        -- On a route fully within tenespace, full intensity
        local from_name = connection.from and connection.from.name
        local to_name = connection.to and connection.to.name
        if (from_name and TENESPACE_LOCATIONS[from_name]) or (to_name and TENESPACE_LOCATIONS[to_name]) then
            return 1.0
        end
        return 0
    end
    
    -- On an approach route - scale by travel progress
    local distance = platform.distance or 0  -- 0-1 progress along route
    local to_name = connection.to and connection.to.name
    
    -- If traveling TO Tenebris, distance increases toward 1 as we approach
    if to_name and TENESPACE_LOCATIONS[to_name] then
        return distance
    end
    
    -- If traveling FROM Tenebris, invert (start at 1, decrease to 0)
    local from_name = connection.from and connection.from.name
    if from_name and TENESPACE_LOCATIONS[from_name] then
        return 1 - distance
    end
    
    return 0
end

--- Spawn smoke effects in a 3x3 chunk area centered on the given chunk
--- @param surface LuaSurface
--- @param chunk_x number Chunk X coordinate (center of 3x3 area)
--- @param chunk_y number Chunk Y coordinate (center of 3x3 area)
--- @param smoke_name string
--- @param config table
--- @param scale_factor number Multiplier for particle counts based on platform size
--- @param proximity number 0-1 proximity to Tenebris (scales spawn chance and counts)
local function spawn_smoke_effect_in_chunk_area(surface, chunk_x, chunk_y, smoke_name, config, scale_factor, proximity)
    -- Scale spawn chance by proximity
    local effective_spawn_chance = config.spawn_chance * proximity
    if math.random() > effective_spawn_chance then
        return
    end
    
    -- Scale particle counts by platform size AND proximity
    local proximity_scale = scale_factor * proximity
    local scaled_min = math.max(1, math.floor(config.count_min * proximity_scale))
    local scaled_max = math.max(1, math.floor(config.count_max * proximity_scale))
    local count = math.random(scaled_min, scaled_max)
    
    -- 3x3 chunk area = 96x96 tiles centered on the chunk
    local min_x = (chunk_x - 1) * 32
    local min_y = (chunk_y - 1) * 32
    local width = 96  -- 3 chunks * 32 tiles
    local height = 96
    
    for _ = 1, count do
        local x = min_x + math.random() * width
        local y = min_y + math.random() * height
        local speed_x = (math.random() * 2 - 1) * (config.speed_max - config.speed_min) + config.speed_min
        local speed_y = (math.random() * 2 - 1) * (config.speed_max - config.speed_min) + config.speed_min
        
        surface.create_trivial_smoke({
            name = smoke_name,
            position = {x, y},
            speed = {speed_x, speed_y},
        })
    end
end

--- Check if an entity is immune to corrosion
--- @param entity LuaEntity
--- @return boolean
local function is_corrosion_immune(entity)
    -- Use SPORE_IMMUNE from banned entities (shared with ground-based system)
    if banned.SPORE_IMMUNE and banned.SPORE_IMMUNE[entity.name] then
        return true
    end
    -- Heat-based entities are protected from acid corrosion
    if entity.prototype and (entity.prototype.heat_energy_source_prototype or entity.prototype.heat_buffer_prototype) then
        return true
    end
    return false
end

--- Apply corrosion damage to entities in a chunk
--- @param surface LuaSurface
--- @param chunk_x number Chunk X coordinate
--- @param chunk_y number Chunk Y coordinate
--- @return number entities_damaged
local function apply_corrosion_in_chunk(surface, chunk_x, chunk_y)
    local area = {
        {chunk_x * 32, chunk_y * 32},
        {(chunk_x + 1) * 32, (chunk_y + 1) * 32}
    }
    
    -- Find all entities with health in chunk
    local all_entities = surface.find_entities_filtered({
        area = area,
    })
    
    -- Filter to only damageable, non-immune player entities (not asteroids/neutral)
    local damageable = {}
    for _, entity in pairs(all_entities) do
        if entity.valid and entity.health and not is_corrosion_immune(entity) then
            -- Only damage player forces (not neutral, enemy, or asteroids)
            local force = entity.force
            if force and force.name ~= "neutral" and force.name ~= "enemy" then
                table.insert(damageable, entity)
            end
        end
    end
    
    -- Random number of entities to damage (0 to max), capped by available entities
    local max_per_chunk = settings.global["tenebris-tenespace-corrosion-entities-per-chunk"].value
    local max_to_damage = math.min(#damageable, max_per_chunk)
    local count = math.random(0, max_to_damage)
    
    -- Shuffle to randomize which entities are damaged
    if count > 0 and #damageable > 1 then
        for i = 1, count do
            local j = math.random(i, #damageable)
            damageable[i], damageable[j] = damageable[j], damageable[i]
        end
    end
    
    -- Apply acid damage silently (no alerts, no sounds) with resistance calculation
    local damage_type = CONFIG.CORROSION.damage_type
    local base_damage = CONFIG.CORROSION.damage_amount
    local entities_damaged = 0
    
    for i = 1, count do
        local entity = damageable[i]
        if entity and entity.valid and entity.prototype then
            -- Calculate effective damage after resistance
            local effective_damage = base_damage
            local resistances = entity.prototype.resistances
            if resistances and resistances[damage_type] then
                local res = resistances[damage_type]
                -- Apply flat decrease first, then percentage
                effective_damage = effective_damage - (res.decrease or 0)
                if effective_damage > 0 then
                    effective_damage = effective_damage * (1 - (res.percent or 0))
                end
            end
            
            -- Only apply if there's effective damage
            if effective_damage > 0 then
                local new_health = entity.health - effective_damage
                if new_health <= 0 then
                    entity.die("neutral")  -- Die with proper death effects
                else
                    entity.health = new_health
                    entities_damaged = entities_damaged + 1
                end
            end
        end
    end
    
    return entities_damaged
end

--- Apply corrosion to random chunks on a platform
--- @param platform LuaSpacePlatform
--- @param cache table The platform's cache entry
--- @return number damaged Total entities damaged this tick
local function apply_corrosion_random(platform, cache)
    local surface = platform.surface
    if not surface or not surface.valid or cache.chunk_count == 0 then
        return 0
    end
    
    local chunks_to_process = math.min(CONFIG.CORROSION_CHUNKS_PER_TICK, cache.chunk_count)
    local total_damaged = 0
    
    for _ = 1, chunks_to_process do
        local chunk = cache.chunks[math.random(cache.chunk_count)]
        if chunk then
            total_damaged = total_damaged + apply_corrosion_in_chunk(surface, chunk.x, chunk.y)
        end
    end
    
    return total_damaged
end

--- Spawn all tenespace effects in random player-occupied chunks
--- @param platform LuaSpacePlatform
--- @param cache table The platform's cache entry
local function spawn_tenespace_effects_on_platform(platform, cache)
    local surface = platform.surface
    if not surface or not surface.valid then
        return
    end
    
    -- Need chunks with player entities to spawn effects
    if cache.chunk_count == 0 then
        return
    end
    
    -- Calculate proximity to Tenebris (scales effects on approach routes)
    local proximity = get_tenebris_proximity(platform)
    if proximity <= 0 then
        return  -- No effects if not approaching/in Tenebris
    end
    
    -- Scale particle counts based on platform size using square root for gentler scaling
    local baseline_chunks = settings.global["tenebris-tenespace-particle-baseline-chunks"].value
    local total_chunks = cache.total_chunks or baseline_chunks
    local scale_factor = math.max(0.3, math.sqrt(total_chunks / baseline_chunks))
    
    -- Pick random chunks with player entities and spawn effects in 3x3 area around them
    local chunks_to_process = math.min(CONFIG.CHUNKS_PER_UPDATE, cache.chunk_count)
    for _ = 1, chunks_to_process do
        local chunk = cache.chunks[math.random(cache.chunk_count)]
        if chunk then
            spawn_smoke_effect_in_chunk_area(surface, chunk.x, chunk.y, "tenespace-cyan-glow", CONFIG.CYAN_GLOW, scale_factor, proximity)
            spawn_smoke_effect_in_chunk_area(surface, chunk.x, chunk.y, "tenespace-cyan-glow-bright", CONFIG.CYAN_BRIGHT, scale_factor, proximity)
            spawn_smoke_effect_in_chunk_area(surface, chunk.x, chunk.y, "tenespace-spore-cloud-small", CONFIG.SPORE_SMALL, scale_factor, proximity)
            spawn_smoke_effect_in_chunk_area(surface, chunk.x, chunk.y, "tenespace-spore-cloud-large", CONFIG.SPORE_LARGE, scale_factor, proximity)
            spawn_smoke_effect_in_chunk_area(surface, chunk.x, chunk.y, "tenespace-spore-wisp", CONFIG.SPORE_WISP, scale_factor, proximity)
        end
    end
end

--- Show corrosion alert to players
--- @param platform LuaSpacePlatform
--- @param damaged number Total entities damaged
local function show_corrosion_alert(platform, damaged)
    if damaged <= 0 then
        return
    end
    
    local force = platform.force
    if not force or not force.valid then
        return
    end
    
    local hub = platform.hub
    if not hub or not hub.valid then
        -- Fallback: just print the message if hub is unavailable
        for _, player in pairs(force.players) do
            if player.valid and player.connected then
                player.print({"", "[color=red]Tenecap Spore Corrosion[/color]: ", damaged, " entities damaged on [color=cyan]", platform.name, "[/color]"})
            end
        end
        return
    end
    
    for _, player in pairs(force.players) do
        if player.valid and player.connected then
            player.add_custom_alert(
                hub,
                {type = "virtual", name = "signal-alert"},
                {"", "[color=red]Tenecap Spore Corrosion[/color]: ", damaged, " entities damaged on [color=cyan]", platform.name, "[/color]"},
                true  -- show_on_map
            )
        end
    end
end

--- Update and return active tenespace platforms in a single pass
--- @return table<number, LuaSpacePlatform> active platforms
local function get_and_update_active_platforms()
    ensure_storage()
    local tracked = storage[ACTIVE_PLATFORMS_KEY]
    local active_platforms = {}
    local new_tracked = {}
    
    -- Single pass through all platforms
    for _, force in pairs(game.forces) do
        if force.valid and force.platforms then
            for _, platform in pairs(force.platforms) do
                if platform.valid and is_platform_in_tenespace(platform) then
                    local platform_id = platform.index
                    active_platforms[platform_id] = platform
                    new_tracked[platform_id] = true
                    
                    -- Check if this platform just entered tenespace
                    if not tracked[platform_id] then
                        -- Trigger immediate cache rebuild for newly entered platform
                        local cache = get_platform_cache(platform)
                        if cache then
                            cache.last_rebuild = 0  -- Force rebuild on next check
                        end
                    end
                end
            end
        end
    end
    
    -- Update tracking (swap to new set)
    storage[ACTIVE_PLATFORMS_KEY] = new_tracked
    
    return active_platforms
end

-- Track when corrosion was last applied
local last_corrosion_tick = 0

--- Combined handler for effects and corrosion - single iteration through platforms
local function on_tenespace_tick(event)
    local current_tick = event.tick
    
    -- Get active platforms (single iteration)
    local active_platforms = get_and_update_active_platforms()
    
    -- Check if corrosion should run this tick
    local corrosion_interval = get_corrosion_interval()
    local should_run_corrosion = (current_tick - last_corrosion_tick) >= corrosion_interval
    if should_run_corrosion then
        last_corrosion_tick = current_tick
    end
    
    -- Single iteration through all active platforms
    for platform_id, platform in pairs(active_platforms) do
        local cache = get_platform_cache(platform)
        if cache then
            -- Handle incremental cache rebuild
            if cache.rebuilding then
                process_cache_rebuild_batch(platform, cache, current_tick)
            elseif cache_needs_rebuild(cache, current_tick) then
                start_cache_rebuild(platform, cache)
            end
            
            -- Only process if cache is ready
            if not cache.rebuilding and cache.chunk_count > 0 then
                -- Always spawn effects
                spawn_tenespace_effects_on_platform(platform, cache)
                
                -- Apply corrosion if it's time
                if should_run_corrosion then
                    local damaged = apply_corrosion_random(platform, cache)
                    if damaged > 0 then
                        show_corrosion_alert(platform, damaged)
                    end
                end
            end
        end
    end
end

--- Clean up stale platform caches
local function cleanup_stale_caches()
    ensure_storage()
    
    -- Build set of valid platform indices
    local valid_platforms = {}
    for _, force in pairs(game.forces) do
        if force.valid and force.platforms then
            for _, platform in pairs(force.platforms) do
                if platform.valid then
                    valid_platforms[platform.index] = true
                end
            end
        end
    end
    
    -- Remove stale cache entries
    for platform_id in pairs(storage[STORAGE_KEY]) do
        if not valid_platforms[platform_id] then
            storage[STORAGE_KEY][platform_id] = nil
        end
    end
    
    -- Remove stale active platform entries
    for platform_id in pairs(storage[ACTIVE_PLATFORMS_KEY]) do
        if not valid_platforms[platform_id] then
            storage[ACTIVE_PLATFORMS_KEY][platform_id] = nil
        end
    end
end

-- Register combined handler - single iteration handles both effects and corrosion
event_manager.subscribe_nth_tick(CONFIG.UPDATE_INTERVAL, "tenespace_effects", on_tenespace_tick)

-- Clean up stale caches periodically (every 10 seconds)
event_manager.subscribe_nth_tick(600, "tenespace_cache_cleanup", cleanup_stale_caches)

-- Initialize storage on init
event_manager.subscribe(tenebris.EVENTS.ON_INIT, "tenespace_effects_init", function()
    ensure_storage()
end, tenebris.PRIORITY.NORMAL)

-- Debug remote interface
remote.add_interface("tenespace_effects", {
    --- Check which platforms are in tenespace
    status = function()
        local count = 0
        local total = 0
        
        ensure_storage()
        local active_count = 0
        for _ in pairs(storage[ACTIVE_PLATFORMS_KEY]) do
            active_count = active_count + 1
        end
        
        for _, force in pairs(game.forces) do
            if force.valid and force.platforms then
                for _, platform in pairs(force.platforms) do
                    if platform.valid then
                        total = total + 1
                        local in_tenespace = is_platform_in_tenespace(platform)
                        local is_tracked = storage[ACTIVE_PLATFORMS_KEY][platform.index] ~= nil
                        local location = platform.space_location
                        local connection = platform.space_connection
                        
                        local status_parts = {}
                        if location then
                            table.insert(status_parts, "at " .. location.name)
                        elseif connection then
                            local from_name = connection.from and connection.from.name or "?"
                            local to_name = connection.to and connection.to.name or "?"
                            table.insert(status_parts, from_name .. " -> " .. to_name)
                        else
                            table.insert(status_parts, "idle")
                        end
                        
                        -- Show cache info
                        local cache = get_platform_cache(platform)
                        local cache_info = ", no cache"
                        if cache then
                            local b = cache.bounds or {}
                            local rebuild_status = ""
                            if cache.rebuilding then
                                local progress = cache.rebuild_index or 0
                                local total_rebuild = cache.rebuild_total or 0
                                rebuild_status = string.format(" [REBUILDING %d/%d]", progress, total_rebuild)
                            end
                            local age = game.tick - (cache.last_rebuild or 0)
                            cache_info = string.format(", %d/%d chunks, bounds: %d,%d to %d,%d, age: %.0fs%s", 
                                cache.chunk_count or 0, 
                                cache.total_chunks or 0, 
                                b.min_x or 0, b.min_y or 0, b.max_x or 0, b.max_y or 0,
                                age / 60,
                                rebuild_status)
                        end
                        
                        game.print(string.format("[%s%s] %s (%s%s)", 
                            in_tenespace and "TENESPACE" or "normal",
                            is_tracked and " TRACKED" or "",
                            platform.name,
                            table.concat(status_parts, ", "),
                            cache_info
                        ))
                        
                        if in_tenespace then count = count + 1 end
                    end
                end
            end
        end
        game.print(string.format("Platforms in tenespace: %d/%d (tracked: %d)", count, total, active_count))
    end,
    
    --- Force spawn effects on all tenespace platforms now
    test = function()
        for _, force in pairs(game.forces) do
            if force.valid and force.platforms then
                for _, platform in pairs(force.platforms) do
                    if platform.valid and is_platform_in_tenespace(platform) then
                        -- Force spawn with 100% chance
                        local surface = platform.surface
                        if surface and surface.valid then
                            for _ = 1, 10 do
                                surface.create_trivial_smoke({
                                    name = "tenespace-cyan-glow-bright",
                                    position = {math.random(-30, 30), math.random(-30, 30)},
                                })
                                surface.create_trivial_smoke({
                                    name = "tenespace-spore-cloud-large",
                                    position = {math.random(-40, 40), math.random(-40, 40)},
                                })
                            end
                            game.print("Spawned test effects on: " .. platform.name)
                        end
                    end
                end
            end
        end
    end,
    
    --- Force rebuild all caches (marks them for incremental rebuild)
    rebuild_caches = function()
        ensure_storage()
        local count = 0
        
        for _, force in pairs(game.forces) do
            if force.valid and force.platforms then
                for _, platform in pairs(force.platforms) do
                    if platform.valid then
                        local cache = get_platform_cache(platform)
                        if cache then
                            cache.last_rebuild = 0  -- Force rebuild on next check
                            cache.rebuilding = false  -- Cancel any in-progress rebuild
                            count = count + 1
                        end
                    end
                end
            end
        end
        game.print("Marked " .. count .. " platform caches for rebuild")
    end,
    
    --- Show active platforms tracking info
    active = function()
        ensure_storage()
        game.print("Active tenespace platforms:")
        for platform_id in pairs(storage[ACTIVE_PLATFORMS_KEY]) do
            game.print("  - Platform ID: " .. platform_id)
        end
    end,
})
