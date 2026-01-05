--- Composite Entity Lifecycle Module
--- Manages creation, destruction, and lookup of composite entities.
---
--- @module composite_entity.lifecycle

local registry = require("lib.composite_entity.registry")
local composite_storage = require("lib.composite_entity.storage")
local heat_rendering = require("lib.heat_rendering")

local lifecycle = {}

--- Generates a unique composite ID.
--- @return string composite_id
local function generate_composite_id()
    return tostring(game.tick) .. "_" .. tostring(math.random(100000, 999999))
end

--- Rotates an offset based on entity direction.
--- @param offset table The offset {x, y}
--- @param direction defines.direction The entity direction
--- @return table rotated_offset
local function rotate_offset(offset, direction)
    if direction == defines.direction.north or direction == nil then
        return { x = offset.x, y = offset.y }
    elseif direction == defines.direction.east then
        -- 90° clockwise: (x, y) → (-y, x)
        return { x = -offset.y, y = offset.x }
    elseif direction == defines.direction.south then
        -- 180°: (x, y) → (-x, -y)
        return { x = -offset.x, y = -offset.y }
    elseif direction == defines.direction.west then
        -- 270° clockwise: (x, y) → (y, -x)
        return { x = offset.y, y = -offset.x }
    end
    return { x = offset.x, y = offset.y }
end

--- Flips an offset based on entity mirroring.
--- @param offset table The offset {x, y}
--- @param mirroring defines.mirroring|nil The entity mirroring (nil if not supported)
--- @return table flipped_offset
local function flip_offset(offset, mirroring)
    -- If mirroring is nil or defines.mirroring doesn't exist, no flip
    if mirroring == nil or not defines.mirroring then
        return { x = offset.x, y = offset.y }
    end
    -- Check for horizontal or vertical mirroring
    if mirroring == defines.mirroring.horizontal then
        return { x = -offset.x, y = offset.y }
    elseif mirroring == defines.mirroring.vertical then
        return { x = offset.x, y = -offset.y }
    end
    -- Unknown or no mirroring applied
    return { x = offset.x, y = offset.y }
end

--- Rotates a direction based on entity direction.
--- @param dir defines.direction The direction to rotate
--- @param entity_direction defines.direction The entity's direction
--- @return defines.direction rotated_direction
local function rotate_direction(dir, entity_direction)
    if entity_direction == defines.direction.north or entity_direction == nil then
        return dir
    end
    
    -- Direction values: north=0, east=4, south=8, west=12 (or 0,1,2,3 depending on version)
    -- We add the entity rotation to the sprite direction
    local directions = {
        defines.direction.north,
        defines.direction.east,
        defines.direction.south,
        defines.direction.west,
    }
    
    -- Find index of dir
    local dir_idx = 1
    for i, d in ipairs(directions) do
        if d == dir then
            dir_idx = i
            break
        end
    end
    
    -- Find rotation amount from entity direction
    local rotation = 0
    for i, d in ipairs(directions) do
        if d == entity_direction then
            rotation = i - 1
            break
        end
    end
    
    -- Apply rotation
    local new_idx = ((dir_idx - 1 + rotation) % 4) + 1
    return directions[new_idx]
end

--- Flips a direction based on entity mirroring.
--- @param dir defines.direction The direction to flip
--- @param mirroring defines.mirroring|nil The entity mirroring
--- @return defines.direction flipped_direction
local function flip_direction(dir, mirroring)
    if mirroring == nil or not defines.mirroring then
        return dir
    end
    
    if mirroring == defines.mirroring.horizontal then
        -- Horizontal flip: east <-> west
        if dir == defines.direction.east then
            return defines.direction.west
        elseif dir == defines.direction.west then
            return defines.direction.east
        end
    elseif mirroring == defines.mirroring.vertical then
        -- Vertical flip: north <-> south
        if dir == defines.direction.north then
            return defines.direction.south
        elseif dir == defines.direction.south then
            return defines.direction.north
        end
    end
    
    return dir
