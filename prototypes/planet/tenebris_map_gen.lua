-- Tenebris Biome System
--
-- Architecture:
--   Layer 1: Base Terrain Properties (elevation_base, aux, vapor_pressure)
--   Layer 2: Biome Regions (raw masks, no exclusions)
--   Layer 3: Priority Resolution (exclusion chain)
--   Layer 4: Biome Effects (elevation mods, cliffiness, tiles)
--   Layer 5: Subbiomes (rings, edges, shores)
--
-- Priority (highest wins):
--   100: Abyssal Gash (impassable)
--   50:  Quartz Forests (elevated plateaus)
--   40:  Sulfur Pits (cliff-ringed depressions)
--   30:  Mercury Pools (liquid)
--   10:  Base terrain (highlands/wastes/lowlands)

data:extend({
	--------------------------------------------------------------------------------
	-- Autoplace Controls
	--------------------------------------------------------------------------------
	{
		type = "autoplace-control",
		name = "tenebris_exposed_lichen_deposit",
		richness = true,
		order = "b[resource]-t[tenebris]-a",
		category = "resource",
	},
	{
		type = "autoplace-control",
		name = "tenebris_plants",
		order = "b[decorative]-t[tenebris]-a",
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "tenebris_cliff",
		order = "b[terrain]-c[cliff]",
		category = "terrain",
	},

	--------------------------------------------------------------------------------
	-- Coordinate Wobble (domain distortion for organic shapes)
	--------------------------------------------------------------------------------
	{
		type = "noise-expression",
		name = "tenebris_wobble_x",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 2001, octaves = 3, input_scale = 1/50, output_scale = 30}",
	},
	{
		type = "noise-expression",
		name = "tenebris_wobble_y",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 2002, octaves = 3, input_scale = 1/50, output_scale = 30}",
	},
	{
		type = "noise-expression",
		name = "tenebris_wobble_large_x",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2003, octaves = 2, input_scale = 1/250, output_scale = 120}",
	},
	{
		type = "noise-expression",
		name = "tenebris_wobble_large_y",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2004, octaves = 2, input_scale = 1/250, output_scale = 120}",
	},

	--------------------------------------------------------------------------------
	-- Helper Functions
	--------------------------------------------------------------------------------
	{
		-- Smooth selection function: returns min-max based on input range
		type = "noise-function",
		name = "tenebris_select",
		parameters = { "input", "from", "to", "slope", "min", "max" },
		expression = "clamp(min(input - (from - slope), to + slope - input) / slope, min, max)",
	},
	{
		-- Decorative placement with clustering
		type = "noise-function",
		name = "trpi",
		parameters = { "base_prob" },
		expression = "min(base_prob, base_prob * clamp(random_penalty{x = x, y = y, seed = 1, source = 1, amplitude = 1} + 0.5, 0, 1))",
	},

	--------------------------------------------------------------------------------
	-- Starting Area Configuration
	--------------------------------------------------------------------------------
	{
		type = "noise-expression",
		name = "tenebris_starting_area_multiplier",
		expression = "0.8",
	},
	{
		-- Random angle for starting area orientation (based on map seed)
		type = "noise-expression",
		name = "tenebris_starting_angle",
		expression = "map_seed_normalized * 3600",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_direction",
		expression = "-1 + 2 * (map_seed_small & 1)",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_highlands",
		expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 60 * tenebris_starting_direction,\z
            distance = 200 * tenebris_starting_area_multiplier,\z
            radius = 180 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 12,\z
            y_distortion = tenebris_wobble_y * 12}",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_lowlands",
		expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 240 * tenebris_starting_direction,\z
            distance = 250 * tenebris_starting_area_multiplier,\z
            radius = 150 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 12,\z
            y_distortion = tenebris_wobble_y * 12}",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_wastes",
		expression = "starting_spot_at_angle{angle = tenebris_starting_angle + 180 * tenebris_starting_direction,\z
            distance = 20 * tenebris_starting_area_multiplier,\z
            radius = 120 * tenebris_starting_area_multiplier,\z
            x_distortion = tenebris_wobble_x * 8,\z
            y_distortion = tenebris_wobble_y * 8}",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_circle",
		expression = "if(distance < 200, 1, 0)",
	},

	--------------------------------------------------------------------------------
	--
	-- LAYER 1: Base Terrain Properties
	-- These are fundamental noise-generated properties, independent of biomes
	--
	--------------------------------------------------------------------------------

	-- Tri-Ridge noise for interesting terrain patterns
	{
		type = "noise-expression",
		name = "tenebris_tri_ridge",
		expression = "0.5 * ((tri_bc < tri_a) * (tri_a - tri_bc) + (tri_ac < tri_b) * (tri_b - tri_ac) + (tri_ab < tri_c) * (tri_c - tri_ab))",
		local_expressions = {
			wobble_x = "x + tenebris_wobble_x * 20",
			wobble_y = "y + tenebris_wobble_y * 20",
			tri_a = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 10000}",
			tri_b = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 20000}",
			tri_c = "1 + multioctave_noise{x = wobble_x, y = wobble_y, persistence = 0.65, octaves = 3, input_scale = 1/1000, seed0 = map_seed, seed1 = 30000}",
			tri_ab = "max(tri_a, tri_b)",
			tri_ac = "max(tri_a, tri_c)",
			tri_bc = "max(tri_b, tri_c)",
		},
	},
	{
		type = "noise-expression",
		name = "tenebris_peaks",
		expression = "multioctave_noise{x = x + tenebris_wobble_x * 25, y = y + tenebris_wobble_y * 25, persistence = 0.7, seed0 = map_seed, seed1 = 1000000, octaves = 3, input_scale = 1/200}",
	},
	{
		type = "noise-expression",
		name = "tenebris_ridges_small",
		expression = "abs(multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1000001, octaves = 3, input_scale = 1/150})",
	},
	{
		type = "noise-expression",
		name = "tenebris_ridges",
		expression = "max(-tenebris_tri_ridge * 0.8, tenebris_peaks) * 2.4",
	},
	{
		type = "noise-expression",
		name = "tenebris_ridge_terrace",
		expression = "terrace{value = clamp(45 + tenebris_ridges * 35, -20, 120), offset = 50, width = 30, strength = 0.2}",
	},
	{
		type = "noise-expression",
		name = "tenebris_starting_elevation",
		expression = "max(45 * min(tenebris_starting_wastes * 2, 1),\z
                          100 * min(tenebris_starting_highlands * 2, 1),\z
                          10 * min(tenebris_starting_lowlands * 2, 1)) + 4 * tenebris_ridges_small",
	},
	{
		-- BASE ELEVATION: Before any biome modifications
		-- This is used for base terrain biome selection (highlands/lowlands/wastes)
		-- Boosted by 300 to give headroom for sulfur pit drops (8 rings × 30 = 240 units)
		-- This ensures deepest pits stay above elevation 0 where cliffs can't form
		type = "noise-expression",
		name = "tenebris_elevation_base",
		expression = "300 + lerp(tenebris_ridge_terrace, tenebris_starting_elevation_smooth, clamp(1.5 - (distance / tenebris_starting_area_multiplier / 400), 0, 1))",
		local_expressions = {
			tenebris_starting_elevation_smooth = "max(45 * min(tenebris_starting_wastes * 2, 1), 100 * min(tenebris_starting_highlands * 2, 1), 10 * min(tenebris_starting_lowlands * 2, 1))",
		},
	},
	{
		-- AUX: Substrate/mineral variation (0-1)
		type = "noise-expression",
		name = "tenebris_aux",
		expression = "clamp(0.5 + 0.5 * aux_noise, 0, 1)",
		local_expressions = {
			aux_noise = "multioctave_noise{x = x + tenebris_wobble_x * 10, y = y + tenebris_wobble_y * 10, persistence = 0.75, octaves = 5, input_scale = 1/70, seed0 = map_seed, seed1 = 7000}",
		},
	},
	{
		-- VAPOR PRESSURE: Chemical concentration (replaces moisture)
		-- Independent noise, not derived from elevation
		type = "noise-expression",
		name = "tenebris_vapor_pressure",
		expression = "clamp(0.5 + 0.5 * vapor_noise, 0, 1)",
		local_expressions = {
			vapor_noise = "multioctave_noise{x = x + tenebris_wobble_x * 8, y = y + tenebris_wobble_y * 8, persistence = 0.6, octaves = 4, input_scale = 1/120, seed0 = map_seed, seed1 = 8000}",
		},
	},
	{
		-- TEMPERATURE
		type = "noise-expression",
		name = "tenebris_temperature",
		expression = "10 + 10 * temp_noise",
		local_expressions = {
			temp_noise = "clamp(0.8 * multioctave_noise{x = x + tenebris_wobble_x * 6, y = y + tenebris_wobble_y * 6, persistence = 0.65, octaves = 4, input_scale = 1/4, seed0 = map_seed, seed1 = 18000}, -1, 1)",
		},
	},

	--------------------------------------------------------------------------------
	--
	-- LAYER 2: Biome Regions (raw masks, NO exclusions)
	-- Each expression defines WHERE a biome wants to exist, ignoring other biomes
	--
	--------------------------------------------------------------------------------

	-- ABYSSAL GASH region
	{
		type = "noise-expression",
		name = "tenebris_gash_min_distance",
		expression = "4000",
	},
	{
		type = "noise-expression",
		name = "tenebris_gash_wobble_x",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3000, octaves = 3, input_scale = 1/800, output_scale = 200}",
	},
	{
		type = "noise-expression",
		name = "tenebris_gash_wobble_y",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3001, octaves = 3, input_scale = 1/800, output_scale = 200}",
	},
	{
		type = "noise-expression",
		name = "tenebris_gash_edge_roughness",
		expression = "0.08 * multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 3050, octaves = 5, input_scale = 1/15}",
	},
	{
		type = "noise-expression",
		name = "tenebris_gash_pattern",
		expression = "abs(multioctave_noise{x = x + tenebris_gash_wobble_x, y = y + tenebris_gash_wobble_y,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 3100, octaves = 3, input_scale = 1/1000}) + tenebris_gash_edge_roughness",
	},
	{
		type = "noise-expression",
		name = "tenebris_gash_distance_fade",
		expression = "smoothstep * smoothstep * (3 - 2 * smoothstep)",
		local_expressions = {
			smoothstep = "clamp((distance - tenebris_gash_min_distance) / 2000, 0, 1)",
		},
	},
	{
		type = "noise-expression",
		name = "tenebris_region_abyssal",
		expression = "(tenebris_gash_pattern < 0.16) * tenebris_gash_distance_fade",
	},

	-- QUARTZ FOREST region
	{
		type = "noise-expression",
		name = "tenebris_quartz_grid",
		expression = "1000",
	},
	{
		type = "noise-expression",
		name = "tenebris_quartz_wx",
		expression = "x + tenebris_wobble_x + tenebris_wobble_large_x",
	},
	{
		type = "noise-expression",
		name = "tenebris_quartz_wy",
		expression = "y + tenebris_wobble_y + tenebris_wobble_large_y",
	},
	{
		type = "noise-expression",
		name = "tenebris_quartz_cells",
		expression = "voronoi_cell_id{x = tenebris_quartz_wx, y = tenebris_quartz_wy, seed0 = map_seed, seed1 = 2010, grid_size = tenebris_quartz_grid, distance_type = 'euclidean', jitter = 0.7}",
	},
	{
		type = "noise-expression",
		name = "tenebris_quartz_pyramids",
		expression = "voronoi_pyramid_noise{x = tenebris_quartz_wx, y = tenebris_quartz_wy, seed0 = map_seed, seed1 = 2010, grid_size = tenebris_quartz_grid, distance_type = 'euclidean', jitter = 0.7}",
	},
	{
		-- Spawn proximity for guaranteed forest near spawn
		type = "noise-expression",
		name = "tenebris_spawn_quartz_proximity",
		expression = "max(0, 1 - sqrt((x - 300)^2 + (y - 300)^2) / 200)",
	},
	{
		-- Cell selection: high ID cells OR cells near spawn
		type = "noise-expression",
		name = "tenebris_quartz_forest_cells",
		expression = "tenebris_quartz_cells > (0.75 - 0.8 * tenebris_spawn_quartz_proximity)",
	},
	{
		-- Continuous value for plateau shape (used for elevation boost and edge detection)
		type = "noise-expression",
		name = "tenebris_quartz_value",
		expression = "max(0, (tenebris_quartz_pyramids - 0.15) * 4) * tenebris_quartz_forest_cells",
	},
	{
		type = "noise-expression",
		name = "tenebris_region_quartz",
		expression = "tenebris_quartz_value > 0",
	},

	-- SULFUR PIT region
	-- Use voronoi for pit placement - this gives us both a region mask AND a gradient
	{
		type = "noise-expression",
		name = "tenebris_sulfur_grid",
		expression = "360", -- Grid spacing for sulfur pit placement (smaller = more pits)
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_wx",
		expression = "x + tenebris_wobble_x + tenebris_wobble_large_x",
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_wy",
		expression = "y + tenebris_wobble_y + tenebris_wobble_large_y",
	},
	{
		-- Cell ID for selecting which cells become sulfur pits
		type = "noise-expression",
		name = "tenebris_sulfur_cells",
		expression = "voronoi_cell_id{x = tenebris_sulfur_wx, y = tenebris_sulfur_wy, seed0 = map_seed, seed1 = 2200, grid_size = tenebris_sulfur_grid, distance_type = 'euclidean', jitter = 0.7}",
	},
	{
		-- Pyramid noise gives ~0.15 at cell edges, ~1 at cell centers (cone shape)
		-- This is our edge-to-center gradient!
		type = "noise-expression",
		name = "tenebris_sulfur_pyramid",
		expression = "voronoi_pyramid_noise{x = tenebris_sulfur_wx, y = tenebris_sulfur_wy, seed0 = map_seed, seed1 = 2200, grid_size = tenebris_sulfur_grid, distance_type = 'euclidean', jitter = 0.7}",
	},
	{
		-- Select ~30% of cells to be sulfur pits (high cell IDs)
		type = "noise-expression",
		name = "tenebris_sulfur_pit_cells",
		expression = "tenebris_sulfur_cells > 0.90",
	},
	{
		-- Continuous value (0 at edge, 1 at center) - only in selected pit cells
		-- Cutoff 0.33, multiplier 4.1 to reach full gradient
		-- No edge noise - cleaner cliff lines
		type = "noise-expression",
		name = "tenebris_sulfur_value",
		expression = "max(0, (tenebris_sulfur_pyramid - 0.33) * 4.1) * tenebris_sulfur_pit_cells",
	},
	{
		type = "noise-expression",
		name = "tenebris_region_sulfur",
		expression = "tenebris_sulfur_value > 0",
	},

	-- MERCURY POOL region
	{
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
            maximum_spot_basement_radius = 300}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_pool_plasma_a",
		expression = "multioctave_noise{x = x + tenebris_wobble_x * 2, y = y + tenebris_wobble_y * 2,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2110, octaves = 3, input_scale = 1/100}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_pool_plasma_b",
		expression = "multioctave_noise{x = x + tenebris_wobble_x * 2, y = y + tenebris_wobble_y * 2,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2120, octaves = 3, input_scale = 1/80}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_pool_plasma",
		expression = "abs(tenebris_mercury_pool_plasma_a - tenebris_mercury_pool_plasma_b)",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_pool_detail",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.6, seed0 = map_seed, seed1 = 2125, octaves = 4, input_scale = 1/40}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_pool_value",
		expression = "-0.15 + tenebris_mercury_pool_plasma - 0.08 * tenebris_mercury_pool_detail - 0.3 * clamp(tenebris_mercury_cluster_regions, 0, 1)",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_river_a",
		expression = "multioctave_noise{x = x + tenebris_wobble_x * 3, y = y + tenebris_wobble_y * 3,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2140, octaves = 2, input_scale = 1/60}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_river_b",
		expression = "multioctave_noise{x = x + tenebris_wobble_x * 3, y = y + tenebris_wobble_y * 3,\z
            persistence = 0.5, seed0 = map_seed, seed1 = 2150, octaves = 2, input_scale = 1/60}",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_river_value",
		expression = "abs(tenebris_mercury_river_a - tenebris_mercury_river_b)",
	},
	{
		type = "noise-expression",
		name = "tenebris_mercury_river_master",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 2160, octaves = 3, input_scale = 1/400}",
	},
	{
		-- Lowlands indicator (elevation 200-320) - gets mercury pools
		type = "noise-expression",
		name = "tenebris_lowlands_indicator",
		expression = "tenebris_select(tenebris_elevation_base, 200, 320, 10, 0, 1)",
	},
	{
		-- Wastes indicator (elevation 320-380) - gets mercury rivers only
		type = "noise-expression",
		name = "tenebris_wastes_indicator",
		expression = "tenebris_select(tenebris_elevation_base, 320, 380, 10, 0, 1)",
	},
	{
		-- Mercury region: separated by biome
		-- Lowlands: pools (cluster-based + generous plasma coverage)
		-- Wastes: rivers/streams only
		type = "noise-expression",
		name = "tenebris_region_mercury",
		expression = "max(\z
            tenebris_lowlands_indicator * max(\z
                (tenebris_mercury_cluster_regions > 0) * (tenebris_mercury_pool_value < 0),\z
                (tenebris_mercury_pool_value < 0.15)),\z
            tenebris_wastes_indicator * (tenebris_mercury_river_master > 0.3) * (tenebris_mercury_river_value < 0.12))",
	},

	-- BASE TERRAIN regions (from elevation_base)
	-- Thresholds boosted by 300 to match elevation_base boost
	{
		type = "noise-expression",
		name = "tenebris_region_highlands",
		expression = "tenebris_select(tenebris_elevation_base, 380, 1000, 10, 0, 1)",
	},
	{
		type = "noise-expression",
		name = "tenebris_region_lowlands",
		expression = "tenebris_select(tenebris_elevation_base, 200, 320, 10, 0, 1)",
	},
	{
		type = "noise-expression",
		name = "tenebris_region_wastes",
		expression = "tenebris_select(tenebris_elevation_base, 320, 380, 10, 0, 1)",
	},

	--------------------------------------------------------------------------------
	--
	-- LAYER 3: Priority Resolution
	-- Each biome excludes all higher-priority biomes
	-- Priority: Abyssal (100) > Quartz (50) > Sulfur (40) > Mercury (30) > Base (10)
	--
	--------------------------------------------------------------------------------

	{
		type = "noise-expression",
		name = "tenebris_biome_abyssal",
		expression = "tenebris_region_abyssal",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_quartz",
		expression = "tenebris_region_quartz * (1 - tenebris_biome_abyssal)",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_sulfur",
		expression = "tenebris_region_sulfur * (1 - tenebris_biome_abyssal) * (1 - tenebris_biome_quartz)",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_mercury",
		expression = "tenebris_region_mercury * (1 - tenebris_biome_abyssal) * (1 - tenebris_biome_quartz) * (1 - tenebris_biome_sulfur)",
	},
	{
		-- Any special biome (for excluding base terrain)
		type = "noise-expression",
		name = "tenebris_biome_any_special",
		expression = "max(tenebris_biome_abyssal, max(tenebris_biome_quartz, max(tenebris_biome_sulfur, tenebris_biome_mercury)))",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_highlands",
		expression = "tenebris_region_highlands * (1 - tenebris_biome_any_special)",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_lowlands",
		expression = "tenebris_region_lowlands * (1 - tenebris_biome_any_special)",
	},
	{
		type = "noise-expression",
		name = "tenebris_biome_wastes",
		expression = "tenebris_region_wastes * (1 - tenebris_biome_any_special)",
	},

	--------------------------------------------------------------------------------
	--
	-- LAYER 4: Biome Effects
	-- Elevation modifications, cliffiness, and tiles based on resolved biomes
	--
	--------------------------------------------------------------------------------

	-- Noise for random inner ring appearance in sulfur pits
	{
		type = "noise-expression",
		name = "tenebris_sulfur_ring_noise",
		expression = "multioctave_noise{x = x, y = y, persistence = 0.5, seed0 = map_seed, seed1 = 2250, octaves = 2, input_scale = 1/40}",
	},

	-- FINAL ELEVATION with biome modifications
	{
		type = "noise-expression",
		name = "tenebris_elevation",
		expression = "max(5, effective_base + highlands_boost + quartz_boost - sulfur_drop)",
		local_expressions = {
			-- Highlands: sharp elevation boost at biome boundary (creates cliff ring)
			-- Boost of 40 ensures at least one cliff tier (cliff_elevation_interval = 30)
			highlands_boost = "40 * tenebris_biome_highlands",

			-- Quartz forests: boost elevation by 100 (creates cliff ring at edges)
			quartz_boost = "100 * tenebris_quartz_value * tenebris_biome_quartz",

			-- Sulfur pits: flatten base elevation to ensure concentric cliff rings
			-- The base terrain varies (typically 300-380), which would cause jagged non-concentric cliffs.
			-- We flatten to a uniform elevation within sulfur pits so ring drops create clean rings.
			--
			-- Flat base of 270 chosen so that:
			--   - It's BELOW typical terrain (300-380 range), ensuring pits are always depressions
			--   - Ring drops are 32 each (slightly > cliff interval of 30 to ensure threshold crossing)
			--   - Ring 0 drops to 238, Ring 1 to 206, Ring 2 to 174, etc.
			--   - Each drop clearly crosses one cliff threshold
			--   - Surrounding terrain (300-380) will always be higher than pit edge (238)
			--   - Deepest point (8 rings): 270 - 256 = 14 (safely above 0)
			sulfur_flat_base = "270",

			-- Hard blend: immediately flatten to uniform base at biome boundary
			-- This ensures the elevation change (and thus cliff) aligns with tile boundary
			sulfur_in_biome = "tenebris_biome_sulfur > 0",

			-- Effective base: hard switch to flat base inside sulfur biome
			effective_base = "if(sulfur_in_biome, sulfur_flat_base, tenebris_elevation_base)",

			-- Sulfur pits: explicit threshold-based drops
			-- tenebris_sulfur_value goes from 0 at edge to ~0.8-0.9 at center
			-- (voronoi pyramid doesn't quite reach 1.0)
			-- Each ring adds 32 units of drop when threshold is crossed
			ring_drop = "32",

			-- 8 rings with thresholds spread across 0-1 range
			-- Now that gradient reaches 1.0+, we can use full range
			-- Ring 0: entire pit (>0) - this creates the outer cliff
			sulfur_ring_0 = "ring_drop * (tenebris_sulfur_value > 0)",
			-- Remaining rings at ~0.14 intervals for even spacing across 0-1
			sulfur_ring_1 = "ring_drop * (tenebris_sulfur_value > 0.06)",
			sulfur_ring_2 = "ring_drop * (tenebris_sulfur_value > 0.15)",
			sulfur_ring_3 = "ring_drop * (tenebris_sulfur_value > 0.28)",
			sulfur_ring_4 = "ring_drop * (tenebris_sulfur_value > 0.56)",
			-- sulfur_ring_5 = "ring_drop * (tenebris_sulfur_value > 0.70)",
			sulfur_ring_6 = "ring_drop * (tenebris_sulfur_value > 0.84)",
			-- sulfur_ring_7 = "ring_drop * (tenebris_sulfur_value > 0.98)",

			-- Total drop = sum of all rings that apply
			sulfur_total_drop = "sulfur_ring_0 + sulfur_ring_1 + sulfur_ring_2 + sulfur_ring_3 + sulfur_ring_4 + sulfur_ring_6",

			-- Gate by biome ownership
			sulfur_drop = "sulfur_total_drop * tenebris_biome_sulfur",
		},
	},

	-- CLIFFINESS: biome-determined
	-- Sulfur pits get constant 2 (like test map), others get noise-based + boosts
	-- Lowlands are flat (no cliffs) to allow mercury pools to dominate
	{
		type = "noise-expression",
		name = "tenebris_cliffiness",
		expression = "max(sulfur_cliffiness, max(highlands_edge_cliffiness, normal_cliffiness))",
		local_expressions = {
			-- Sulfur pits: constant 2, exactly like test map (no noise, no exclusions)
			sulfur_cliffiness = "2 * tenebris_biome_sulfur",

			-- Highlands edges: high cliffiness at biome boundaries
			-- Use the raw region mask to detect edge (where biome transitions from 0 to 1)
			highlands_edge = "tenebris_biome_highlands * (1 - tenebris_select(tenebris_elevation_base, 390, 1000, 10, 0, 1))",
			highlands_edge_cliffiness = "3 * highlands_edge",

			-- Normal areas: noise-based with quartz edge boost
			base_cliffiness = "0.7 + 0.5 * multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1300, octaves = 2, input_scale = 1/100}",
			quartz_edge_boost = "3 * tenebris_biome_quartz * (tenebris_quartz_pyramids > 0.1) * (tenebris_quartz_pyramids < 0.3)",
			spawn_distance = "sqrt((x - 300)^2 + (y - 300)^2)",
			spawn_exclusion = "clamp((spawn_distance - 20) / 30, 0, 1)",
			-- Lowlands are flat - suppress cliffs in lowlands biome
			lowlands_exclusion = "1 - tenebris_biome_lowlands",
			normal_cliffiness = "max(0, base_cliffiness + quartz_edge_boost) * spawn_exclusion * lowlands_exclusion",
		},
	},

	-- TILE expressions (just the prioritized biome masks)
	{
		type = "noise-expression",
		name = "tenebris_tile_abyssal",
		expression = "tenebris_biome_abyssal",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_quartz",
		expression = "tenebris_biome_quartz",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_sulfur",
		expression = "tenebris_biome_sulfur",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_mercury",
		expression = "tenebris_biome_mercury",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_highlands",
		expression = "tenebris_biome_highlands",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_lowlands",
		expression = "tenebris_biome_lowlands",
	},
	{
		type = "noise-expression",
		name = "tenebris_tile_wastes",
		expression = "tenebris_biome_wastes",
	},

	--------------------------------------------------------------------------------
	--
	-- LAYER 5: Subbiomes
	-- Variations within biomes (rings, edges, shores)
	--
	--------------------------------------------------------------------------------

	-- Sulfur pit rings (for potential tile variation or decoratives)
	-- DEBUG: These subbiomes will show us if sulfur_value actually varies inside pits
	-- If all tiles are the same color, the value is constant. If rings appear, it varies.
	{
		type = "noise-expression",
		name = "tenebris_subbiome_sulfur_outer",
		expression = "tenebris_biome_sulfur * (tenebris_sulfur_value > 0) * (tenebris_sulfur_value < 0.20)",
	},
	{
		type = "noise-expression",
		name = "tenebris_subbiome_sulfur_middle",
		expression = "tenebris_biome_sulfur * (tenebris_sulfur_value >= 0.20) * (tenebris_sulfur_value < 0.65)",
	},
	{
		type = "noise-expression",
		name = "tenebris_subbiome_sulfur_inner",
		expression = "tenebris_biome_sulfur * (tenebris_sulfur_value >= 0.65)",
	},

	-- Sulfur pit tile autoplace ranges
	-- Use aux noise for natural mingling between tile zones (Vulcanus-style blending)
	-- The aux term is multiplied by biome mask so tiles only appear in sulfur pits
	{
		type = "noise-expression",
		name = "tenebris_sulfur_pit_rock_range",
		-- Outer ring: sulfur_value 0-0.20, with aux noise for mingling
		expression = "tenebris_subbiome_sulfur_outer + tenebris_biome_sulfur * (aux - 0.3)",
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_volcanic_cracks_range",
		-- Middle ring: sulfur_value 0.20-0.65, with aux noise for mingling
		expression = "tenebris_subbiome_sulfur_middle + tenebris_biome_sulfur * (aux - 0.2)",
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_volcanic_cracks_warm_range",
		-- Inner ring: sulfur_value 0.65+, with aux noise for mingling
		expression = "tenebris_subbiome_sulfur_inner + tenebris_biome_sulfur * (aux - 0.1)",
	},

	-- Lowland tile autoplace ranges
	-- Five tiles mixed using aux noise for natural variation
	-- Order (by aux value): cauliflower (low aux) -> dead-skin -> infection -> vein-bulges -> vein-dead (high aux)
	{
		type = "noise-expression",
		name = "tenebris_lowland_cauliflower_range",
		-- Base tile, favored at low aux values
		expression = "tenebris_biome_lowlands * (0.3 - aux)",
	},
	{
		type = "noise-expression",
		name = "tenebris_lowland_dead_skin_range",
		-- Low-mid aux range
		expression = "tenebris_biome_lowlands * (0.2 - abs(aux - 0.25))",
	},
	{
		type = "noise-expression",
		name = "tenebris_lowland_infection_range",
		-- Mid aux range
		expression = "tenebris_biome_lowlands * (0.2 - abs(aux - 0.45))",
	},
	{
		type = "noise-expression",
		name = "tenebris_lowland_vein_bulges_range",
		-- High-mid aux range
		expression = "tenebris_biome_lowlands * (0.2 - abs(aux - 0.65))",
	},
	{
		type = "noise-expression",
		name = "tenebris_lowland_vein_dead_range",
		-- High aux values
		expression = "tenebris_biome_lowlands * (aux - 0.7)",
	},

	-- Mercury shores (for stromatolites)
	-- Shore zone includes mercury edges AND adjacent land
	-- Stromatolites can spawn on mercury tiles (near edges) and on adjacent lowlands/wastes tiles
	{
		type = "noise-expression",
		name = "tenebris_subbiome_mercury_shore",
		expression = "max(\z
            tenebris_biome_mercury * (tenebris_mercury_pool_value > 0.05),\z
            tenebris_biome_lowlands * (tenebris_mercury_pool_value >= 0.15) * (tenebris_mercury_pool_value < 0.30),\z
            tenebris_biome_wastes * (tenebris_mercury_river_master > 0.2) * (tenebris_mercury_river_value >= 0.10) * (tenebris_mercury_river_value < 0.25))",
	},

	-- Quartz edges (for cliffs and transition decoratives)
	{
		type = "noise-expression",
		name = "tenebris_subbiome_quartz_edge",
		expression = "tenebris_biome_quartz * (tenebris_quartz_pyramids > 0.1) * (tenebris_quartz_pyramids < 0.3)",
	},
	{
		type = "noise-expression",
		name = "tenebris_subbiome_quartz_plateau",
		expression = "tenebris_biome_quartz * (tenebris_quartz_pyramids >= 0.3)",
	},

	--------------------------------------------------------------------------------
	-- Entity Placement Expressions
	--------------------------------------------------------------------------------
	{
		type = "noise-expression",
		name = "tenebris_lichen_probability",
		expression = "0.002 * max(tenebris_biome_highlands, tenebris_biome_wastes)",
	},
	{
		type = "noise-expression",
		name = "tenebris_quartz_node_probability",
		expression = "0.003 * tenebris_biome_wastes",
	},
	{
		type = "noise-expression",
		name = "tenebris_lucifunnel_probability",
		expression = "0.02 * tenebris_biome_highlands",
	},
	{
		type = "noise-expression",
		name = "tenebris_tenecap_probability",
		expression = "0.04 * tenebris_biome_lowlands",
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_geyser_probability",
		expression = "(control:tenebris_cinnabar_geyser:size > 0) * 0.003 * tenebris_biome_sulfur",
	},
	{
		type = "noise-expression",
		name = "tenebris_sulfur_geyser_richness",
		expression = "tenebris_biome_sulfur * 500000 * control:tenebris_cinnabar_geyser:richness",
	},
	{
		type = "noise-expression",
		name = "tenebris_stromatolite_probability",
		expression = "0.15 * tenebris_subbiome_mercury_shore",
	},

	--------------------------------------------------------------------------------
	-- Sulfur Pit Decorative Placement
	-- Moderate probabilities - enough to spawn but not overwhelming
	--------------------------------------------------------------------------------
	{
		-- Large sulfur stains - sparse
		type = "noise-expression",
		name = "tenebris_sulfur_stain_probability",
		expression = "0.01 * tenebris_biome_sulfur",
	},
	{
		-- Small spotty stains
		type = "noise-expression",
		name = "tenebris_sulfur_stain_small_probability",
		expression = "0.02 * tenebris_biome_sulfur",
	},
	{
		-- Acid puddles - deeper in pits
		type = "noise-expression",
		name = "tenebris_sulfuric_acid_puddle_probability",
		expression = "0.01 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.3)",
	},
	{
		-- Small acid puddles
		type = "noise-expression",
		name = "tenebris_sulfuric_acid_puddle_small_probability",
		expression = "0.01 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.2)",
	},
	{
		-- Small sulfur rocks
		type = "noise-expression",
		name = "tenebris_small_sulfur_rock_probability",
		expression = "0.02 * tenebris_biome_sulfur",
	},
	{
		-- Tiny sulfur rocks
		type = "noise-expression",
		name = "tenebris_tiny_sulfur_rock_probability",
		expression = "0.04 * tenebris_biome_sulfur",
	},
	{
		-- Rock clusters - sparser
		type = "noise-expression",
		name = "tenebris_sulfur_rock_cluster_probability",
		expression = "0.02 * tenebris_biome_sulfur",
	},
	{
		-- Sulfur chimney vents - rare
		type = "noise-expression",
		name = "tenebris_sulfur_chimney_probability",
		expression = "0.01 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.4)",
	},
	{
		-- Truncated chimneys - outer areas
		type = "noise-expression",
		name = "tenebris_sulfur_chimney_truncated_probability",
		expression = "0.015 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.15) * (tenebris_sulfur_value < 0.4)",
	},
	{
		-- Faded chimneys - middle areas with weak gas
		type = "noise-expression",
		name = "tenebris_sulfur_chimney_faded_probability",
		expression = "0.012 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.25) * (tenebris_sulfur_value < 0.6)",
	},
	{
		-- Cold/extinct chimneys - outer rim, no gas
		type = "noise-expression",
		name = "tenebris_sulfur_chimney_cold_probability",
		expression = "0.02 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.1) * (tenebris_sulfur_value < 0.3)",
	},
	{
		-- Short chimneys - small rock formations, scattered
		type = "noise-expression",
		name = "tenebris_sulfur_chimney_short_probability",
		expression = "0.018 * tenebris_biome_sulfur * (tenebris_sulfur_value > 0.2)",
	},
	-- Note: Fire is now spawned when active chimneys are destroyed (dying_trigger_effect)
	-- rather than being autoplaced as a separate entity

	--------------------------------------------------------------------------------
	-- Quartz Forest Ortet Placement
	--------------------------------------------------------------------------------
	{
		type = "noise-expression",
		name = "tenebris_plateau_favorability",
		expression = "tenebris_quartz_pyramids * tenebris_quartz_forest_cells",
	},
	{
		type = "noise-expression",
		name = "tenebris_spawn_exclusion",
		expression = "clamp((sqrt((x - 300)^2 + (y - 300)^2) - 400) / 50, 0, 1)",
	},
	{
		type = "noise-expression",
		name = "tenebris_ortet_spots",
		expression = "spot_noise{x = x, y = y, seed0 = map_seed, seed1 = 3001,\z
            candidate_spot_count = 16,\z
            suggested_minimum_candidate_point_spacing = 300,\z
            density_expression = tenebris_biome_quartz * 3 * tenebris_spawn_exclusion,\z
            spot_quantity_expression = 1,\z
            spot_radius_expression = 1,\z
            spot_favorability_expression = tenebris_plateau_favorability + 0.1,\z
            hard_region_target_quantity = false,\z
            basement_value = -1,\z
            maximum_spot_basement_radius = 1}",
	},
	{
		type = "noise-expression",
		name = "tenebris_spawn_ortet",
		expression = "max(0, 1 - sqrt((x - 300)^2 + (y - 300)^2) / 3)",
	},
	{
		type = "noise-expression",
		name = "tenebris_ortet_probability",
		expression = "((tenebris_ortet_spots > 0) + (tenebris_spawn_ortet > 0.5)) * tenebris_biome_quartz",
	},
})

