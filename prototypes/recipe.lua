--- Phase 1 Tenebris Recipes
--- Clean redesign of all recipes for the Tenebris planet

local constants = require("__tenebris-prime__.prototypes.constants")
local tenebris = require("__tenebris-prime__.lib.tenebris")
local centipede_constants = require("lib.centipede_constants")

-- Crystal icon data for generating composite icons
local crystal_icons = {
	["citrine"] = { icon = "__tenebris-prime__/graphics/icons/crystals/citrine.png", icon_size = 64 },
	["onyx"] = { icon = "__tenebris-prime__/graphics/icons/crystals/onyx.png", icon_size = 64, tint = tenebris.TINT.ONYX },
	["prasiolite"] = { icon = "__tenebris-prime__/graphics/icons/crystals/prasiolite.png", icon_size = 64, tint = tenebris.TINT.PRASIOLITE },
	["amethyst"] = { icon = "__tenebris-prime__/graphics/icons/crystals/amethyst.png", icon_size = 64 },
	["ruby-agate"] = { icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64 },
	["sapphire-agate"] = { icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64, tint = tenebris.TINT.SAPPHIRE },
}

--- Helper function to look up an item's icon from data.raw
--- @param item_name string The item name to look up
--- @return string|nil, number|nil The icon path and size, or nil if not found
local function get_item_icon(item_name)
	-- Check common item types
	local item_types = {"item", "item-with-entity-data", "capsule", "ammo", "tool", "armor", "gun"}
	for _, item_type in ipairs(item_types) do
		local item = data.raw[item_type] and data.raw[item_type][item_name]
		if item then
			if item.icon then
				return item.icon, item.icon_size or 64
			elseif item.icons and item.icons[1] then
				return item.icons[1].icon, item.icons[1].icon_size or 64
			end
		end
	end
	return nil, nil
end

--- Helper function to generate 6 crystal variant recipes
--- @param base_name string The base recipe name (e.g., "piezoelectric-motor")
--- @param recipe_template table The recipe template with all properties except the crystal ingredient
--- @param crystal_amount number The amount of crystals to add (defaults to 1)
--- @param icon_options table|nil Optional icon generation settings. If nil or partial, auto-fills from result item.
--- @return table Array of 6 recipes, one for each crystal type
local function create_crystal_variant_recipes(base_name, recipe_template, crystal_amount, icon_options)
	crystal_amount = crystal_amount or 1
	icon_options = icon_options or {}

	-- First crystal type is the "main" entry for factoriopedia
	local main_recipe_name = base_name .. "-" .. constants.CRYSTAL_TYPES[1]

	-- Auto-detect background icon from result item if not provided
	if not icon_options.background_icon and not icon_options.overlay_icon then
		local result_item = nil
		if recipe_template.results and recipe_template.results[1] then
			result_item = recipe_template.results[1].name
		elseif recipe_template.result then
			result_item = recipe_template.result
		end
		
		if result_item then
			local item_icon, item_icon_size = get_item_icon(result_item)
			if item_icon then
				icon_options.background_icon = item_icon
				icon_options.background_icon_size = icon_options.background_icon_size or item_icon_size
			end
		end
	end
	
	-- Apply defaults for all patterns
	icon_options.crystal_shift = icon_options.crystal_shift or {8, 8}
	icon_options.crystal_scale = icon_options.crystal_scale or 0.3
	
	-- Apply defaults for crystal-in-front pattern
	if icon_options.background_icon then
		icon_options.crystal_in_front = icon_options.crystal_in_front ~= false -- default true
		icon_options.background_scale = icon_options.background_scale or 0.5
	end

	local recipes = {}
	for i, crystal in ipairs(constants.CRYSTAL_TYPES) do
		local recipe = table.deepcopy(recipe_template)
		recipe.name = base_name .. "-" .. crystal

		-- Add the crystal ingredient (item name has tenebris- prefix)
		table.insert(recipe.ingredients, { type = "item", name = "tenebris-" .. crystal, amount = crystal_amount })

		-- Generate composite icon if icon_options provided
		if icon_options.background_icon or icon_options.overlay_icon then
			if icon_options.crystal_in_front and icon_options.background_icon then
				-- Background icon with crystal in front (crystal is small overlay)
				local crystal_icon = table.deepcopy(crystal_icons[crystal])
				crystal_icon.scale = icon_options.crystal_scale
				crystal_icon.shift = icon_options.crystal_shift
				
				local background_icon = {
					icon = icon_options.background_icon,
					icon_size = icon_options.background_icon_size or 64,
					scale = icon_options.background_scale or 0.5,
					tint = icon_options.background_tint,
				}
				recipe.icons = { background_icon, crystal_icon }
			elseif icon_options.overlay_icon then
				-- Crystal as main icon with overlay in front (crystal is full-size background)
				local crystal_icon = table.deepcopy(crystal_icons[crystal])
				crystal_icon.scale = icon_options.background_scale or 0.5
				
				local overlay_icon = {
					icon = icon_options.overlay_icon,
					icon_size = icon_options.overlay_icon_size or 64,
					shift = icon_options.overlay_shift or {8, 8},
					scale = icon_options.overlay_scale or 0.3,
				}
				recipe.icons = { crystal_icon, overlay_icon }
			end
		end

		table.insert(recipes, recipe)
	end

	return recipes
end

local piezoelectric_motor_template = {
	type = "recipe",
	category = "crystal-resonance",
	subgroup = "tenebris-cr-motors",
	enabled = false,
	energy_required = 10,
	ingredients = {
		{ type = "fluid", name = "lubricant", amount = 15 },
		{ type = "item", name = "supercapacitor", amount = 2 },
		{ type = "fluid", name = "molten-iron", amount = 50 },
		{ type = "item", name = "tenebris-biopipe", amount = 1 },
		-- Crystal will be added by the function
	},
	results = {
		{ type = "item", name = "piezoelectric-motor", amount = 1 },
	},
	allow_productivity = true,
}

local piezoelectric_science_template = {
	type = "recipe",
	category = "crystal-resonance",
	subgroup = "tenebris-cr-science",
	enabled = false,
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "tenebris-ceramic-plate", amount = 2 },
		{ type = "item", name = "tenebris-chitosan", amount = 2 },
		{ type = "item", name = "tenebris-cinnabar", amount = 1 },
		-- Crystal will be added by the function
	},
	results = {
		{ type = "item", name = "piezoelectric-science-pack", amount = 1 },
	},
	allow_productivity = true,
}

