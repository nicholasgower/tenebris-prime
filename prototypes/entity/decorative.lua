--- Tenebris Decoratives
--- Decorative entities for Tenebris surface biomes
--- References space-age graphics directly (no copying needed)

local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")
local base_tile_sounds = require("__base__/prototypes/tile/tile-sounds")

-- Tile layer constants
local decal_tile_layer = 255

-- Collision mask helper
local function dec_default_collision()
    return {layers = {doodad = true}, colliding_with_tiles_only = true}
end

-- Helper to create picture arrays from numbered files
local function make_pictures(base_path, suffix, width, height, count, scale, shift)
    local pics = {}
    for i = 1, count do
        local idx = string.format("%02d", i)
        table.insert(pics, {
            filename = base_path .. idx .. suffix,
            width = width,
            height = height,
            scale = scale or 0.5,
            shift = shift or {0, 0},
        })
    end
    return pics
end

-- Cyan tint for highland decoratives (matches lucifunnel glow)
local CYAN_TINT = {r = 0.4, g = 0.9, b = 1.0, a = 1.0}

-- Mercury/silver tint for mercury shore decoratives
local MERCURY_TINT = {r = 0.7, g = 0.7, b = 0.75, a = 1.0}

-- Purple tint for lowland decoratives
local PURPLE_TINT = {r = 0.6, g = 0.5, b = 0.7, a = 1.0}

-- =============================================================================
-- LOWLAND DECORATIVES (near lichen deposits, wet areas)
-- =============================================================================

-- Nerve roots - organic veiny patterns for lowlands
local tenebris_nerve_roots = {
    name = "tenebris-nerve-roots",
    type = "optimized-decorative",
    order = "t[tenebris]-a[lowland]-a[nerve-roots]",
    collision_box = {{-2.5, -2.5}, {2.5, 2.5}},
    collision_mask = dec_default_collision(),
    walking_sound = base_tile_sounds.walking.plant,
    render_layer = "decals",
    tile_layer = decal_tile_layer - 1,
    autoplace = {
        tile_restriction = {"tenebris-debug-lowlands"},
        probability_expression = "trpi(0.02)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-01.png",
            width = 1536,
            height = 990,
            shift = {0, -0.25},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-02.png",
            width = 1536,
            height = 990,
            shift = {0, -0.25},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-03.png",
            width = 1536,
            height = 990,
            shift = {0, -0.25},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/nerve-roots/nerve-root-dense-04.png",
            width = 1536,
            height = 990,
            shift = {0, -0.25},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
    }
}

-- Wispy lichen near lichen deposits
local tenebris_wispy_lichen = {
    name = "tenebris-wispy-lichen",
    type = "optimized-decorative",
    order = "t[tenebris]-a[lowland]-b[wispy-lichen]",
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    collision_mask = dec_default_collision(),
    render_layer = "decorative",
    walking_sound = base_tile_sounds.walking.small_bush,
    autoplace = {
        tile_restriction = {"tenebris-debug-lowlands"},
        placement_density = 2,
        probability_expression = "trpi(0.08)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/wispy-lichen/wispy-lichen-00.png",
            width = 120,
            height = 80,
            shift = {0.08, -0.06},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/wispy-lichen/wispy-lichen-01.png",
            width = 130,
            height = 95,
            shift = {0.02, -0.09},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/wispy-lichen/wispy-lichen-02.png",
            width = 122,
            height = 76,
            shift = {0, 0.02},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/wispy-lichen/wispy-lichen-03.png",
            width = 121,
            height = 75,
            shift = {0.09, -0.01},
            scale = 0.5,
            tint = PURPLE_TINT,
        },
    }
}

-- =============================================================================
-- MERCURY SHORE DECORATIVES (around mercury pools)
-- =============================================================================

-- Calcite-like mineral stains around mercury
local tenebris_mercury_stain = {
    name = "tenebris-mercury-stain",
    type = "optimized-decorative",
    order = "t[tenebris]-b[mercury]-a[stain]",
    collision_box = {{-3, -3}, {3, 3}},
    collision_mask = dec_default_collision(),
    render_layer = "decals",
    tile_layer = decal_tile_layer - 6,
    autoplace = {
        probability_expression = "tenebris_mercury_shore_mask * 0.1"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-01.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-02.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-03.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/calcite-stain/calcite-stain-04.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
    }
}

