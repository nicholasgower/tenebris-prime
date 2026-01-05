--- Piezoelectric Generator Fluid Transfer
--- Transfers tenebris-heat fluid from the heat interface to the hidden generator.
--- This is needed because the internal fluid boxes at position {0,0} don't auto-connect.
---
--- @module quartz_forest.fluid_transfer

local tenebris = require("lib.tenebris")
local piezo_constants = require("lib.piezoelectric_constants")
local composite_storage = tenebris.composite_entity.storage
local event_manager = tenebris.event_manager

local PRIORITY = tenebris.PRIORITY.GAMEPLAY
local FLUID_NAME = piezo_constants.FLUID.name
local TIERS = piezo_constants.TIERS

-- Run every 5 ticks (12x/second) with scaled transfer amount
local UPDATE_INTERVAL = 5
local TRANSFER_PER_INTERVAL = 50  -- 10 per tick * 5 ticks

--- Transfer fluid from interface to generator for a single tier
--- @param tier table The tier configuration
local function transfer_fluid_for_tier(tier)
    -- Use type-specific lookup for O(n) on this tier only
    local composites = composite_storage.get_by_type(tier.composite_name)
    
    for composite_id, composite in pairs(composites) do
        local interface = composite.entities[tier.interface_name]
        local generator = composite.entities[tier.generator_name]
        
        if not interface or not interface.valid or not generator or not generator.valid then
            goto continue
        end
        
        -- Get fluid from interface's output fluidbox
        local interface_fluidbox = interface.fluidbox
        local generator_fluidbox = generator.fluidbox
        
        if not interface_fluidbox or not generator_fluidbox then
            goto continue
        end
        
        if #interface_fluidbox == 0 or #generator_fluidbox == 0 then
            goto continue
        end
        
        local interface_fluid = interface_fluidbox[1]
        local generator_fluid = generator_fluidbox[1]
        
        if interface_fluid and interface_fluid.name == FLUID_NAME then
            -- Calculate how much to transfer
            local available = interface_fluid.amount
            local generator_current = generator_fluid and generator_fluid.amount or 0
            local generator_capacity = generator_fluidbox.get_capacity(1) or 500
            local space = generator_capacity - generator_current
            
            local transfer_amount = math.min(available, space, TRANSFER_PER_INTERVAL)
            
            if transfer_amount > 0 then
                local temperature = interface_fluid.temperature or 500
                
                -- Update interface: reduce fluid
                local new_interface_amount = interface_fluid.amount - transfer_amount
                if new_interface_amount > 0 then
                    interface_fluidbox[1] = {
                        name = FLUID_NAME,
                        amount = new_interface_amount,
                        temperature = temperature
                    }
                else
                    interface_fluidbox[1] = nil
                end
                
                -- Update generator: add fluid
                local new_generator_amount = generator_current + transfer_amount
                generator_fluidbox[1] = {
                    name = FLUID_NAME,
                    amount = new_generator_amount,
                    temperature = temperature
                }
            end
        end
        
        ::continue::
    end
end

--- Transfer fluid for all piezoelectric tiers
local function transfer_fluid()
    for _, tier in ipairs(TIERS) do
        transfer_fluid_for_tier(tier)
    end
end

-- Run fluid transfer every 5 ticks (12x/second) for balanced performance
event_manager.subscribe_nth_tick(UPDATE_INTERVAL, "piezo_fluid_transfer", function(_)
    transfer_fluid()
end, PRIORITY)

return {}
