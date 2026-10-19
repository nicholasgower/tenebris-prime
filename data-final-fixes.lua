require("util")

data.raw["cargo-pod"]["cargo-pod"].created_effect = {
    {
        type = "direct",
        action_delivery = {
            type = "delayed",
            delayed_trigger = "cargo-pod-malfunction"
        }
    }
}

data:extend({
    {
        type = "delayed-active-trigger",
        name = "cargo-pod-malfunction",
        delay = 300,
        action =
        {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "script",
                        effect_id = "cargo-pod-spawned"
                    }
                }
            }
        }
    }
})

local science_to_update = {
    "promethium-science-pack",
    "research-productivity"
}

for _, tech in pairs(science_to_update) do
    table.insert(data.raw["technology"][tech].unit.ingredients, { "bioluminescent-science-pack", 1 })
    table.insert(data.raw["technology"][tech].prerequisites, "bioluminescent-science-pack")
end

table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "sulfuric-acid-tile"); --From ams-acid-landfill

require("__tenebris-prime__.prototypes.bioluminescent-final-fixes")
require("__tenebris-prime__.compat.canal-excavator-data-final-fixes")
require("__tenebris-prime__.compat.alien-module")

-- The map generation of Tenebris used the noise expression names of Terra Palus (terrapalus_*), so with Terra Palus
-- installed one planet got the other's terrain. Tenebris has its own tenebris_* names now; the old names stay for
-- the surfaces of older saves, which keep the names they were created with, unless another mod defines them.
for _, suffix in pairs({
    "above_deep_water_mask", "aux", "biome_mask_green", "biome_mix",
    "elevation", "fertile_spots_coastal", "fertile_spots_coastal_raw", "moisture",
    "segmentation_multiplier", "spawner", "spawner_small", "starting_angle",
    "starting_area_multiplier", "starting_enemies", "starting_enemies_safe", "starting_fertile",
    "temperature", "wobble_large_x", "wobble_large_y", "wobble_x",
    "wobble_y",
}) do
    if not data.raw["noise-expression"]["terrapalus_" .. suffix] then
        data:extend({{type = "noise-expression", name = "terrapalus_" .. suffix, expression = "tenebris_" .. suffix}})
    end
end
