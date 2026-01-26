--- Bioluminescent particle and light helpers
--- Shared between data stage prototypes

local constants = require("lib.constants")
local TINT = constants.TINT

local bioluminescent = {}

--- Creates a bioluminescent particle visualisation with irrational period
---@param position table Position offset {x, y}
---@param period number Period in ticks (use irrational values like 100 * math.pi)
---@param scale_range table {begin_scale, end_scale}
---@param offset_range number Max offset in x/y
---@param speed_multiplier number Multiplier for movement speeds (default 1)
---@param anim_scale number|nil Animation scale (default 0.15)
function bioluminescent.make_particle(position, period, scale_range, offset_range, speed_multiplier, anim_scale)
    speed_multiplier = speed_multiplier or 1
    anim_scale = anim_scale or 0.15
    return {
        count = 1,
        offset_x = { -offset_range, offset_range },
        offset_y = { -offset_range, offset_range },
        positions = { position },
        render_layer = "object",
        probability = 0.8,
        period = period,
        fade_in_progress_duration = 0.3,
        fade_out_progress_duration = 0.7,
        begin_scale = scale_range[1],
        end_scale = scale_range[2],
        speed_x = { -0.004 * speed_multiplier, 0.004 * speed_multiplier },
        speed_y = { -0.006 * speed_multiplier, 0.001 * speed_multiplier },
        speed_z = { 0.005 * speed_multiplier, 0.015 * speed_multiplier },
        movement_slowdown_factor_x = 0.98,
        movement_slowdown_factor_y = 0.98,
        movement_slowdown_factor_z = 0.9995,
        animation = {
            filename = "__core__/graphics/light-medium.png",
            width = 300,
            height = 300,
            frame_count = 1,
            scale = anim_scale,
            tint = TINT.BIOLUMINESCENT_GLOW,
            blend_mode = "additive",
            draw_as_glow = true,
        },
    }
end

--- Creates a static flickering ambient light for bioluminescent plants
---@param size number Light radius
---@param intensity number Light intensity
function bioluminescent.make_light(size, intensity)
    return {
        count = 1,
        positions = {{ 0, -0.3 }},
        render_layer = "object",
        age_discrimination = -10,  -- Randomize phase per entity to desync plants
        light = {
            intensity = intensity,
            size = size,
            color = TINT.BIOLUMINESCENT_LIGHT,
            flicker_interval = 90,
            flicker_min_modifier = 0.5,
            flicker_max_modifier = 1.0,
        },
    }
end

return bioluminescent