--------------------------------------------------------------------------------
-- Map Generation Settings Function
--------------------------------------------------------------------------------
tenebris = function()
	return {
		cliff_settings = {
			name = "cliff-tenebris",
			control = "tenebris_cliff",
			cliff_elevation_interval = 30,
			cliff_elevation_0 = 40,
			richness = 0.95,
			cliff_smoothing = 0,
		},
		property_expression_names = {
			-- Core terrain properties
			elevation = "tenebris_elevation",
			aux = "tenebris_aux",
			moisture = "tenebris_vapor_pressure",
			temperature = "tenebris_temperature",
			cliffiness = "tenebris_cliffiness",
			cliff_elevation = "cliff_elevation_from_elevation",

			-- Entity placement
			["entity:quartz-node:probability"] = "tenebris_quartz_node_probability",
			["entity:tenebris-cinnabar-geyser:probability"] = "tenebris_sulfur_geyser_probability",
			["entity:tenebris-cinnabar-geyser:richness"] = "tenebris_sulfur_geyser_richness",
			["entity:tenebris-quartz-forest-ortet:probability"] = "tenebris_ortet_probability",

			-- Tile placement (debug tiles)
			["tile:tenebris-mercury-tile:probability"] = "tenebris_tile_mercury",
			["tile:tenebris-debug-highlands:probability"] = "tenebris_tile_highlands",
			["tile:tenebris-debug-quartz:probability"] = "tenebris_tile_quartz",
			["tile:tenebris-debug-wastes:probability"] = "tenebris_tile_wastes",

			-- Lowland tiles (five-tile system with aux mixing)
			["tile:tenebris-lowland-cauliflower:probability"] = "tenebris_lowland_cauliflower_range",
			["tile:tenebris-lowland-dead-skin:probability"] = "tenebris_lowland_dead_skin_range",
			["tile:tenebris-lowland-infection:probability"] = "tenebris_lowland_infection_range",
			["tile:tenebris-lowland-vein-bulges:probability"] = "tenebris_lowland_vein_bulges_range",
			["tile:tenebris-lowland-vein-dead:probability"] = "tenebris_lowland_vein_dead_range",

			-- Sulfur pit tiles (three-tier system)
			["tile:tenebris-sulfur-pit-rock:probability"] = "tenebris_sulfur_pit_rock_range",
			["tile:tenebris-sulfur-volcanic-cracks:probability"] = "tenebris_sulfur_volcanic_cracks_range",
			["tile:tenebris-sulfur-volcanic-cracks-warm:probability"] = "tenebris_sulfur_volcanic_cracks_warm_range",

			-- Sulfur pit decoratives (Tenebris versions)
			["decorative:tenebris-sulfur-stain:probability"] = "tenebris_sulfur_stain_probability",
			["decorative:tenebris-sulfur-stain-small:probability"] = "tenebris_sulfur_stain_small_probability",
			["decorative:tenebris-sulfuric-puddle:probability"] = "tenebris_sulfuric_acid_puddle_probability",
			["decorative:tenebris-sulfuric-puddle-small:probability"] = "tenebris_sulfuric_acid_puddle_small_probability",
			["decorative:tenebris-small-sulfur-rock:probability"] = "tenebris_small_sulfur_rock_probability",
			["decorative:tenebris-tiny-sulfur-rock:probability"] = "tenebris_tiny_sulfur_rock_probability",
			["decorative:tenebris-sulfur-rock-cluster:probability"] = "tenebris_sulfur_rock_cluster_probability",
		},
		autoplace_controls = {
			["tenebris_exposed_lichen_deposit"] = {},
			["tenebris_plants"] = {},
			["tenebris_cliff"] = {},
			["tenebris_cinnabar_geyser"] = {},
		},
		autoplace_settings = {
			["tile"] = {
				settings = {
					["tenebris-abyssal-water"] = {},
					["tenebris-mercury-tile"] = {},
					["tenebris-debug-highlands"] = {},
					["tenebris-debug-quartz"] = {},
					["tenebris-debug-wastes"] = {},
					-- Lowland tiles (five-tile system with aux mixing)
					["tenebris-lowland-cauliflower"] = {},
					["tenebris-lowland-dead-skin"] = {},
					["tenebris-lowland-infection"] = {},
					["tenebris-lowland-vein-bulges"] = {},
					["tenebris-lowland-vein-dead"] = {},
					-- Sulfur pit tiles (three-tier system)
					["tenebris-sulfur-pit-rock"] = {},
					["tenebris-sulfur-volcanic-cracks"] = {},
					["tenebris-sulfur-volcanic-cracks-warm"] = {},
				},
			},
			["decorative"] = {
				settings = {
					["tenebris-mercury-stain"] = {},
					["tenebris-mercury-coral"] = {},
					["tenebris-highland-roots"] = {},
					["tenebris-mycelium"] = {},
					["tenebris-cracked-mud"] = {},
					["tenebris-wispy-lichen"] = {},
					-- Sulfur pit decoratives (Tenebris versions)
					["tenebris-sulfur-stain"] = {},
					["tenebris-sulfur-stain-small"] = {},
					["tenebris-sulfuric-puddle"] = {},
					["tenebris-sulfuric-puddle-small"] = {},
					["tenebris-small-sulfur-rock"] = {},
					["tenebris-tiny-sulfur-rock"] = {},
					["tenebris-sulfur-rock-cluster"] = {},
				},
			},
			["entity"] = {
				settings = {
					["tenebris-exposed-lichen-deposit"] = {},
					["tenebris-cinnabar-geyser"] = {},
					["quartz-node"] = {},
					["tenebris-quartz-forest-ortet"] = {},
					["tenebris-sulfur-chimney"] = {},
					["tenebris-sulfur-chimney-faded"] = {},
					["tenebris-sulfur-chimney-cold"] = {},
					["tenebris-sulfur-chimney-short"] = {},
					["tenebris-sulfur-chimney-truncated"] = {},
				},
			},
		},
	}
end

return tenebris
