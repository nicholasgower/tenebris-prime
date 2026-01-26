--- Luciferin Flare Entity
--- A bioluminescent fire-type entity that provides light and expires after a set duration

local constants = require("lib.constants")
local bioluminescent = require("lib.bioluminescent")
local meld = require("meld")

local make_bioluminescent_particle = bioluminescent.make_particle

local fire_flame = data.raw["fire"]["fire-flame"]

-- Create bioluminescent particle smoke
data:extend({
    {
        type = "trivial-smoke",
        name = "luciferin-flare-particle",
        animation = {
            filename = "__core__/graphics/light-medium.png",
            priority = "high",
            width  = 300,
            height = 300,
            frame_count = 1,
            scale = 0.06,
            tint = constants.TINT.BIOLUMINESCENT_GLOW,
            draw_as_glow = true,
            blend_mode = "additive",
        },
        duration = 60 * 3,  -- 3 seconds
        fade_in_duration = 30,
        fade_away_duration = 60,
        render_layer = "smoke",
        cyclic = true,
        movement_slow_down_factor = 1.0,  -- No slowdown, maintain speed
        spread_duration = 30,
    },
    {
        type = "trivial-smoke",
        name = "luciferin-flare-particle-stationary",
        animation = {
            filename = "__core__/graphics/light-medium.png",
            priority = "high",
            width = 300,
            height = 300,
            frame_count = 1,
            scale = 0.13,
            tint = constants.TINT.BIOLUMINESCENT_GLOW,
            draw_as_glow = true,
            blend_mode = "additive",
        },
        duration = 60 * 1,  -- 3 seconds
        fade_in_duration = 20,
        fade_away_duration = 20,
        render_layer = "smoke",
        cyclic = true,
        affected_by_wind = false,
        movement_slow_down_factor = 0,
        spread_duration = 30,
    }
})

-- Create our custom fire by melding with the base fire-flame
local luciferin_flare = meld(table.deepcopy(fire_flame), {
    name = "luciferin-flare",
    icon = "__tenebris-prime__/graphics/icons/luciferin.png",
    hidden_in_factoriopedia = true,
    damage_per_tick = {amount = 3, type = "fire"},
    spread_delay = 999999999,  -- Don't spread
    spread_delay_deviation = 0,
    maximum_spread_count = 0,
    lifetime = 60 * 60 * 5,  -- 5 minutes
    initial_lifetime = 60 * 60 * 5,
    fade_in_duration = 30,
    fade_out_duration = 60,
    light = meld.overwrite(
        {intensity = 0.8, size = 28, color = constants.TINT.BIOLUMINESCENT_GLOW}
    ),
    color = constants.TINT.BIOLUMINESCENT_GLOW,
    smoke = meld.overwrite({
        {
            name = "luciferin-flare-particle-stationary", 
            frequency = 2.1, 
            position = {0, 0},
            deviation = {0.7, 0.7},
            starting_vertical_speed = 0, 
            starting_frame_speed = 0, 
            vertical_speed_slowdown = 0
        },
        {
            name = "luciferin-flare-particle", 
            frequency = 1.7, 
            position = {0, 0},
            deviation = {0.4, 0.4},
            starting_vertical_speed = 0.1,  -- Slow upward drift
            vertical_speed_slowdown = 1,
        },
    }),
    on_fuel_added_action = meld.delete(),
    smoke_source_pictures = meld.delete(),
    pictures = meld.delete(),
    burnt_patch_alpha_default = 0.4,
})

data:extend({luciferin_flare})