local crystal_breakdown_template = {
	type = "recipe",
	category = "crystal-resonance",
	subgroup = "tenebris-cr-seedlings",
	enabled = false,
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "tenebris-hydrofluoric-acid", amount = 50 },
		-- Crystal will be added by the function
	},
	results = {
		{ type = "item", name = "tenebris-crystal-seedling", amount_min = 1, amount_max = 4 },
	},
}

local heated_agricultural_tower_template = {
	type = "recipe",
	category = "crafting",
	subgroup = "tenebris-heated-agriculture",
	enabled = false,
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "heat-pipe", amount = 10 },
		{ type = "item", name = "superconductor", amount = 10 },
		{ type = "item", name = "agricultural-tower", amount = 2 },
		-- Crystal will be added manually (10 of any crystal type)
	},
	results = {
		{ type = "item", name = "tenebris-heated-agricultural-tower", amount = 1 },
	},
}

local piezoelectric_inserter_template = {
	type = "recipe",
	category = "crystal-resonance",
	subgroup = "tenebris-inserter",
	enabled = false,
	energy_required = 0.5,
	ingredients = {
		{ type = "item", name = "inserter", amount = 1 },
		{ type = "item", name = "supercapacitor", amount = 4 },
		{ type = "item", name = "piezoelectric-motor", amount = 2 },
		-- Crystal will be added by the function
	},
	results = {
		{ type = "item", name = "piezoelectric-inserter", amount = 1 },
	},
}

local crystal_oscillator_template = {
	type = "recipe",
	category = "crystal-resonance",
	subgroup = "tenebris-cr-oscillators",
	enabled = false,
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "luciferin", amount = 20 },
		{ type = "fluid", name = "molten-copper", amount = 100 },
		-- Crystal will be added by the function
	},
	results = {
		{ type = "item", name = "tenebris-crystal-oscillator", amount = 1 },
	},
	allow_productivity = true,
}

local lightning_furnace_template = {
	type = "recipe",
	category = "crafting",
	subgroup = "tenebris-machines",
	enabled = false,
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "electric-furnace", amount = 1 },
		{ type = "item", name = "lightning-collector", amount = 1 },
		{ type = "item", name = "tenebris-ceramic-circuitry", amount = 20 },
		{ type = "item", name = "superconductor", amount = 20 },
		-- Crystal will be added by the function (10 of any crystal type)
	},
	results = {
		{ type = "item", name = "tenebris-lightning-furnace", amount = 1 },
	},
}

-- ========================================
-- CRYSTAL VARIANT RECIPES (GENERATED)
-- ========================================
local crystal_variant_recipes = {}

for _, recipe in ipairs(create_crystal_variant_recipes("piezoelectric-motor", piezoelectric_motor_template, 1)) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("piezoelectric-science-pack", piezoelectric_science_template, 1)) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("crystal-seedling-from", crystal_breakdown_template, 1)) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("tenebris-heated-agricultural-tower", heated_agricultural_tower_template, 10, {
	background_tint = tenebris.TINT.HEAT_LIGHT,
})) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("piezoelectric-inserter", piezoelectric_inserter_template, 1, {
	background_tint = tenebris.TINT.DARK_ORANGE,
})) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("crystal-oscillator", crystal_oscillator_template, 1)) do
	table.insert(crystal_variant_recipes, recipe)
end

for _, recipe in ipairs(create_crystal_variant_recipes("tenebris-lightning-furnace", lightning_furnace_template, 10)) do
	table.insert(crystal_variant_recipes, recipe)
end

