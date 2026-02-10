--- Lightning Furnace Energy Display
--- Shows energy level as floating text above the furnace
--- Displays the hidden collector's energy buffer (where lightning strikes)
--- Subscription is managed dynamically by composite.lua (only active when furnaces exist).

local tenebris = require("lib.tenebris")
local composite_storage = tenebris.composite_entity.storage

local COLLECTOR_ENTITY = tenebris.ENTITY.LIGHTNING_COLLECTOR_HIDDEN
local FURNACE_ENTITY = tenebris.ENTITY.LIGHTNING_FURNACE
local COMPOSITE_TYPE = "lightning-furnace-composite"

--- Display update handler - called every 2 seconds when furnaces exist
--- @param event NthTickEventData
local function on_nth_tick_display(event)
    -- Use type-specific lookup for efficiency
    local furnace_composites = composite_storage.get_by_type(COMPOSITE_TYPE)
    
    for composite_id, composite in pairs(furnace_composites) do
        local furnace = composite.entities[FURNACE_ENTITY]
        local collector = composite.entities[COLLECTOR_ENTITY]
        
        if not furnace or not furnace.valid or not collector or not collector.valid then
            goto continue
        end
        
        -- Show collector's energy (where lightning strikes accumulate)
        if collector.energy and collector.electric_buffer_size then
            local collector_energy_mj = collector.energy / 1000000
            local collector_capacity_mj = collector.electric_buffer_size / 1000000
            local collector_percentage = (collector.energy / collector.electric_buffer_size) * 100
            
            -- Also show furnace buffer
            local furnace_energy_mj = furnace.energy and (furnace.energy / 1000000) or 0
            local furnace_capacity_mj = furnace.electric_buffer_size and (furnace.electric_buffer_size / 1000000) or 0
            
            -- Display both buffers
            local text = string.format(
                "⚡ Lightning: %.1f / %.0f MJ (%.0f%%)\n🔥 Furnace: %.1f / %.0f MJ",
                collector_energy_mj, collector_capacity_mj, collector_percentage,
                furnace_energy_mj, furnace_capacity_mj
            )
            
            -- Display the text above the entity
            furnace.surface.create_entity({
                name = "flying-text",
                position = {furnace.position.x, furnace.position.y - 2.5},
                text = text,
                color = {r = 0.5, g = 0.7, b = 1.0}  -- Light blue
            })
        end
        
        ::continue::
    end
end

-- Export subscription details for dynamic management by composite.lua
return {
    tick_interval = 2 * tenebris.TICKS.PER_SECOND,
    name = "lightning_furnace_display",
    handler = on_nth_tick_display,
    priority = tenebris.PRIORITY.UI
}