end

--- Transforms an offset based on definition settings and entity orientation.
--- Applies rotation first, then flip.
--- @param offset table The offset {x, y}
--- @param definition table The composite definition
--- @param direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @return table transformed_offset
local function transform_offset(offset, definition, direction, mirroring)
    local result = { x = offset.x, y = offset.y }
    
    if definition.supports_rotation and direction then
        result = rotate_offset(result, direction)
    end
    
    if definition.supports_flipping and mirroring then
        result = flip_offset(result, mirroring)
    end
    
    return result
end

--- Transforms a direction based on definition settings and entity orientation.
--- Applies rotation first, then flip.
--- @param dir defines.direction The direction to transform
--- @param definition table The composite definition
--- @param entity_direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @return defines.direction transformed_direction
local function transform_direction(dir, definition, entity_direction, mirroring)
    local result = dir
    
    if definition.supports_rotation and entity_direction then
        result = rotate_direction(result, entity_direction)
    end
    
    if definition.supports_flipping and mirroring then
        result = flip_direction(result, mirroring)
    end
    
    return result
end

--- Transforms a heat connections array based on entity orientation.
--- @param connections table Array of { offset = {x, y}, direction = defines.direction }
--- @param definition table The composite definition
--- @param entity_direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @return table transformed_connections
local function transform_connections(connections, definition, entity_direction, mirroring)
    local result = {}
    for i, conn in ipairs(connections) do
        local offset = conn.offset
        -- Normalize offset to {x, y} format
        if offset[1] ~= nil then
            offset = { x = offset[1], y = offset[2] }
        end
        
        result[i] = {
            offset = transform_offset(offset, definition, entity_direction, mirroring),
            direction = transform_direction(conn.direction, definition, entity_direction, mirroring),
        }
    end
    return result
end

--- Transforms orientation (0-1 range) based on entity direction and mirroring.
--- @param orientation number Base orientation (0=north, 0.25=east, 0.5=south, 0.75=west)
--- @param definition table The composite definition
--- @param entity_direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @return number transformed_orientation
local function transform_orientation(orientation, definition, entity_direction, mirroring)
    local result = orientation
    
    if definition.supports_rotation and entity_direction then
        -- Add rotation based on entity direction
        local rotation = 0
        if entity_direction == defines.direction.east then
            rotation = 0.25
        elseif entity_direction == defines.direction.south then
            rotation = 0.5
        elseif entity_direction == defines.direction.west then
            rotation = 0.75
        end
        result = (result + rotation) % 1
    end
    
    if definition.supports_flipping and mirroring and defines.mirroring then
        -- Flipping reverses direction
        if mirroring == defines.mirroring.vertical or mirroring == defines.mirroring.horizontal then
            result = (result + 0.5) % 1
        end
    end
    
    return result
end

--- Transforms a flow arrows array based on entity orientation.
--- @param arrows table Array of { offset = {x, y}, orientation = number }
--- @param definition table The composite definition
--- @param entity_direction defines.direction The entity direction
--- @param mirroring defines.mirroring The entity mirroring
--- @return table transformed_arrows
local function transform_arrows(arrows, definition, entity_direction, mirroring)
    local result = {}
    for i, arrow in ipairs(arrows) do
        local offset = arrow.offset
        -- Normalize offset to {x, y} format
        if offset[1] ~= nil then
            offset = { x = offset[1], y = offset[2] }
        end
        
        result[i] = {
            offset = transform_offset(offset, definition, entity_direction, mirroring),
            orientation = transform_orientation(arrow.orientation, definition, entity_direction, mirroring),
        }
    end
    return result
end

