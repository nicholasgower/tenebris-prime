--- Quartz Forest Constants
--- Shared constants for quartz forest generation and bud spawning.
--- This file has NO runtime dependencies and can be safely required in data.lua.
---
--- @module lib.quartz_forest_constants

local centipede_constants = require("lib.centipede_constants")

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

constants.TECHNOLOGIES = {
	LUCIFERIN_EXPLOSIVES = "luciferin-explosives",
	LUCIFERIN_KINETICS_1 = "luciferin-kinetics-1",
	LUCIFERIN_KINETICS_2 = "luciferin-kinetics-2",
	LUCIFERIN_KINETICS_3 = "luciferin-kinetics-3",
	LUCIFERIN_KINETICS_4 = "luciferin-kinetics-4",
}

constants.ORTET_DEATH_TO_TECHNOLOGY_UNLOCK_COUNTER_MAP = {
	[constants.TECHNOLOGIES.LUCIFERIN_EXPLOSIVES] = 1,
	[constants.TECHNOLOGIES.LUCIFERIN_KINETICS_1] = 2,
	[constants.TECHNOLOGIES.LUCIFERIN_KINETICS_2] = 6,
	[constants.TECHNOLOGIES.LUCIFERIN_KINETICS_3] = 10,
	[constants.TECHNOLOGIES.LUCIFERIN_KINETICS_4] = 15,
}

constants.ORTET_DEATH_APOCALYPSE_WAVE_MEMBERSHIP = {
	[1] = {
		[centipede_constants.VARIANTS.medium] = 4,
		[centipede_constants.VARIANTS.small] = 9,
		[centipede_constants.VARIANTS.premature] = 18,
	},
	[2] = {
		[centipede_constants.VARIANTS.large] = 1,
		[centipede_constants.VARIANTS.medium] = 6,
		[centipede_constants.VARIANTS.small] = 10,
		[centipede_constants.VARIANTS.premature] = 20,
	},
	[3] = {
		[centipede_constants.VARIANTS.large] = 3,
		[centipede_constants.VARIANTS.medium] = 10,
		[centipede_constants.VARIANTS.small] = 15,
		[centipede_constants.VARIANTS.premature] = 25,
	},
	[4] = {
		[centipede_constants.VARIANTS.large] = 5,
		[centipede_constants.VARIANTS.medium] = 15,
		[centipede_constants.VARIANTS.small] = 25,
		[centipede_constants.VARIANTS.premature] = 35,
	},
	[5] = {
		[centipede_constants.VARIANTS.large] = 8,
		[centipede_constants.VARIANTS.medium] = 20,
		[centipede_constants.VARIANTS.small] = 30,
		[centipede_constants.VARIANTS.premature] = 60,
	},
	[6] = {
		[centipede_constants.VARIANTS.large] = 12,
		[centipede_constants.VARIANTS.medium] = 25,
		[centipede_constants.VARIANTS.small] = 40,
		[centipede_constants.VARIANTS.premature] = 80,
	},
}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

--- Calculate how many buds to spawn based on distance from spawn
--- @param distance number Distance from spawn (0,0)
--- @return number Number of buds to spawn (MIN_COUNT to MAX_COUNT)
function constants.calculate_bud_count(distance)
	local fraction = math.min(1, distance / constants.BUD.MAX_DISTANCE_FOR_SCALING)
	local bud_count = constants.BUD.MIN_COUNT
		+ math.floor(fraction * (constants.BUD.MAX_COUNT - constants.BUD.MIN_COUNT))
	return bud_count
end

return constants
