--- Tenebris Entity Manager
--- Manages entity behaviors specific to Tenebris:
--- - Spore-based entity disabling (entities disabled until pollution clears spores)
--- - Banned entity destruction (certain entity types cannot exist on Tenebris)
--- - Ghost cleanup (prevents robots from rebuilding banned entities)
---
--- @module tenebris_entity_manager

local tenebris = require("lib.tenebris")
local banned = require("scripts.entity_manager.banned_entities")

local entity_manager = {}


--- Checks if an entity is banned on Tenebris
--- @param entity LuaEntity The entity to check
--- @return boolean is_banned True if this entity cannot exist on Tenebris
local function is_banned_entity(entity)
    -- Check allowlist first - these entities are never banned
    if banned.ALLOWED_NAMES and banned.ALLOWED_NAMES[entity.name] then
        return false
    end
    -- Check type-based bans (all entities of this type)
    if banned.TYPES[entity.type] then
        return true
    end
    -- Check name-based bans (specific entities only)
    if banned.NAMES[entity.name] then
        return true
    end
    return false
end


--- Checks if an entity uses heat (should be excluded from spore tracking)
--- @param entity LuaEntity The entity to check
--- @return boolean is_heated True if entity uses heat energy
local function is_heated_entity(entity)
    if entity.prototype == nil then
        return true
    end
    return entity.prototype.heat_energy_source_prototype ~= nil or entity.prototype.heat_buffer_prototype ~= nil
end


--- Checks if an entity is immune to spore effects (tracking, disabling, damage)
--- @param entity LuaEntity The entity to check
--- @return boolean is_immune True if entity should never be affected by spores
local function is_spore_immune(entity)
    return banned.SPORE_IMMUNE and banned.SPORE_IMMUNE[entity.name] or false
end


--- Gets the chunk position for a map position
--- @param map_position MapPosition The map position
--- @return ChunkPosition chunk_position The chunk coordinates
local function get_chunk_position(map_position)
    return {
        x = math.floor(map_position.x / 32),
        y = math.floor(map_position.y / 32)
    }
end


--- Converts chunk position back to map position (center of chunk)
--- @param chunk_position ChunkPosition The chunk coordinates
--- @return MapPosition map_position The center of the chunk in map coordinates
local function chunk_to_map_position(chunk_position)
    return {
        x = chunk_position.x * 32 + 16,
        y = chunk_position.y * 32 + 16
    }
end


--- Creates a numeric hash for a chunk position (faster than string formatting)
--- @param chunk_position ChunkPosition The chunk coordinates
--- @return number hash A unique numeric key for this chunk
local function hash_chunk(chunk_position)
    -- Supports chunks from -100000 to +100000 without collision
    return chunk_position.x * 200001 + chunk_position.y
end


--- Ensures the entity tracker storage is initialized
local function ensure_storage_initialized()
    if storage.tenebris_entity_tracker == nil then
        storage.tenebris_entity_tracker = {}
    end
end


--- Checks if a ghost is for a banned entity
--- @param ghost LuaEntity The ghost entity
--- @return boolean is_banned True if the ghost is for a banned entity
local function is_banned_ghost(ghost)
    -- Check allowlist first - these entities are never banned
    if banned.ALLOWED_NAMES and banned.ALLOWED_NAMES[ghost.ghost_name] then
        return false
    end
    -- Check type-based bans
    if banned.TYPES[ghost.ghost_type] then
        return true
    end
    -- Check name-based bans
    if banned.NAMES[ghost.ghost_name] then
        return true
    end
    return false
end


--- Handles a banned entity being placed - destroys it and any ghost
--- @param entity LuaEntity The banned entity
--- @return boolean was_banned True if entity was banned and destroyed
local function handle_banned_entity(entity)
    if not is_banned_entity(entity) then
        return false
    end
    
    -- Store position and surface before destroying
    local position = entity.position
    local surface = entity.surface
    
    -- Destroy the entity with death effects
    entity.die()
    
    -- Find and destroy any ghost at this position to prevent robot rebuilding
    local ghosts = surface.find_entities_filtered{
        position = position,
        radius = 0.5,
        type = "entity-ghost"
    }
    for _, ghost in pairs(ghosts) do
        if ghost.valid and is_banned_ghost(ghost) then
            ghost.destroy()
        end
    end
    
    return true
end


