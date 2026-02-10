--- Event Manager Dispatcher Module
--- Dispatches Factorio events to all registered subscribers in priority order.
--- Handles error isolation and automatic event registration.
---
--- @module event_manager.dispatcher

local registry = require("lib.event_manager.registry")

local dispatcher = {}

--- Tracks which events have been set up with Factorio
--- @type table<number|string, boolean>
local registered_events = {}

--- Special lifecycle events that use different registration methods
--- @type table<string, boolean>
local LIFECYCLE_EVENTS = {
    ["on_init"] = true,
    ["on_load"] = true,
    ["on_configuration_changed"] = true
}

--- Cache of known Factorio event IDs for O(1) lookup
--- Built once at load time instead of iterating defines.events on every dispatch
--- @type table<number, boolean>
local KNOWN_EVENT_IDS = {}

-- Build the cache at load time
for _, event_id in pairs(defines.events) do
    KNOWN_EVENT_IDS[event_id] = true
end

--- Dispatches an event to all registered subscribers.
--- Executes subscribers in priority order (low to high).
--- Wraps each subscriber in pcall for error isolation.
---
--- @param event_id number|string The event ID
--- @param event_data table The event data from Factorio
--- @usage
---   -- Typically called automatically by setup_event
---   dispatcher.dispatch(tenebris.EVENTS.ON_BUILT_ENTITY, event)
function dispatcher.dispatch(event_id, event_data)
    local subs = registry.get_subscribers(event_id)
    
    -- Even if modifications happen during iteration,
    -- they create a new table, so this reference stays valid
    for _, sub in ipairs(subs) do
        local success, err = pcall(sub.handler, event_data)
        if not success then
            -- Log error but continue to next subscriber
            log(string.format(
                "[Event Manager] Error in subscriber '%s' for event %s: %s",
                sub.name,
                tostring(event_id),
                tostring(err)
            ))
            
            -- Also print to console if possible
            if game then
                game.print(string.format(
                    "[Event Manager] Error in '%s': %s",
                    sub.name,
                    tostring(err)
                ))
            end
        end
    end
end

--- Sets up a Factorio event handler for the given event.
--- Uses lazy registration - only sets up when first subscriber is added.
--- Automatically detects event type and uses appropriate registration method.
---
--- @param event_id number|string The event ID or special lifecycle event name or tick count
--- @return boolean success True if setup successfully
--- @return string|nil error_message Error message if setup failed
--- @usage
---   -- Usually called automatically from subscribe
---   dispatcher.setup_event(tenebris.EVENTS.ON_BUILT_ENTITY)
function dispatcher.setup_event(event_id)
    -- Already set up
    if registered_events[event_id] then
        return true, nil
    end
    
    -- Handle special lifecycle events
    if type(event_id) == "string" and LIFECYCLE_EVENTS[event_id] then
        if event_id == "on_init" then
            script.on_init(function()
                dispatcher.dispatch("on_init", {})
            end)
        elseif event_id == "on_load" then
            script.on_load(function()
                dispatcher.dispatch("on_load", {})
            end)
        elseif event_id == "on_configuration_changed" then
            script.on_configuration_changed(function(data)
                dispatcher.dispatch("on_configuration_changed", data)
            end)
        end
        
        registered_events[event_id] = true
        return true, nil
    end
    
    -- Handle standard events (numeric ID or custom event)
    if type(event_id) == "number" then
        -- O(1) lookup using cached event IDs instead of iterating defines.events
        if KNOWN_EVENT_IDS[event_id] then
            -- Register as a standard Factorio event
        local success_event = pcall(function()
            script.on_event(event_id, function(event)
                dispatcher.dispatch(event_id, event)
            end)
        end)
        
        if success_event then
            registered_events[event_id] = true
            return true, nil
        end
        
            return false, "Failed to register event: " .. tostring(event_id)
        else
            -- Not a known event, treat as nth_tick interval
        local success_tick = pcall(function()
            script.on_nth_tick(event_id, function(event)
                dispatcher.dispatch(event_id, event)
            end)
        end)
        
        if success_tick then
            registered_events[event_id] = true
            return true, nil
        end
        
            return false, "Failed to register nth_tick: " .. tostring(event_id)
        end
    end
    
    -- Unknown event type
    return false, string.format("Unknown event type: %s (type: %s)", tostring(event_id), type(event_id))
end

--- Checks if an event has been set up with Factorio.
---
--- @param event_id number|string The event ID
--- @return boolean is_setup True if event handler is registered with Factorio
--- @usage
---   if dispatcher.is_event_setup(tenebris.EVENTS.ON_BUILT_ENTITY) then
---     print("Event is active")
---   end
function dispatcher.is_event_setup(event_id)
    return registered_events[event_id] == true
end

--- Gets all event IDs that have been set up with Factorio.
---
--- @return table event_ids Array of event IDs
--- @usage
---   for _, event_id in ipairs(dispatcher.get_setup_events()) do
---     print("Setup: " .. tostring(event_id))
---   end
function dispatcher.get_setup_events()
    local events = {}
    for event_id, _ in pairs(registered_events) do
        table.insert(events, event_id)
    end
    return events
end

--- Manually triggers an event dispatch (for testing).
--- This bypasses Factorio's event system and directly calls subscribers.
---
--- @param event_id number|string The event ID
--- @param event_data table The event data to pass to subscribers
--- @usage
---   -- For testing
---   dispatcher.trigger_event(tenebris.EVENTS.ON_BUILT_ENTITY, { entity = test_entity })
function dispatcher.trigger_event(event_id, event_data)
    dispatcher.dispatch(event_id, event_data or {})
end

return dispatcher

