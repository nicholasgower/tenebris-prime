--- Lightning Furnace Composite Registration
--- Registers the lightning furnace as a composite entity with hidden lightning collector and electric pole.
--- Manages dynamic event subscription - tick handlers only run when furnaces exist.

local tenebris = require("lib.tenebris")
local event_manager = tenebris.event_manager

-- Import handler modules (they export subscription details instead of auto-subscribing)
local energy_handler = require("scripts.lightning_furnace.energy")
local display_handler = require("scripts.lightning_furnace.display")

local STORAGE_KEY = "lightning_furnace_count"

-- Forward declarations
local subscribe_handlers
local unsubscribe_handlers

--- Subscribe to tick handlers (called when first furnace is created)
subscribe_handlers = function()
    -- Only subscribe if not already subscribed
    if not event_manager.is_registered(energy_handler.event_id, energy_handler.name) then
        event_manager.subscribe(
            energy_handler.event_id,
            energy_handler.name,
            energy_handler.handler,
            energy_handler.priority
        )
    end
    
    if not event_manager.is_registered("nth_tick_" .. display_handler.tick_interval, display_handler.name) then
        event_manager.subscribe_nth_tick(
            display_handler.tick_interval,
            display_handler.name,
            display_handler.handler,
            display_handler.priority
        )
    end
end

--- Unsubscribe from tick handlers (called when last furnace is destroyed)
unsubscribe_handlers = function()
    event_manager.unsubscribe(energy_handler.event_id, energy_handler.name)
    event_manager.unsubscribe("nth_tick_" .. display_handler.tick_interval, display_handler.name)
end

--- Initialize storage on game start
event_manager.subscribe("on_init", "lightning_furnace_storage_init", function()
    storage[STORAGE_KEY] = storage[STORAGE_KEY] or 0
end, tenebris.PRIORITY.INFRASTRUCTURE)

--- Restore subscriptions on load if furnaces exist
event_manager.subscribe("on_load", "lightning_furnace_restore_subscriptions", function()
    -- Note: Can't access storage in on_load, but subscriptions persist across saves
    -- The on_configuration_changed handler will fix any issues
end, tenebris.PRIORITY.INFRASTRUCTURE)

--- Handle configuration changes (mod updates, etc)
event_manager.subscribe("on_configuration_changed", "lightning_furnace_config_changed", function()
    storage[STORAGE_KEY] = storage[STORAGE_KEY] or 0
    
    -- Recount furnaces from composite storage to ensure accuracy
    local composite_storage = tenebris.composite_entity.storage
    local furnace_composites = composite_storage.get_by_type("lightning-furnace-composite")
    local count = 0
    for _ in pairs(furnace_composites) do
        count = count + 1
    end
    storage[STORAGE_KEY] = count
    
    -- Sync subscriptions with current count
    if count > 0 then
        subscribe_handlers()
    else
        unsubscribe_handlers()
    end
end, tenebris.PRIORITY.INFRASTRUCTURE)

-- Register the composite
tenebris.composite_entity.registry.register({
    name = "lightning-furnace-composite",
    
    entities = {
        -- Interface: the visible furnace (player interacts with this)
        {
            prototype = "tenebris-lightning-furnace",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: lightning collector
        {
            prototype = "tenebris-lightning-collector-hidden",
            interface = false,
            offset = {x = 0, y = 0},
        },
        -- Hidden: electric pole for power distribution
        {
            prototype = "tenebris-lightning-furnace-pole-hidden",
            interface = false,
            offset = {x = 0, y = 0},
        }
    },
    
    hooks = {
        on_created = function(composite_id, entities)
            -- Increment count and subscribe if this is the first furnace
            storage[STORAGE_KEY] = (storage[STORAGE_KEY] or 0) + 1
            if storage[STORAGE_KEY] == 1 then
                subscribe_handlers()
            end
        end,
        
        on_destroyed = function(composite_id, entities)
            -- Decrement count and unsubscribe if this was the last furnace
            storage[STORAGE_KEY] = (storage[STORAGE_KEY] or 1) - 1
            if storage[STORAGE_KEY] <= 0 then
                storage[STORAGE_KEY] = 0
                unsubscribe_handlers()
            end
        end
    }
})

return {}