--- Handles entity construction on Tenebris
--- @param entity LuaEntity The entity that was built
function entity_manager.on_built_entity(entity)
    -- Check for banned entities first
    if handle_banned_entity(entity) then
        return
    end
    
    ensure_storage_initialized()
    
    -- Skip heated entities and spore-immune entities for tracking
    if is_heated_entity(entity) or is_spore_immune(entity) then
        return
    end

    -- Entities without unit_number can't be tracked reliably
    if not entity.unit_number then
        return
    end

    local force_name = entity.force.name
    if storage.tenebris_entity_tracker[force_name] == nil then
        storage.tenebris_entity_tracker[force_name] = {}
    end

    local chunk_position = get_chunk_position(entity.position)
    local chunk_hash = hash_chunk(chunk_position)
    
    if storage.tenebris_entity_tracker[force_name][chunk_hash] == nil then
        local map_position = chunk_to_map_position(chunk_position)
        local pollution_value = entity.surface.get_pollution(map_position)
        local disable_entities = pollution_value < tenebris.SPORE.POWER_THRESHOLD
        
        storage.tenebris_entity_tracker[force_name][chunk_hash] = {
            chunk_position = chunk_position,
            disable_entities = disable_entities,
            entities = {}  -- Dictionary keyed by unit_number for O(1) operations
        }
    end

    local chunk_data = storage.tenebris_entity_tracker[force_name][chunk_hash]
    entity.disabled_by_script = chunk_data.disable_entities
    chunk_data.entities[entity.unit_number] = entity
end


--- Handles entity destruction on Tenebris
--- @param entity LuaEntity The entity that was destroyed
function entity_manager.on_entity_destroyed(entity)
    if is_heated_entity(entity) then
        return
    end

    if not entity.unit_number then
        return
    end

    if not storage.tenebris_entity_tracker then
        return
    end

    local force_name = entity.force.name
    if storage.tenebris_entity_tracker[force_name] == nil then
        return
    end

    local chunk_position = get_chunk_position(entity.position)
    local chunk_hash = hash_chunk(chunk_position)
    local chunk_data = storage.tenebris_entity_tracker[force_name][chunk_hash]
    
    if chunk_data == nil or chunk_data.entities == nil then
        return
    end

    -- O(1) removal using dictionary
    chunk_data.entities[entity.unit_number] = nil

    -- Clean up empty chunks
    if next(chunk_data.entities) == nil then
        storage.tenebris_entity_tracker[force_name][chunk_hash] = nil
    end
end


--- Handles ghost creation after entity death - destroys banned entity ghosts
--- @param ghost LuaEntity The ghost entity
function entity_manager.on_ghost_created(ghost)
    if not ghost or not ghost.valid then
        return
    end
    
    if is_banned_ghost(ghost) then
        ghost.destroy()
    end
end


--- Periodic pollution check - updates entity disabled state and applies spore damage
function entity_manager.on_pollution_check_tick()
    if not storage.tenebris_entity_tracker then
        return
    end

    local tenebris_planet = game.planets[tenebris.PLANET.TENEBRIS]
    if not tenebris_planet or not tenebris_planet.surface then
        return
    end

    local surface = tenebris_planet.surface
    local damage_percent = tonumber(settings.global["tenebris-spore-damage-percent"].value) / 100
    local max_damage_per_chunk = settings.global["tenebris-spore-damage-entities-per-chunk"].value

    for force_name, force_chunks in pairs(storage.tenebris_entity_tracker) do
        local force_total_damaged = 0
        local alert_entity = nil  -- Track one entity for the alert
        
        for chunk_hash, chunk_data in pairs(force_chunks) do
            if chunk_data == nil then
                goto continue
            end
            
            -- Get pollution at chunk center
            local map_position = chunk_to_map_position(chunk_data.chunk_position)
            local pollution_value = surface.get_pollution(map_position)
            
            -- Two separate thresholds:
            -- power_threshold: entities are enabled when pollution is above this
            -- protection_threshold: entities are protected from damage when pollution is above this
            local should_disable = pollution_value < tenebris.SPORE.POWER_THRESHOLD
            local should_damage = pollution_value < tenebris.SPORE.PROTECTION_THRESHOLD
            
            -- Clean up invalid entities and update disable state if changed
            local state_changed = should_disable ~= chunk_data.disable_entities
            local has_valid_entities = false
            local damageable_entities = {}
            
            for unit_number, entity in pairs(chunk_data.entities) do
                if not entity.valid then
                    -- Clean up invalid entities
                    chunk_data.entities[unit_number] = nil
                elseif is_spore_immune(entity) then
                    entity.disabled_by_script = false
                    chunk_data.entities[unit_number] = nil
                else
                    has_valid_entities = true
                    -- Only update if state changed
                    if state_changed then
                        entity.disabled_by_script = should_disable
                    end
                    
                    -- Collect entities that can be damaged
                    if should_damage and entity.health then
                        table.insert(damageable_entities, entity)
                    end
                end
            end
            
            -- Randomly select 0 to max_damage_per_chunk entities to damage
            if #damageable_entities > 0 then
                -- Fisher-Yates shuffle for random selection
                for i = #damageable_entities, 2, -1 do
                    local j = math.random(1, i)
                    damageable_entities[i], damageable_entities[j] = damageable_entities[j], damageable_entities[i]
                end
                
                -- Random number of entities to damage (0 to max), capped by available
                local max_to_damage = math.min(max_damage_per_chunk, #damageable_entities)
                local damage_limit = math.random(0, max_to_damage)
                for i = 1, damage_limit do
                    local entity = damageable_entities[i]
                    if entity.valid and entity.prototype then
                        local max_health = entity.prototype.get_max_health()
                        local base_damage = max_health * damage_percent
                        
                        -- Calculate effective damage after acid resistance
                        local effective_damage = base_damage
                        local resistances = entity.prototype.resistances
                        if resistances and resistances["acid"] then
                            local res = resistances["acid"]
                            effective_damage = effective_damage - (res.decrease or 0)
                            if effective_damage > 0 then
                                effective_damage = effective_damage * (1 - (res.percent or 0))
                            end
                        end
                        
                        -- Apply damage silently if effective
                        if effective_damage > 0 then
                            local new_health = entity.health - effective_damage
                            if new_health <= 0 then
                                entity.die("neutral")
                            else
                                entity.health = new_health
                                force_total_damaged = force_total_damaged + 1
                                -- Track first damaged entity for alert
                                if not alert_entity then
                                    alert_entity = entity
                                end
                            end
                        end
                    end
                end
            end
            
            chunk_data.disable_entities = should_disable
            
            -- Clean up empty chunks
            if not has_valid_entities then
                force_chunks[chunk_hash] = nil
            end

            ::continue::
        end
        
        -- Show single consolidated custom alert for this force if entities were damaged
        if force_total_damaged > 0 and alert_entity and alert_entity.valid then
            local force = game.forces[force_name]
            if force and force.valid then
                for _, player in pairs(force.players) do
                    if player.valid and player.connected then
                        player.add_custom_alert(
                            alert_entity,
                            {type = "virtual", name = "signal-alert"},
                            {"", "[color=red]Tenecap Spore Corrosion[/color]: ", force_total_damaged, " entities damaged on [color=orange]Tenebris[/color]"},
                            true  -- show_on_map
                        )
                    end
                end
            end
        end
    end
end


--- Initializes storage for entity tracking
function entity_manager.on_init()
    if storage.tenebris_entity_tracker == nil then
        storage.tenebris_entity_tracker = {}
    end
end


-- Self-register with event manager
local event_manager = tenebris.event_manager

--- Priority for entity management (critical - must run before other handlers)
local ENTITY_PRIORITY = tenebris.PRIORITY.CRITICAL

-- Entity built events
event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "tenebris_entity_built", function(event)
    local entity = event.entity
    if not entity or not entity.valid or not entity.surface then
        return
    end
    
    if not tenebris.is_on_tenebris(entity) then
        return
    end
    
    entity_manager.on_built_entity(entity)
end, ENTITY_PRIORITY)

