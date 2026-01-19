--- Tenebris Prime Tile Effects
--- Defines custom tile-effect prototypes for puddles, water, and liquid metal effects.
--- These must be loaded before tiles that reference them.

local constants = require("lib.constants")
local TILE_COLOR = constants.TILE_COLOR

--#region Lowland Murky Effects

-- Tenebris dark murky water effect (base visual parameters for puddle shader)
local tenebris_murky_water = {
    type = "tile-effect",
    name = "tenebris-murky-water",
    shader = "water",
    water = {
        shader_variation = "wetland-water",
        lightmap_alpha = 0,  -- needed for water mask
        textures = {
            {
                filename = "__space-age__/graphics/terrain/gleba/watercaustics.png",
                width = 512,
                height = 512
            },
            {
                filename = "__space-age__/graphics/terrain/gleba/wetland-dead-skin-shader.png",
                width = 512 * 4,
                height = 512 * 2
            }
        },
        texture_variations_columns = 1,
        texture_variations_rows = 1,
        secondary_texture_variations_columns = 4,
        secondary_texture_variations_rows = 2,
        
        animation_speed = 0.6,  -- Slower, more ominous
        animation_scale = { 0.5, 0.5 },
        tick_scale = 3,
        
        specular_lightness = TILE_COLOR.LOWLAND_SPECULAR,  -- Very dim specular
        foam_color = TILE_COLOR.LOWLAND_FOAM,  -- Dark purple foam
        foam_color_multiplier = 0.4,
        
        dark_threshold = { 0.6, 0.6 },  -- More darkness
        reflection_threshold = { 0.6, 0.6 },
        specular_threshold = { 0.08, 0.12 },  -- Subtle specular
        
        near_zoom = 1 / 16,
        far_zoom = 1 / 16,
    }
}

-- Tenebris dark murky puddle effect (references water effect)
local tenebris_murky_puddle = {
    type = "tile-effect",
    name = "tenebris-murky-puddle",
    shader = "puddle",
    puddle = {
        puddle_noise_texture = {
            filename = "__space-age__/graphics/terrain/gleba/puddle-noise.png",
            size = 512
        },
        water_effect = "tenebris-murky-water"
    }
}

--#endregion

--#region Mercury (Liquid Metal) Effect

-- Mercury uses wetland-water shader - based on Gleba's wetland-grey with silver colors
local tenebris_mercury = {
    type = "tile-effect",
    name = "tenebris-mercury",
    shader = "water",
    water = {
        shader_variation = "wetland-water",
        lightmap_alpha = 0,
        textures = {
            {
                filename = "__space-age__/graphics/terrain/gleba/watercaustics.png",
                width = 512,
                height = 512
            },
            {
                filename = "__space-age__/graphics/terrain/gleba/wetland-dead-skin-shader.png",
                width = 512 * 4,
                height = 512 * 2
            }
        },
        texture_variations_columns = 1,
        texture_variations_rows = 1,
        secondary_texture_variations_columns = 4,
        secondary_texture_variations_rows = 2,
        
        -- Gleba's exact animation settings
        animation_speed = 0.2,
        animation_scale = { 9.4, 6.8 },
        tick_scale = 0.1,
        
        -- Our silver colors
        specular_lightness = TILE_COLOR.MERCURY_SPECULAR,
        foam_color = TILE_COLOR.MERCURY_FOAM,
        foam_color_multiplier = 0.4,
        
        -- Gleba's exact thresholds
        dark_threshold = { 0.5, 0.8 },
        reflection_threshold = { 1, 1 },
        specular_threshold = { 0.09, 0.15 },
        
        near_zoom = 1 / 16,
        far_zoom = 1 / 16,
    }
}

--#endregion

data:extend({
    -- Lowland effects
    tenebris_murky_water,
    tenebris_murky_puddle,
    -- Mercury effect
    tenebris_mercury,
})
