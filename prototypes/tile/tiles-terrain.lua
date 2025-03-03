


-- local muluna_dirt_base=table.deepcopy(data.raw["tile"]["lowland-cream-cauliflower"])

-- local color={
--     {55,55,55},
--     {50,50,50},
--     {45,45,45},
--     {60,60,60},
--     {70,70,70},
--     {80,80,80},
-- }

-- for i = 1,2,1 do
--     local muluna_dirt=table.deepcopy(muluna_dirt_base)
--     muluna_dirt.name="tenebris-blue-grass-"..tostring(i)
--     muluna_dirt.autoplace = {probability_expression = 'expression_in_range_base(0.45, -10, 0.55, 0.35) + 0.25*noise_layer_noise('..tostring(i)..')'}
--     muluna_dirt.localised_name={"tile-name.tenebris-blue-grass",tostring(i)}
--     muluna_dirt.variants = tile_variations_template(
--     "__alien-biomes-graphics__/graphics/terrain/vegetation-green-grass-"..tostring(i)..".png", "__base__/graphics/terrain/masks/transition-1.png",
--     {
   
--       max_size = 4,
--       [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
--       [2] = { probability = 1, weights = {0.070, 0.070, 0.025, 0.070, 0.070, 0.070, 0.007, 0.025, 0.070, 0.050, 0.015, 0.026, 0.030, 0.005, 0.070, 0.027 }, },
--       [4] = { probability = 1.00, weights = {0.070, 0.070, 0.070, 0.070, 0.070, 0.070, 0.015, 0.070, 0.070, 0.070, 0.015, 0.050, 0.070, 0.070, 0.065, 0.070 }, },
--       --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} }
--     }
    
   
    
--   )
--   muluna_dirt.layer=19+i
--   muluna_dirt.map_color=color[i] 
--   data:extend{muluna_dirt}
-- end

-- for i = 1,6,1 do
--     local muluna_dirt=table.deepcopy(muluna_dirt_base)
--     muluna_dirt.name="tenebris-violet-grass-"..tostring(i)
--     muluna_dirt.autoplace = {probability_expression = 'expression_in_range_base(0.45, -10, 0.55, 0.35) + 0.25*noise_layer_noise('..tostring(i)..')'}
--     muluna_dirt.localised_name={"tile-name.tenebris-blue-grass",tostring(i)}
--     muluna_dirt.variants = tile_variations_template(
--     "__alien-biomes-graphics__/graphics/terrain/vegetation-purple-dirt-"..tostring(i)..".png", "__base__/graphics/terrain/masks/transition-1.png",
--     {
   
--       max_size = 4,
--       [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
--       [2] = { probability = 1, weights = {0.070, 0.070, 0.025, 0.070, 0.070, 0.070, 0.007, 0.025, 0.070, 0.050, 0.015, 0.026, 0.030, 0.005, 0.070, 0.027 }, },
--       [4] = { probability = 1.00, weights = {0.070, 0.070, 0.070, 0.070, 0.070, 0.070, 0.015, 0.070, 0.070, 0.070, 0.015, 0.050, 0.070, 0.070, 0.065, 0.070 }, },
--       --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} }
--     }
    
   
    
--   )
--   muluna_dirt.layer=19+i
--   muluna_dirt.map_color=color[i]
--   data:extend{muluna_dirt}
-- end





