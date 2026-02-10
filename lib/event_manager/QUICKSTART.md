# Event Manager - Quick Reference

## What Changed

### Old System
```
scripts/hooks/
├── on_built_entity.lua        ← Monolithic hook files
├── on_player_mined_entity.lua  ← All handlers in one place
├── on_entity_died.lua
└── ...
```

### New System
```
lib/event_manager/              ← Event manager core
├── init.lua
├── registry.lua
└── dispatcher.lua

Scripts self-register:
├── lib/composite_entity/events.lua   ← Composite lifecycle
├── scripts/spore_clearance.lua       ← Spore system
├── scripts/resonate_ortet_buds.lua   ← Quartz system
├── scripts/tenebris_pole_prevention.lua
├── scripts/deep_space_sensing_events.lua
├── scripts/cargo_corrosion_events.lua
└── scripts/tick_events.lua
```

## Basic Usage

```lua
local tenebris = require("lib.tenebris")

tenebris.event_manager.subscribe(
    tenebris.EVENTS.ON_BUILT_ENTITY,  -- Event
    "my_system",                       -- Name
    function(event)                    -- Handler
        game.print("Built: " .. event.entity.name)
    end,
    tenebris.PRIORITY.GAMEPLAY         -- Priority (lower = earlier)
)
```

## Priority Guide

| Range | Purpose | Examples |
|-------|---------|----------|
| 0-99 | Critical infrastructure | Composite entities (10) |
| 100-199 | Gameplay mechanics | Spore clearance (100), Quartz (100) |
| 200-299 | UI and effects | Visual feedback |
| 900-999 | Logging | Debug logging |

## Event Types

```lua
-- Standard events (use tenebris.EVENTS.*)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "name", handler, priority)

-- Custom events
tenebris.event_manager.subscribe(my_custom_event_id, "name", handler, priority)

-- Lifecycle events
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_INIT, "name", handler, priority)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_LOAD, "name", handler, priority)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_CONFIGURATION_CHANGED, "name", handler, priority)

-- Periodic ticks
tenebris.event_manager.subscribe(60, "every_second", handler, priority)     -- Every 60 ticks
tenebris.event_manager.subscribe(3600, "every_minute", handler, priority)   -- Every 3600 ticks
```

## Key Features

✅ **Multiple subscribers per event** - No more one-handler limitation  
✅ **Priority-based ordering** - Control execution order  
✅ **Stable sorting** - Equal priority = registration order  
✅ **Error isolation** - One crash doesn't stop others  
✅ **Lazy registration** - Events registered only when needed  
✅ **Auto-detection** - Works with all event types automatically  
✅ **Self-registration** - Modules register themselves  
✅ **Dynamic subscription** - Add/remove at runtime  

## Common Patterns

### Simple Handler
```lua
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_CREATED, "welcome", function(event)
    game.get_player(event.player_index).print("Welcome!")
end, tenebris.PRIORITY.UI)
```

### Conditional Handler
```lua
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "tenebris_check", function(event)
    if not event.entity or not event.entity.valid then return end
    
    if tenebris.is_on_tenebris(event.entity) then
        game.print("Built on Tenebris!")
    end
end, tenebris.PRIORITY.GAMEPLAY)
```

### Multiple Events, Same Handler
```lua
local function on_destroyed(event)
    -- Handle entity destruction
end

tenebris.event_manager.subscribe(tenebris.EVENTS.ON_PLAYER_MINED_ENTITY, "cleanup", on_destroyed, tenebris.PRIORITY.GAMEPLAY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ROBOT_MINED_ENTITY, "cleanup", on_destroyed, tenebris.PRIORITY.GAMEPLAY)
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_ENTITY_DIED, "cleanup", on_destroyed, tenebris.PRIORITY.GAMEPLAY)
```

### Self-Registering Module
```lua
-- scripts/my_system.lua
local tenebris = require("lib.tenebris")

local my_system = {}

function my_system.do_work(entity)
    -- System logic
end

-- Self-register when loaded
tenebris.event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system", function(event)
    my_system.do_work(event.entity)
end, tenebris.PRIORITY.GAMEPLAY)

return my_system
```

Then in `control.lua`:
```lua
require("scripts.my_system")  -- Loads and self-registers
```

## Debugging Commands

```lua
-- View statistics
/c game.print(serpent.block(tenebris.event_manager.get_stats()))

-- Check if registered
/c game.print(tenebris.event_manager.is_registered(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system"))

-- Manually trigger event
/c tenebris.event_manager.trigger(tenebris.EVENTS.ON_BUILT_ENTITY, {entity = game.player.selected})
```

## Migration Checklist

When adding a new system:

1. ✅ Create your module in `scripts/`
2. ✅ Add `event_manager.subscribe()` calls at the bottom
3. ✅ Require your module in `control.lua`
4. ✅ Choose appropriate priority (see guide above)
5. ✅ Test that it works

**No need to:**
- ❌ Create hook files in `scripts/hooks/`
- ❌ Manually call `script.on_event()`
- ❌ Worry about multiple handlers per event

## What's Next?

- Read [full documentation](README.md) for complete API reference
- See [composite entity library](../composite_entity/README.md) for usage example
- Check existing event subscribers in `scripts/` for patterns

Happy event handling! 🎮

