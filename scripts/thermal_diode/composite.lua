--- Thermal Diode Composite Registration
--- Registers both steel and ceramic thermal diodes as composite entities.
--- 1x2 design: endpoints swap between closed (single-sided) and open (double-sided).

local tenebris = require("lib.tenebris")
local thermal_diode = require("scripts.thermal_diode.init")

-- Register the steel thermal diode composite
tenebris.composite_entity.registry.register({
    name = "steel-thermal-diode-composite",
    supports_rotation = true,
    supports_flipping = true,
    
    entities = {
        -- Interface: decider combinator (circuit connections + state display)
        {
            prototype = "tenebris-steel-thermal-diode",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: input endpoint (starts closed - north connection for default orientation)
        {
            prototype = "tenebris-steel-thermal-diode-endpoint-closed-n",
            key = "input",
            interface = false,
            offset = {x = 0, y = -0.5},
        },
        -- Hidden: output endpoint (starts closed - south connection for default orientation)
        {
            prototype = "tenebris-steel-thermal-diode-endpoint-closed-s",
            key = "output",
            interface = false,
            offset = {x = 0, y = 0.5},
        },
    },
    
    hooks = {
        on_created = function(composite_id, entities, direction, mirroring)
            thermal_diode.on_diode_created(composite_id, entities, direction, mirroring, "steel")
        end,
        on_destroyed = function(composite_id, entities)
            thermal_diode.on_diode_destroyed(composite_id, entities)
        end,
        on_orientation_changed = function(composite_id, entities, direction, mirroring)
            thermal_diode.on_diode_orientation_changed(composite_id, entities, direction, mirroring, "steel")
        end,
    }
})

-- Register the ceramic thermal diode composite
tenebris.composite_entity.registry.register({
    name = "ceramic-thermal-diode-composite",
    supports_rotation = true,
    supports_flipping = true,
    
    entities = {
        -- Interface: decider combinator (circuit connections + state display)
        {
            prototype = "tenebris-ceramic-thermal-diode",
            interface = true,
            offset = {x = 0, y = 0},
        },
        -- Hidden: input endpoint (starts closed - north connection for default orientation)
        {
            prototype = "tenebris-ceramic-thermal-diode-endpoint-closed-n",
            key = "input",
            interface = false,
            offset = {x = 0, y = -0.5},
        },
        -- Hidden: output endpoint (starts closed - south connection for default orientation)
        {
            prototype = "tenebris-ceramic-thermal-diode-endpoint-closed-s",
            key = "output",
            interface = false,
            offset = {x = 0, y = 0.5},
        },
    },
    
    hooks = {
        on_created = function(composite_id, entities, direction, mirroring)
            thermal_diode.on_diode_created(composite_id, entities, direction, mirroring, "ceramic")
        end,
        on_destroyed = function(composite_id, entities)
            thermal_diode.on_diode_destroyed(composite_id, entities)
        end,
        on_orientation_changed = function(composite_id, entities, direction, mirroring)
            thermal_diode.on_diode_orientation_changed(composite_id, entities, direction, mirroring, "ceramic")
        end,
    }
})

return {}