--- Creates a composite entity at the given position.
--- Creates the interface entity and all other entities in the definition.
---
--- @param surface LuaSurface The surface to create on
--- @param position MapPosition The position for the interface entity
--- @param definition_name string The registered composite definition name
--- @param force LuaForce The force that owns the composite
--- @param direction defines.direction|nil Optional direction for rotation support
--- @param mirroring defines.mirroring|nil Optional mirroring for flip support
--- @return string|nil composite_id The composite ID if successful, nil otherwise
function lifecycle.create(surface, position, definition_name, force, direction, mirroring)
    local definition = registry.get(definition_name)
    if not definition then
        game.print("[Composite] Unknown definition: " .. tostring(definition_name))
        return nil
    end
    
    local composite_id = generate_composite_id()
    local entities = {}
    local interface_entity = nil
    local interface_position = position
    
    -- Default direction (mirroring can be nil if not supported/applied)
    direction = direction or defines.direction.north
    -- mirroring stays as passed (nil is valid)
    
    -- First pass: create all entities
    for _, entity_def in ipairs(definition.entities) do
        local offset = transform_offset(entity_def.offset, definition, direction, mirroring)
        local entity_position = {
            x = interface_position.x + offset.x,
            y = interface_position.y + offset.y
        }
        
        local entity = surface.create_entity{
            name = entity_def.prototype,
            position = entity_position,
            force = force,
            direction = entity_def.interface and direction or nil,
            raise_built = false,
            create_build_effect_smoke = false
        }
        
        if not entity then
            -- Cleanup any already-created entities
            for _, created in pairs(entities) do
                if created and created.valid then
                    created.destroy()
                end
            end
            game.print("[Composite] Failed to create entity: " .. entity_def.prototype)
            return nil
        end
        
        -- Store by key if provided, else by prototype
        local storage_key = entity_def.key or entity_def.prototype
        entities[storage_key] = entity
        
        if entity_def.interface then
            interface_entity = entity
        else
            -- Non-interface entities are hidden and non-interactable
            entity.destructible = false
            entity.minable = false
            if entity.operable ~= nil then
                entity.operable = false
            end
        end
    end
    
    if not interface_entity then
        -- Shouldn't happen if registration validation worked
        for _, entity in pairs(entities) do
            if entity and entity.valid then
                entity.destroy()
            end
        end
        game.print("[Composite] No interface entity found")
        return nil
    end
    
    -- Store in storage
    composite_storage.store(composite_id, definition_name, interface_entity, entities)
    
    -- Call on_created hook with direction/mirroring info
    if definition.hooks and definition.hooks.on_created then
        local success, err = pcall(definition.hooks.on_created, composite_id, entities, direction, mirroring)
        if not success then
            game.print("[Composite] Error in on_created hook: " .. tostring(err))
        end
    end
    
    return composite_id
end

--- Destroys a composite entity and all its entities.
---
--- @param composite_id string The composite ID
--- @return boolean success
function lifecycle.destroy(composite_id)
    local composite = composite_storage.get(composite_id)
    if not composite then
        return false
    end
    
    local definition = registry.get(composite.definition_name)
    
    -- Call on_destroyed hook before destroying entities
    if definition and definition.hooks and definition.hooks.on_destroyed then
        local success, err = pcall(definition.hooks.on_destroyed, composite_id, composite.entities)
        if not success then
            game.print("[Composite] Error in on_destroyed hook: " .. tostring(err))
        end
    end
    
    -- Destroy all entities
    for _, entity in pairs(composite.entities) do
        if entity and entity.valid then
            entity.destroy({ raise_destroy = false })
        end
    end
    
    -- Remove from storage
    composite_storage.remove(composite_id)
    
    return true
end

--- Gets a composite by ID.
---
--- @param composite_id string The composite ID
--- @return table|nil composite_data { definition_name, interface, entities }
function lifecycle.get(composite_id)
    return composite_storage.get(composite_id)
end

