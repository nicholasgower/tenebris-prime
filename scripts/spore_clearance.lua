local _TENEBRIS = "tenebris" 

local spore_clearance = {
    spore_clearance_threshold = 50,
}


local function _xor(a, b)
    return (a and not b) or (not a and b)
end


local function _is_deny_list_exclusion(entity)
    -- Deny from tracking if the entity has a heat energy source prototype.
    if entity.prototype == nil then
        return true
    end

    return entity.prototype.heat_energy_source_prototype ~= nil or entity.prototype.heat_buffer_prototype ~= nil
end


local function _get_nearest_chunk(map_position)
    return {
        x = math.floor(map_position.x / 32),
        y = math.floor(map_position.y / 32)
    }
end


local function hash_chunk(chunk_position)
    return string.format("%d, %d", chunk_position.x, chunk_position.y)
end


function spore_clearance.on_built_entity(entity)
    if _is_deny_list_exclusion(entity) then
        return
    end

    local force_name = entity.force.name
    if storage.tenebris_spore_tracker[force_name] == nil then
        storage.tenebris_spore_tracker[force_name] = {}
    end

    local containing_chunk = _get_nearest_chunk(entity.position)
    local chunk_hash = hash_chunk(containing_chunk)
    if storage.tenebris_spore_tracker[force_name][chunk_hash] == nil then
        local surface = entity.surface
        local pollution_value = surface.get_pollution(entity.position)
        
        local disable_entities_in_chunk = pollution_value < spore_clearance.spore_clearance_threshold
        storage.tenebris_spore_tracker[force_name][chunk_hash] = {
            chunk_position = containing_chunk,
            latest_spore_clearance_value = pollution_value,
            disable_entities_in_chunk = disable_entities_in_chunk,
            entities_in_chunk = {}
        }
    end

    entity.disabled_by_script = storage.tenebris_spore_tracker[force_name][chunk_hash].disable_entities_in_chunk
    table.insert(
        storage.tenebris_spore_tracker[force_name][chunk_hash].entities_in_chunk, 
        entity
    )
end


function spore_clearance.on_entity_destroyed(entity)
    if _is_deny_list_exclusion(entity) then
        return
    end

    local force_name = entity.force.name
    if storage.tenebris_spore_tracker[force_name] == nil then
        return
    end

    local containing_chunk = _get_nearest_chunk(entity.position)
    local chunk_hash = hash_chunk(containing_chunk)
    if storage.tenebris_spore_tracker[force_name][chunk_hash] == nil then
        return
    end
    
    local entities_in_chunk = storage.tenebris_spore_tracker[force_name][chunk_hash].entities_in_chunk

    if entities_in_chunk == nil then
        return
    end

    local new_entities_in_chunk = {}
    -- In the worst case, this is 1023 operations.
    for _, stored_entity in ipairs(entities_in_chunk) do
        -- Copying the whole table over with pruned elements is much cheaper than calling remove and also preserves count...
        if stored_entity ~= nil and stored_entity ~= entity and stored_entity.valid then
            table.insert(new_entities_in_chunk, stored_entity)
        end
    end
    entities_in_chunk = new_entities_in_chunk

    if #entities_in_chunk == 0 then
        -- We can just set this to nil because we may fill this part of the table in again later.
        storage.tenebris_spore_tracker[force_name][chunk_hash] = nil
    end
end


function spore_clearance.on_pollution_check_tick()
    local tenebris = game.planets[_TENEBRIS]
    if tenebris.surface == nil then
        return
    end

    for force_name, _ in pairs(storage.tenebris_spore_tracker) do
        for chunk_hash in pairs(storage.tenebris_spore_tracker[force_name]) do
            local spore_chunk_storage_table = storage.tenebris_spore_tracker[force_name][chunk_hash]
            if spore_chunk_storage_table == nil then
                goto continue -- this fucking language
            end
            
            local pollution_value = tenebris.surface.get_pollution(spore_chunk_storage_table.chunk_position)
            local disable_entities_in_chunk = pollution_value < spore_clearance.spore_clearance_threshold
            
            -- If the disabled state changes, we need to flip the entities from on to off or vice versa
            if _xor(disable_entities_in_chunk, spore_chunk_storage_table.disable_entities_in_chunk) then
                spore_chunk_storage_table.disable_entities_in_chunk = disable_entities_in_chunk
                if spore_chunk_storage_table.entities_in_chunk == nil then
                    goto continue
                end

                for _, entity in pairs(spore_chunk_storage_table.entities_in_chunk) do
                    if entity.valid then
                        entity.disabled_by_script = disable_entities_in_chunk
                    end
                end
            end

            spore_chunk_storage_table.latest_spore_clearance_value = pollution_value

            ::continue::
        end
    end
end


function spore_clearance.on_init()
    if storage.tenebris_spore_tracker == nil then
        storage.tenebris_spore_tracker = {}
    end
end


return spore_clearance