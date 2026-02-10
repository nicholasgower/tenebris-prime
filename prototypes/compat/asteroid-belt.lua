--- Compatibility: AsteroidBelt
--- When AsteroidBelt is loaded, adds a dense asteroid zone at 0.6-0.75 on the
--- fulgora-tenebris and maraxsis-tenebris routes to simulate passing through the belt.

if not mods["AsteroidBelt"] then
    return
end

log("[Tenebris Prime] AsteroidBelt detected - adding dense asteroid zone to Tenebris routes")

local tenebris_asteroid_util = require("__tenebris-prime__.prototypes.planet.asteroid-spawn-definitions")

-- Dense asteroid zone configuration (based on AsteroidBelt's belt_base values)
-- These values create a significantly denser asteroid field between 0.6 and 0.75
local BELT_ZONE_START = 0.6
local BELT_ZONE_END = 0.75

-- Belt-density spawn definition for routes passing through the asteroid belt
-- This is a modified version of fulgora_tenebris with a dense zone in the middle
tenebris_asteroid_util.fulgora_tenebris_belt = {
    -- Moderate centipede presence approaching Tenebris
    eggroid_spawns = {
        {name = "centipede-eggroid-small", spawn_points = {
            {distance = 0.3, probability = 0, speed = 0.015},
            {distance = 0.5, probability = 0.0005, speed = 0.015},
            {distance = 0.9, probability = 0.002, speed = 0.015},
        }},
        {name = "centipede-eggroid-medium", spawn_points = {
            {distance = 0.4, probability = 0, speed = 0.012},
            {distance = 0.6, probability = 0.0002, speed = 0.012},
            {distance = 0.9, probability = 0.001, speed = 0.012},
        }},
        {name = "centipede-eggroid-large", spawn_points = {
            {distance = 0.5, probability = 0, speed = 0.01},
            {distance = 0.7, probability = 0.0001, speed = 0.01},
            {distance = 0.9, probability = 0.0005, speed = 0.01},
        }},
    },
    -- Small and medium bismuth asteroids only (no big/huge)
    bismuth_spawns = {
        {name = "small-bismuth-asteroid", spawn_points = {
            {distance = 0.75, probability = 0, speed = 0.02},
            {distance = 0.8, probability = 0.001, speed = 0.02},
            {distance = 0.9, probability = 0.002, speed = 0.02},
        }},
        {name = "medium-bismuth-asteroid", spawn_points = {
            {distance = 0.75, probability = 0, speed = 0.015},
            {distance = 0.8, probability = 0.0005, speed = 0.015},
            {distance = 0.9, probability = 0.001, speed = 0.015},
        }},
    },
    -- Chunk spawns with dense zone at 0.6-0.75
    probability_on_range_chunk = {
        {position = 0.1, probability = tenebris_asteroid_util.fulgora_chunks, angle_when_stopped = tenebris_asteroid_util.chunk_angle},
        {position = 0.55, probability = tenebris_asteroid_util.fulgora_chunks, angle_when_stopped = tenebris_asteroid_util.chunk_angle},
        {position = BELT_ZONE_START, probability = 0.005, angle_when_stopped = tenebris_asteroid_util.chunk_angle},  -- Belt density
        {position = BELT_ZONE_END, probability = 0.005, angle_when_stopped = tenebris_asteroid_util.chunk_angle},    -- Belt density
        {position = 0.8, probability = tenebris_asteroid_util.tenebris_chunks, angle_when_stopped = tenebris_asteroid_util.chunk_angle},
        {position = 0.9, probability = tenebris_asteroid_util.tenebris_chunks, angle_when_stopped = tenebris_asteroid_util.chunk_angle},
    },
    -- Small asteroid spawns with dense zone
    probability_on_range_small = {
        {position = 0.1, probability = 0, angle_when_stopped = tenebris_asteroid_util.small_angle},
        {position = 0.55, probability = 0, angle_when_stopped = tenebris_asteroid_util.small_angle},
        {position = BELT_ZONE_START, probability = 0.004, angle_when_stopped = tenebris_asteroid_util.small_angle},  -- Belt density
        {position = BELT_ZONE_END, probability = 0.004, angle_when_stopped = tenebris_asteroid_util.small_angle},    -- Belt density
        {position = 0.8, probability = 0, angle_when_stopped = tenebris_asteroid_util.small_angle},
        {position = 0.9, probability = 0, angle_when_stopped = tenebris_asteroid_util.small_angle},
    },
    -- Medium asteroid spawns with dense zone
    probability_on_range_medium = {
        {position = 0.1, probability = 0, angle_when_stopped = tenebris_asteroid_util.medium_angle},
        {position = 0.55, probability = 0, angle_when_stopped = tenebris_asteroid_util.medium_angle},
        {position = BELT_ZONE_START, probability = 0.05, angle_when_stopped = tenebris_asteroid_util.medium_angle},  -- Belt density
        {position = BELT_ZONE_END, probability = 0.05, angle_when_stopped = tenebris_asteroid_util.medium_angle},    -- Belt density
        {position = 0.8, probability = 0, angle_when_stopped = tenebris_asteroid_util.medium_angle},
        {position = 0.9, probability = 0, angle_when_stopped = tenebris_asteroid_util.medium_angle},
    },
    -- Big asteroid spawns with dense zone
    probability_on_range_big = {
        {position = 0.1, probability = tenebris_asteroid_util.fulgora_big, angle_when_stopped = tenebris_asteroid_util.huge_angle},
        {position = 0.55, probability = tenebris_asteroid_util.fulgora_big, angle_when_stopped = tenebris_asteroid_util.huge_angle},
        {position = BELT_ZONE_START, probability = 0.01, angle_when_stopped = tenebris_asteroid_util.big_angle},     -- Belt density
        {position = BELT_ZONE_END, probability = 0.01, angle_when_stopped = tenebris_asteroid_util.big_angle},       -- Belt density
        {position = 0.8, probability = tenebris_asteroid_util.tenebris_big, angle_when_stopped = tenebris_asteroid_util.huge_angle},
        {position = 0.9, probability = tenebris_asteroid_util.tenebris_big, angle_when_stopped = tenebris_asteroid_util.huge_angle},
    },
    -- Huge asteroid spawns (normal, no belt zone for huge)
    probability_on_range_huge = {
        {position = 0.1, probability = tenebris_asteroid_util.fulgora_huge, angle_when_stopped = tenebris_asteroid_util.huge_angle},
        {position = 0.9, probability = tenebris_asteroid_util.tenebris_huge, angle_when_stopped = tenebris_asteroid_util.huge_angle},
    },
    type_ratios = {
        {position = 0.1, ratios = tenebris_asteroid_util.fulgora_ratio},
        {position = 0.2, ratios = {4, 5, 1, 0}},
        {position = 0.3, ratios = {5, 6, 2, 0}},
        {position = 0.4, ratios = {6, 7, 2, 0}},
        {position = 0.55, ratios = {9, 9, 2, 0}},
        {position = BELT_ZONE_START, ratios = {6, 8, 5, 0}},  -- Belt zone: balanced with oxide
        {position = BELT_ZONE_END, ratios = {6, 8, 5, 0}},    -- Belt zone: balanced with oxide
        {position = 0.8, ratios = {3, 12, 1, 0}},
        {position = 0.9, ratios = tenebris_asteroid_util.tenebris_ratio},
    },
}

-- Update fulgora-tenebris route if it exists
local fulgora_tenebris = data.raw["space-connection"]["fulgora-tenebris"]
if fulgora_tenebris then
    fulgora_tenebris.asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.fulgora_tenebris_belt)
    log("[Tenebris Prime] Updated fulgora-tenebris with belt asteroid zone")
end

-- Update maraxsis-tenebris route if it exists
local maraxsis_tenebris = data.raw["space-connection"]["maraxsis-tenebris"]
if maraxsis_tenebris then
    maraxsis_tenebris.asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.fulgora_tenebris_belt)
    log("[Tenebris Prime] Updated maraxsis-tenebris with belt asteroid zone")
end

-- Note: paracelsin-tenebris is NOT updated - it uses the normal spawn definition
