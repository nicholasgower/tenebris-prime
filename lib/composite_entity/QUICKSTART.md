# Composite Entity Library - Quick Reference

## What This Is

A lifecycle management library for composite entities in Factorio mods. Composite entities are multi-part structures where multiple Factorio entities work together as one logical unit.

## Files

```
lib/composite_entity/
├── README.md           # Full documentation
├── EXAMPLE.lua         # Usage examples
├── init.lua            # Library entry point
├── registry.lua        # Composite definition registry
├── lifecycle.lua       # Entity lifecycle management
├── storage.lua         # Global state management
└── events.lua          # Event subscriptions
```

## How to Use

### 1. Create Entity Prototypes (Data Stage)

```lua
-- prototypes/entity/my_entities.lua
data:extend({
    -- Interface entity (player interacts with this)
    {
        type = "beacon",
        name = "my-glowing-beacon",
        -- ... normal properties ...
    },
    -- Hidden entity (non-interactable)
    {
        type = "simple-entity-with-owner",
        name = "my-beacon-glow",
        selectable_in_game = false,
        -- ... glow graphics ...
    }
})
```

### 2. Register Composite (Control Stage)

```lua
-- control.lua or scripts/my_system/composite.lua
local registry = require("lib.composite_entity.registry")

registry.register({
    name = "glowing-beacon",
    
    entities = {
        -- Interface: player interacts with this
        {
            prototype = "my-glowing-beacon",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: auto-created, non-interactable
        {
            prototype = "my-beacon-glow",
            interface = false,
            offset = {x = 0, y = 0},
        }
    },
    
    hooks = {
        on_created = function(composite_id, entities)
            local beacon = entities["my-glowing-beacon"]
            local glow = entities["my-beacon-glow"]
            game.print("Beacon created!")
        end
    }
})

-- Require events module
require("lib.composite_entity.events")
```

The library automatically:
- Creates all entities when interface is placed
- Destroys all entities when interface is mined/destroyed
- Makes hidden entities non-interactable
- Handles blueprints (only blueprints interface entity)

## API Quick Reference

```lua
local lifecycle = require("lib.composite_entity.lifecycle")

-- Create a composite
local composite_id = lifecycle.create(surface, position, "glowing-beacon", force)

-- Get composite data
local composite = lifecycle.get(composite_id)
-- composite.entities["my-glowing-beacon"]
-- composite.entities["my-beacon-glow"]

-- Get specific entity
local glow = lifecycle.get_entity(composite_id, "my-beacon-glow")

-- Get composite from interface entity
local id = lifecycle.get_by_interface(interface_entity)

-- Destroy composite
lifecycle.destroy(composite_id)
```

## Storage Structure

```lua
-- Internally indexed by force (callers don't need to track force)
storage.composites = {
    ["player"] = {  -- force name
        ["composite_id"] = {
            definition_name = "glowing-beacon",
            interface = LuaEntity,
            entities = {
                ["my-glowing-beacon"] = LuaEntity,
                ["my-beacon-glow"] = LuaEntity,
            }
        }
    }
}

-- Reverse lookup for composite_id -> force
storage.composite_to_force = {
    ["composite_id"] = "player"
}
```

## Testing

```lua
-- In-game console:

-- Check registered composites
/c game.print(require("lib.composite_entity.registry").count())

-- Get storage stats
/c local s = require("lib.composite_entity.storage")
/c game.print(s.get_stats().total_composites)

-- Cleanup invalid composites
/c local s = require("lib.composite_entity.storage")
/c game.print("Cleaned: " .. s.cleanup_invalid_entities())
```

## See Also

- `README.md` - Complete API documentation
- `EXAMPLE.lua` - Detailed usage examples
