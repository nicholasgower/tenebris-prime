-- Tenebris Biome System
-- 
-- Biome Hierarchy:
--   Layer 1 (base): Desolate Wastes (default)
--   Layer 2 (elevation): Lucifunnel Highlands (high) / Tenecap Lowlands (low)
--   Layer 3 (spots): Quartz Forests, Mercury Pools, Sulfuric Geysers
--   Layer 4 (override): Abyssal Gashes (impassable trenches)
--
-- Starting area: Desolate Wastes, minimum 5000 tiles from abyssal gashes

data:extend{
    --------------------------------------------------------------------------------
    -- Autoplace Controls
    --------------------------------------------------------------------------------
    {
        type = "autoplace-control",
        name = "tenebris_exposed_lichen_deposit",
        richness = true,
        order = "b[resource]-t[tenebris]-a",
        category = "resource"
    },
    {
        type = "autoplace-control",
        name = "tenebris_plants",
        order = "b[decorative]-t[tenebris]-a",
        category = "terrain"
    },
    {
        type = "autoplace-control",
        name = "tenebris_cliff",
        order = "b[terrain]-c[cliff]",
        category = "terrain"
    },

    --------------------------------------------------------------------------------
    -- Coordinate Wobble (domain distortion for organic shapes)
    -- Must be defined early as many expressions depend on these
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_wobble_x",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 2001, octaves = 3, input_scale = 1/50, output_scale = 30}"
    },
    {
        type = "noise-expression",
        name = "tenebris_wobble_y",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 2002, octaves = 3, input_scale = 1/50, output_scale = 30}"
    },
    {
        type = "noise-expression",
        name = "tenebris_wobble_large_x",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2003, octaves = 2, input_scale = 1/250, output_scale = 120}"
    },
    {
        type = "noise-expression",
        name = "tenebris_wobble_large_y",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2004, octaves = 2, input_scale = 1/250, output_scale = 120}"
    },

    --------------------------------------------------------------------------------
    -- Helper Functions (like Gleba)
    --------------------------------------------------------------------------------
    {
        -- Smooth selection function: returns min-max based on input range
        type = "noise-function",
        name = "tenebris_select",
        parameters = {"input", "from", "to", "slope", "min", "max"},
        expression = "clamp(min(input - (from - slope), to + slope - input) / slope, min, max)"
    },

    --------------------------------------------------------------------------------
    -- Starting Area Configuration
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_starting_area_multiplier",
        expression = "0.8"
    },
    {
        -- Random angle for starting area orientation (based on map seed)
        type = "noise-expression",
        name = "tenebris_starting_angle",
        expression = "map_seed_normalized * 3600"
    },
    {
        -- Direction for spiral/rotation effects
        type = "noise-expression",
        name = "tenebris_starting_direction",
        expression = "-1 + 2 * (map_seed_small & 1)"
    },

    --------------------------------------------------------------------------------
    -- Starting Area Features (placed at specific angles around spawn)
    --------------------------------------------------------------------------------
    {
        -- Highlands to the "north" of starting orientation
        type = "noise-expression",
        name = "tenebris_starting_highlands",
        expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 60 * tenebris_starting_direction,\z
            distance = 200 * tenebris_starting_area_multiplier,\z
            radius = 180 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 12,\z
            y_distortion = tenebris_wobble_y * 12}"
    },
    {
        -- Lowlands to the "south" of starting orientation
        type = "noise-expression",
        name = "tenebris_starting_lowlands",
        expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 240 * tenebris_starting_direction,\z
            distance = 250 * tenebris_starting_area_multiplier,\z
            radius = 150 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 12,\z
            y_distortion = tenebris_wobble_y * 12}"
    },
    {
        -- Wastes landing zone (where player spawns)
        type = "noise-expression",
        name = "tenebris_starting_wastes",
        expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 180 * tenebris_starting_direction,\z
            distance = 20 * tenebris_starting_area_multiplier,\z
            radius = 120 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 8,\z
            y_distortion = tenebris_wobble_y * 8}"
    },

    --------------------------------------------------------------------------------
    -- Tri-Ridge Noise (creates interesting terrain patterns like Gleba)
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_tri_ridge",
        -- Three competing noise layers create ridge patterns
        expression = "0.5 * ((tri_bc < tri_a) * (tri_a - tri_bc) + (tri_ac < tri_b) * (tri_b - tri_ac) + (tri_ab < tri_c) * (tri_c - tri_ab))",
        local_expressions = {
            wobble_x = "x + tenebris_wobble_x * 20",
            wobble_y = "y + tenebris_wobble_y * 20",
            tri_a = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 10000}",
            tri_b = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 20000}",
            tri_c = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 30000}",
            tri_ab = "max(tri_a, tri_b)",
            tri_ac = "max(tri_a, tri_c)",
            tri_bc = "max(tri_b, tri_c)"
        }
    },

    --------------------------------------------------------------------------------
    -- Base Terrain: Elevation (Gleba-inspired)
    --------------------------------------------------------------------------------
    {
        -- Peak noise for highland mountains
        type = "noise-expression",
        name = "tenebris_peaks",
        expression = "multioctave_noise{x = x + tenebris_wobble_x * 25, y = y + tenebris_wobble_y * 25, persistence = 0.7, seed0 = map_seed, seed1 = 1000000, octaves = 3, input_scale = 1/200}"
    },
    {
        -- Small-scale ridge detail
        type = "noise-expression",
        name = "tenebris_ridges_small",
        expression = "abs(multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1000001, octaves = 3, input_scale = 1/150})"
    },
    {
        -- Combined ridges from tri-ridge and peaks
        type = "noise-expression",
        name = "tenebris_ridges",
        expression = "max(-tenebris_tri_ridge * 0.8, tenebris_peaks) * 2.4 + 0.2 * tenebris_ridges_small"
    },
    {
        -- Terrace the ridges for plateau effects
        -- Center around 45 (middle of wastes 20-80), with gentle variation
        -- Wastes should be most common, then lowlands, then highlands
        type = "noise-expression",
        name = "tenebris_ridge_terrace",
        expression = "terrace{value = clamp(45 + tenebris_ridges * 35, -20, 120), offset = 50, width = 30, strength = 0.2}"
    },
    {
        -- Starting area elevation blend
        type = "noise-expression",
        name = "tenebris_starting_elevation",
        expression = "max(5 * min(tenebris_starting_wastes * 2, 1),\z
                          80 * min(tenebris_starting_highlands * 2, 1),\z
                          -10 * min(tenebris_starting_lowlands * 2, 1)) + 4 * tenebris_ridges_small"
    },
    {
        -- Raw elevation before biome adjustments
        type = "noise-expression",
        name = "tenebris_elevation_raw",
        expression = "lerp(tenebris_ridge_terrace, tenebris_starting_elevation, clamp(1.5 - (distance / tenebris_starting_area_multiplier / 400), 0, 1))"
    },
    {
        -- Final elevation (ranges: <0 water, 0-20 lowland, 20-80 wastes, 80+ highlands)
        -- Quartz forests get elevation boost to create cliff rings at edges
        type = "noise-expression",
        name = "tenebris_elevation",
        expression = "tenebris_elevation_raw + 3 * (0.5 - abs(high_freq)) + quartz_elevation_boost",
        local_expressions = {
            high_freq = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1, octaves = 3, input_scale = 1/18}",
            -- Boost elevation inside quartz forests so cliffs form at edges
            quartz_elevation_boost = "100 * max(tenebris_quartz_forest_raw, tenebris_spawn_quartz_forest)"
        }
    },

    --------------------------------------------------------------------------------
    -- Aux, Moisture, Temperature
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_aux",
        expression = "clamp(0.5 + 0.5 * aux_noise, 0, 1)",
        local_expressions = {
            aux_noise = "multioctave_noise{x = x + tenebris_wobble_x * 10, y = y + tenebris_wobble_y * 10, persistence = 0.75, octaves = 5, input_scale = 1/70, seed0 = map_seed, seed1 = 7000}"
        }
    },
    {
        type = "noise-expression",
        name = "tenebris_moisture",
        -- Moisture follows elevation: lowlands wet, highlands dry
        expression = "clamp(1 - min(0.25 + (tenebris_elevation / 80), 0.5 + (tenebris_elevation - 20) / 200), 0, 1)"
    },
    {
        type = "noise-expression",
        name = "tenebris_temperature",
        expression = "10 + 10 * temp_noise",
        local_expressions = {
            temp_noise = "clamp(0.8 * multioctave_noise{x = x + tenebris_wobble_x * 6, y = y + tenebris_wobble_y * 6, persistence = 0.65, octaves = 4, input_scale = 1/4, seed0 = map_seed, seed1 = 18000}, -1, 1)"
        }
    },
    {
        type = "noise-expression",
        name = "tenebris_cliffiness",
        -- Standard cliffiness - cliffs now form naturally at elevation transitions
        -- Quartz forests get elevation boost which creates cliff rings at their edges
        -- Reduce cliffiness in the spawn quartz forest area to ensure ortet can spawn
        expression = "clamp(0.7 + 0.5 * cliffiness_basic, 0, 1) * spawn_exclusion",
        local_expressions = {
            cliffiness_basic = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1300, octaves = 2, input_scale = 1/100}",
            -- Reduce cliffs within 50 tiles of spawn ortet location (300, 300)
            spawn_distance = "sqrt((x - 300)^2 + (y - 300)^2)",
            spawn_exclusion = "clamp((spawn_distance - 20) / 30, 0, 1)"
        }
    },

    --------------------------------------------------------------------------------
    -- Biome Masks (derived from elevation, using tenebris_select)
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_highlands_mask",
        -- Highlands: elevation > 80 (smooth transition 70-90)
        expression = "tenebris_select(tenebris_elevation, 80, 1000, 10, 0, 1)"
    },
    {
        type = "noise-expression",
        name = "tenebris_lowlands_mask",
        -- Lowlands: elevation < 20 (smooth transition 10-25)
        expression = "tenebris_select(tenebris_elevation, -100, 20, 10, 0, 1)"
    },
    {
        type = "noise-expression",
        name = "tenebris_wastes_mask",
        -- Wastes: elevation 20-80 (default biome)
        expression = "tenebris_select(tenebris_elevation, 20, 80, 10, 0, 1)"
    },

    --------------------------------------------------------------------------------
    -- Quartz Ortet Forests (Voronoi-based like Fulgora islands)
    --------------------------------------------------------------------------------
    {
        -- Grid size controls spacing between potential forest centers (~1000 tiles)
        type = "noise-expression",                                                                                      
        name = "tenebris_quartz_grid",
        expression = "1000"
    },
    {
        -- Distorted X coordinate for organic shapes
        type = "noise-expression",
        name = "tenebris_quartz_wx",
        expression = "x + tenebris_wobble_x + tenebris_wobble_large_x"
    },
    {
        -- Distorted Y coordinate for organic shapes
        type = "noise-expression",
        name = "tenebris_quartz_wy",
        expression = "y + tenebris_wobble_y + tenebris_wobble_large_y"
    },
    {
        -- Voronoi cell IDs - each cell gets unique ID 0-1
        type = "noise-expression",
        name = "tenebris_quartz_cells",
        expression = "voronoi_cell_id{x = tenebris_quartz_wx, y = tenebris_quartz_wy, seed0 = map_seed, seed1 = 2010, grid_size = tenebris_quartz_grid, distance_type = 'euclidean', jitter = 0.7}"
    },
    {
        -- Voronoi pyramids - plateau shapes (high in center ~0.5, low at edges ~0)
        type = "noise-expression",
        name = "tenebris_quartz_pyramids",
        expression = "voronoi_pyramid_noise{x = tenebris_quartz_wx, y = tenebris_quartz_wy, seed0 = map_seed, seed1 = 2010, grid_size = tenebris_quartz_grid, distance_type = 'euclidean', jitter = 0.7}"
    },
    {
        -- Only cells with ID > 0.75 become forests (sparse selection, ~25% of cells)
        type = "noise-expression",
        name = "tenebris_quartz_forest_cells",
        expression = "tenebris_quartz_cells > 0.75"
    },
    {
        -- Apply pyramid shape only to selected forest cells, scaled to create plateau
        type = "noise-expression",
        name = "tenebris_quartz_forest_raw",
        expression = "(tenebris_quartz_pyramids - 0.15) * 4 * tenebris_quartz_forest_cells"
    },
    {
        -- For cliffiness calculations - raw proximity value
        type = "noise-expression",
        name = "tenebris_quartz_forest_spots",
        expression = "tenebris_quartz_forest_raw"
    },
    {
        -- Guaranteed quartz forest near spawn (centered around 300, 300)
        type = "noise-expression",
        name = "tenebris_spawn_quartz_forest",
        expression = "max(0, 1 - sqrt((x - 300)^2 + (y - 300)^2) / 100)"
    },
    {
        type = "noise-expression",
        name = "tenebris_quartz_forest_mask",
        -- Combine voronoi forests + spawn forest
        expression = "(tenebris_quartz_forest_raw > 0) + (tenebris_spawn_quartz_forest > 0.2) > 0"
    },

    --------------------------------------------------------------------------------
    -- Mercury Pools AND Rivers (combined approach)
    --------------------------------------------------------------------------------
    {
        -- Cluster regions: large spots where mercury pools CAN exist
        type = "noise-expression",
        name = "tenebris_mercury_cluster_regions",
        expression = "spot_noise{x = x + tenebris_wobble_large_x, y = y + tenebris_wobble_large_y,\z
            seed0 = map_seed, seed1 = 2100,\z
            candidate_spot_count = 15,\z
            suggested_minimum_candidate_point_spacing = 800,\z
            region_size = 2000,\z
            density_expression = 6,\z
            spot_quantity_expression = 1,\z
            spot_radius_expression = 200,\z
            spot_favorability_expression = 1,\z
            hard_region_target_quantity = 0,\z
            basement_value = -1,\z
            maximum_spot_basement_radius = 300}"
    },
    --------------------------------------------------------------------------------
    -- POOLS: Vulcanus-style inverted plasma (mercury is default, plasma carves land)
    --------------------------------------------------------------------------------
    {
        -- Pool plasma layer A: larger scale for main pool shapes
        type = "noise-expression",
        name = "tenebris_mercury_pool_plasma_a",
        expression = "multioctave_noise{x = x + tenebris_wobble_x * 2, y = y + tenebris_wobble_y * 2,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2110, octaves = 3, input_scale = 1/100}"
    },
    {
        -- Pool plasma layer B: different seed for variety
        type = "noise-expression",
        name = "tenebris_mercury_pool_plasma_b",
        expression = "multioctave_noise{x = x + tenebris_wobble_x * 2, y = y + tenebris_wobble_y * 2,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2120, octaves = 3, input_scale = 1/80}"
    },
    {
        -- Combined plasma: abs(a - b) creates organic crack patterns
        -- LOW values = cracks = where LAND is carved out
        -- HIGH values = between cracks = MERCURY remains
        type = "noise-expression",
        name = "tenebris_mercury_pool_plasma",
        expression = "abs(tenebris_mercury_pool_plasma_a - tenebris_mercury_pool_plasma_b)"
    },
    {
        -- Detail noise for irregular edges (subtracted like Vulcanus)
        type = "noise-expression",
        name = "tenebris_mercury_pool_detail",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2125, octaves = 4, input_scale = 1/40}"
    },
    {
        -- Pool value: Vulcanus-style formula with cluster fade
        -- Baseline -0.15 (biased towards mercury), plasma adds land, detail subtracts for jagged edges
        -- Cluster region value is SUBTRACTED: high cluster value (center) = more negative = mercury
        -- At cluster edges (cluster value ~0), pool value shifts positive = land (smooth fade)
        -- Result: negative = mercury, positive = land
        type = "noise-expression",
        name = "tenebris_mercury_pool_value",
        expression = "-0.15 + tenebris_mercury_pool_plasma - 0.08 * tenebris_mercury_pool_detail - 0.3 * clamp(tenebris_mercury_cluster_regions, 0, 1)"
    },
    --------------------------------------------------------------------------------
    -- RIVERS: Plasma noise (separate from pools)
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_mercury_river_a",
        expression = "multioctave_noise{x = x + tenebris_wobble_x * 3, y = y + tenebris_wobble_y * 3,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2140, octaves = 2, input_scale = 1/60}"
    },
    {
        type = "noise-expression",
        name = "tenebris_mercury_river_b",
        expression = "multioctave_noise{x = x + tenebris_wobble_x * 3, y = y + tenebris_wobble_y * 3,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2150, octaves = 2, input_scale = 1/60}"
    },
    {
        -- River value: low values (thin cracks) become rivers
        type = "noise-expression",
        name = "tenebris_mercury_river_value",
        expression = "abs(tenebris_mercury_river_a - tenebris_mercury_river_b)"
    },
    {
        -- Master noise to control where rivers can exist (prevents them everywhere)
        type = "noise-expression",
        name = "tenebris_mercury_river_master",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 2160, octaves = 3, input_scale = 1/400}"
    },
    --------------------------------------------------------------------------------
    -- Combined Mercury Masks
    --------------------------------------------------------------------------------
    {
        -- For backwards compatibility
        type = "noise-expression",
        name = "tenebris_mercury_pool_spots",
        expression = "tenebris_mercury_cluster_regions"
    },
    {
        type = "noise-expression",
        name = "tenebris_mercury_pool_mask",
        -- POOLS: Within clusters, mercury where pool_value < 0 (inverted Vulcanus style)
        -- RIVERS: Where plasma cracks are thin (river_value < threshold)
        -- Excluded from highlands (elevation >= 80)
        expression = "(tenebris_elevation < 80) * max(\z
            (tenebris_mercury_cluster_regions > 0) * (tenebris_mercury_pool_value < 0),\z
            (tenebris_mercury_river_master > 0.3) * (tenebris_mercury_river_value < 0.12))"
    },
    {
        type = "noise-expression",
        name = "tenebris_mercury_shore_mask",
        -- Shore: around pools (near zero) OR along rivers
        -- Excluded from highlands (elevation >= 80)
        expression = "(tenebris_elevation < 80) * max(\z
            (tenebris_mercury_cluster_regions > -0.2) * (tenebris_mercury_pool_value >= 0) * (tenebris_mercury_pool_value < 0.1),\z
            (tenebris_mercury_river_master > 0.2) * (tenebris_mercury_river_value >= 0.12) * (tenebris_mercury_river_value < 0.20))"
    },
    {
        -- Pool and shore mask for stromatolites: pools AND shores (NOT rivers)
        type = "noise-expression",
        name = "tenebris_mercury_pool_shore_mask",
        expression = "(tenebris_elevation < 80) * (tenebris_mercury_cluster_regions > 0) * (tenebris_mercury_pool_value < 0.1)"
    },

    --------------------------------------------------------------------------------
    -- Spot Features: Sulfuric Geyser Peaks
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_sulfur_geyser_spots",
        -- Reduced: less frequent, smaller spots
        expression = "spot_noise{x = x + tenebris_wobble_x, y = y + tenebris_wobble_y, seed0 = map_seed, seed1 = 2200,\z
            candidate_spot_count = 10,\z
            suggested_minimum_candidate_point_spacing = 800,\z
            region_size = 1500,\z
            density_expression = 4,\z
            spot_quantity_expression = 1,\z
            spot_radius_expression = 50,\z
            spot_favorability_expression = 1,\z
            hard_region_target_quantity = 0,\z
            basement_value = -1,\z
            maximum_spot_basement_radius = 80}"
    },
    {
        type = "noise-expression",
        name = "tenebris_sulfur_geyser_edge_noise",
        -- Noise for organic geyser zone boundaries
        expression = "0.2 * multioctave_noise{x = x, y = y, seed0 = map_seed, seed1 = 2250, persistence = 0.6, octaves = 3, input_scale = 1/15}"
    },
    {
        type = "noise-expression",
        name = "tenebris_sulfur_geyser_mask",
        -- Excluded from lowlands (elevation < 20)
        expression = "(tenebris_elevation >= 20) * ((tenebris_sulfur_geyser_spots + tenebris_sulfur_geyser_edge_noise) > 0)"
    },

    --------------------------------------------------------------------------------
    -- Abyssal Gashes (Maraxsis-style: large organic blob zones as world borders)
    -- Uses abs(multioctave_noise) like Maraxsis's trench system
    -- DEBUG MODE: Set to 500 for testing, change to 10000 for production
    --------------------------------------------------------------------------------
    {
        -- Minimum distance from spawn before gashes can appear
        type = "noise-expression",
        name = "tenebris_gash_min_distance",
        expression = "4000"
    },
    {
        -- Wobble for organic shapes
        type = "noise-expression",
        name = "tenebris_gash_wobble_x",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3000, octaves = 3, input_scale = 1/800, output_scale = 200}"
    },
    {
        type = "noise-expression",
        name = "tenebris_gash_wobble_y",
        expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3001, octaves = 3, input_scale = 1/800, output_scale = 200}"
    },
    {
        -- High-frequency noise to roughen gash edges - creates spikey borders
        type = "noise-expression",
        name = "tenebris_gash_edge_roughness",
        expression = "0.08 * multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3050, octaves = 5, input_scale = 1/15}"
    },
    {
        -- Core gash pattern: abs(noise) creates blob patterns
        -- Edge roughness added to create jagged/irregular boundaries
        type = "noise-expression",
        name = "tenebris_gash_elevation",
        expression = "abs(multioctave_noise{x = x + tenebris_gash_wobble_x, y = y + tenebris_gash_wobble_y,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 3100, octaves = 3, input_scale = 1/1000}) + tenebris_gash_edge_roughness"
    },
    {
        -- Distance fade: smooth cubic transition from 0 at min_distance to 1 over 2000 tiles
        -- Uses smoothstep-like curve for organic fade-in
        type = "noise-expression",
        name = "tenebris_gash_distance_fade_linear",
        expression = "clamp((distance - tenebris_gash_min_distance) / 2000, 0, 1)"
    },
    {
        -- Smoothstep curve: 3t² - 2t³ for smooth acceleration/deceleration
        type = "noise-expression",
        name = "tenebris_gash_distance_fade",
        expression = "tenebris_gash_distance_fade_linear * tenebris_gash_distance_fade_linear * (3 - 2 * tenebris_gash_distance_fade_linear)"
    },
    {
        -- Raw gash value before distance fade: 1 where gash should appear, 0 elsewhere
        type = "noise-expression",
        name = "tenebris_gash_raw",
        expression = "if(tenebris_gash_elevation < 0.16, 1, 0)"
    },
    {
        -- Final gash mask: multiply raw gash by distance fade for smooth transition
        -- Gashes gradually appear as you move further from spawn
        type = "noise-expression",
        name = "tenebris_abyssal_gash",
        expression = "tenebris_gash_raw * tenebris_gash_distance_fade"
    },
    {
        type = "noise-expression",
        name = "tenebris_abyssal_gash_soft",
        -- Softer version with gradual edge transition, also faded by distance
        expression = "clamp((0.20 - tenebris_gash_elevation) / 0.06, 0, 1) * tenebris_gash_distance_fade"
    },

    --------------------------------------------------------------------------------
    -- Starting Area Helpers
    --------------------------------------------------------------------------------
    {
        type = "noise-expression",
        name = "tenebris_starting_area_multiplier",
        expression = "1"
    },
    {
        type = "noise-expression",
        name = "tenebris_starting_circle",
        -- 1 in starting area, 0 outside
        expression = "if(distance < 200, 1, 0)"
    },

    --------------------------------------------------------------------------------
    -- Combined Tile Probability Expressions
    --------------------------------------------------------------------------------
    -- Abyssal gash tiles (highest priority)
    {
        type = "noise-expression",
        name = "tenebris_tile_abyssal",
        expression = "tenebris_abyssal_gash"
    },
    -- Mercury pool tiles
    {
        type = "noise-expression",
        name = "tenebris_tile_mercury",
        expression = "tenebris_mercury_pool_mask * (1 - tenebris_abyssal_gash)"
    },
    -- Highland tiles (high elevation, not in special zones)
    {
        type = "noise-expression",
        name = "tenebris_tile_highlands",
        expression = "tenebris_highlands_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask) * (1 - tenebris_sulfur_geyser_mask)"
    },
    -- Lowland tiles (low elevation, not in special zones)
    {
        type = "noise-expression",
        name = "tenebris_tile_lowlands",
        expression = "tenebris_lowlands_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask)"
    },
    -- Sulfur geyser area tiles
    {
        type = "noise-expression",
        name = "tenebris_tile_sulfur",
        expression = "tenebris_sulfur_geyser_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask)"
    },
    -- Wastes tiles (default fallback)
    {
        type = "noise-expression",
        name = "tenebris_tile_wastes",
        expression = "tenebris_wastes_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask) * (1 - tenebris_sulfur_geyser_mask) * (1 - tenebris_quartz_forest_mask)"
    },
    -- Quartz forest tiles
    {
        type = "noise-expression",
        name = "tenebris_tile_quartz",
        expression = "tenebris_quartz_forest_mask * (1 - tenebris_abyssal_gash)"
    },

    --------------------------------------------------------------------------------
    -- Entity Placement Expressions
    --------------------------------------------------------------------------------
    -- Lichen deposits: only in highlands and wastes
    {
        type = "noise-expression",
        name = "tenebris_lichen_probability",
        expression = "0.002 * max(tenebris_highlands_mask, tenebris_wastes_mask) * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask)"
    },
    -- Quartz nodes (geodes): only in wastes
    {
        type = "noise-expression",
        name = "tenebris_quartz_node_probability",
        expression = "0.003 * tenebris_wastes_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_mercury_pool_mask)"
    },
    -- Lucifunnels: only in highlands
    {
        type = "noise-expression",
        name = "tenebris_lucifunnel_probability",
        expression = "0.02 * tenebris_highlands_mask * (1 - tenebris_abyssal_gash)"
    },
    -- Tenecaps: only in lowlands
    {
        type = "noise-expression",
        name = "tenebris_tenecap_probability",
        expression = "0.04 * tenebris_lowlands_mask * (1 - tenebris_abyssal_gash)"
    },
    -- Sulfuric geysers: only at sulfur geyser spots, excluded from quartz forests
    {
        type = "noise-expression",
        name = "tenebris_sulfur_geyser_probability",
        -- Low probability for sparse geyser placement, excluded from quartz forests
        expression = "(control:sulfuric_acid_geyser:size > 0) * 0.003 * tenebris_sulfur_geyser_mask * (1 - tenebris_abyssal_gash) * (1 - tenebris_quartz_forest_mask)"
    },
    {
        type = "noise-expression",
        name = "tenebris_sulfur_geyser_richness",
        expression = "tenebris_sulfur_geyser_mask * 500000 * control:sulfuric_acid_geyser:richness"
    },
    -- Stromatolites: ring around mercury pools only (not rivers)
    {
        type = "noise-expression",
        name = "tenebris_stromatolite_probability",
        expression = "0.05 * tenebris_mercury_pool_shore_mask * (1 - tenebris_abyssal_gash)"
    },

    --------------------------------------------------------------------------------
    -- Quartz Forest Ortet Placement
    -- Sparse placement within quartz forest plateaus, ~500 tiles apart
    -- Only 1 ortet per spot - use tiny radius and high threshold
    --------------------------------------------------------------------------------
    {
        -- Plateau center favorability - higher values near pyramid peaks
        -- Used as favorability for spot_noise to prefer plateau centers
        type = "noise-expression",
        name = "tenebris_plateau_favorability",
        expression = "tenebris_quartz_pyramids * tenebris_quartz_forest_cells"
    },
    {
        -- Exclusion zone around spawn ortet (300, 300) - prevents spot_noise from placing there
        -- Returns 0 within 400 tiles of spawn, fades to 1 at 450 tiles
        -- This ensures no ortets spawn within 400 tiles of the guaranteed spawn ortet
        type = "noise-expression",
        name = "tenebris_spawn_exclusion",
        expression = "clamp((sqrt((x - 300)^2 + (y - 300)^2) - 400) / 50, 0, 1)"
    },
    {
        -- Ortet spots using spot_noise for spacing enforcement
        -- Uses plateau favorability to prefer centers
        -- Large spacing (300) and low candidate count (4) to prevent clustering
        -- Excludes area near spawn ortet to prevent doubling up
        type = "noise-expression",
        name = "tenebris_ortet_spots",
        expression = "spot_noise{x = x, y = y, seed0 = map_seed, seed1 = 3001,\z
            candidate_spot_count = 16,\z
            suggested_minimum_candidate_point_spacing = 300,\z
            density_expression = tenebris_quartz_forest_mask * 3 * tenebris_spawn_exclusion,\z
            spot_quantity_expression = 1,\z
            spot_radius_expression = 1,\z
            spot_favorability_expression = tenebris_plateau_favorability + 0.1,\z
            hard_region_target_quantity = false,\z
            basement_value = -1,\z
            maximum_spot_basement_radius = 1}"
    },
    {
        -- Guaranteed ortet at spawn quartz forest center (300, 300)
        -- Uses a tiny spot (radius 3) so only 1 ortet spawns
        type = "noise-expression",
        name = "tenebris_spawn_ortet",
        expression = "max(0, 1 - sqrt((x - 300)^2 + (y - 300)^2) / 3)"
    },
    {
        -- Ortet probability: spot noise (with spacing) OR spawn ortet location
        -- Lower threshold (> 0) since spot_noise returns positive values at spot centers
        type = "noise-expression",
        name = "tenebris_ortet_probability",
        expression = "((tenebris_ortet_spots > 0) + (tenebris_spawn_ortet > 0.5)) * tenebris_quartz_forest_mask * (1 - tenebris_abyssal_gash)"
    },
    -- NOTE: Buds are spawned programmatically around ortets via scripts/quartz_forest/map_generation.lua
    -- This gives us better control over spacing (50+ tiles) and count (1-10 based on distance from spawn)

}

