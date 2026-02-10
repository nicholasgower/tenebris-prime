--- Phase 1 Tenebris Fluids
--- Clean redesign of all fluids for the Tenebris planet

local meld = require("meld")

data:extend({
    -- ========================================
    -- ATMOSPHERIC FLUIDS
    -- ========================================
    {
        type = "fluid",
        name = "tenebris-atmosphere",
        icon = "__tenebris-prime__/graphics/icons/fluid/tenebris-atmosphere.png",
        icon_size = 64,
        subgroup = "tenebris-fluids",
        order = "a[atmosphere]",
        default_temperature = 30,
        max_temperature = 100,
        heat_capacity = "1kJ",
        base_flow_rate = data.raw.fluid.steam.base_flow_rate,
        base_color = {1, 1, 1},
        flow_color = {0.5, 0.5, 1},
        gas_temperature = 25,
    },
    
    -- ========================================
    -- WASTE FLUIDS
    -- ========================================
    {
        type = "fluid",
        name = "tenebris-sulfinated-spore-waste",
        icon = "__tenebris-prime__/graphics/icons/fluid/sulfuric-waste-water.png",
        icon_size = 64,
        subgroup = "tenebris-fluids",
        order = "b[waste]",
        default_temperature = 15,
        max_temperature = 100,
        heat_capacity = "0.2kJ",
        base_color = {0.2, 0.15, 0.1},
        flow_color = {0.4, 0.3, 0.2},
        auto_barrel = false
    },
    
    -- ========================================
    -- MERCURY CHAIN
    -- ========================================
    {
        type = "fluid",
        name = "tenebris-mercury",
        subgroup = "tenebris-fluids",
        order = "c[mercury]",
        default_temperature = 15,
        max_temperature = 700,
        base_color = { 0.678, 0.659, 0.647 },
        flow_color = { 0.694, 0.678, 0.678 },
        icon = "__tenebris-prime__/graphics/icons/fluid/mercury.png",
        icon_size = 64,
        icon_mipmaps = 4,
        auto_barrel = false
    },
    
    -- ========================================
    -- ACIDS & PROCESSING FLUIDS
    -- ========================================
    {
        type = "fluid",
        name = "tenebris-hydrofluoric-acid",
        icon = "__tenebris-prime__/graphics/icons/fluid/molecule-hydrofluoric-acid.png",
        icon_size = 64,
        subgroup = "tenebris-fluids",
        order = "d[acid]",
        default_temperature = 15,
        max_temperature = 100,
        heat_capacity = "0.2kJ",
        base_color = {0.7, 0.9, 0.9},
        flow_color = {0.8, 1, 1},
        auto_barrel = false
    },
    {
        type = "fluid",
        name = "tenebris-quartz-slurry",
        icon = "__tenebris-prime__/graphics/icons/fluid/quartz-slurry.png",
        icon_size = 64,
        subgroup = "tenebris-fluids",
        order = "e[slurry]",
        default_temperature = 15,
        max_temperature = 100,
        heat_capacity = "0.2kJ",
        base_color = {0.8, 0.8, 0.85},
        flow_color = {0.9, 0.9, 0.95},
        auto_barrel = false
    },
    
    -- ========================================
    -- MOLTEN METALS
    -- ========================================
    {
        type = "fluid",
        name = "tenebris-molten-bismuth",
        icon = "__space-age__/graphics/icons/fluid/molten-iron.png", -- Placeholder
        icon_size = 64,
        default_temperature = 1000,
        max_temperature = 1000,
        heat_capacity = "1kJ",
        subgroup = "tenebris-fluids",
        order = "f[molten]",
        base_color = {r = 0.6, g = 0.5, b = 0.7},
        flow_color = {r = 0.8, g = 0.7, b = 0.9}
    },
    
    -- ========================================
    -- SPECIAL FLUIDS (TODO: Will be replaced)
    -- ========================================
    -- Piezoelectric heat transfer fluid (uses centralized constants)
    (function()
        local piezo = require("lib.piezoelectric_constants")
        return meld(table.deepcopy(data.raw["fluid"]["steam"]), {
            name = piezo.FLUID.name,
            icon = "__core__/graphics/arrows/heat-exchange-indication.png",
            icon_size = 48,
            heat_capacity = piezo.FLUID.heat_capacity,
            hidden = true,
            hidden_in_factoriopedia = true,
        })
    end)(),
})