--- Gets a specific entity from a composite by name.
---
--- @param composite_id string The composite ID
--- @param prototype string The entity prototype name
--- @return LuaEntity|nil entity
function lifecycle.get_entity(composite_id, prototype)
    local composite = composite_storage.get(composite_id)
    if not composite or not composite.entities then
        return nil
    end
    
    return composite.entities[prototype]
end

--- Gets the interface entity's position for a composite.
--- Useful when entity placement snaps to grid and actual position differs from requested.
---
--- @param composite_id string The composite ID
--- @return MapPosition|nil position The interface entity's actual position, or nil if not found
function lifecycle.get_interface_position(composite_id)
    local composite = composite_storage.get(composite_id)
    if not composite or not composite.interface or not composite.interface.valid then
        return nil
    end
    
    return composite.interface.position
end

--- Gets the composite ID for an interface entity.
---
--- @param interface_entity LuaEntity The interface entity
--- @return string|nil composite_id
function lifecycle.get_by_interface(interface_entity)
    return composite_storage.get_composite_id_for_interface(interface_entity)
end

--- Checks if an entity is an interface entity of a registered composite.
---
--- @param entity LuaEntity The entity to check
--- @return boolean is_interface
--- @return table|nil definition
function lifecycle.is_interface_entity(entity)
    return registry.is_composite_interface(entity)
end

--- Resolves the actual entity name to create, supporting dynamic name resolution.
--- If entity_def has an prototype_resolver function, it's called with the interface entity.
--- Otherwise, entity_def.prototype is returned.
---
--- @param entity_def table The entity definition from the composite
--- @param interface_entity LuaEntity The interface entity (for quality/context lookup)
--- @return string prototype The resolved entity prototype name
local function resolve_prototype(entity_def, interface_entity)
    if entity_def.prototype_resolver then
        local success, result = pcall(entity_def.prototype_resolver, interface_entity)
        if success and result then
            return result
        end
        -- Fall back to base name if resolver fails
        game.print("[Composite] prototype_resolver failed, using fallback: " .. tostring(entity_def.prototype))
    end
    return entity_def.prototype
end

--- Handles the interface entity being created (placed by player/robot).
--- Creates all other entities in the composite.
---
--- @param interface_entity LuaEntity The interface entity that was placed
--- @param event table The event data
--- @return string|nil composite_id
function lifecycle.on_interface_created(interface_entity, event)
    local is_interface, definition = registry.is_composite_interface(interface_entity)
    if not is_interface then
        return nil
    end
    
    -- Check if already tracked (avoid duplicate creation)
    local existing_id = composite_storage.get_composite_id_for_interface(interface_entity)
    if existing_id then
        return existing_id
    end
    
    local composite_id = generate_composite_id()
    local entities = { [interface_entity.name] = interface_entity }
    
    -- Get orientation from interface entity
    local direction = interface_entity.direction or defines.direction.north
    -- mirroring may not exist on all entities or Factorio versions
    local mirroring = nil
    if defines.mirroring and interface_entity.mirroring then
        mirroring = interface_entity.mirroring
    end
    
    -- Create other entities
    for _, entity_def in ipairs(definition.entities) do
        if not entity_def.interface then
            local offset = transform_offset(entity_def.offset, definition, direction, mirroring)
            local entity_position = {
                x = interface_entity.position.x + offset.x,
                y = interface_entity.position.y + offset.y
            }
            
            -- Resolve entity name (supports dynamic resolution based on interface quality, etc.)
            local prototype = resolve_prototype(entity_def, interface_entity)
            
            local entity = interface_entity.surface.create_entity{
                name = prototype,
                position = entity_position,
                force = interface_entity.force,
                raise_built = false,
                create_build_effect_smoke = false
            }
            
            if entity then
                -- Make non-interactable
                entity.destructible = false
                entity.minable = false
                if entity.operable ~= nil then
                    entity.operable = false
                end
                
                -- Store by key if provided, else by resolved entity name
                local storage_key = entity_def.key or prototype
                entities[storage_key] = entity
            else
                game.print("[Composite] Failed to create: " .. prototype)
            end
        end
    end
    
    -- Create heat connection renders if defined
    local heat_renders = nil
    if definition.heat_connections then
        local hc = definition.heat_connections
        local show_on_hover = hc.show_indicator_on_hover ~= false  -- default true
        
        -- Transform connections based on entity orientation
        local transformed = transform_connections(hc, definition, direction, mirroring)
        heat_renders = heat_rendering.create_connections(interface_entity, transformed, not show_on_hover)
    end
    
    -- Create flow arrow renders if defined
    local arrow_renders = nil
    if definition.flow_arrows then
        local fa = definition.flow_arrows
        local only_in_alt = fa.only_in_alt_mode ~= false  -- default true
        
        -- Transform arrows based on entity orientation
        local transformed = transform_arrows(fa, definition, direction, mirroring)
        arrow_renders = heat_rendering.create_arrows(interface_entity, transformed, only_in_alt)
    end
    
    -- Store in storage
    composite_storage.store(composite_id, definition.name, interface_entity, entities, heat_renders, arrow_renders)
    
    -- Call on_created hook with direction/mirroring info
    if definition.hooks and definition.hooks.on_created then
        local success, err = pcall(definition.hooks.on_created, composite_id, entities, direction, mirroring)
        if not success then
            game.print("[Composite] Error in on_created hook: " .. tostring(err))
        end
    end

    return composite_id
