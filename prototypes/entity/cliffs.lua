-- Tenebris Cliffs
-- Uses Vulcanus cliff graphics with custom name

require("util")

-- scaled_cliff is defined in base/prototypes/entity/entity-util.lua
data:extend{
    scaled_cliff({
        mod_name = "__space-age__",  -- Vulcanus graphics are in space-age
        name = "cliff-tenebris",
        map_color = {80, 70, 90},  -- Darker purple-grey for Tenebris
        suffix = "vulcanus",       -- Use Vulcanus cliff sprites
        subfolder = "vulcanus",
        scale = 1.0,
        has_lower_layer = true,
        sprite_size_multiplier = 2,
    })
}

