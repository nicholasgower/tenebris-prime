--- Piezoelectric Generator Constants
--- Shared tier definitions used by both data stage (prototypes) and runtime (scripts).
--- This file has NO runtime dependencies and can be safely required in data.lua.
---
--- @module lib.piezoelectric_constants

local constants = {}

-- =============================================================================
-- GLOBAL SETTINGS (tune these to adjust power output)
-- =============================================================================

--- Fluid configuration for tenebris-heat
constants.FLUID = {
    name = "tenebris-heat",
    -- Heat capacity affects power output: power = fluid/tick × (temp - min_temp) × heat_capacity × 60
    heat_capacity = "4.2kJ",
    -- Temperature the recipe produces fluid at
    output_temperature = 500,
    -- Minimum temperature for generator to consume
    min_temperature = 100,
}

--- Recipe configuration
constants.RECIPE = {
    name = "tenebris-piezoelectric-heating",
    -- Fluid produced per craft cycle (must support highest tier consumption)
    -- Tier 4 uses 10 fluid/tick = 600 fluid/second
    fluid_output = 600,
    -- Time per craft in seconds
    energy_required = 1,
}

--- Tier definitions for piezoelectric generators
--- Each tier represents a different maturity level when capturing quartz ortets.
---
--- @field tier number The tier number (1-4)
--- @field suffix string Entity name suffix (e.g., "-tier-1")
--- @field min_maturity number Minimum growth progress for this tier (0-1)
--- @field max_maturity number Maximum growth progress for this tier (0-1)
--- @field interface_name string Main visible entity name (heat interface)
--- @field generator_name string Hidden generator entity name
--- @field pole_name string Hidden electric pole entity name
--- @field composite_name string Composite registration name
--- @field power_output string Power output as string (e.g., "100MW")
--- @field supply_radius number Electric pole supply radius in tiles (max 64)
--- @field heat_consumption string Heat consumption as string (e.g., "50MW")
--- @field min_working_temp number Minimum temperature for heat interface to work
--- @field fluid_per_tick number Fluid consumption per tick for generator
--- @field energy_usage string Energy usage for heat interface (matches heat_consumption)
constants.TIERS = {
    {
        tier = 1,
        suffix = "-tier-1",
        min_maturity = 0,
        max_maturity = 0.25,
        interface_name = "tenebris-piezoelectric-interface-tier-1",
        generator_name = "tenebris-piezoelectric-generator-hidden-tier-1",
        pole_name = "tenebris-piezoelectric-pole-hidden-tier-1",
        composite_name = "piezoelectric-generator-composite-tier-1",
        power_output = "100MW",
        supply_radius = 40,
        heat_consumption = "50MW",
        min_working_temp = 500,
        fluid_per_tick = 1,
        energy_usage = "50MW",
    },
    {
        tier = 2,
        suffix = "-tier-2",
        min_maturity = 0.25,
        max_maturity = 0.50,
        interface_name = "tenebris-piezoelectric-interface-tier-2",
        generator_name = "tenebris-piezoelectric-generator-hidden-tier-2",
        pole_name = "tenebris-piezoelectric-pole-hidden-tier-2",
        composite_name = "piezoelectric-generator-composite-tier-2",
        power_output = "300MW",
        supply_radius = 50,
        heat_consumption = "150MW",
        min_working_temp = 600,
        fluid_per_tick = 3,
        energy_usage = "150MW",
    },
    {
        tier = 3,
        suffix = "-tier-3",
        min_maturity = 0.50,
        max_maturity = 0.75,
        interface_name = "tenebris-piezoelectric-interface-tier-3",
        generator_name = "tenebris-piezoelectric-generator-hidden-tier-3",
        pole_name = "tenebris-piezoelectric-pole-hidden-tier-3",
        composite_name = "piezoelectric-generator-composite-tier-3",
        power_output = "600MW",
        supply_radius = 56,
        heat_consumption = "300MW",
        min_working_temp = 700,
        fluid_per_tick = 6,
        energy_usage = "300MW",
    },
    {
        tier = 4,
        suffix = "-tier-4",
        min_maturity = 0.75,
        max_maturity = 1.0,
        interface_name = "tenebris-piezoelectric-interface-tier-4",
        generator_name = "tenebris-piezoelectric-generator-hidden-tier-4",
        pole_name = "tenebris-piezoelectric-pole-hidden-tier-4",
        composite_name = "piezoelectric-generator-composite-tier-4",
        power_output = "1GW",
        supply_radius = 64,
        heat_consumption = "500MW",
        min_working_temp = 800,
        fluid_per_tick = 10,
        energy_usage = "500MW",
    },
}

--- Get tier by maturity level
--- @param maturity number Growth progress from 0 to 1
--- @return table tier The tier configuration for this maturity level
function constants.get_tier_by_maturity(maturity)
    for i = #constants.TIERS, 1, -1 do
        local tier = constants.TIERS[i]
        if maturity >= tier.min_maturity then
            return tier
        end
    end
    return constants.TIERS[1]
end

--- Get tier by tier number
--- @param tier_num number The tier number (1-4)
--- @return table|nil tier The tier configuration, or nil if not found
function constants.get_tier(tier_num)
    return constants.TIERS[tier_num]
end

return constants