--------------------------------------------------------------------------------
-- Map Generation Settings Function
--------------------------------------------------------------------------------
tenebris = function()
    return
    {
        cliff_settings =
        {
            name = "cliff-tenebris",
            control = "tenebris_cliff",
            -- Cliffs at elevation 90+ (quartz forests are boosted to 100+)
            -- This creates natural cliff rings around quartz forests like Fulgora islands
            cliff_elevation_interval = 40,
            cliff_elevation_0 = 90,
            richness = 0.80,
            cliff_smoothing = 0
        },
        property_expression_names =
        {
            -- Core terrain properties
            elevation = "tenebris_elevation",
            aux = "tenebris_aux",
            moisture = "tenebris_moisture",
            temperature = "tenebris_temperature",
            cliffiness = "tenebris_cliffiness",
            cliff_elevation = "cliff_elevation_from_elevation",
            
            -- Entity placement by biome
            -- Note: lichen deposits use resource_autoplace for proper ore patch clustering
            ["entity:quartz-node:probability"] = "tenebris_quartz_node_probability",
            ["entity:sulfuric-acid-geyser:probability"] = "tenebris_sulfur_geyser_probability",
            ["entity:sulfuric-acid-geyser:richness"] = "tenebris_sulfur_geyser_richness",
            ["entity:tenebris-quartz-forest-ortet:probability"] = "tenebris_ortet_probability",
            -- NOTE: Buds are spawned programmatically, not via autoplace
            
            -- Tile placement by biome (using debug tiles with distinct colors)
            -- Note: Abyssal and Mercury tiles use their own autoplace definitions
            
            -- Mercury pools (purple via tile definition)
            ["tile:tenebris-mercury-tile:probability"] = "tenebris_tile_mercury",
            
            -- DEBUG TILES with distinct map colors
            -- Highlands (cyan)
            ["tile:tenebris-debug-highlands:probability"] = "tenebris_tile_highlands",
            
            -- Lowlands (green)
            ["tile:tenebris-debug-lowlands:probability"] = "tenebris_tile_lowlands",
            
            -- Sulfur geysers (red)
            ["tile:tenebris-debug-sulfur:probability"] = "tenebris_tile_sulfur",
            
            -- Quartz forests (magenta)
            ["tile:tenebris-debug-quartz:probability"] = "tenebris_tile_quartz",
            
            -- Wastes (yellow/orange - default biome)
            ["tile:tenebris-debug-wastes:probability"] = "tenebris_tile_wastes",
        },
        autoplace_controls =
        {
            ["tenebris_exposed_lichen_deposit"] = {},
            ["tenebris_plants"] = {},
            ["tenebris_cliff"] = {},
            ["sulfuric_acid_geyser"] = {},
        },
        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    -- Debug tiles with distinct colors for biome visualization
                    ["tenebris-abyssal-water"] = {},     -- Abyssal gashes (dark)
                    ["tenebris-mercury-tile"] = {},      -- Mercury pools (silver)
                    ["tenebris-debug-highlands"] = {},   -- Highlands (cyan)
                    ["tenebris-debug-lowlands"] = {},    -- Lowlands (green)
                    ["tenebris-debug-sulfur"] = {},      -- Sulfur geysers (red)
                    ["tenebris-debug-quartz"] = {},      -- Quartz forests (magenta)
                    ["tenebris-debug-wastes"] = {},      -- Wastes (yellow/orange)
                }
            },
            -- Decoratives: inherit from Gleba (no override)
            -- ["decorative"]w = { settings = {} },
            ["entity"] =
            {
                settings =
                {
                    ["tenebris-exposed-lichen-deposit"] = {},
                    ["sulfuric-acid-geyser"] = {},
                    ["quartz-node"] = {},
                    ["tenebris-quartz-forest-ortet"] = {},
                    -- NOTE: Buds are spawned programmatically around ortets
                }
            }
        }
    }
end

return tenebris