-- Build the main recipes array
local all_recipes = {
		-- ========================================
		-- BIOLOGICAL PROCESSING
		-- ========================================
		{
			type = "recipe",
			name = "lucifunnel-processing",
			category = "organic-or-assembling",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 0.5,
			icon = "__tenebris-prime__/graphics/icons/lucifunnel-processing.png",
			icon_size = 64,
			ingredients = {
				{ type = "item", name = "lucifunnel", amount = 1 },
			},
			results = {
				{ type = "item", name = "luciferin", amount = 1 },
				{ type = "item", name = "lucifunnel-seed", amount = 1, probability = 0.1 },
			},
			main_product = "luciferin",
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenecap-processing",
			category = "organic-or-assembling",
			subgroup = "tenebris-organic-products",
			enabled = false,
			icon = "__tenebris-prime__/graphics/icons/tenecap-processing.png",
			icon_size = 64,
			energy_required = 1,
			ingredients = {
				{ type = "item", name = "tenecap", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenecap-spore", amount = 1 },
				{ type = "item", name = "tenebris-chitin", amount = 1 },
			},
			main_product = "tenebris-chitin",
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-chitin-nutrients",
			category = "organic",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 2,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/chitin.png", icon_size = 64, shift = {-8, -8}, scale = 0.5 },
				{ icon = "__space-age__/graphics/icons/nutrients.png", icon_size = 64, shift = {8, 8}, scale = 0.7 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-chitin", amount = 1 },
			},
			results = {
				{ type = "item", name = "nutrients", amount = 12 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-chitosan",
			category = "chemistry",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "item", name = "tenebris-chitin", amount = 4 },
				{ type = "fluid", name = "tenebris-hydrofluoric-acid", amount = 20 },
			},
			results = {
				{ type = "item", name = "tenebris-chitosan", amount = 1 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- ATMOSPHERIC PROCESSING
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-atmosphere",
			category = "chemistry",
			subgroup = "tenebris-atmosphere-processing",
			enabled = false,
			energy_required = 20,
			ingredients = {},
			results = {
				{ type = "fluid", name = "tenebris-atmosphere", amount = 100 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-atmosphere-separation-carbon",
			category = "oil-processing",
			subgroup = "tenebris-atmosphere-processing",
			enabled = false,
			energy_required = 4,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/fluid/tenebris-atmosphere.png", icon_size = 64, shift = {0, -8}, scale = 0.4 },
				{ icon = "__space-age__/graphics/icons/fluid/ammonia.png", icon_size = 64, shift = {-10, 8}, scale = 0.3 },
				{ icon = "__space-age__/graphics/icons/fluid/fluorine.png", icon_size = 64, shift = {0, 8}, scale = 0.3 },
				{ icon = "__tenebris-prime__/graphics/icons/fluid/sulfuric-waste-water.png", icon_size = 64, shift = {10, 8}, scale = 0.3 },
			},
			ingredients = {
				{ type = "fluid", name = "tenebris-atmosphere", amount = 100 },
				{ type = "fluid", name = "sulfuric-acid", amount = 50 },
				{ type = "item", name = "tenebris-carbon-spore-filter", amount = 1 },
			},
			results = {
				{ type = "fluid", name = "ammonia", amount = 25 },
				{ type = "fluid", name = "fluorine", amount = 5 },
				{ type = "fluid", name = "tenebris-sulfinated-spore-waste", amount = 20 },
				{ type = "item", name = "tenebris-used-carbon-spore-filter", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-atmosphere-separation-ceramic",
			category = "oil-processing",
			subgroup = "tenebris-atmosphere-processing",
			enabled = false,
			energy_required = 4,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/fluid/tenebris-atmosphere.png", icon_size = 64, shift = {0, -8}, scale = 0.4 },
				{ icon = "__space-age__/graphics/icons/fluid/ammonia.png", icon_size = 64, shift = {-10, 8}, scale = 0.3 },
				{ icon = "__space-age__/graphics/icons/fluid/fluorine.png", icon_size = 64, shift = {0, 8}, scale = 0.3 },
				{ icon = "__tenebris-prime__/graphics/icons/fluid/sulfuric-waste-water.png", icon_size = 64, shift = {10, 8}, scale = 0.3 },
			},
			ingredients = {
				{ type = "fluid", name = "tenebris-atmosphere", amount = 100 },
				{ type = "fluid", name = "sulfuric-acid", amount = 50 },
				{ type = "item", name = "tenebris-ceramic-filter", amount = 1 },
			},
			results = {
				{ type = "fluid", name = "ammonia", amount = 25 },
				{ type = "fluid", name = "fluorine", amount = 10 },
				{ type = "fluid", name = "tenebris-sulfinated-spore-waste", amount = 10 },
				{ type = "item", name = "tenebris-used-ceramic-filter", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenecap-spore-purification",
			category = "centrifuging",
			subgroup = "tenebris-atmosphere-processing",
			enabled = false,
			energy_required = 2,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/fluid/sulfuric-waste-water.png", icon_size = 64, shift = {0, -8}, scale = 0.6 },
				{ icon = "__tenebris-prime__/graphics/icons/tenecap-spore.png", icon_size = 64, shift = {-8, 8}, scale = 0.4 },
				{ icon = "__base__/graphics/icons/sulfur.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			ingredients = {
				{ type = "fluid", name = "tenebris-sulfinated-spore-waste", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenecap-spore", amount = 4 },
				{ type = "item", name = "sulfur", amount = 1 },
			},
			main_product = "sulfur",
			allow_productivity = true,
		},

		-- ========================================
		-- MERCURY PROCESSING
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-cinnabar",
			category = "chemistry",
			subgroup = "tenebris-mercury-products",
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "fluid", name = "tenebris-mercury", amount = 20 },
				{ type = "item", name = "sulfur", amount = 1 },
				{ type = "item", name = "luciferin", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-cinnabar", amount = 1 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- QUARTZ & MINERAL PROCESSING
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-stone-centrifuging",
			category = "centrifuging",
			subgroup = "tenebris-minerals",
			enabled = false,
			auto_recycle = false,
			energy_required = 2,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__base__/graphics/icons/stone.png", icon_size = 64, scale = 0.5 },
				{ icon = "__tenebris-prime__/graphics/icons/quartz-ore.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			main_product = "tenebris-quartz-ore",
			ingredients = {
				{ type = "item", name = "stone", amount = 10 },
				{ type = "fluid", name = "sulfuric-acid", amount = 50 },
			},
			results = {
				{ type = "item", name = "tenebris-quartz-ore", amount = 120, probability = 0.0025 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-quartz-slurry",
			category = "chemistry",
			subgroup = "tenebris-minerals",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "tenebris-quartz-ore", amount = 10 },
				{ type = "fluid", name = "tenebris-hydrofluoric-acid", amount = 20 },
			},
			results = {
				{ type = "fluid", name = "tenebris-quartz-slurry", amount = 10 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- CERAMIC PRODUCTION
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-ceramic-plate",
			category = "metallurgy",
			subgroup = "tenebris-ceramic-products",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "fluid", name = "tenebris-mercury", amount = 100 },
				{ type = "fluid", name = "tenebris-quartz-slurry", amount = 10 },
				{ type = "item", name = "tenebris-bismuth-ore", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-plate", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-plate-from-molten-bismuth",
			category = "metallurgy",
			subgroup = "tenebris-ceramic-products",
			enabled = false,
			energy_required = 2,
			icons = {
				{ icon = "__space-age__/graphics/icons/fluid/molten-iron.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/bismuth-ore.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/ceramic-plate.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "fluid", name = "tenebris-mercury", amount = 50 },
				{ type = "fluid", name = "tenebris-quartz-slurry", amount = 10 },
				{ type = "fluid", name = "tenebris-molten-bismuth", amount = 100 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-plate", amount = 4 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-carbon-spore-filter",
			category = "crafting",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "carbon", amount = 2 },
				{ type = "item", name = "tenebris-chitin", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-carbon-spore-filter", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-carbon-spore-filter-cleaning",
			category = "chemistry",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = false,
			hide_from_player_crafting = true,
			energy_required = 2,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.5 },
				{ icon = "__tenebris-prime__/graphics/icons/filter/carbon-filter.png", icon_size = 64, scale = 0.35 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-used-carbon-spore-filter", amount = 1 },
				{ type = "item", name = "carbon", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-carbon-spore-filter", amount = 1, probability = 0.99 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-filter",
			category = "crafting",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = false,
			energy_required = 0.67,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-plate", amount = 1 },
				{ type = "item", name = "carbon-fiber", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-filter", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-filter-cleaning",
			category = "chemistry",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = false,
			hide_from_player_crafting = true,
			energy_required = 2,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.5 },
				{ icon = "__tenebris-prime__/graphics/icons/filter/ceramic-filter.png", icon_size = 64, scale = 0.35 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-used-ceramic-filter", amount = 1 },
				{ type = "item", name = "carbon", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-filter", amount = 1, probability = 0.99 },
			},
		},
		-- ========================================
		-- ATMOSPHERIC FILTRATION (heated atmosphere scrubber)
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-atmosphere-scrubbing-carbon",
			category = "atmospheric-filtration",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = true,
			hide_from_player_crafting = true,
			energy_required = 60,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.5 },
				{ icon = "__tenebris-prime__/graphics/icons/fluid/tenebris-atmosphere.png", icon_size = 64, shift = {-8, 0}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/filter/carbon-filter.png", icon_size = 64, shift = {8, 0}, scale = 0.35 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-carbon-spore-filter", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-used-carbon-spore-filter", amount = 1 },
				{ type = "item", name = "tenecap-spore", amount_min = 2, amount_max = 16 },
			},
			main_product = "tenebris-used-carbon-spore-filter",
			allow_productivity = false,
			allow_quality = false,
		},
		{
			type = "recipe",
			name = "tenebris-atmosphere-scrubbing-ceramic",
			category = "atmospheric-filtration",
			subgroup = "tenebris-atmosphere-filtration",
			enabled = true,
			hide_from_player_crafting = true,
			energy_required = 60,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.5 },
				{ icon = "__tenebris-prime__/graphics/icons/fluid/tenebris-atmosphere.png", icon_size = 64, shift = {-8, 0}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/filter/ceramic-filter.png", icon_size = 64, shift = {8, 0}, scale = 0.35 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-filter", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-used-ceramic-filter", amount = 1 },
				{ type = "item", name = "tenecap-spore", amount_min = 4, amount_max = 24 },
			},
			main_product = "tenebris-used-ceramic-filter",
			allow_productivity = false,
			allow_quality = false,
		},
		{
			type = "recipe",
			name = "tenebris-luciferin-explosives",
			category = "chemistry-or-cryogenics",
			subgroup = "tenebris-luciferin-fuels",
			enabled = false,
			energy_required = 4,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/luciferin.png", icon_size = 64, shift = {0, -8}, scale = 0.4 },
				{ icon = "__base__/graphics/icons/sulfur.png", icon_size = 64, shift = {-8, 8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/explosives.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			ingredients = {
				{ type = "item", name = "luciferin", amount = 18 },
				{ type = "item", name = "sulfur", amount = 1 },
				{ type = "fluid", name = "ammonia", amount = 20 },
			},
			results = {
				{ type = "item", name = "explosives", amount = 4 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-crystal-seedling",
			category = "chemistry",
			subgroup = "tenebris-cr-seedlings",
			enabled = false,
			energy_required = 20,
			ingredients = {
				{ type = "fluid", name = "tenebris-quartz-slurry", amount = 50 },
				{ type = "item", name = "tenebris-ceramic-filter", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-crystal-seedling", amount = 2, probability = 0.01 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-quartz-geode-processing",
			category = "crystal-resonance",
			subgroup = "tenebris-minerals",
			enabled = false,
			energy_required = 6,
			icons = {
				-- Left column (back): citrine, onyx, prasiolite
				{ icon = "__tenebris-prime__/graphics/icons/crystals/citrine.png", icon_size = 64, shift = {-12, -10}, scale = 0.2 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/onyx.png", icon_size = 64, shift = {-12, 0}, scale = 0.2, tint = tenebris.TINT.ONYX },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/prasiolite.png", icon_size = 64, shift = {-12, 10}, scale = 0.2, tint = tenebris.TINT.PRASIOLITE },
				-- Right column (back): amethyst, ruby-agate, sapphire-agate
				{ icon = "__tenebris-prime__/graphics/icons/crystals/amethyst.png", icon_size = 64, shift = {12, -10}, scale = 0.2 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64, shift = {12, 0}, scale = 0.2 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64, shift = {12, 10}, scale = 0.2, tint = tenebris.TINT.SAPPHIRE },
				-- Front: quartz geode
				{ icon = "__tenebris-prime__/graphics/icons/quartz-ore.png", icon_size = 64, scale = 0.45 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-quartz-geode", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount_min = 1, amount_max = 8, probability = 0.25 },
				{ type = "item", name = "tenebris-onyx", amount_min = 2, amount_max = 3, probability = 0.20 },
				{ type = "item", name = "tenebris-prasiolite", amount_min = 2, amount_max = 5, probability = 0.20 },
				{ type = "item", name = "tenebris-amethyst", amount_min = 3, amount_max = 6, probability = 0.15 },
				{ type = "item", name = "tenebris-ruby-agate", amount_min = 1, amount_max = 2, probability = 0.12 },
				{ type = "item", name = "tenebris-sapphire-agate", amount_min = 1, amount_max = 3, probability = 0.08 },
			},
		},

		-- ========================================
		-- FUEL PRODUCTION
		-- ========================================
		{
			type = "recipe",
			name = "luciferin-solid-fuel",
			category = "chemistry-or-cryogenics",
			subgroup = "tenebris-luciferin-fuels",
			enabled = false,
			energy_required = 2,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/luciferin.png", icon_size = 64, shift = {0, -8}, scale = 0.4 },
				{ icon = "__space-age__/graphics/icons/carbon.png", icon_size = 64, shift = {-8, 8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/solid-fuel.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			ingredients = {
				{ type = "item", name = "luciferin", amount = 10 },
				{ type = "item", name = "carbon", amount = 2 },
				{ type = "fluid", name = "ammonia", amount = 20 },
			},
			results = {
				{ type = "item", name = "solid-fuel", amount = 2 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "luciferin-rocket-fuel",
			category = "cryogenics",
			subgroup = "tenebris-luciferin-fuels",
			enabled = false,
			energy_required = 15,
			icons = {
				{ icon = "__space-age__/graphics/icons/calcite.png", icon_size = 64, shift = {-10, -8}, scale = 0.3 },
				{ icon = "__base__/graphics/icons/solid-fuel.png", icon_size = 64, shift = {0, -8}, scale = 0.3 },
				{ icon = "__tenebris-prime__/graphics/icons/luciferin.png", icon_size = 64, shift = {10, -8}, scale = 0.3 },
				{ icon = "__base__/graphics/icons/rocket-fuel.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "calcite", amount = 4 },
				{ type = "item", name = "solid-fuel", amount = 4 },
				{ type = "item", name = "luciferin", amount = 20 },
			},
			results = {
				{ type = "item", name = "rocket-fuel", amount = 2 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "chitosan-carbon-fiber",
			category = "organic",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 2,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/chitosan.png", icon_size = 64, shift = {-8, -8}, scale = 0.4 },
				{ icon = "__space-age__/graphics/icons/carbon-fiber.png", icon_size = 64, shift = {8, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-cinnabar", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 50 },
				{ type = "item", name = "carbon", amount = 2 },
				{ type = "item", name = "tenebris-chitosan", amount = 1 },
			},
			results = {
				{ type = "item", name = "carbon-fiber", amount = 1 },
				{ type = "item", name = "sulfur", amount = 1 },
				{ type = "fluid", name = "tenebris-mercury", amount = 10 },
			},
			main_product = "carbon-fiber",
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-circuitry",
			category = "electromagnetics",
			subgroup = "tenebris-ceramic-products",
			enabled = false,
			energy_required = 8,
			ingredients = {
				{ type = "item", name = "superconductor", amount = 2 },
				{ type = "item", name = "tenebris-ceramic-plate", amount = 1 },
				{ type = "item", name = "tenebris-circuit-waste", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-concrete",
			category = "metallurgy-or-assembling",
			subgroup = "terrain",
			enabled = false,
			energy_required = 10,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/crystals/cinnabar.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/fluid/sulfuric-acid.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/concrete.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "fluid", name = "molten-iron", amount = 20 },
				{ type = "item", name = "stone-brick", amount = 5 },
				{ type = "item", name = "tenebris-cinnabar", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 100 },
			},
			results = {
				{ type = "item", name = "concrete", amount = 10 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-reinforced-concrete",
			category = "metallurgy",
			subgroup = "terrain",
			enabled = false,
			energy_required = 15,
			icons = {
				{ icon = "__space-age__/graphics/icons/fluid/molten-iron.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/carbon-fiber.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/refined-concrete.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "fluid", name = "molten-iron", amount = 100 },
				{ type = "item", name = "carbon-fiber", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 50 },
			},
			results = {
				{ type = "item", name = "refined-concrete", amount = 10 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- ACID PRODUCTION
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-hydrofluoric-acid",
			category = "cryogenics",
			subgroup = "fluid-recipes",
			enabled = false,
			energy_required = 8,
			ingredients = {
				{ type = "fluid", name = "fluorine", amount = 10 },
				{ type = "item", name = "luciferin", amount = 10 },
				{ type = "item", name = "tenebris-ferric-waste", amount = 2 },
				{ type = "fluid", name = "sulfuric-acid", amount = 20 },
			},
			results = {
				{ type = "fluid", name = "tenebris-hydrofluoric-acid", amount = 10 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- SPACE & OBSERVATION
		-- ========================================
		{
			type = "recipe",
			name = "observation-satellite",
			category = "electronics",
			subgroup = "space-related",
			enabled = false,
			energy_required = 80,
			ingredients = {
				{ type = "item", name = "low-density-structure", amount = 100 },
				{ type = "item", name = "solar-panel", amount = 100 },
				{ type = "item", name = "accumulator", amount = 100 },
				{ type = "item", name = "radar", amount = 5 },
				{ type = "item", name = "processing-unit", amount = 100 },
				{ type = "item", name = "rocket-fuel", amount = 50 },
				{ type = "item", name = "superconductor", amount = 50 },
			},
			results = {
				{ type = "item", name = "observation-satellite", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "molten-iron-from-ferric-waste",
			category = "metallurgy",
			subgroup = "tenebris-metallurgy",
			enabled = false,
			energy_required = 32,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/ferric-waste.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/calcite.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/fluid/molten-iron.png", icon_size = 64, shift = {0, 6}, scale = 0.6 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-ferric-waste", amount = 30 },
				{ type = "item", name = "calcite", amount = 1 },
			},
			results = {
				{ type = "fluid", name = "molten-iron", amount = 500 },
				{ type = "item", name = "tenecap-spore", amount = 10 },
			},
			main_product = "molten-iron",
		},
		{
			type = "recipe",
			name = "molten-copper-from-cupric-waste",
			category = "metallurgy",
			subgroup = "tenebris-metallurgy",
			enabled = false,
			energy_required = 32,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/cupric-waste.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/calcite.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/fluid/molten-copper.png", icon_size = 64, shift = {0, 6}, scale = 0.6 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-cupric-waste", amount = 30 },
				{ type = "item", name = "calcite", amount = 1 },
			},
			results = {
				{ type = "fluid", name = "molten-copper", amount = 500 },
				{ type = "item", name = "tenecap-spore", amount = 10 },
			},
			main_product = "molten-copper",
		},
		{
			type = "recipe",
			name = "tenebris-circuit-waste-recycling",
			category = "recycling",
			subgroup = "tenebris-waste-products",
			enabled = false,
			energy_required = 0.5,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/electronic-waste.png", icon_size = 64 },
				{ icon = "__quality__/graphics/icons/recycling.png", icon_size = 64 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-circuit-waste", amount = 4 },
			},
			results = {
				{ type = "item", name = "tenebris-ferric-waste", amount = 3 },
				{ type = "item", name = "tenebris-cupric-waste", amount = 8 },
				{ type = "item", name = "plastic-bar", amount = 2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-repair-pack-from-waste",
			category = "crafting",
			subgroup = "tenebris-waste-products",
			enabled = false,
			energy_required = 0.5,
			factoriopedia_alternative = "repair-pack",
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/ferric-waste.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/cupric-waste.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/repair-pack.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-ferric-waste", amount = 2 },
				{ type = "item", name = "tenebris-cupric-waste", amount = 1 },
			},
			results = {
				{ type = "item", name = "repair-pack", amount = 1 },
			},
		},
		-- Centipede corpse processing chain
		{
			type = "recipe",
			name = "tenebris-centipede-corpse-grinding",
			category = "crushing",
			subgroup = "space-crushing",
			enabled = false,
			energy_required = 5,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/centipede-corpse.png", icon_size = 64 },
				{ icon = "__PlanetsLib__/graphics/icons/asteroid-crushing.png", icon_size = 64 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-centipede-corpse", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-radiation-hardened-chitin", amount = 8 },
				{ type = "item", name = "tenebris-centipede-corpse", amount = 1, probability = 0.2 },
			},
			main_product = "tenebris-radiation-hardened-chitin",
		},
		{
			type = "recipe",
			name = "tenebris-radiation-hardened-chitin-processing",
			category = "crushing",
			subgroup = "space-crushing",
			enabled = false,
			energy_required = 1,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/organic-chitin-plate.png", icon_size = 64 },
				{ icon = "__PlanetsLib__/graphics/icons/asteroid-crushing.png", icon_size = 64 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-radiation-hardened-chitin", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-chitin", amount = 4 },
				{ type = "item", name = "tenebris-radiation-hardened-chitin", amount = 1, probability = 0.2 },
			},
			main_product = "tenebris-chitin",
			surface_conditions = {
				{
					property = "innate-energy-luminosity",
					min = 1
				}
			},
		},
		{
			type = "recipe",
			name = "tenebris-cupric-mercury-amalgam",
			category = "metallurgy",
			subgroup = "tenebris-mercury-products",
			enabled = false,
			energy_required = 12,
			ingredients = {
				{ type = "item", name = "tenebris-cupric-waste", amount = 2 },
				{ type = "fluid", name = "tenebris-mercury", amount = 100 },
			},
			results = {
				{ type = "item", name = "tenebris-cupric-mercury-amalgam", amount = 2 },
			},
		},
		-- Biopipe from chitin (early, tenecap-processing)
		{
			type = "recipe",
			name = "tenebris-biopipe",
			category = "crafting",
			subgroup = "tenebris-fluid-logistics",
			enabled = false,
			energy_required = 0.5,
			icons = {
				{ icon = "__base__/graphics/icons/pipe.png", icon_size = 64, scale = 0.5, tint = tenebris.TINT.CHITOSAN },
				{ icon = "__tenebris-prime__/graphics/icons/chitin.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-ferric-waste", amount = 2 },
				{ type = "item", name = "tenebris-chitin", amount = 6 },
			},
			results = {
				{ type = "item", name = "tenebris-biopipe", amount = 1 },
			},
		},
		-- Biopipe from chitosan (later, chitosan tech)
		{
			type = "recipe",
			name = "tenebris-biopipe-from-chitosan",
			category = "crafting",
			subgroup = "tenebris-fluid-logistics",
			enabled = false,
			energy_required = 0.5,
			ingredients = {
				{ type = "item", name = "tenebris-chitosan", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-biopipe", amount = 1 },
			},
		},
		-- Biopipe to ground from chitin (early, tenecap-processing)
		{
			type = "recipe",
			name = "tenebris-biopipe-to-ground",
			category = "crafting",
			subgroup = "tenebris-fluid-logistics",
			enabled = false,
			energy_required = 0.5,
			icons = {
				{ icon = "__base__/graphics/icons/pipe-to-ground.png", icon_size = 64, scale = 0.5, tint = tenebris.TINT.CHITOSAN },
				{ icon = "__tenebris-prime__/graphics/icons/chitin.png", icon_size = 64, shift = {8, 8}, scale = 0.4 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-biopipe", amount = 10 },
				{ type = "item", name = "tenebris-chitin", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-biopipe-to-ground", amount = 2 },
			},
		},
		-- Biopipe to ground from chitosan (later, chitosan tech)
		{
			type = "recipe",
			name = "tenebris-biopipe-to-ground-from-chitosan",
			category = "crafting",
			subgroup = "tenebris-fluid-logistics",
			enabled = false,
			energy_required = 0.5,
			ingredients = {
				{ type = "item", name = "tenebris-biopipe", amount = 10 },
				{ type = "item", name = "tenebris-chitosan", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-biopipe-to-ground", amount = 2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-lubricant",
			category = "chemistry",
			subgroup = "fluid-recipes",
			enabled = false,
			energy_required = 1,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/chitosan.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__tenebris-prime__/graphics/icons/fluid/mercury.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/fluid/lubricant.png", icon_size = 64, shift = {0, 8}, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-chitosan", amount = 1 },
				{ type = "fluid", name = "tenebris-mercury", amount = 50 },
			},
			results = {
				{ type = "fluid", name = "lubricant", amount = 10 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-quartz-ortet-robo-interface",
			category = "crafting",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 5,
			ingredients = {
				{ type = "item", name = "roboport", amount = 1 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 8 },
				{ type = "item", name = "electric-mining-drill", amount = 2 },
				{ type = "item", name = "piezoelectric-converter-capture-bot-rocket", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-quartz-ortet-robo-interface", amount = 1 },
			},
		},
		-- ========================================
		-- LIGHTLESS BEACONS
		-- ========================================
		{
			type = "recipe",
			name = "tenebris-bioinfusor",
			category = "cryogenics",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 5,
			ingredients = {
				{ type = "item", name = "quantum-processor", amount = 200 },
				{ type = "item", name = "electromagnetic-plant", amount = 1 },
				{ type = "item", name = "tenebris-chitosan", amount = 100 },
				{ type = "item", name = "tenebris-crystal-oscillator", amount = 20 },
			},
			results = {
				{ type = "item", name = "tenebris-bioinfusor", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-biobeacon",
			category = "cryogenics",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "fluid", name = "fluoroketone-cold", amount = 200 },
				{ type = "item", name = "tenebris-crystal-oscillator", amount = 16 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 30 },
				{ type = "item", name = "beacon", amount = 2 },
				{ type = "item", name = "quantum-processor", amount = 50 },
			},
			results = {
				{ type = "item", name = "tenebris-biobeacon", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-battery",
			category = "chemistry-or-cryogenics",
			subgroup = "intermediate-product",
			enabled = false,
			energy_required = 4,
			icons = {
				{ icon = "__base__/graphics/icons/copper-plate.png", icon_size = 64, shift = {0, -8}, scale = 0.4 },
				{ icon = "__tenebris-prime__/graphics/icons/ferric-waste.png", icon_size = 64, shift = {-8, 8}, scale = 0.35 },
				{ icon = "__base__/graphics/icons/battery.png", icon_size = 64, shift = {8, 8}, scale = 0.45 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-cupric-mercury-amalgam", amount = 1 },
				{ type = "item", name = "tenebris-ferric-waste", amount = 1 },
				{ type = "fluid", name = "sulfuric-acid", amount = 20 },
			},
			results = {
				{ type = "item", name = "battery", amount = 2 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-rocket-part",
			category = "rocket-building",
			subgroup = "space-related",
			enabled = false,
			energy_required = 3,
			hide_from_player_crafting = true,
			auto_recycle = false,
			ingredients = {
				{ type = "item", name = "rocket-fuel", amount = 1 },
				{ type = "item", name = "carbon-fiber", amount = 1 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 1 },
				{ type = "item", name = "tenebris-crystal-oscillator", amount = 1 },
			},
			results = {
				{ type = "item", name = "rocket-part", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-robot-frame",
			category = "crafting",
			subgroup = "tenebris-ceramic-products",
			enabled = false,
			energy_required = 20,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 1 },
				{ type = "item", name = "supercapacitor", amount = 2 },
				{ type = "item", name = "carbon-fiber", amount = 1 },
				{ type = "item", name = "piezoelectric-motor", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-robot-frame", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-construction-robot",
			category = "crafting",
			subgroup = "logistic-network",
			enabled = false,
			energy_required = 0.5,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-robot-frame", amount = 1 },
				{ type = "item", name = "tenebris-chitosan", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-construction-robot", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-logistic-robot",
			category = "crafting",
			subgroup = "logistic-network",
			enabled = false,
			energy_required = 0.5,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-robot-frame", amount = 1 },
				{ type = "item", name = "luciferin", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-logistic-robot", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-ceramic-plated-heat-pipe",
			category = "metallurgy-or-assembling",
			subgroup = "tenebris-thermal-energy",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type = "item", name = "heat-pipe", amount = 1 },
				{ type = "item", name = "tenebris-ceramic-plate", amount = 4 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-plated-heat-pipe", amount = 1 },
			},
		},
		-- Thermal Battery - high thermal mass heat storage
		{
			type = "recipe",
			name = "tenebris-thermal-battery",
			category = "metallurgy",
			subgroup = "tenebris-thermal-energy",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "heat-pipe", amount = 20 },
				{ type = "item", name = "tenebris-quartz-ore", amount = 200 },
				{ type = "item", name = "tungsten-plate", amount = 200 },
			},
			results = {
				{ type = "item", name = "tenebris-thermal-battery", amount = 1 },
			},
		},
		-- Steel Thermal Diode - one-way heat flow with threshold control
		{
			type = "recipe",
			name = "tenebris-steel-thermal-diode",
			category = "electromagnetics",
			subgroup = "tenebris-thermal-energy",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type = "item", name = "heat-pipe", amount = 4 },
				{ type = "item", name = "decider-combinator", amount = 1 },
				{ type = "item", name = "piezoelectric-motor", amount = 2 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-steel-thermal-diode", amount = 1 },
			},
		},
		-- Ceramic Thermal Diode - faster heat transfer variant
		{
			type = "recipe",
			name = "tenebris-ceramic-thermal-diode",
			category = "electromagnetics",
			subgroup = "tenebris-thermal-energy",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-plated-heat-pipe", amount = 4 },
				{ type = "item", name = "decider-combinator", amount = 1 },
				{ type = "item", name = "piezoelectric-motor", amount = 2 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 4 },
			},
			results = {
				{ type = "item", name = "tenebris-ceramic-thermal-diode", amount = 1 },
			},
		},
		-- Piezoelectric Capture Bot Rocket - captures quartz forest entities
		{
			type = "recipe",
			name = "piezoelectric-converter-capture-bot-rocket",
			category = "electromagnetics",
			subgroup = "ammo",
			enabled = false,
			energy_required = 5,
			ingredients = {
				{ type = "item", name = "tenebris-radiation-hardened-chitin", amount = 4 },
				{ type = "item", name = "capture-robot-rocket", amount = 1 },
				{ type = "item", name = "superconductor", amount = 2 },
				{ type = "item", name = "heat-exchanger", amount = 2 },
			},
			results = {
				{ type = "item", name = "piezoelectric-converter-capture-bot-rocket", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "piezoelectric-lamp",
			category = "crafting",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "small-lamp", amount = 5 },
				{ type = "item", name = "supercapacitor", amount = 2 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 1 },
			},
			results = {
				{ type = "item", name = "piezoelectric-lamp", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-heated-atmosphere-scrubber",
			category = "crafting",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "quantum-processor", amount = 10 },
				{ type = "item", name = "tenebris-chitin", amount = 30 },
				{ type = "item", name = "heating-tower", amount = 2 },
				{ type = "item", name = "efficiency-module-3", amount = 4 },
				{ type = "item", name = "atan-air-scrubber", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-heated-atmosphere-scrubber", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-heated-pumpjack",
			category = "crafting",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 5,
			ingredients = {
				{ type = "item", name = "pumpjack", amount = 1 },
				{ type = "item", name = "heat-pipe", amount = 10 },
				{ type = "item", name = "tenebris-chitin", amount = 20 },
				{ type = "item", name = "tungsten-plate", amount = 10 },
			},
			results = {
				{ type = "item", name = "tenebris-heated-pumpjack", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-heated-big-mining-drill",
			category = "crafting",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "big-mining-drill", amount = 1 },
				{ type = "item", name = "heat-pipe", amount = 20 },
				{ type = "item", name = "tenebris-chitin", amount = 40 },
				{ type = "item", name = "tungsten-plate", amount = 20 },
			},
			results = {
				{ type = "item", name = "tenebris-heated-big-mining-drill", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-resonance-chamber",
			category = "crafting-with-fluid",
			subgroup = "tenebris-machines",
			enabled = false,
			energy_required = 20,
			ingredients = {
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 40 },
				{ type = "item", name = "speed-module-3", amount = 2 },
				{ type = "item", name = "tenebris-ceramic-plate", amount = 100 },
				{ type = "item", name = "tenebris-chitosan", amount = 10 },
				{ type = "item", name = "heating-tower", amount = 2 },
				{ type = "fluid", name = "tenebris-mercury", amount = 1000 },
			},
			results = {
				{ type = "item", name = "tenebris-crystal-resonance-chamber", amount = 1 },
			},
		},

		-- ========================================
		-- MERCURIAL BIOTA (PHASE 2 TRANSITION)
		-- ========================================

		{
			type = "recipe",
			name = "tenebris-molten-bismuth",
			category = "metallurgy",
			subgroup = "tenebris-metallurgy",
			enabled = false,
			energy_required = 32,
			icons = {
				{ icon = "__tenebris-prime__/graphics/icons/bismuth-ore.png", icon_size = 64, shift = {-8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/calcite.png", icon_size = 64, shift = {8, -8}, scale = 0.35 },
				{ icon = "__space-age__/graphics/icons/fluid/molten-iron.png", icon_size = 64, shift = {0, 6}, scale = 0.6 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-bismuth-ore", amount = 20 },
				{ type = "item", name = "calcite", amount = 1 },
			},
			results = {
				{ type = "fluid", name = "tenebris-molten-bismuth", amount = 500 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "mercurial-archaea-cultivation",
			category = "organic",
			subgroup = "tenebris-mercury-products",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "fluid", name = "tenebris-molten-bismuth", amount = 10 },
				{ type = "item", name = "mercurial-archaea", amount = 30 },
			},
			results = {
				{ type = "item", name = "mercurial-stromatolite", amount = 2 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "overgrowth-luciferin-soil",
			category = "organic",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "overgrowth-jellynut-soil", amount = 1 },
				{ type = "item", name = "lucifunnel-seed", amount = 12 },
				{ type = "item", name = "luciferin", amount = 40 },
				{ type = "item", name = "tenebris-chitin", amount = 4 },
			},
			results = {
				{ type = "item", name = "overgrowth-luciferin-soil", amount = 1 },
			},
			allow_productivity = true,
		},
		{
			type = "recipe",
			name = "overgrowth-tenecap-soil",
			category = "organic",
			subgroup = "tenebris-organic-products",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "overgrowth-yumako-soil", amount = 1 },
				{ type = "item", name = "tenecap-spore", amount = 50 },
				{ type = "item", name = "luciferin", amount = 40 },
				{ type = "item", name = "tenebris-chitin", amount = 4 },
			},
			results = {
				{ type = "item", name = "overgrowth-tenecap-soil", amount = 1 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- CRYSTAL RESONANCE CHAMBER RECIPES
		-- ========================================

		-- Seedling → Geode (1 recipe)
		{
			type = "recipe",
			name = "tenebris-quartz-geode",
			category = "crystal-resonance",
			subgroup = "tenebris-minerals",
			enabled = false,
			energy_required = 10,
			ingredients = {
				{ type = "item", name = "tenebris-crystal-seedling", amount = 1 },
				{ type = "fluid", name = "tenebris-quartz-slurry", amount = 50 },
			},
			results = {
				{ type = "item", name = "tenebris-quartz-geode", amount = 1 },
			},
			allow_productivity = true,
		},

		-- Crystal Reprocessing (2 same → 1 random different, 6 recipes)
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-citrine",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/citrine.png", icon_size = 64, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-citrine", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-onyx", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-prasiolite", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-amethyst", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-ruby-agate", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-sapphire-agate", amount = 1, probability = 0.2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-onyx",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/onyx.png", icon_size = 64, scale = 0.5, tint = tenebris.TINT.ONYX },
			},
			ingredients = {
				{ type = "item", name = "tenebris-onyx", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-prasiolite", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-amethyst", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-ruby-agate", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-sapphire-agate", amount = 1, probability = 0.2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-prasiolite",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/prasiolite.png", icon_size = 64, scale = 0.5, tint = tenebris.TINT.PRASIOLITE },
			},
			ingredients = {
				{ type = "item", name = "tenebris-prasiolite", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-onyx", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-amethyst", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-ruby-agate", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-sapphire-agate", amount = 1, probability = 0.2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-amethyst",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/amethyst.png", icon_size = 64, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-amethyst", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-onyx", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-prasiolite", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-ruby-agate", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-sapphire-agate", amount = 1, probability = 0.2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-ruby-agate",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64, scale = 0.5 },
			},
			ingredients = {
				{ type = "item", name = "tenebris-ruby-agate", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-onyx", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-prasiolite", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-amethyst", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-sapphire-agate", amount = 1, probability = 0.2 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-crystal-reprocess-sapphire-agate",
			category = "crystal-resonance",
			subgroup = "tenebris-cr-reprocess",
			enabled = false,
			energy_required = 8,
			icons = {
				{ icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png", icon_size = 64, scale = 0.8 },
				{ icon = "__tenebris-prime__/graphics/icons/crystals/agate.png", icon_size = 64, scale = 0.5, tint = tenebris.TINT.SAPPHIRE },
			},
			ingredients = {
				{ type = "item", name = "tenebris-sapphire-agate", amount = 2 },
			},
			results = {
				{ type = "item", name = "tenebris-citrine", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-onyx", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-prasiolite", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-amethyst", amount = 1, probability = 0.2 },
				{ type = "item", name = "tenebris-ruby-agate", amount = 1, probability = 0.2 },
			},
		},

		-- ========================================
		-- SPACE RESOURCES
		-- ========================================

		{
			type = "recipe",
			name = "bismuth-asteroid-crushing",
			icons = {
				{ icon = "__space-age__/graphics/icons/promethium-asteroid-chunk.png", icon_size = 64 },
				{ icon = "__PlanetsLib__/graphics/icons/asteroid-crushing.png", icon_size = 64 },
			},
			category = "crushing",
			subgroup = "space-crushing",
			auto_recycle = false,
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "bismuth-asteroid-chunk", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-bismuth-ore", amount = 10 },
				{ type = "item", name = "bismuth-asteroid-chunk", amount = 1, probability = 0.2 },
			},
			main_product = "tenebris-bismuth-ore",
		},

		{
			type = "recipe",
			name = "infected-carbonic-chunk-crushing",
			icons = {
				{ icon = "__space-age__/graphics/icons/carbonic-asteroid-chunk.png", icon_size = 64, infected = 0.8, tint = centipede_constants.EGGROID_ICON_TINT },
				{ icon = "__PlanetsLib__/graphics/icons/asteroid-crushing.png", icon_size = 64 },
			},
			category = "crushing",
			subgroup = "space-crushing",
			auto_recycle = false,
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "infected-carbonic-chunk", amount = 1 },
			},
			results = {
				{ type = "item", name = "luciferin", amount = 24 },
				{ type = "item", name = "carbon", amount = 3 },
				{ type = "item", name = "infected-carbonic-chunk", amount = 1, probability = 0.2 },
			},
			main_product = "luciferin",
			allow_productivity = true,
		},

		-- ========================================
		-- ROCKET INFRASTRUCTURE
		-- ========================================

		{
			type = "recipe",
			name = "tenebris-rocket-silo",
			category = "crafting-with-fluid",
			subgroup = "space-related",
			enabled = false,
			energy_required = 60,
			ingredients = {
				{ type = "item", name = "concrete", amount = 1000 },
				{ type = "item", name = "tenebris-ceramic-circuitry", amount = 200 },
				{ type = "item", name = "tenebris-biopipe", amount = 100 },
				{ type = "item", name = "piezoelectric-motor", amount = 200 },
				{ type = "fluid", name = "molten-iron", amount = 10000 },
			},
			results = {
				{ type = "item", name = "rocket-silo", amount = 1 },
			},
		},

		-- ========================================
		-- HIGH-ENERGY POTENTIAL FORGING
		-- ========================================

		{
			type = "recipe",
			name = "tenebris-mercurial-lattice",
			category = "crafting",
			subgroup = "tenebris-mercury-products",
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "item", name = "mercurial-archaea", amount = 20 },
				{ type = "item", name = "carbon-fiber", amount = 1 },
			},
			results = {
				{ type = "item", name = "tenebris-mercurial-lattice", amount = 1 },
			},
		},
		{
			type = "recipe",
			name = "tenebris-mercury-vii-plate",
			category = "lightning-smelting",
			subgroup = "tenebris-mercury-products",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type = "item", name = "tenebris-mercurial-lattice", amount = 600 },
			},
			results = {
				{ type = "item", name = "tenebris-mercury-vii-plate", amount = 50 },
			},
			allow_productivity = true,
		},

		-- ========================================
		-- PIEZOELECTRIC HEATING
		-- ========================================
		-- Piezoelectric heating recipe (uses centralized constants)
		(function()
			local piezo = require("lib.piezoelectric_constants")
			return {
				type = "recipe",
				name = piezo.RECIPE.name,
				category = "tenebris-heating",
				subgroup = "tenebris-organic-products",
				icon = "__core__/graphics/arrows/heat-exchange-indication.png",
				icon_size = 48,
				enabled = true, -- Always enabled (used by captured entities)
				hidden = true, -- Not shown in crafting menu
				energy_required = piezo.RECIPE.energy_required,
				ingredients = {},
				results = {
					{ type = "fluid", name = piezo.FLUID.name, amount = piezo.RECIPE.fluid_output, temperature = piezo.FLUID.output_temperature },
				},
			}
		end)(),
}

-- Merge crystal variant recipes into all_recipes and register
for _, recipe in ipairs(crystal_variant_recipes) do
	table.insert(all_recipes, recipe)
end

data:extend(all_recipes)
