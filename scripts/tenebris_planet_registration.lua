--- Tenebris Planet Registration
--- Registers discoverable targets via deep space sensing.
--- This file decouples the planet data from the deep_space_sensing library.
---
--- @module tenebris_planet_registration

local tenebris = require("lib.tenebris")
local deep_space_sensing = require("scripts.deep_space_sensing.init")

local registration = {}

--- Discoverable planet/region configurations
--- Hardness is a difficulty multiplier (1.0 = normal, higher = harder to discover)
local DISCOVERABLE_CONFIGS = {
    {
        planet_name = tenebris.SPACE_LOCATION.TENEBRIS,
        display_name = "Tenebris",
        tech_name = "planet-discovery-tenebris",
        hardness = 6.0,
    },
    {
        planet_name = tenebris.SPACE_LOCATION.IRIDESCENT_RIVER,  -- Reference point for distance calculations
        display_name = "Tenespace",
        tech_name = "deep-space-discovery-tenespace",
        hardness = 22.0,
    },
    {
        planet_name = tenebris.SPACE_LOCATION.LIGHTLESS_GATEWAY,  -- Reference point for distance calculations
        display_name = "Lightless Abyss",
        tech_name = "deep-space-discovery-lightless-abyss",
        hardness = 67.0,
    },
}

--- Registers all discoverable planets with the deep space sensing system
--- Call this during control.lua initialization
function registration.register()
    local all_success = true
    
    for _, config in ipairs(DISCOVERABLE_CONFIGS) do
        local success, err = deep_space_sensing.register_discoverable_planet(config)
        
        if not success then
            log("[Tenebris] Failed to register " .. config.planet_name .. " for discovery: " .. tostring(err))
            all_success = false
        end
    end
    
    return all_success
end

--- Gets all discoverable configurations (for inspection/debugging)
--- @return table configs All discoverable planet configurations
function registration.get_configs()
    return DISCOVERABLE_CONFIGS
end

return registration