end

--- Handles the interface entity being rotated or flipped.
--- Moves hidden entities to their new transformed positions.
---
--- @param interface_entity LuaEntity The interface entity that was rotated/flipped
--- @param previous_direction defines.direction|nil The previous direction (for rotation events)
--- @return boolean success
function lifecycle.on_interface_orientation_changed(interface_entity, previous_direction)
    local composite_id = composite_storage.get_composite_id_for_interface(interface_entity)
    if not composite_id then
        return false
    end
    
    local composite = composite_storage.get(composite_id)
    if not composite then
        return false
    end
    
    local definition = registry.get(composite.definition_name)
    if not definition then
        return false
    end
    
    -- Skip if this composite doesn't support orientation changes
    if not definition.supports_rotation and not definition.supports_flipping then
        return false
    end
    
    -- Get new orientation from interface entity
    local direction = interface_entity.direction or defines.direction.north
    local mirroring = interface_entity.mirroring  -- nil if not supported
    
    -- Teleport hidden entities to new positions
    for _, entity_def in ipairs(definition.entities) do
        if not entity_def.interface then
            -- Lookup by key if provided, else by prototype
            local storage_key = entity_def.key or entity_def.prototype
            local entity = composite.entities[storage_key]
            if entity and entity.valid then
                local offset = transform_offset(entity_def.offset, definition, direction, mirroring)
                local new_position = {
                    x = interface_entity.position.x + offset.x,
                    y = interface_entity.position.y + offset.y
                }
                entity.teleport(new_position)
            end
        end
    end
    
    -- Update heat connection renders if defined
    if definition.heat_connections then
        -- Destroy old renders
        heat_rendering.destroy_all(composite.heat_renders)
        
        -- Create new renders with updated orientation
        local hc = definition.heat_connections
        local show_on_hover = hc.show_indicator_on_hover ~= false
        local transformed = transform_connections(hc, definition, direction, mirroring)
        
        -- Check if any player has this entity selected (indicators should be visible if so)
        local is_selected = false
        if show_on_hover then
            for _, player in pairs(game.players) do
                if player.selected == interface_entity then
                    is_selected = true
                    break
                end
            end
        end
        
        local indicator_visible = not show_on_hover or is_selected
        local heat_renders = heat_rendering.create_connections(interface_entity, transformed, indicator_visible)
        composite_storage.update_heat_renders(composite_id, heat_renders)
    end
    
    -- Update flow arrow renders if defined
    if definition.flow_arrows then
        -- Destroy old arrows
        heat_rendering.destroy_all(composite.arrow_renders)
        
        -- Create new arrows with updated orientation
        local fa = definition.flow_arrows
        local only_in_alt = fa.only_in_alt_mode ~= false
        local transformed = transform_arrows(fa, definition, direction, mirroring)
        local arrow_renders = heat_rendering.create_arrows(interface_entity, transformed, only_in_alt)
        composite_storage.update_arrow_renders(composite_id, arrow_renders)
    end
    
    -- Call on_orientation_changed hook
    if definition.hooks and definition.hooks.on_orientation_changed then
        local success, err = pcall(definition.hooks.on_orientation_changed, composite_id, composite.entities, direction, mirroring)
        if not success then
            game.print("[Composite] Error in on_orientation_changed hook: " .. tostring(err))
        end
    end
    
    return true
