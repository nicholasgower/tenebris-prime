--- Tenespace Ambient Effects
--- Defines smoke/particle effects for space platforms traveling in tenespace routes.

local smoke_animations = require("__base__.prototypes.entity.smoke-animations")

--- Cyan bioluminescent dots
--- Small scattered light points that fade in and out gently
local cyan_glow_smoke = {
    type = "trivial-smoke",
    name = "tenespace-cyan-glow",
    duration = 480,
    fade_in_duration = 180,         -- Gentle fade-in (~3s)
    fade_away_duration = 250,       -- Slow fade-out (~4s)
    spread_duration = 300,
    start_scale = 0.15,             -- Small dot
    end_scale = 0.3,                -- Stays small
    color = {r = 0.4, g = 1.0, b = 1.0, a = 0.8},
    cyclic = true,
    affected_by_wind = false,
    render_layer = "air-object",
    movement_slow_down_factor = 0.995,
    animation = {
        filename = "__core__/graphics/light-medium.png",
        priority = "high",
        width = 300,
        height = 300,
        frame_count = 1,
        scale = 0.15,
        tint = {r = 0.4, g = 1.0, b = 1.0, a = 0.8},
        blend_mode = "additive",
    },
    glow_fade_away_duration = 300
}

--- Slightly brighter cyan dot
--- A bit larger and brighter but still small
local cyan_glow_bright = {
    type = "trivial-smoke",
    name = "tenespace-cyan-glow-bright",
    duration = 600,
    fade_in_duration = 200,         -- Gentle fade-in
    fade_away_duration = 350,       -- Slow fade
    spread_duration = 400,
    start_scale = 0.2,              -- Slightly larger dot
    end_scale = 0.5,                -- Grows a bit
    color = {r = 0.5, g = 1.0, b = 1.0, a = 0.9},
    cyclic = true,
    affected_by_wind = false,
    render_layer = "air-object",
    movement_slow_down_factor = 0.998,
    animation = {
        filename = "__core__/graphics/light-medium.png",
        priority = "high",
        width = 300,
        height = 300,
        frame_count = 1,
        scale = 0.2,
        tint = {r = 0.5, g = 1.0, b = 1.0, a = 1.0},
        blend_mode = "additive",
    },
    glow_fade_away_duration = 400
}

--- Thick black tenecap spore clouds
--- Dense, dark particles with soft alpha blending - darker RGB to compensate for lower alpha
local spore_cloud_small = {
    type = "trivial-smoke",
    name = "tenespace-spore-cloud-small",
    duration = 1800,
    fade_in_duration = 600,
    fade_away_duration = 900,
    spread_duration = 1200,
    start_scale = 150,
    end_scale = 300,
    color = {r = 0.01, g = 0.01, b = 0.02, a = 0.6},  -- Very dark, stronger alpha
    cyclic = true,
    affected_by_wind = false,
    render_layer = "air-object",
    movement_slow_down_factor = 0.995,
    animation = {
        width = 152,
        height = 120,
        line_length = 5,
        frame_count = 60,
        shift = {-0.53125, -0.4375},
        priority = "high",
        animation_speed = 0.02,  -- Slower animation
        filename = "__base__/graphics/entity/smoke/smoke.png",
        tint = {r = 0.02, g = 0.02, b = 0.03, a = 0.65},  -- Nearly black
        blend_mode = "normal",
        flags = { "smoke" }
    }
}

--- Large rolling spore clouds for dramatic effect
local spore_cloud_large = {
    type = "trivial-smoke",
    name = "tenespace-spore-cloud-large",
    duration = 3600,
    fade_in_duration = 1200,
    fade_away_duration = 1800,
    spread_duration = 2400,
    start_scale = 200,
    end_scale = 600,
    color = {r = 0.005, g = 0.005, b = 0.01, a = 0.65},  -- Nearly pure black
    cyclic = true,
    affected_by_wind = false,
    render_layer = "air-object",
    movement_slow_down_factor = 0.998,
    animation = {
        width = 152,
        height = 120,
        line_length = 5,
        frame_count = 60,
        shift = {-0.53125, -0.4375},
        priority = "high",
        animation_speed = 0.01,  -- Even slower animation
        filename = "__base__/graphics/entity/smoke/smoke.png",
        tint = {r = 0.01, g = 0.01, b = 0.015, a = 0.7},  -- Nearly black
        blend_mode = "normal",
        flags = { "smoke" }
    }
}

--- Wisps - thin tendrils that snake through the void
local spore_wisp = {
    type = "trivial-smoke",
    name = "tenespace-spore-wisp",
    duration = 1200,
    fade_in_duration = 400,
    fade_away_duration = 600,
    spread_duration = 800,
    start_scale = 50,
    end_scale = 250,
    color = {r = 0.02, g = 0.02, b = 0.03, a = 0.55},  -- Very dark
    cyclic = true,
    affected_by_wind = false,
    render_layer = "air-object",
    movement_slow_down_factor = 0.98,
    animation = {
        filename = "__base__/graphics/entity/smoke-fast/smoke-fast.png",
        priority = "high",
        width = 50,
        height = 50,
        frame_count = 16,
        animation_speed = 0.008,  -- Slower animation
        scale = 0.6,
        tint = {r = 0.03, g = 0.03, b = 0.04, a = 0.6},  -- Very dark
        blend_mode = "normal",
        flags = { "smoke" }
    }
}

data:extend({
    cyan_glow_smoke,
    cyan_glow_bright,
    spore_cloud_small,
    spore_cloud_large,
    spore_wisp,
})

