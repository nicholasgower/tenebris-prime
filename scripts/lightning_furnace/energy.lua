--- Lightning Furnace Energy Transfer
--- Transfers energy from lightning collector to furnace's internal buffer.
--- Runs periodically to move stored lightning energy from collector buffer to furnace.
--- Subscription is managed dynamically by composite.lua (only active when furnaces exist).

local tenebris = require("lib.tenebris")
local composite_storage = tenebris.composite_entity.storage

local COMPOSITE_TYPE = "lightning-furnace-composite"
local COLLECTOR_ENTITY = tenebris.ENTITY.LIGHTNING_COLLECTOR_HIDDEN
local FURNACE_ENTITY = tenebris.ENTITY.LIGHTNING_FURNACE

--- Energy transfer handler - called every tick when furnaces exist
--- @param event EventData.on_tick
local function on_tick_energy_transfer(event)
    -- Use type-specific lookup for O(n) on lightning furnaces only, not all composites
    local furnace_composites = composite_storage.get_by_type(COMPOSITE_TYPE)
    
    for composite_id, composite in pairs(furnace_composites) do
        local furnace = composite.entities[FURNACE_ENTITY]
        local collector = composite.entities[COLLECTOR_ENTITY]
        
        if not furnace or not furnace.valid or not collector or not collector.valid then
            goto continue
        end
        
        -- Transfer energy from collector to furnace
        if collector.energy > 0 and furnace.energy then
            local transfer_per_tick = 400000  -- 24MW / 60 = 400kW per tick
            local available_energy = collector.energy
            local buffer_space = furnace.electric_buffer_size - furnace.energy
            local transfer_amount = math.min(available_energy, buffer_space, transfer_per_tick)
            
            if transfer_amount > 0 then
                collector.energy = collector.energy - transfer_amount
                furnace.energy = furnace.energy + transfer_amount
            end
        end
        
        -- Apply energy consumption (drain or active crafting)
        if furnace.energy > 0 then
            local consumption_per_tick
            if furnace.is_crafting() then
                -- Active crafting: 10MW base + module effects
                local base_consumption = 10000000  -- 10MW
                local consumption_bonus = furnace.consumption_bonus or 0
                consumption_per_tick = (base_consumption * (1 + consumption_bonus)) / 60
            else
                -- Idle drain: 1MW
                consumption_per_tick = 16666.67  -- 1MW / 60 ticks
            end
            furnace.energy = math.max(0, furnace.energy - consumption_per_tick)
        end
        
        ::continue::
    end
end

-- Export subscription details for dynamic management by composite.lua
return {
    event_id = tenebris.EVENTS.ON_TICK,
    name = "lightning_energy_transfer",
    handler = on_tick_energy_transfer,
    priority = tenebris.PRIORITY.GAMEPLAY
}