event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_BUILT_ENTITY, "tenebris_entity_robot_built", function(event)
    local entity = event.entity
    if not entity or not entity.valid or not entity.surface then
        return
    end
    
    if not tenebris.is_on_tenebris(entity) then
        return
    end
    
    entity_manager.on_built_entity(entity)
end, ENTITY_PRIORITY)

-- Entity destroyed events
event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_MINED_ENTITY, "tenebris_entity_player_mined", function(event)
    if not event.entity or not event.entity.valid then
        return
    end
    
    if not tenebris.is_on_tenebris(event.entity) then
        return
    end
    
    entity_manager.on_entity_destroyed(event.entity)
end, ENTITY_PRIORITY)

event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_MINED_ENTITY, "tenebris_entity_robot_mined", function(event)
    if not event.entity or not event.entity.valid then
        return
    end
    
    if not tenebris.is_on_tenebris(event.entity) then
        return
    end
    
    entity_manager.on_entity_destroyed(event.entity)
end, ENTITY_PRIORITY)

event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "tenebris_entity_died", function(event)
    if not event.entity then
        return
    end
    
    if not tenebris.is_on_tenebris(event.entity) then
        return
    end
    
    entity_manager.on_entity_destroyed(event.entity)
end, ENTITY_PRIORITY)

-- Ghost cleanup for banned entities
event_manager.subscribe(tenebris.EVENTS.ON_POST_ENTITY_DIED, "tenebris_ghost_cleanup", function(event)
    local ghost = event.ghost
    if not ghost or not ghost.valid then
        return
    end
    
    if not tenebris.is_tenebris_surface(ghost.surface) then
        return
    end
    
    entity_manager.on_ghost_created(ghost)
end, ENTITY_PRIORITY)

-- Initialization
event_manager.subscribe(tenebris.EVENTS.ON_INIT, "tenebris_entity_manager", function()
    entity_manager.on_init()
end, ENTITY_PRIORITY)

-- Migration from old storage key
event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "tenebris_entity_manager_migrate", function()
    -- Migrate old spore_tracker to new entity_tracker
    if storage.tenebris_spore_tracker and not storage.tenebris_entity_tracker then
        storage.tenebris_entity_tracker = storage.tenebris_spore_tracker
        storage.tenebris_spore_tracker = nil
    end
    entity_manager.on_init()
end, ENTITY_PRIORITY)

-- Periodic pollution check tick (interval configurable via settings)
event_manager.subscribe_nth_tick(tenebris.get_spore_check_interval(), "entity_manager_pollution_check", function(_)
    entity_manager.on_pollution_check_tick()
end, ENTITY_PRIORITY)


return entity_manager

