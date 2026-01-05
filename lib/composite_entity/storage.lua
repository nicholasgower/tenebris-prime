--- Composite Entity Storage Module
--- Manages persistent storage of composite entity relationships.
--- Storage is internally indexed by force, but API callers don't need to track force.
---
--- Internal storage structure:
---   storage.composites[force_name][composite_id] = { definition_name, interface, entities, ... }
---   storage.interface_to_composite[force_name][unit_number] = composite_id
---   storage.composites_by_type[force_name][definition_name][composite_id] = true
---   storage.composite_to_force[composite_id] = force_name  (reverse lookup)
---
--- @module composite_entity.storage

local composite_storage = {}

--- Initializes the storage structure for a specific force.
--- @param force_name string The force name
local function initialize_force(force_name)
    if not storage.composites then
        storage.composites = {}
    end
    if not storage.composites[force_name] then
        storage.composites[force_name] = {}
    end
    
    if not storage.interface_to_composite then
        storage.interface_to_composite = {}
    end
    if not storage.interface_to_composite[force_name] then
        storage.interface_to_composite[force_name] = {}
    end
    
    if not storage.composites_by_type then
        storage.composites_by_type = {}
    end
    if not storage.composites_by_type[force_name] then
        storage.composites_by_type[force_name] = {}
    end
    
    if not storage.composite_to_force then
        storage.composite_to_force = {}
    end
end

--- Initializes the base storage structure.
--- Called during on_init and on_configuration_changed.
function composite_storage.initialize()
    if not storage.composites then
        storage.composites = {}
    end
    if not storage.interface_to_composite then
        storage.interface_to_composite = {}
    end
    if not storage.composites_by_type then
        storage.composites_by_type = {}
    end
    if not storage.composite_to_force then
        storage.composite_to_force = {}
    end
end

--- Gets the force name for a composite ID.
--- @param composite_id string The composite ID
--- @return string|nil force_name
function composite_storage.get_force(composite_id)
    composite_storage.initialize()
    return storage.composite_to_force[composite_id]
end

--- Generates a unique composite ID.
--- @return string composite_id
local function generate_composite_id()
    return tostring(game.tick) .. "_" .. tostring(math.random(100000, 999999))
end

--- Stores a composite entity.
--- @param composite_id string The unique composite ID
--- @param definition_name string The registered definition name
--- @param interface LuaEntity The interface entity (player-interactable)
--- @param entities table Named table of entities { [prototype] = LuaEntity }
--- @param heat_renders table|nil Optional heat connection render objects
--- @param arrow_renders table|nil Optional flow arrow render objects
--- @return boolean success
function composite_storage.store(composite_id, definition_name, interface, entities, heat_renders, arrow_renders)
    if not composite_id or not interface or not interface.valid then
        return false
    end
    if not interface.unit_number then
        game.print("[Composite] Interface entity must have a unit_number")
        return false
    end
    if not interface.force then
        game.print("[Composite] Interface entity must have a force")
        return false
    end
    
    local force_name = interface.force.name
    initialize_force(force_name)
    
    storage.composites[force_name][composite_id] = {
        definition_name = definition_name,
        interface = interface,
        entities = entities,
        heat_renders = heat_renders,
        arrow_renders = arrow_renders,
    }
    
    -- Store reverse lookup: composite_id -> force_name
    storage.composite_to_force[composite_id] = force_name
    
    -- Store reverse lookup for interface -> composite_id (keyed by unit_number)
    storage.interface_to_composite[force_name][interface.unit_number] = composite_id
    
    -- Store type index for fast type-based lookups
    if not storage.composites_by_type[force_name][definition_name] then
        storage.composites_by_type[force_name][definition_name] = {}
    end
    storage.composites_by_type[force_name][definition_name][composite_id] = true
    
    return true
end

--- Updates the heat renders for a composite.
--- @param composite_id string The composite ID
--- @param heat_renders table The new heat render objects
function composite_storage.update_heat_renders(composite_id, heat_renders)
    local force_name = composite_storage.get_force(composite_id)
    if not force_name then return end
    
    local composite = storage.composites[force_name][composite_id]
    if composite then
        composite.heat_renders = heat_renders
    end
end

--- Updates the arrow renders for a composite.
--- @param composite_id string The composite ID
--- @param arrow_renders table The new arrow render objects
function composite_storage.update_arrow_renders(composite_id, arrow_renders)
    local force_name = composite_storage.get_force(composite_id)
    if not force_name then return end
    
    local composite = storage.composites[force_name][composite_id]
    if composite then
        composite.arrow_renders = arrow_renders
    end
end

--- Retrieves a composite by ID.
--- @param composite_id string The composite ID
--- @return table|nil composite_data { definition_name, interface, entities }
function composite_storage.get(composite_id)
    local force_name = composite_storage.get_force(composite_id)
    if not force_name then return nil end
    
    return storage.composites[force_name][composite_id]
