-- Ceramic Heat Pipe Variants
-- Experimental heat pipes with different specific_heat and max_transfer values

local meld = require("meld")
local tenebris = require("lib.tenebris")

local base_heat_pipe = data.raw["heat-pipe"]["heat-pipe"]
local ceramic_tint = tenebris.TINT.CERAMIC

-- Helper to apply tint recursively to all sprites (skip shadows and glow)
local function apply_tint_recursive(obj, tint)
    if not obj or type(obj) ~= "table" then return end
    
    -- Apply tint to sprite objects (have filename but aren't shadows/glow)
    if obj.filename and not obj.draw_as_shadow and not obj.draw_as_glow and not obj.draw_as_light then
        obj.tint = tint
    end
    
    -- Recurse into nested tables
    for _, v in pairs(obj) do
        if type(v) == "table" then
            apply_tint_recursive(v, tint)
        end
    end
end

-- Production ceramic heat pipe (based on v6 with normal gradient)
-- High thermal mass (2MJ), extreme transfer (10GW), normal gradient (1)
local ceramic_heat_pipe = meld(table.deepcopy(base_heat_pipe), {
    name = "tenebris-ceramic-plated-heat-pipe",
    icons = {
        {
            icon = "__base__/graphics/icons/heat-pipe.png",
            icon_size = 64,
            tint = ceramic_tint,
        }
    },
    minable = {mining_time = 0.2, result = "tenebris-ceramic-plated-heat-pipe"},
    heat_buffer = meld.overwrite({
        max_temperature = 1000,
        specific_heat = "2MJ",
        max_transfer = "10GW",
        min_temperature_gradient = 1,
        minimum_glow_temperature = 350,
        glow_alpha_modifier = 0.6,
        connections = base_heat_pipe.heat_buffer.connections,
    }),
})

-- Apply ceramic tint to all entity graphics
apply_tint_recursive(ceramic_heat_pipe.connection_sprites, ceramic_tint)
apply_tint_recursive(ceramic_heat_pipe.heat_glow_sprites, ceramic_tint)

data:extend({ceramic_heat_pipe})

