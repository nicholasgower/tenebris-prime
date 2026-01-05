--- Quartz Roboport Interface Constants
--- Shared constants for the quartz roboport interface entity.
--- This file has NO runtime dependencies and can be safely required in data.lua.
---
--- @module lib.quartz_roboport_constants

local constants = {}

-- =============================================================================
-- ROBOPORT CONFIGURATION
-- =============================================================================

--- Charging station configuration
constants.CHARGING_STATION_COUNT = 0
constants.CHARGING_ENERGY = "500kW"
constants.CHARGING_DISTANCE = 0
constants.CHARGING_STATION_SHIFT = {0, 0.25}
constants.CHARGING_THRESHOLD_DISTANCE = 0

--- Logistics radius in tiles (base roboport is 25)
constants.LOGISTICS_RADIUS = 20

--- Construction radius in tiles (base roboport is 55)
constants.CONSTRUCTION_RADIUS = 10

--- Energy configuration
constants.ENERGY_USAGE = "100W"
constants.RECHARGE_MINIMUM = "20MJ"

--- Connection configuration
constants.LOGISTICS_CONNECTION_DISTANCE = 20
constants.RADAR_RANGE = 2

return constants

