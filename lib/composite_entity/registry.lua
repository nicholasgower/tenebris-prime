--- Composite Entity Registry Module
--- Manages registration and lookup of composite entity definitions.
--- Composites are defined as a group of entities with one interface entity
--- that the player interacts with.
---
--- @module composite_entity.registry

local registry = {}

--- Internal storage for composite definitions
--- @type table<string, table>
local composite_definitions = {}

--- Lookup table: prototype -> definition_name (for interface entities)
--- @type table<string, string>
local interface_entity_lookup = {}

--- Registers a composite entity definition.
---
--- @param definition table The composite definition:
---   - name: string - Unique identifier for this composite type
---   - supports_rotation: boolean|nil - If true, rotate offsets based on interface direction
---   - supports_flipping: boolean|nil - If true, flip offsets based on interface mirroring
---   - entities: table - Array of entity definitions:
---     - prototype: string - Entity prototype name
---     - interface: boolean - If true, this is the player-interactable entity
---     - offset: table - Position offset {x, y} relative to interface entity
---   - hooks: table|nil - Optional lifecycle hooks:
---     - on_created: function(composite_id, entities, direction, mirroring) - After creation
---     - on_destroyed: function(composite_id, entities) - Before destruction
---     - on_orientation_changed: function(composite_id, entities, direction, mirroring) - After rotation/flip
--- @return boolean success
--- @return string|nil error_message
function registry.register(definition)
    -- Validate required fields
    if not definition.name or type(definition.name) ~= "string" then
        return false, "Definition must have a 'name' field (string)"
    end
    
    if not definition.entities or type(definition.entities) ~= "table" then
        return false, "Definition must have an 'entities' field (table)"
    end
    
    -- Validate entities and find interface
    local interface_entity = nil
    local interface_count = 0
    
    for i, entity_def in ipairs(definition.entities) do
        if not entity_def.prototype or type(entity_def.prototype) ~= "string" then
            return false, string.format("Entity %d must have 'prototype' field (string)", i)
        end
        
        if not entity_def.offset or type(entity_def.offset) ~= "table" then
            return false, string.format("Entity %d must have 'offset' field (table)", i)
        end
        
        if entity_def.offset.x == nil or entity_def.offset.y == nil then
            return false, string.format("Entity %d offset must have 'x' and 'y' fields", i)
        end
        
        -- Set defaults
        if entity_def.interface == nil then
            entity_def.interface = false
        end
        
        if entity_def.interface then
            interface_count = interface_count + 1
            interface_entity = entity_def.prototype
        end
    end
    
    -- Must have exactly one interface entity
    if interface_count == 0 then
        return false, "Definition must have exactly one entity with 'interface = true'"
    end
    
    if interface_count > 1 then
        return false, "Definition can only have one entity with 'interface = true'"
    end
    
    -- Check for duplicate registration
    if composite_definitions[definition.name] then
        return false, string.format("Composite '%s' is already registered", definition.name)
    end
    
    -- Store the definition
    composite_definitions[definition.name] = definition
    
    -- Add interface entity to lookup
    interface_entity_lookup[interface_entity] = definition.name
    
    return true, nil
end

--- Retrieves a composite definition by name.
--- @param name string The definition name
--- @return table|nil definition
function registry.get(name)
    return composite_definitions[name]
end

--- Retrieves a composite definition by interface entity name.
--- @param prototype string The interface entity prototype name
--- @return table|nil definition
function registry.get_by_prototype(prototype)
    local def_name = interface_entity_lookup[prototype]
    if def_name then
        return composite_definitions[def_name]
    end
    return nil
end

--- Checks if an entity prototype name is a registered interface entity.
--- @param prototype string The entity prototype name
--- @return boolean is_interface
function registry.is_interface_entity(prototype)
    return interface_entity_lookup[prototype] ~= nil
end

--- Checks if an entity instance is a registered interface entity.
--- @param entity LuaEntity The entity to check
--- @return boolean is_interface
--- @return table|nil definition
function registry.is_composite_interface(entity)
    if not entity or not entity.valid then
        return false, nil
    end
    
    local definition = registry.get_by_prototype(entity.name)
    return definition ~= nil, definition
end

--- Gets all registered composite definitions.
--- @return table<string, table> definitions
function registry.get_all()
    return composite_definitions
end

--- Gets the count of registered composites.
--- @return number count
function registry.count()
    local count = 0
    for _ in pairs(composite_definitions) do
        count = count + 1
    end
    return count
end

--- Unregisters a composite definition.
--- @param name string The definition name
--- @return boolean success
function registry.unregister(name)
    local definition = composite_definitions[name]
    if definition then
        -- Remove from interface lookup
        for _, entity_def in ipairs(definition.entities) do
            if entity_def.interface then
                interface_entity_lookup[entity_def.prototype] = nil
            end
        end
        
        composite_definitions[name] = nil
        return true
    end
    return false
end

--- Clears all registered definitions.
function registry.clear_all()
    composite_definitions = {}
    interface_entity_lookup = {}
end

return registry
