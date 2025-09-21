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
    "research-productivity"
}

for _, tech in pairs(science_to_update) do
    table.insert(data.raw["technology"][tech].unit.ingredients, { "bioluminescent-science-pack", 1 })
    table.insert(data.raw["technology"][tech].prerequisites, "photonic-derangement")
end

table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "sulfuric-acid-tile"); --From ams-acid-landfill