end

--- Gets the composite ID for an interface entity.
--- @param interface_entity LuaEntity The interface entity
--- @return string|nil composite_id
function composite_storage.get_composite_id_for_interface(interface_entity)
    if not interface_entity or not interface_entity.valid or not interface_entity.unit_number then
        return nil
    end
    if not interface_entity.force then
        return nil
    end
    
    local force_name = interface_entity.force.name
    initialize_force(force_name)
    return storage.interface_to_composite[force_name][interface_entity.unit_number]
end

--- Removes a composite from storage.
--- Does NOT destroy entities - only removes tracking data.
--- @param composite_id string The composite ID
--- @return boolean success
function composite_storage.remove(composite_id)
    local force_name = composite_storage.get_force(composite_id)
    if not force_name then return false end
    
    local composite = storage.composites[force_name][composite_id]
    if not composite then
        return false
    end
    
    -- Remove interface reverse lookup (keyed by unit_number)
    if composite.interface and composite.interface.valid and composite.interface.unit_number then
        storage.interface_to_composite[force_name][composite.interface.unit_number] = nil
    end
    
    -- Remove from type index
    local definition_name = composite.definition_name
    if definition_name and storage.composites_by_type[force_name] and storage.composites_by_type[force_name][definition_name] then
        storage.composites_by_type[force_name][definition_name][composite_id] = nil
    end
    
    -- Remove from force lookup
    storage.composite_to_force[composite_id] = nil
    
    -- Remove composite data
    storage.composites[force_name][composite_id] = nil
    return true
end

--- Validates and cleans up invalid entity references.
--- @return number cleaned_count Number of invalid composites removed
function composite_storage.cleanup_invalid_entities()
    composite_storage.initialize()
    
    local total_removed = 0
    
    for force_name, force_composites in pairs(storage.composites) do
        local to_remove = {}
        
        for composite_id, composite in pairs(force_composites) do
            local should_remove = false
            
            -- Check if interface is invalid
            if not composite.interface or not composite.interface.valid then
                should_remove = true
            else
                -- Check if any entities are invalid
                for _, entity in pairs(composite.entities) do
                    if not entity or not entity.valid then
                        should_remove = true
                        break
                    end
                end
            end
            
            if should_remove then
                table.insert(to_remove, composite_id)
            end
        end
        
        for _, composite_id in ipairs(to_remove) do
            composite_storage.remove(composite_id)
        end
        
        total_removed = total_removed + #to_remove
    end
    
    return total_removed
end

--- Gets statistics about stored composites.
--- @return table stats { total_composites, invalid_composites }
function composite_storage.get_stats()
    composite_storage.initialize()
    
    local total = 0
    local invalid = 0
    
    for _, force_composites in pairs(storage.composites) do
        for _, composite in pairs(force_composites) do
            total = total + 1
            if not composite.interface or not composite.interface.valid then
                invalid = invalid + 1
            end
        end
    end
    
    return {
        total_composites = total,
        invalid_composites = invalid
    }
end

--- Gets all stored composites across all forces.
--- @return table composites { [composite_id] = composite_data }
function composite_storage.get_all()
    composite_storage.initialize()
    
    local result = {}
    for _, force_composites in pairs(storage.composites) do
        for composite_id, composite in pairs(force_composites) do
            result[composite_id] = composite
        end
    end
    return result
end

--- Gets all composites of a specific type across all forces.
--- @param definition_name string The composite definition name
--- @return table composites { [composite_id] = composite_data }
function composite_storage.get_by_type(definition_name)
    composite_storage.initialize()
    
    local result = {}
    
    for force_name, force_type_index in pairs(storage.composites_by_type) do
        local type_index = force_type_index[definition_name]
        if type_index then
            for composite_id, _ in pairs(type_index) do
                local composite = storage.composites[force_name][composite_id]
                if composite then
                    result[composite_id] = composite
                end
            end
        end
    end
    
    return result
end

--- Rebuilds the type index and force lookup from existing composites.
function composite_storage.rebuild_type_index()
    composite_storage.initialize()
    
    storage.composites_by_type = {}
    storage.composite_to_force = {}
    
    for force_name, force_composites in pairs(storage.composites) do
        storage.composites_by_type[force_name] = {}
        
        for composite_id, composite in pairs(force_composites) do
            -- Rebuild force lookup
            storage.composite_to_force[composite_id] = force_name
            
            -- Rebuild type index
            local definition_name = composite.definition_name
            if definition_name then
                if not storage.composites_by_type[force_name][definition_name] then
                    storage.composites_by_type[force_name][definition_name] = {}
                end
                storage.composites_by_type[force_name][definition_name][composite_id] = true
            end
        end
    end
end

return composite_storage
