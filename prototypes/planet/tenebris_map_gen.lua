tenebris = function()
    return
    {
        cliff_settings =
        {
            name = "cliff-gleba",
            control = "gleba_cliff",
            cliff_elevation_0 = 40,
            cliff_elevation_interval = 60,
            richness = 0.80,
            cliff_smoothing = 0 -- Not critical but looks better
        },
        property_expression_names =
        {
            elevation = "gleba_elevation",
            aux = "gleba_aux",
            moisture = "gleba_moisture",
            temperature = "gleba_temperature",
            cliffiness = "gleba_cliffiness",
            cliff_elevation = "cliff_elevation_from_elevation",
            enemy_base_radius = "gleba_enemy_base_radius",
            enemy_base_frequency = "gleba_enemy_base_frequency",
            ["entity:stone:richness"] = "gleba_stone_richness",
            ["entity:stone:probability"] = "gleba_stone_probability",

            ["decorative:red-desert-bush:probability"] = "gleba_red_desert_bush_probability",
            ["decorative:white-desert-bush:probability"] = "gleba_white_desert_bush_probability",
            ["decorative:red-pita:probability"] = "gleba_red_pita_probability",
            ["decorative:green-bush-mini:probability"] = "gleba_green_bush_probability",
            ["decorative:green-croton:probability"] = "gleba_green_cronton_probability",
            ["decorative:green-pita:probability"] = "gleba_green_pita_probability",
            ["decorative:green-pita-mini:probability"] = "gleba_green_pita_mini_probability",
            ["decorative:lichen-decal:probability"] = "gleba_orange_lichen_probability",
            ["decorative:shroom-decal:probability"] = "gleba_carpet_shroom_probability",
            ["decorative:cracked-mud-decal:probability"] = "gleba_cracked_mud_probability",
            ["decorative:light-mud-decal:probability"] = "gleba_light_mud_probability",
            ["decorative:dark-mud-decal:probability"] = "gleba_dark_mud_probability",
            ["decorative:green-carpet-grass:probability"] = "gleba_green_carpet_grass_probability",
            ["decorative:green-hairy-grass:probability"] = "gleba_green_hairy_grass_probability"
        },
        autoplace_controls =
        {
            ["tenebris_plants"] = {},
            ["tenebris_enemies"] = {},
            ["quartz_ore"] = {},
            ["gleba_water"] = {},
            ["rocks"] = {},
        },
        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    ["sulfuric-acid-tile"] = {},
                    ["dirt-1"] = {},
                    ["dirt-2"] = {},
                    ["dirt-3"] = {},
                    ["lowland-cream-cauliflower-2"] = {},
                    ["lowland-cream-cauliflower"] = {},
                    ["lowland-dead-skin"] = {},
                    ["lowland-dead-skin-2"] = {},
                }

            },
            ["decorative"] =
            {
                settings =
                {
                    ["light-mud-decal"] = {},
                    ["dark-mud-decal"] = {},
                    ["cracked-mud-decal"] = {},
                    ["lichen-decal"] = {},
                    ["shroom-decal"] = {}
                }
            },
            ["entity"] =
            {
                settings =
                {
                    ["stone"] = {},
                    ["quartz-ore"] = {},
                    ["crude-oil"] = {},
                    ["iron-ore"] = {},
                    ["copper-ore"] = {},
                    ["quartz-node"] = {},
                }
            }
        }
    }
end

return tenebris
