--- Quartz Forest Constants
--- Shared constants for quartz forest generation and bud spawning.
--- This file has NO runtime dependencies and can be safely required in data.lua.
---
--- @module lib.quartz_forest_constants

local constants = {}

-- =============================================================================
-- BUD SPAWNING CONFIGURATION
-- =============================================================================

--- Bud count scaling
constants.BUD = {
    --- Minimum number of buds to spawn around an ortet (at spawn)
    MIN_COUNT = 1,
    --- Maximum number of buds to spawn around an ortet (at max distance)
    MAX_COUNT = 10,
    --- Minimum spacing between buds in tiles
    SPACING = 50,
    --- Minimum distance from ortet center in tiles
    MIN_DISTANCE = 30,
    --- Maximum distance from ortet center in tiles
    MAX_DISTANCE = 150,
    --- Distance from spawn at which max buds are reached
    MAX_DISTANCE_FOR_SCALING = 5000,
    --- Probability (0-1) of successfully spawning a bud when the ortet spawner triggers
    SPAWN_PROBABILITY = 0.04,
    --- Maximum buds an ortet can have at once (captures don't free slots, only destruction does)
    MAX_PER_ORTET = 10,
    --- Radius to search for parent ortet when a bud spawns
    ORTET_SEARCH_RADIUS = 200,
}

-- =============================================================================
-- ENTITY NAMES
-- =============================================================================

constants.ENTITIES = {
    ORTET = "tenebris-quartz-forest-ortet",
    BUD = "tenebris-quartz-ortet-bud",
    BUD_SPAWNER = "tenebris-quartz-ortet-bud-spawner",
}

-- =============================================================================
-- TILE NAMES
-- =============================================================================

constants.TILES = {
    QUARTZ_FOREST = "tenebris-debug-quartz",
}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

--- Calculate how many buds to spawn based on distance from spawn
--- @param distance number Distance from spawn (0,0)
--- @return number Number of buds to spawn (MIN_COUNT to MAX_COUNT)
function constants.calculate_bud_count(distance)
    local fraction = math.min(1, distance / constants.BUD.MAX_DISTANCE_FOR_SCALING)
    local bud_count = constants.BUD.MIN_COUNT + math.floor(fraction * (constants.BUD.MAX_COUNT - constants.BUD.MIN_COUNT))
    return bud_count
end

return constants