end

--- Handles the interface entity being destroyed or mined.
--- Destroys all other entities in the composite.
---
--- @param interface_entity LuaEntity The interface entity being destroyed
--- @param event table The event data
--- @return boolean success
function lifecycle.on_interface_destroyed(interface_entity, event)
    local composite_id = composite_storage.get_composite_id_for_interface(interface_entity)
    if not composite_id then
        return false
    end
    
    local composite = composite_storage.get(composite_id)
    if not composite then
        return false
    end
    
    local definition = registry.get(composite.definition_name)
    
    -- Call on_destroyed hook
    if definition and definition.hooks and definition.hooks.on_destroyed then
        local success, err = pcall(definition.hooks.on_destroyed, composite_id, composite.entities)
        if not success then
            game.print("[Composite] Error in on_destroyed hook: " .. tostring(err))
        end
    end
    
    -- Destroy heat connection renders
    heat_rendering.destroy_all(composite.heat_renders)
    
    -- Destroy flow arrow renders
    heat_rendering.destroy_all(composite.arrow_renders)
    
    -- Destroy non-interface entities
    for prototype, entity in pairs(composite.entities) do
        if entity and entity.valid and entity ~= interface_entity then
            entity.destroy({ raise_destroy = false })
        end
    end
    
    -- Remove from storage
    composite_storage.remove(composite_id)
    
    return true
end

--- Sets the visibility of heat indicators for a composite.
--- @param composite_id string The composite ID
--- @param visible boolean Whether to show indicators
function lifecycle.set_heat_indicators_visible(composite_id, visible)
    local composite = composite_storage.get(composite_id)
    if composite and composite.heat_renders then
        heat_rendering.set_indicators_visible(composite.heat_renders, visible)
    end
end

--- Swaps a component entity to a different prototype.
--- Preserves position, updates storage automatically.
--- @param composite_id string The composite ID
--- @param entity_key string The key in the entities table (e.g., "input", "output")
--- @param new_prototype string The new prototype name
--- @return LuaEntity|nil new_entity The new entity, or nil on failure
--- @return LuaEntity|nil old_entity The old entity (still valid until caller decides to destroy)
function lifecycle.swap_entity(composite_id, entity_key, new_prototype)
    local composite = composite_storage.get(composite_id)
    if not composite then
        return nil, nil
    end
    
    local old_entity = composite.entities[entity_key]
    if not old_entity or not old_entity.valid then
        return nil, nil
    end
    
    -- Already the right prototype
    if old_entity.name == new_prototype then
        return old_entity, nil
    end
    
    local position = old_entity.position
    local force = old_entity.force
    local surface = old_entity.surface
    
    -- Create new entity first
    local new_entity = surface.create_entity{
        name = new_prototype,
        position = position,
        force = force,
        raise_built = false,
        create_build_effect_smoke = false,
    }
    
    if new_entity then
        new_entity.destructible = false
        
        -- Update storage
        composite.entities[entity_key] = new_entity
    end
    
    -- Return both so caller can transfer properties and destroy old
    return new_entity, old_entity
end

return lifecycle
