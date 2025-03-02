data:extend{ --Terra Palus expressions
        {
            type = "noise-expression",
            name = "terrapalus_fertile_spots_coastal_raw",
            expression = "spot_noise{x = x + wobble_noise_x * 15,\z
                                    y = y + wobble_noise_y * 15,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1,\z
                                    candidate_spot_count = 80,\z
                                    suggested_minimum_candidate_point_spacing = 128,\z
                                    skip_span = 1,\z
                                    skip_offset = 0,\z
                                    region_size = 1024,\z
                                    density_expression = 80,\z
                                    spot_quantity_expression = 1000,\z
                                    spot_radius_expression = 32,\z
                                    hard_region_target_quantity = 0,\z
                                    spot_favorability_expression = 60,\z
                                    basement_value = -0.5,\z
                                    maximum_spot_basement_radius = 128}",
            local_expressions = {
                wobble_noise_x = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 3000000, octaves = 2, input_scale = 1/20}",
                wobble_noise_y = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 4000000, octaves = 2, input_scale = 1/20}"
            }
        },
        {
            type = "noise-expression",
            name = "terrapalus_starting_fertile",
            expression = "spot_noise{x = x + wobble_noise_x * 15,\z
                                    y = y + wobble_noise_y * 15,\z
                                    seed0 = map_seed,\z
                                    seed1 = 2,\z
                                    candidate_spot_count = 80,\z
                                    suggested_minimum_candidate_point_spacing = 128,\z
                                    skip_span = 1,\z
                                    skip_offset = 0,\z
                                    region_size = 1024,\z
                                    density_expression = 80,\z
                                    spot_quantity_expression = 1000,\z
                                    spot_radius_expression = 32,\z
                                    hard_region_target_quantity = 0,\z
                                    spot_favorability_expression = 60,\z
                                    basement_value = -0.5,\z
                                    maximum_spot_basement_radius = 128}",
            local_expressions = {
                wobble_noise_x = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 3000000, octaves = 2, input_scale = 1/20}",
                wobble_noise_y = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 4000000, octaves = 2, input_scale = 1/20}"
            }
        },
        {
            type = "noise-expression",
            name = "terrapalus_fertile_spots_coastal",
            expression = "max(min(1, terrapalus_starting_fertile * 4), min(exclude_middle, terrapalus_fertile_spots_coastal_raw) - max(0, -(terrapalus_elevation + 2) / 5) - max(0, (terrapalus_elevation - 10) / 5))",
            local_expressions = {
                exclude_middle = "(distance / terrapalus_starting_area_multiplier / 150) - 2.2"
            }
        },
        {
            type = "noise-expression",
            name = "terrapalus_starting_area_multiplier",
            expression = "0.7"
        },
           -- Autoplace controls for enemy spawners
        {
            type = "autoplace-control",
            name = "gleba-spawner",
            richness = true,
            order = "b[enemy]-c[gleba-spawner]",
            category = "enemy"
        },
        {
            type = "autoplace-control",
            name = "gleba-spawner-small",
            richness = true,
            order = "b[enemy]-d[gleba-spawner-small]",
            category = "enemy"
        },
        -- Basic control expressions
        {
            type = "noise-expression",
            name = "terrapalus_segmentation_multiplier",
            expression = 1
        },
        -- Basic terrain noise for mixing biomes
        {
            type = "noise-expression",
            name = "terrapalus_biome_mix",
            expression = "clamp(multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1, octaves = 3, input_scale = 1/150}, 0, 1)"
        },
        -- Moisture based on Gleba's implementation
        {
            type = "noise-expression",
            name = "terrapalus_moisture",
            expression = "clamp(1 - min(0.25 + (terrapalus_elevation / 80), 0.5 + (terrapalus_elevation - 20) / 400), 0, 1)"
        },
        -- Elevation mixing Nauvis and Gleba patterns
        {
            type = "noise-expression",
            name = "terrapalus_elevation",
            expression = "lerp(nauvis_style, gleba_style, terrapalus_biome_mix)",
            local_expressions = {
                nauvis_style = "100 + 50 * basic_noise",
                gleba_style = "clamp(elevation_value * 0.5 + mud_noise, -1.5, 19.9) + 0.15 * mud_noise",
                basic_noise = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1000000, octaves = 3, input_scale = 1/60}",
                elevation_value = "150",
                mud_noise = "-8 + 16 * gleba_mud_basins"
            }
        },
        -- From Gleba's implementation
        {
            type = "noise-expression",
            name = "gleba_mud_basins",
            expression = "1 - abs(multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1000000, octaves = 3, input_scale = 1/10})"
        },
        {
            type = "noise-expression",
            name = "terrapalus_aux",
            expression = "clamp(0.5 + basic_noise, 0, 1)",
            local_expressions = {
                basic_noise = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1, octaves = 3, input_scale = 1/60}"
            }
        },
        {
            type = "noise-expression",
            name = "terrapalus_temperature",
            expression = "14 + 6 * basic_noise",
            local_expressions = {
                basic_noise = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 2, octaves = 3, input_scale = 1/60}"
            }
        },    
            -- Add starting enemies safe zone expression
            {
                type = "noise-expression",
                name = "terrapalus_starting_enemies_safe",
                expression = "spot_at_angle{angle = terrapalus_starting_angle + 40,\z
                                          distance = 210 * terrapalus_starting_area_multiplier,\z
                                          radius = 30 * terrapalus_starting_area_multiplier,\z
                                          x_distortion = 0.1 * terrapalus_starting_area_multiplier * (terrapalus_wobble_x + terrapalus_wobble_large_x),\z
                                          y_distortion = 0.1 * terrapalus_starting_area_multiplier * (terrapalus_wobble_y + terrapalus_wobble_large_y)}"
            },
            {
                type = "noise-expression",
                name = "terrapalus_starting_angle",
                expression = "map_seed_normalized * 3600"
            },
            {
                type = "noise-expression",
                name = "terrapalus_wobble_x",
                expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 10, octaves = 2, input_scale = 1/8}"
            },
            {
                type = "noise-expression",
                name = "terrapalus_wobble_y",
                expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1010, octaves = 2, input_scale = 1/8}"
            },
            {
                type = "noise-expression",
                name = "terrapalus_wobble_large_x",
                expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 20, octaves = 2, input_scale = 1/2}"
            },
            {
                type = "noise-expression",
                name = "terrapalus_wobble_large_y",
                expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1020, octaves = 2, input_scale = 1/2}"
            },
        
        -- Enemy base control expressions
        {
            type = "noise-expression",
            name = "terrapalus_spawner",
            expression = "max(0.01 * terrapalus_starting_enemies, max(min(0.02, enemy_autoplace_base(0, 8)), min(0.001, terrapalus_fertile_spots_coastal * 5000 - terrapalus_biome_mask_green * 25000)) * (distance > 500 * terrapalus_starting_area_multiplier)) * terrapalus_above_deep_water_mask"
        },
        {
            type = "noise-expression",
            name = "terrapalus_spawner_small",
            expression = "max(0.02 * terrapalus_starting_enemies, 0.02 * terrapalus_starting_enemies_safe, min(0.02, enemy_autoplace_base(0, 8)), min(0.001, terrapalus_fertile_spots_coastal * 5000 - terrapalus_biome_mask_green * 25000)) * terrapalus_above_deep_water_mask * (1 - terrapalus_starting_enemies_safe)"
        },
        {
            type = "noise-expression",
            name = "terrapalus_starting_enemies",
            expression = "spot_noise{x = x + wobble_noise_x * 15,\z
                                    y = y + wobble_noise_y * 15,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1,\z
                                    candidate_spot_count = 80,\z
                                    suggested_minimum_candidate_point_spacing = 128,\z
                                    skip_span = 1,\z
                                    skip_offset = 0,\z
                                    region_size = 1024,\z
                                    density_expression = 80,\z
                                    spot_quantity_expression = 1000,\z
                                    spot_radius_expression = 32,\z
                                    hard_region_target_quantity = 0,\z
                                    spot_favorability_expression = 60,\z
                                    basement_value = -0.5,\z
                                    maximum_spot_basement_radius = 128}",
            local_expressions = {
                wobble_noise_x = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 3000000, octaves = 2, input_scale = 1/20}",
                wobble_noise_y = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 4000000, octaves = 2, input_scale = 1/20}"
            }
        },
        {
            type = "noise-expression",
            name = "terrapalus_above_deep_water_mask",
            expression = "terrapalus_elevation > -10"
        },
        -- Other required expressions for enemy spawning
        {
            type = "noise-expression",
            name = "terrapalus_biome_mask_green",
            expression = "terrapalus_aux > 0.375"
        },
        {
            type = "noise-expression",
            name = "terrapalus_starting_area_multiplier",
            expression = "0.7"
        },
        {
            type = "noise-expression",
            name = "terrapalus_fertile_spots_coastal",
            expression = "max(min(1, terrapalus_starting_fertile * 4), min(exclude_middle, terrapalus_fertile_spots_coastal_raw) - max(0, -(terrapalus_elevation + 2) / 5) - max(0, (terrapalus_elevation - 10) / 5))",
            local_expressions = {
                exclude_middle = "(distance / terrapalus_starting_area_multiplier / 150) - 2.2"
            }
        }
}



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
            elevation = "terrapalus_elevation",
            temperature = "terrapalus_temperature",
            moisture = "terrapalus_moisture",
            aux = "terrapalus_aux",
            -- elevation = "gleba_elevation",
            -- aux = "gleba_aux",
            -- moisture = "gleba_moisture",
            -- temperature = "gleba_temperature",
            cliffiness = "gleba_cliffiness",
            cliff_elevation = "cliff_elevation_from_elevation",
            enemy_base_radius = "gleba_enemy_base_radius",
            enemy_base_frequency = "gleba_enemy_base_frequency",
            ["entity:gleba-spawner:probability"] = "terrapalus_spawner",
            ["entity:gleba-spawner-small:probability"] = "terrapalus_spawner_small",
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
            --["enemy-base"] = {},
            ["gleba-spawner"] = {},
            ["gleba-spawner-small"] = {},
            
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
                    -- ["enemy-base"] = {
                    --     frequency = 1,
                    --     size = 1.4,
                    --     richness = 1.0
                    -- },
                    ["gleba-spawner"] = {
                        frequency = 1,
                        size = 1.4,
                        richness = 1.0
                    },
                    ["gleba-spawner-small"] = {
                        frequency = 1,
                        size = 1.6,
                        richness = 1.0
                    }
                }
            }
        }
    }
end

return tenebris
