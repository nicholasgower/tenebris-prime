--- Quartz Forest Composite Registration
--- Registers composite entities for the quartz forest system:
--- 1. Quartz Ortet Bud - Plant (interface, visible) + Spawner (hidden, handles capture)
--- 2. Piezoelectric Generator tiers - Heat interface + hidden generator + hidden pole

local tenebris = require("lib.tenebris")

-- =============================================================================
-- QUARTZ ORTET BUD COMPOSITE
-- Interface: Plant (visible, player interacts with this)
-- Hidden: Spawner (handles capture rockets)
-- =============================================================================

tenebris.composite_entity.registry.register({
    name = "tenebris-quartz-ortet-bud",
    
    entities = {
        -- Interface: spawner (handles capture rockets)
        {
            prototype = "tenebris-quartz-ortet-bud-spawner",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: visible plant (shows growth animation)
        {
            prototype = "tenebris-quartz-ortet-bud",
            interface = false,
            offset = {x = 0, y = 0},
        },
    },
    
    hooks = {}
})


-- =============================================================================
-- PIEZOELECTRIC GENERATOR COMPOSITES (per tier)
-- Interface: Heat Interface (visible) - player interacts, pipes heat in
-- Hidden: Generator - consumes tenebris-heat fluid, outputs electricity
-- Hidden: Electric Pole - distributes power over isolated network
-- =============================================================================

local TIERS = tenebris.PIEZOELECTRIC.TIERS

for _, tier in ipairs(TIERS) do
    tenebris.composite_entity.registry.register({
        name = tier.composite_name,
        
        entities = {
            -- Interface: the heat interface (visible, player interacts with this)
            {
                prototype = tier.interface_name,
                interface = true,
                offset = {x = 0, y = 0},
            },
            -- Hidden: generator that produces electricity
            {
                prototype = tier.generator_name,
                interface = false,
                offset = {x = 0, y = 0},
            },
            -- Hidden: electric pole for power distribution
            {
                prototype = tier.pole_name,
                interface = false,
                offset = {x = 0, y = 0},
            },
        },
        
        hooks = {
            on_created = function(composite_id, entities)
                log(string.format("[Tenebris] Piezoelectric generator tier %d created",
                    tier.tier))
            end
        }
    })
end

return {}
