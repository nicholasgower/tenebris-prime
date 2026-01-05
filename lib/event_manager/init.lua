--- Event Manager Public API
--- Provides a unified interface for event subscription and management.
--- Automatically handles lazy event registration with Factorio.
---
--- @module event_manager

local registry = require("lib.event_manager.registry")
local dispatcher = require("lib.event_manager.dispatcher")

local event_manager = {}

--- Subscribes a handler to an event with optional priority.
--- Automatically sets up the Factorio event handler on first subscription.
--- Uses stable sorting: equal priority subscribers execute in registration order.
---
--- @param event_id number|string Event ID from tenebris.EVENTS.*, custom event ID, or lifecycle event name ("on_init", "on_load", "on_configuration_changed")
--- @param name string Unique subscriber name (e.g., "composite_lifecycle", "spore_clearance")
--- @param handler function Handler function that receives event_data
--- @param priority number|nil Priority (default: 100). Lower executes first. Recommended ranges:
---   - 0-99: Critical infrastructure
---   - 100-199: Gameplay mechanics
---   - 200-299: UI and effects
---   - 900-999: Logging and debugging
--- @return boolean success True if subscribed successfully
--- @return string|nil error_message Error message if failed
--- @usage
---   tenebris.event_manager.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system", function(event)
---     game.print("Entity built: " .. event.entity.name)
---   end, tenebris.PRIORITY.GAMEPLAY)
function event_manager.subscribe(event_id, name, handler, priority)
    -- Subscribe to registry
    local success, err = registry.subscribe(event_id, name, handler, priority)
    if not success then
        return false, err
    end
    
    -- Lazy registration: set up Factorio event handler if not already done
    if not dispatcher.is_event_setup(event_id) then
        local setup_ok, setup_err = dispatcher.setup_event(event_id)
        if not setup_ok then
            -- Rollback subscription if event setup failed
            registry.unsubscribe(event_id, name)
            return false, "Failed to setup event: " .. tostring(setup_err)
        end
    end
    
    return true, nil
end

--- Unsubscribes a handler from an event.
---
--- @param event_id number|string The event ID
--- @param name string The subscriber name to remove
--- @return boolean success True if unsubscribed, false if not found
--- @usage
---   tenebris.event_manager.unsubscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system")
function event_manager.unsubscribe(event_id, name)
    return registry.unsubscribe(event_id, name)
end

--- Checks if a subscriber is registered for an event.
---
--- @param event_id number|string The event ID
--- @param name string The subscriber name
--- @return boolean is_registered True if registered
--- @usage
---   if tenebris.event_manager.is_registered(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system") then
---     print("Already subscribed")
---   end
function event_manager.is_registered(event_id, name)
    return registry.is_registered(event_id, name)
end

--- Gets statistics about the event manager.
--- Useful for debugging and monitoring.
---
--- @return table stats Table containing:
---   - total_events: number of events with subscribers
---   - total_subscribers: total subscribers across all events
---   - setup_events: number of events registered with Factorio
---   - events: per-event subscriber counts
--- @usage
---   local stats = event_manager.get_stats()
---   game.print(serpent.block(stats))
function event_manager.get_stats()
    local stats = registry.get_stats()
    
    -- Add dispatcher info
    local setup_events = dispatcher.get_setup_events()
    stats.setup_events = #setup_events
    
    return stats
end

--- Manually triggers an event (for testing).
---
--- @param event_id number|string The event ID
--- @param event_data table The event data
--- @usage
---   -- For testing
---   tenebris.event_manager.trigger(tenebris.EVENTS.ON_BUILT_ENTITY, { entity = test_entity })
function event_manager.trigger(event_id, event_data)
    dispatcher.trigger_event(event_id, event_data)
end

--- Clears all subscribers for an event.
---
--- @param event_id number|string The event ID
--- @return boolean success True if cleared
--- @usage
---   tenebris.event_manager.clear_event(tenebris.EVENTS.ON_BUILT_ENTITY)
function event_manager.clear_event(event_id)
    return registry.clear_event(event_id)
end

--- Clears all subscriptions (use with caution, mainly for testing).
---
--- @usage
---   event_manager.clear_all()
function event_manager.clear_all()
    registry.clear_all()
end

--- Tracks which nth_tick intervals have been registered with Factorio
--- @type table<number, boolean>
local registered_nth_ticks = {}

--- Subscribes a handler to run every N ticks.
--- Use this instead of subscribe() for nth_tick handlers to avoid ambiguity with Factorio event IDs.
--- Multiple subscribers to the same tick interval share one Factorio handler.
---
--- @param tick_interval number The number of ticks between calls (e.g., 60 for every second)
--- @param name string Unique subscriber name
--- @param handler function Handler function that receives event_data
--- @param priority number|nil Priority (default: 100)
--- @return boolean success True if subscribed successfully
--- @return string|nil error_message Error message if failed
--- @usage
---   event_manager.subscribe_nth_tick(60, "my_system", function(event)
---     game.print("Called every second!")
---   end)
function event_manager.subscribe_nth_tick(tick_interval, name, handler, priority)
    -- Subscribe to registry using a unique key to avoid collision with event IDs
    local tick_key = "nth_tick_" .. tick_interval
    local success, err = registry.subscribe(tick_key, name, handler, priority)
    if not success then
        return false, err
    end
    
    -- Only register with Factorio if this interval hasn't been set up yet
    if not registered_nth_ticks[tick_interval] then
        script.on_nth_tick(tick_interval, function(event)
            dispatcher.dispatch(tick_key, event)
        end)
        registered_nth_ticks[tick_interval] = true
    end
    
    return true, nil
end

--- Direct access to registry module (advanced usage).
event_manager.registry = registry

--- Direct access to dispatcher module (advanced usage).
event_manager.dispatcher = dispatcher

return event_manager

