--- Example: How to Create Composite Entities
--- This file demonstrates how to use the composite entity library
--- to create multi-part structures in your Factorio mod.

--[[
STEP 1: Define your entity prototypes in data stage (data.lua or prototypes/)

In your prototypes file, define all the entity prototypes as normal:

```lua
-- prototypes/entity/my_entities.lua
data:extend({
    -- Interface entity (the one players interact with)
    {
        type = "furnace",
        name = "lightning-generator",
        -- ... all normal entity properties ...
        minable = { mining_time = 0.5, result = "lightning-generator" },
    },
    
    -- Hidden entities (spawned automatically, non-interactable)
    {
        type = "electric-pole",
        name = "lightning-generator-pole",
        -- ... properties ...
        selectable_in_game = false,  -- Make it non-selectable
        collision_mask = {layers = {}},  -- Allow overlap
    },
    {
        type = "simple-entity-with-owner",
        name = "lightning-generator-glow",
        -- ... properties ...
        selectable_in_game = false,
    }
})
```

STEP 2: Register the composite in control.lua

In control.lua, register your composite:

```lua
-- control.lua
local registry = require("lib.composite_entity.registry")

registry.register({
    name = "lightning-generator-composite",
    
    entities = {
        -- Interface: player interacts with this entity
        {
            prototype = "lightning-generator",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: power distribution pole
        {
            prototype = "lightning-generator-pole",
            interface = false,
            offset = {x = 0, y = 0},
        },
        -- Hidden: visual glow effect
        {
            prototype = "lightning-generator-glow",
            interface = false,
            offset = {x = 0, y = -1},
        }
    },
    
    -- Optional: Lifecycle hooks
    hooks = {
        on_created = function(composite_id, entities)
            -- 'entities' is a named table: entities["entity-name"]
            local generator = entities["lightning-generator"]
            local pole = entities["lightning-generator-pole"]
            game.print("Lightning generator created with ID: " .. composite_id)
        end,
        
        on_destroyed = function(composite_id, entities)
            -- Called before entities are destroyed
            game.print("Lightning generator being dismantled!")
        end
    }
})

-- Require events module to hook into lifecycle
require("lib.composite_entity.events")
```

STEP 3: Create composites programmatically (optional)

```lua
local lifecycle = require("lib.composite_entity.lifecycle")

-- Create a new composite
local composite_id = lifecycle.create(
    surface,                          -- LuaSurface
    {x = 10, y = 20},                -- Position
    "lightning-generator-composite", -- Definition name
    game.forces.player               -- Force
)

-- Access entities by name
local generator = lifecycle.get_entity(composite_id, "lightning-generator")
local pole = lifecycle.get_entity(composite_id, "lightning-generator-pole")

-- Or get all composite data
local composite = lifecycle.get(composite_id)
-- composite.entities["lightning-generator"]
-- composite.entities["lightning-generator-pole"]
-- composite.interface -- the interface entity
-- composite.definition_name -- "lightning-generator-composite"

-- Destroy the composite
lifecycle.destroy(composite_id)
```

STEP 4: That's it! The library handles lifecycle automatically.

The library automatically:
- Creates all entities when the interface entity is placed
- Destroys all entities when the interface is mined/destroyed
- Sets hidden entities to destructible=false, minable=false
- Handles blueprints (only blueprints the interface entity)
- Works with robots, scripts, and player actions

ACCESSING COMPOSITES FROM ENTITIES:

```lua
-- When you have an interface entity and need the composite
local composite_id = lifecycle.get_by_interface(interface_entity)
local composite = lifecycle.get(composite_id)

-- Access specific entity
local pole = composite.entities["lightning-generator-pole"]
```

EXAMPLE USE CASES:

1. Generator with Power Distribution
   - Interface: furnace or assembly machine
   - Hidden: electric pole for power distribution
   - Hooks: Transfer energy in on_tick

2. Building with Shadow/Glow
   - Interface: any building
   - Hidden: simple-entity-with-owner for visual effects

3. Multi-Component Machine
   - Interface: player-facing control panel
   - Hidden: multiple functional entities working together

ADVANCED: Custom Energy Transfer Script

```lua
local storage = require("lib.composite_entity.storage")

-- In on_tick handler
local all_composites = storage.get_all()
for composite_id, composite in pairs(all_composites) do
    if composite.definition_name == "lightning-generator-composite" then
        local generator = composite.entities["lightning-generator"]
        local pole = composite.entities["lightning-generator-pole"]
        
        if generator.valid and pole.valid then
            -- Transfer energy from generator to pole
            if generator.energy > 1000000 then
                generator.energy = generator.energy - 1000000
                pole.energy = pole.energy + 1000000
            end
        end
    end
end
```

DEBUGGING:

```lua
-- Check registered composites
/c local reg = require("lib.composite_entity.registry")
/c game.print("Registered: " .. reg.count())

-- Get storage stats
/c local storage = require("lib.composite_entity.storage")
/c local stats = storage.get_stats()
/c game.print("Total: " .. stats.total_composites)

-- Cleanup invalid entities
/c storage.cleanup_invalid_entities()
```

]]

return {}
