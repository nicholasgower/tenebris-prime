--- Event Manager Registry Module
--- Manages subscriber registration with priority-based stable sorting.
--- Handles dynamic subscription/unsubscription safely through table reallocation.
---
--- @module event_manager.registry

local registry = {}

--- Storage for all event subscribers
--- Structure: { [event_id] = { {name, handler, priority, sequence}, ... } }
--- @type table<number|string, table[]>
local subscribers = {}

--- Global sequence counter for stable sorting
--- @type number
local sequence_counter = 0

--- Subscribes a handler to an event with a given priority.
--- If a subscriber with the same name already exists for this event, it will be updated.
--- Uses stable sorting: subscribers with equal priority execute in registration order.
---
--- @param event_id number|string The event ID (from tenebris.EVENTS.* or custom) or special string ("on_init", "on_load", "on_configuration_changed")
--- @param name string Unique name for this subscriber (e.g., "composite_lifecycle", "spore_clearance")
--- @param handler function The handler function(event_data)
--- @param priority number|nil Priority value (default: 100). Lower values execute first (0-99: critical, 100-199: gameplay, 200-299: UI, 900-999: logging)
--- @return boolean success True if subscribed successfully
--- @return string|nil error_message Error message if subscription failed
--- @usage
---   registry.subscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system", my_handler, tenebris.PRIORITY.GAMEPLAY)
function registry.subscribe(event_id, name, handler, priority)
    -- Validate inputs
    if not event_id then
        return false, "event_id is required"
    end
    
    if not name or type(name) ~= "string" or name == "" then
        return false, "name must be a non-empty string"
    end
    
    if not handler or type(handler) ~= "function" then
        return false, "handler must be a function"
    end
    
    priority = priority or 100
    if type(priority) ~= "number" then
        return false, "priority must be a number"
    end
    
    -- Initialize event subscriber list if needed
    if not subscribers[event_id] then
        subscribers[event_id] = {}
    end
    
    -- Build new subscriber list with the new/updated subscriber
    local new_list = {}
    local added = false
    
    for _, sub in ipairs(subscribers[event_id]) do
        if sub.name == name then
            -- Update existing subscriber, preserve sequence for stable position
            table.insert(new_list, {
                name = name,
                handler = handler,
                priority = priority,
                sequence = sub.sequence
            })
            added = true
        else
            table.insert(new_list, sub)
        end
    end
    
    -- Add as new subscriber if not updating
    if not added then
        sequence_counter = sequence_counter + 1
        table.insert(new_list, {
            name = name,
            handler = handler,
            priority = priority,
            sequence = sequence_counter
        })
    end
    
    -- Sort by priority (ascending), then by sequence for stable sort
    table.sort(new_list, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.sequence < b.sequence
    end)
    
    -- Replace entire list (safe for concurrent iteration)
    subscribers[event_id] = new_list
    
    return true, nil
end

--- Unsubscribes a handler from an event.
--- Creates a new subscriber list without the target, avoiding nil holes.
---
--- @param event_id number|string The event ID
--- @param name string The name of the subscriber to remove
--- @return boolean success True if unsubscribed, false if not found
--- @usage
---   registry.unsubscribe(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system")
function registry.unsubscribe(event_id, name)
    if not subscribers[event_id] then
        return false
    end
    
    -- Build new list excluding the named subscriber
    local new_list = {}
    local found = false
    
    for _, sub in ipairs(subscribers[event_id]) do
        if sub.name ~= name then
            table.insert(new_list, sub)
        else
            found = true
        end
    end
    
    -- Replace entire list
    subscribers[event_id] = new_list
    
    return found
end

--- Gets all subscribers for an event, sorted by priority.
--- Returns a stable reference that remains valid even if modifications occur.
---
--- @param event_id number|string The event ID
--- @return table subscribers Array of subscriber tables {name, handler, priority, sequence}
--- @usage
---   local subs = registry.get_subscribers(tenebris.EVENTS.ON_BUILT_ENTITY)
---   for _, sub in ipairs(subs) do
---     print(sub.name, sub.priority)
---   end
function registry.get_subscribers(event_id)
    return subscribers[event_id] or {}
end

--- Checks if a specific subscriber is registered for an event.
---
--- @param event_id number|string The event ID
--- @param name string The subscriber name
--- @return boolean is_registered True if the subscriber exists
--- @usage
---   if registry.is_registered(tenebris.EVENTS.ON_BUILT_ENTITY, "my_system") then
---     print("Already registered")
---   end
function registry.is_registered(event_id, name)
    if not subscribers[event_id] then
        return false
    end
    
    for _, sub in ipairs(subscribers[event_id]) do
        if sub.name == name then
            return true
        end
    end
    
    return false
end

--- Gets all event IDs that have subscribers.
---
--- @return table event_ids Array of event IDs (numbers or strings)
--- @usage
---   for _, event_id in ipairs(registry.get_registered_events()) do
---     print("Event: " .. tostring(event_id))
---   end
function registry.get_registered_events()
    local events = {}
    for event_id, _ in pairs(subscribers) do
        table.insert(events, event_id)
    end
    return events
end

--- Gets statistics about registered subscribers.
--- Useful for debugging and monitoring.
---
--- @return table stats Table containing:
---   - total_events: number of events with subscribers
---   - total_subscribers: total number of subscribers across all events
---   - events: table mapping event_id -> subscriber count
--- @usage
---   local stats = registry.get_stats()
---   game.print(string.format("%d events, %d subscribers", stats.total_events, stats.total_subscribers))
function registry.get_stats()
    local stats = {
        total_events = 0,
        total_subscribers = 0,
        events = {}
    }
    
    for event_id, subs in pairs(subscribers) do
        stats.total_events = stats.total_events + 1
        local count = #subs
        stats.total_subscribers = stats.total_subscribers + count
        stats.events[tostring(event_id)] = count
    end
    
    return stats
end

--- Clears all subscribers for an event.
---
--- @param event_id number|string The event ID
--- @return boolean success True if cleared, false if event had no subscribers
--- @usage
---   registry.clear_event(tenebris.EVENTS.ON_BUILT_ENTITY)
function registry.clear_event(event_id)
    if not subscribers[event_id] then
        return false
    end
    
    subscribers[event_id] = {}
    return true
end

--- Clears all subscribers from all events.
--- Use with caution - primarily for testing.
---
--- @usage
---   registry.clear_all()
function registry.clear_all()
    subscribers = {}
    sequence_counter = 0
end

return registry

