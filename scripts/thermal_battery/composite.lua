--- Thermal Battery Composite Registration
--- Registers the thermal battery as a composite entity for GUI support.

local tenebris = require("lib.tenebris")

-- Register the composite (single reactor entity)
tenebris.composite_entity.registry.register({
    name = "thermal-battery-composite",
    
    entities = {
        -- Single reactor entity handles everything: visuals, heat buffer, circuits
        {
            prototype = "tenebris-thermal-battery",
            interface = true,
            offset = {x = 0, y = 0},
        },
    },
    
    hooks = {}
})

return {}
