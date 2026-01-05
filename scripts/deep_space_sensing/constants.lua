--- Deep Space Sensing Constants
--- Shared constants for the deep space sensing system.
---
--- @module deep_space_sensing.constants

local constants = {}

--- Scan interval in seconds between discovery attempts
constants.SCAN_INTERVAL_SECONDS = 60

--- Default configuration for discoverable planets
constants.DEFAULT_PLANET_CONFIG = {
    hardness = 1.0,                    -- Multiplier for discovery difficulty (higher = harder)
    base_contribution_scale = 0.10,    -- Per-satellite contribution at distance 0 (10% chance)
    decay_scale = 25,                  -- Distance at which contribution drops to 37% of base
}

--- Default contribution calculation config
constants.DEFAULT_CONTRIBUTION_CONFIG = {
    -- Exponential decay formula: contribution = base_scale * e^(-distance / decay_scale)
    -- With base_scale=0.10 and decay_scale=25:
    --   Distance 0:  10% per satellite
    --   Distance 25: 3.7% per satellite
    --   Distance 50: 1.35% per satellite
    --   Distance 75: 0.5% per satellite
    --   Distance 100: 0.18% per satellite
    base_scale = 0.10,   -- Base contribution per satellite at distance 0 (10%)
    decay_scale = 25,    -- Distance at which contribution drops to 37% of base
}

--- Storage keys used in global storage
constants.STORAGE_KEYS = {
    ORBITAL_SATELLITES = "deep_space_orbital_observation_satellites",
    CONTRIBUTION_PROBABILITIES = "deep_space_orbital_satellite_contribution_probabilities",
    DISCOVERY_TARGETS = "deep_space_discovery_targets",
    LAST_SCAN_TICK = "deep_space_last_scan_tick",
}

--- Technology name that unlocks deep space sensing
constants.UNLOCK_TECHNOLOGY = "deep-space-sensing"

--- GUI element names
constants.GUI = {
    BUTTON_NAME = "planetary_discovery_button",
    FRAME_NAME = "planetary_discovery_frame",
    CONTENT_PANE_NAME = "planetary_discovery_content",
    PREFIX = "planetary_discovery",
}

--- Item name for the observation satellite
constants.OBSERVATION_SATELLITE_ITEM = "observation-satellite"

--- Quality strength multipliers for satellites
--- Higher quality satellites contribute more to discovery chance
--- Indexed by quality level (0-4) for stability across mods
constants.QUALITY_STRENGTH = {
    [0] = 1.0,  -- normal
    [1] = 1.3,  -- uncommon
    [2] = 1.6,  -- rare
    [3] = 1.9,  -- epic
    [4] = 2.5,  -- legendary
}

return constants

