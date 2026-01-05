# Composite Entity Lifecycle Library

A Lua library for managing composite entities in Factorio mods. Composite entities are multi-part structures where several individual entities work together as a single logical unit.

## Features

- **Automatic Lifecycle Management** - All entities created/destroyed together
- **Interface Entity Pattern** - One entity handles player interaction
- **Named Entity Lookup** - O(1) access to entities by name
- **Blueprint Support** - Composites work seamlessly with blueprints
- **Mining Prevention** - Non-interface entities are protected

## Quick Start

### 1. Register the Composite

```lua
local registry = require("lib.composite_entity.registry")

registry.register({
    name = "my-generator-composite",
    
    entities = {
        -- Interface: player interacts with this
        {
            prototype = "my-generator",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: power distribution
        {
            prototype = "my-generator-pole",
            interface = false,
            offset = {x = 0, y = 0},
        }
    },
    
    hooks = {
        on_created = function(composite_id, entities)
            -- All entities are in the named 'entities' table
            local generator = entities["my-generator"]
            local pole = entities["my-generator-pole"]
        end,
        on_destroyed = function(composite_id, entities)
            -- Called before entities are destroyed
        end
    }
})
```

### 2. Create Composites

```lua
local lifecycle = require("lib.composite_entity.lifecycle")

-- Create via API
local composite_id = lifecycle.create(
    surface,
    position,
    "my-generator-composite",
    force
)

-- Or let events handle it (automatic for interface entities)
```

### 3. Access Entities

```lua
-- Get composite data
local composite = lifecycle.get(composite_id)
local generator = composite.entities["my-generator"]

-- Or use get_entity shorthand
local pole = lifecycle.get_entity(composite_id, "my-generator-pole")

-- Get composite from interface entity
local id = lifecycle.get_by_interface(entity)
```

### 4. Destroy Composites

```lua
lifecycle.destroy(composite_id)
-- All entities are destroyed automatically
```

## API Reference

### Registry Module

```lua
local registry = require("lib.composite_entity.registry")
```

| Function | Description |
|----------|-------------|
| `register(definition)` | Registers a composite definition |
| `get(name)` | Gets definition by name |
| `get_by_prototype(prototype)` | Gets definition by interface entity name |
| `is_interface_entity(prototype)` | Checks if entity is an interface |

### Lifecycle Module

```lua
local lifecycle = require("lib.composite_entity.lifecycle")
```

| Function | Description |
|----------|-------------|
| `create(surface, position, name, force)` | Creates composite, returns composite_id |
| `destroy(composite_id)` | Destroys all entities, cleans storage |
| `get(composite_id)` | Gets composite data (definition_name, interface, entities) |
| `get_entity(composite_id, prototype)` | Gets specific entity by name |
| `get_by_interface(interface_entity)` | Gets composite_id for an interface entity |
| `is_interface_entity(entity)` | Checks if entity is a registered interface |

### Storage Module

```lua
local storage = require("lib.composite_entity.storage")
```

| Function | Description |
|----------|-------------|
| `initialize()` | Initializes storage tables |
| `store(id, name, interface, entities)` | Stores composite |
| `get(composite_id)` | Gets composite data |
| `get_composite_id_for_interface(entity)` | Reverse lookup |
| `remove(composite_id)` | Removes from storage |
| `get_all()` | Gets all composites |
| `cleanup_invalid_entities()` | Removes invalid references |

## Composite Definition Structure

```lua
{
    name = "unique-composite-id",
    
    entities = {
        {
            prototype = "interface-entity-name",  -- Required
            interface = true,                       -- One must be true
            offset = {x = 0, y = 0},               -- Required
        },
        {
            prototype = "hidden-entity-name",
            interface = false,                      -- Hidden, non-interactable
            offset = {x = 0, y = 0},
        }
    },
    
    hooks = {  -- Optional
        on_created = function(composite_id, entities) end,
        on_destroyed = function(composite_id, entities) end
    }
}
```

## Storage Structure

```lua
-- Composites indexed by force, then by ID (API callers don't need to track force)
storage.composites = {
    ["player"] = {  -- force name
        ["12345_678901"] = {
            definition_name = "my-generator-composite",
            interface = LuaEntity,
            entities = {
                ["my-generator"] = LuaEntity,
                ["my-generator-pole"] = LuaEntity,
            }
        }
    }
}

-- Reverse lookup: composite_id -> force_name
storage.composite_to_force = {
    ["12345_678901"] = "player"
}

-- Reverse lookup: interface unit_number -> composite_id (also force-indexed)
storage.interface_to_composite = {
    ["player"] = {
        [unit_number] = "12345_678901"
    }
}
```

## Event Flow

```
Interface entity placed
    ↓
events.lua: on_entity_created
    ↓
lifecycle.on_interface_created()
    ↓
- Generate composite_id (game.tick + random)
- Create all other entities
- Set hidden entities: destructible=false, minable=false
- Store in storage.composites
- Store interface → composite_id mapping
- Call on_created hook

Interface entity mined/destroyed
    ↓
events.lua: on_entity_mined/died
    ↓
lifecycle.on_interface_destroyed()
    ↓
- Call on_destroyed hook
- Destroy all non-interface entities
- Remove from storage
```

## Examples

### Piezoelectric Generator (Multi-tier)

```lua
for _, tier in ipairs(TIERS) do
    registry.register({
        name = tier.composite_name,
        
        entities = {
            {
                prototype = tier.interface_name,
                interface = true,
                offset = {x = 0, y = 0},
            },
            {
                prototype = tier.generator_name,
                interface = false,
                offset = {x = 0, y = 0},
            },
            {
                prototype = tier.pole_name,
                interface = false,
                offset = {x = 0, y = 0},
            },
        },
    })
end
```

### Lightning Furnace

```lua
registry.register({
    name = "lightning-furnace-composite",
    
    entities = {
        {
            prototype = "tenebris-lightning-furnace",
            interface = true,
            offset = {x = 0, y = 0},
        },
        {
            prototype = "tenebris-lightning-collector-hidden",
            interface = false,
            offset = {x = 0, y = 0},
        },
        {
            prototype = "tenebris-lightning-furnace-pole-hidden",
            interface = false,
            offset = {x = 0, y = 0},
        }
    },
})
```

## Design Principles

1. **One Interface Entity** - Each composite has exactly one entity the player interacts with
2. **Named Lookup** - Entities stored by name for O(1) access
3. **Generated IDs** - Composites use `game.tick + random` for unique IDs
4. **Hidden by Default** - Non-interface entities have `destructible=false`, `minable=false`
5. **Automatic Events** - Interface placement/destruction handled automatically

## License

Part of the Tenebris Prime mod.