-- Stunted coral around mercury (already grey, minimal tint)
local tenebris_mercury_coral = {
    name = "tenebris-mercury-coral",
    type = "optimized-decorative",
    order = "t[tenebris]-b[mercury]-b[coral]",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = dec_default_collision(),
    render_layer = "decorative",
    autoplace = {
        tile_restriction = {"tenebris-mercury-tile"},
        probability_expression = "trpi(0.04)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-01.png",
            width = 86,
            height = 79,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-02.png",
            width = 75,
            height = 71,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-03.png",
            width = 64,
            height = 56,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
        {
            filename = "__space-age__/graphics/decorative/coral-stunted-grey/coral-stunted-grey-04.png",
            width = 45,
            height = 39,
            scale = 0.5,
            tint = MERCURY_TINT,
        },
    }
}

-- =============================================================================
-- HIGHLAND DECORATIVES (lucifunnel habitat, elevated terrain)
-- =============================================================================

-- Curly roots with cyan tint (matches lucifunnel glow)
local tenebris_highland_roots = {
    name = "tenebris-highland-roots",
    type = "optimized-decorative",
    order = "t[tenebris]-c[highland]-a[roots]",
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = dec_default_collision(),
    walking_sound = base_tile_sounds.walking.plant,
    render_layer = "decals",
    tile_layer = decal_tile_layer - 1,
    autoplace = {
        tile_restriction = {"tenebris-debug-highlands", "tenebris-debug-quartz"},
        probability_expression = "trpi(0.03)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-01.png",
            width = 1257,
            height = 1257,
            scale = 0.45,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-02.png",
            width = 1257,
            height = 1257,
            scale = 0.45,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-03.png",
            width = 1257,
            height = 1257,
            scale = 0.45,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-04.png",
            width = 1257,
            height = 1257,
            scale = 0.45,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/curly-root-grey/curly-root-grey-05.png",
            width = 1257,
            height = 1257,
            scale = 0.45,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
    }
}

-- Mycelium network with cyan tint
local tenebris_mycelium = {
    name = "tenebris-mycelium",
    type = "optimized-decorative",
    order = "t[tenebris]-c[highland]-b[mycelium]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = dec_default_collision(),
    walking_sound = base_tile_sounds.walking.plant,
    render_layer = "decals",
    tile_layer = decal_tile_layer - 1,
    autoplace = {
        tile_restriction = {"tenebris-debug-highlands", "tenebris-debug-quartz"},
        probability_expression = "trpi(0.03)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/mycelium/mycelium-01.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/mycelium/mycelium-02.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/mycelium/mycelium-03.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
        {
            filename = "__space-age__/graphics/decorative/mycelium/mycelium-04.png",
            width = 512,
            height = 512,
            scale = 0.5,
            tint = CYAN_TINT,
            draw_as_glow = true,
        },
    }
}

-- =============================================================================
-- WASTES DECORATIVES (barren, dusty terrain)
-- =============================================================================

-- Cracked mud decals for wastes
local tenebris_cracked_mud = {
    name = "tenebris-cracked-mud",
    type = "optimized-decorative",
    order = "t[tenebris]-d[wastes]-a[cracked-mud]",
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = dec_default_collision(),
    render_layer = "decals",
    tile_layer = decal_tile_layer - 2,
    autoplace = {
        tile_restriction = {"tenebris-debug-wastes"},
        probability_expression = "trpi(0.015)"
    },
    pictures = {
        {
            filename = "__space-age__/graphics/decorative/grey-cracked-mud-decal/grey-cracked-mud-decal-00.png",
            width = 474,
            height = 337,
            scale = 0.5,
        },
        {
            filename = "__space-age__/graphics/decorative/grey-cracked-mud-decal/grey-cracked-mud-decal-01.png",
            width = 473,
            height = 265,
            scale = 0.5,
        },
        {
            filename = "__space-age__/graphics/decorative/grey-cracked-mud-decal/grey-cracked-mud-decal-02.png",
            width = 473,
            height = 267,
            scale = 0.5,
        },
        {
            filename = "__space-age__/graphics/decorative/grey-cracked-mud-decal/grey-cracked-mud-decal-03.png",
            width = 432,
            height = 243,
            scale = 0.5,
        },
    }
}

data:extend({
    -- Lowlands
    tenebris_nerve_roots,
    tenebris_wispy_lichen,
    -- Mercury shores
    tenebris_mercury_stain,
    tenebris_mercury_coral,
    -- Highlands
    tenebris_highland_roots,
    tenebris_mycelium,
    -- Wastes
    tenebris_cracked_mud,
})
