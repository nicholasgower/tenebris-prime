meld = require("meld")
local constants = require("lib.constants")

local function order_data(type_name, group_ordering, data_name, order_variable)
    -- Guard: check if the prototype exists before trying to set its order
    if not data.raw[type_name] or not data.raw[type_name][data_name] then
        -- Silently skip if the prototype doesn't exist
        return ""
    end
    
    return meld(data.raw[type_name][data_name], {
        order = string.format("t[tenebris]-%s-%s[%s]", group_ordering, order_variable, data_name)
    })
end

-- For items that need to be positioned relative to base game subgroups
-- prefix: the base game order to position after (e.g., "b" for after "energy")
local function order_data_prefixed(type_name, prefix, group_ordering, data_name, order_variable)
    if not data.raw[type_name] or not data.raw[type_name][data_name] then
        return ""
    end
    
    return meld(data.raw[type_name][data_name], {
        order = string.format("%s-t[tenebris]-%s-%s[%s]", prefix, group_ordering, order_variable, data_name)
    })
end

local function build_group_ordering(group_name, group_order)
    return string.format("%s[%s]", group_order, group_name)
end

-- Items and Recipes
deep_space_sensing = build_group_ordering("deep-space-sensing", "a")
agriculture = build_group_ordering("agriculture", "b")
seeds = build_group_ordering("seeds", "c")
minerals = build_group_ordering("tenebris-minerals", "d")
organic_products = build_group_ordering("tenebris-organic-products", "e")
crystallization = build_group_ordering("crystallization", "f")
atmosphere_filtration = build_group_ordering("tenebris-atmosphere-filtration", "a")
atmosphere_distillation = build_group_ordering("tenebris-atmosphere-processing", "a")
cryogenic_process = build_group_ordering("cryogenic-process", "i")
orbital_harvesting = build_group_ordering("orbital-harvesting", "j")
space_crushing = build_group_ordering("space-crushing", "j-a")
casting = build_group_ordering("casting", "k")
weaponry = build_group_ordering("weaponry", "l")
waste_burning = build_group_ordering("waste-burning", "m")
lightning_processing = build_group_ordering("lightning-processing", "n")
waste_products = build_group_ordering("tenebris-waste-products", "o")
gemstones = build_group_ordering("gemstones", "p")
ceramic_products = build_group_ordering("tenebris-ceramic-products", "q")
piezoelectric_products = build_group_ordering("tenebris-piezoelectric-products", "r")
mercury_products = build_group_ordering("tenebris-mercury-products", "s")
piezoelectric_science = build_group_ordering("tenebris-piezoelectric-science-pack", "y-a")
tenebris_tools = build_group_ordering("tools", "t")
tenebris_pipes = build_group_ordering("pipes", "v")
tenebris_fluid_logistics = build_group_ordering("tenebris-fluid-logistics", "wa")
thermal_energy = build_group_ordering("thermal-energy", "a")
tenebris_machines = build_group_ordering("machines", "ab")
tenebris_logistics = build_group_ordering("logistics", "w")
fluids_atmosphere = build_group_ordering("fluids-atmosphere", "x")
fluids_waste = build_group_ordering("fluids-waste", "y")
fluids_mercury = build_group_ordering("fluids-mercury", "z")
fluids_processing = build_group_ordering("fluids-processing", "za")
cr_reprocess = build_group_ordering("tenebris-cr-reprocess", "q-a-b")
cr_seedlings = build_group_ordering("tenebris-cr-seedlings", "q-a-c")
cr_oscillators = build_group_ordering("tenebris-cr-oscillators", "q-a-d")
cr_motors = build_group_ordering("tenebris-cr-motors", "q-a-e")
cr_science = build_group_ordering("tenebris-cr-science", "q-a-f")
crystal_processing = build_group_ordering("tenebris-crystal-processing", "q-a")
luciferin_fuels = build_group_ordering("tenebris-luciferin-fuels", "a")
tenebris_tech = build_group_ordering("tenebris-tech", "a")
tenebris_locations = build_group_ordering("locations", "a")
tenebris_connections = build_group_ordering("connections", "a")

-- BIOLOGICAL MATERIALS
order_data("item", agriculture, "lucifunnel", "a")
order_data("item", agriculture, "tenecap", "b")

order_data("item", seeds, "lucifunnel-seed", "a")
order_data("recipe", seeds, "lucifunnel-processing", "b")
order_data("item", seeds, "tenecap-spore", "c")
order_data("recipe", seeds, "tenecap-processing", "d")
order_data("item", seeds, "overgrowth-luciferin-soil", "e")
order_data("item", seeds, "overgrowth-tenecap-soil", "f")
order_data("recipe", seeds, "overgrowth-luciferin-soil", "k")
order_data("recipe", seeds, "overgrowth-tenecap-soil", "l")

order_data("item", organic_products, "luciferin", "a")
order_data("item", organic_products, "tenebris-chitin", "b")
order_data("item", organic_products, "tenebris-chitosan", "c")
order_data("recipe", organic_products, "chitin-processing", "d")
order_data("recipe", organic_products, "chitosan-advanced-circuit", "f")
order_data("recipe", organic_products, "chitin-concrete", "g")
order_data("recipe", organic_products, "chitosan-lubricant", "h")
order_data("recipe", organic_products, "chitosan-carbon-fiber", "i")
order_data("recipe", organic_products, "tenebris-chitin-nutrients", "z")  -- At the end of organic products

-- WASTE PRODUCTS
order_data("item", waste_products, "tenebris-ferric-waste", "a")
order_data("item", waste_products, "tenebris-cupric-waste", "b")
order_data("item", waste_products, "tenebris-circuit-waste", "c")
order_data("recipe", waste_products, "molten-iron-from-ferric-waste", "d")
order_data("recipe", waste_products, "molten-copper-from-cupric-waste", "e")
order_data("recipe", waste_products, "tenebris-circuit-waste-recycling", "f")
order_data("recipe", waste_products, "tenebris-repair-pack-from-waste", "g")

-- MINERALS & ORES (Crystal Resonance Chamber flow)
order_data("resource", minerals, "tenebris-exposed-lichen-deposit", "a")
order_data("recipe", minerals, "tenebris-stone-centrifuging", "b")
order_data("item", minerals, "tenebris-quartz-ore", "c")
order_data("item", minerals, "tenebris-quartz-geode", "d")
order_data("recipe", minerals, "tenebris-quartz-geode", "e")
order_data("recipe", minerals, "tenebris-quartz-geode-processing", "f")
order_data("recipe", minerals, "tenebris-quartz-slurry", "g")
order_data("item", minerals, "tenebris-bismuth-ore", "h")
order_data("item", minerals, "tenebris-cinnabar", "i")

-- GEMSTONES
order_data("item", gemstones, "tenebris-onyx", "a")
order_data("item", gemstones, "tenebris-citrine", "b")
order_data("item", gemstones, "tenebris-prasiolite", "c")
order_data("item", gemstones, "tenebris-amethyst", "d")
order_data("item", gemstones, "tenebris-ruby-agate", "e")
order_data("item", gemstones, "tenebris-sapphire-agate", "f")

-- CERAMIC PRODUCTS
order_data("item", ceramic_products, "tenebris-ceramic-plate", "a")
order_data("item", ceramic_products, "tenebris-ceramic-filter", "b")
order_data("item", ceramic_products, "tenebris-used-ceramic-filter", "c")
order_data("item", ceramic_products, "tenebris-carbon-spore-filter", "d")
order_data("item", ceramic_products, "tenebris-used-carbon-spore-filter", "e")
order_data("item", ceramic_products, "tenebris-ceramic-circuitry", "f")
order_data("item", ceramic_products, "tenebris-ceramic-robot-frame", "g")
order_data("item", crystal_processing, "tenebris-crystal-seedling", "a")
order_data("item", crystal_processing, "tenebris-crystal-oscillator", "b")

-- Row 2: Reprocessing
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-citrine", "a")
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-onyx", "b")
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-prasiolite", "c")
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-amethyst", "d")
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-ruby-agate", "e")
order_data("recipe", cr_reprocess, "tenebris-crystal-reprocess-sapphire-agate", "f")

-- Row 3: Crystal Seedlings (from quartz slurry first, then from crystals)
order_data("recipe", cr_seedlings, "tenebris-crystal-seedling", "a")
order_data("recipe", cr_seedlings, "crystal-seedling-from-citrine", "b")
order_data("recipe", cr_seedlings, "crystal-seedling-from-onyx", "c")
order_data("recipe", cr_seedlings, "crystal-seedling-from-prasiolite", "d")
order_data("recipe", cr_seedlings, "crystal-seedling-from-amethyst", "e")
order_data("recipe", cr_seedlings, "crystal-seedling-from-ruby-agate", "f")
order_data("recipe", cr_seedlings, "crystal-seedling-from-sapphire-agate", "g")

-- Row 4: Oscillators
order_data("recipe", cr_oscillators, "crystal-oscillator-citrine", "a")
order_data("recipe", cr_oscillators, "crystal-oscillator-onyx", "b")
order_data("recipe", cr_oscillators, "crystal-oscillator-prasiolite", "c")
order_data("recipe", cr_oscillators, "crystal-oscillator-amethyst", "d")
order_data("recipe", cr_oscillators, "crystal-oscillator-ruby-agate", "e")
order_data("recipe", cr_oscillators, "crystal-oscillator-sapphire-agate", "f")

-- Row 5: Piezoelectric Motors
order_data("recipe", cr_motors, "piezoelectric-motor-citrine", "a")
order_data("recipe", cr_motors, "piezoelectric-motor-onyx", "b")
order_data("recipe", cr_motors, "piezoelectric-motor-prasiolite", "c")
order_data("recipe", cr_motors, "piezoelectric-motor-amethyst", "d")
order_data("recipe", cr_motors, "piezoelectric-motor-ruby-agate", "e")
order_data("recipe", cr_motors, "piezoelectric-motor-sapphire-agate", "f")

-- Row 6: Piezoelectric Science
order_data("recipe", cr_science, "piezoelectric-science-pack-citrine", "a")
order_data("recipe", cr_science, "piezoelectric-science-pack-onyx", "b")
order_data("recipe", cr_science, "piezoelectric-science-pack-prasiolite", "c")
order_data("recipe", cr_science, "piezoelectric-science-pack-amethyst", "d")
order_data("recipe", cr_science, "piezoelectric-science-pack-ruby-agate", "e")
order_data("recipe", cr_science, "piezoelectric-science-pack-sapphire-agate", "f")

-- MERCURY PRODUCTS
order_data("recipe", mercury_products, "tenebris-cinnabar", "a")
order_data("item", mercury_products, "tenebris-cupric-mercury-amalgam", "b")
order_data("recipe", mercury_products, "tenebris-cupric-mercury-amalgam", "c")
order_data("item", mercury_products, "mercurial-stromatolite", "d")
order_data("item", mercury_products, "mercurial-archaea", "e")
order_data("recipe", mercury_products, "mercurial-archaea-cultivation", "f")
order_data("item", mercury_products, "tenebris-mercurial-vat", "g")
order_data("recipe", mercury_products, "tenebris-mercurial-vat", "h")
order_data("item", mercury_products, "tenebris-mercury-vii-plate", "i")
order_data("recipe", mercury_products, "tenebris-mercury-vii-plate", "j")

-- PIEZOELECTRIC PRODUCTS
order_data("item", piezoelectric_products, "piezoelectric-converter", "a")
order_data("item", piezoelectric_products, "piezoelectric-motor", "b")

-- PIEZOELECTRIC SCIENCE PACK
order_data("tool", piezoelectric_science, "piezoelectric-science-pack", "a")
-- Recipe ordering now in crystal resonance chamber section (cr_science)

-- TOOLS & EQUIPMENT
-- (repair-pack is base game item, recipe is tenebris-repair-pack-from-waste)
order_data("recipe", tenebris_tools, "tenebris-repair-pack-from-waste", "a")

-- MACHINES & BUILDINGS
order_data("item", tenebris_machines, "tenebris-heated-atmosphere-scrubber", "a")
order_data("recipe", tenebris_machines, "tenebris-heated-atmosphere-scrubber", "b")
order_data("item", tenebris_machines, "tenebris-heated-pumpjack", "c")
order_data("recipe", tenebris_machines, "tenebris-heated-pumpjack", "d")
order_data("item", tenebris_machines, "tenebris-heated-big-mining-drill", "e")
order_data("recipe", tenebris_machines, "tenebris-heated-big-mining-drill", "f")
order_data("item", tenebris_machines, "tenebris-crystal-resonance-chamber", "g")
order_data("recipe", tenebris_machines, "tenebris-crystal-resonance-chamber", "h")
order_data("item", tenebris_machines, "tenebris-heated-agricultural-tower", "i")
-- heated agricultural tower recipes are crystal variants, ordered in cr_science section
order_data("item", tenebris_machines, "tenebris-lightning-furnace", "j")
-- lightning furnace recipes are crystal variants, ordered in cr_science section
order_data("item", tenebris_machines, "tenebris-quartz-ortet-robo-interface", "k")
order_data("recipe", tenebris_machines, "tenebris-quartz-ortet-robo-interface", "l")
order_data("item", tenebris_machines, "tenebris-bioinfusor", "m")
order_data("recipe", tenebris_machines, "tenebris-bioinfusor", "n")
order_data("item", tenebris_machines, "tenebris-biobeacon", "o")
order_data("recipe", tenebris_machines, "tenebris-biobeacon", "p")

-- PIPES
order_data("item", tenebris_fluid_logistics, "tenebris-biopipe", "a")
order_data("item", tenebris_fluid_logistics, "tenebris-biopipe-to-ground", "b")
order_data("recipe", tenebris_fluid_logistics, "tenebris-biopipe", "c")
order_data("recipe", tenebris_fluid_logistics, "tenebris-biopipe-from-chitosan", "d")
order_data("recipe", tenebris_fluid_logistics, "tenebris-biopipe-to-ground", "e")
order_data("recipe", tenebris_fluid_logistics, "tenebris-biopipe-to-ground-from-chitosan", "f")

-- THERMAL ENERGY (production group, after base "energy" subgroup which is "b")
order_data_prefixed("item-subgroup", "b", thermal_energy, "tenebris-thermal-energy", "")
order_data_prefixed("item", "b", thermal_energy, "tenebris-ceramic-plated-heat-pipe", "a")
order_data_prefixed("recipe", "b", thermal_energy, "tenebris-ceramic-plated-heat-pipe", "b")
order_data_prefixed("item", "b", thermal_energy, "tenebris-thermal-battery", "c")
order_data_prefixed("recipe", "b", thermal_energy, "tenebris-thermal-battery", "d")
order_data_prefixed("item", "b", thermal_energy, "tenebris-steel-thermal-diode", "e")
order_data_prefixed("recipe", "b", thermal_energy, "tenebris-steel-thermal-diode", "f")
order_data_prefixed("item", "b", thermal_energy, "tenebris-ceramic-thermal-diode", "g")
order_data_prefixed("recipe", "b", thermal_energy, "tenebris-ceramic-thermal-diode", "h")

-- LOGISTICS
order_data("item", tenebris_logistics, "piezoelectric-inserter", "a")
order_data("item", tenebris_logistics, "tenebris-ceramic-construction-robot", "b")
order_data("item", tenebris_logistics, "tenebris-ceramic-logistic-robot", "c")
order_data("ammo", tenebris_logistics, "piezoelectric-converter-capture-bot-rocket", "d")
order_data("item", tenebris_logistics, "piezoelectric-lamp", "e")
order_data("recipe", tenebris_logistics, "piezoelectric-lamp", "f")

-- FLUIDS
order_data("fluid", fluids_atmosphere, "tenebris-atmosphere", "a")

order_data("fluid", fluids_waste, "sulfinated-spore-waste", "a")

order_data("fluid", fluids_mercury, "tenebris-mercury", "a")

order_data("fluid", fluids_processing, "tenebris-hydrofluoric-acid", "a")

-- LEGACY CRYSTALLIZATION (to be deprecated)
order_data("item", crystallization, "quartz-crystal", "a")
order_data("item", crystallization, "quartz-crystal-seedling", "b")
order_data("recipe", crystallization, "quartz-ore-washing", "c")
order_data("recipe", crystallization, "quartz-crystal-reduction", "d")
order_data("item", crystallization, "photonic-crystal", "e")
order_data("item", crystallization, "bioluminescent-crystal", "f")
order_data("recipe", crystallization, "bioluminescent-crystal-organics", "g")
order_data("recipe", crystallization, "bioluminescent-crystal-forging", "h")

-- LEGACY ATMOSPHERE FILTRATION (to be updated)
-- Atmosphere filtration: scrubber, filters (build/clean), scrubbing recipes
order_data("item", atmosphere_filtration, "tenebris-heated-atmosphere-scrubber", "a")
order_data("recipe", atmosphere_filtration, "tenebris-heated-atmosphere-scrubber", "b")
order_data("recipe", atmosphere_filtration, "tenebris-carbon-spore-filter", "c")
order_data("recipe", atmosphere_filtration, "tenebris-carbon-spore-filter-cleaning", "d")
order_data("recipe", atmosphere_filtration, "tenebris-ceramic-filter", "e")
order_data("recipe", atmosphere_filtration, "tenebris-ceramic-filter-cleaning", "f")
order_data("recipe", atmosphere_filtration, "tenebris-atmosphere-scrubbing-carbon", "g")
order_data("recipe", atmosphere_filtration, "tenebris-atmosphere-scrubbing-ceramic", "h")

order_data("recipe", atmosphere_distillation, "tenebris-atmosphere", "a")
order_data("recipe", atmosphere_distillation, "tenebris-atmosphere-separation", "b")
order_data("item", atmosphere_distillation, "sulfuric-waste-spores", "c")
order_data("recipe", atmosphere_distillation, "tenecap-spore-purification", "d")

order_data("recipe", cryogenic_process, "sulfuric-fluoroketone", "a")
order_data("recipe", cryogenic_process, "ammonic-acidification", "b")

-- LUCIFERIN FUELS
order_data("recipe", luciferin_fuels, "luciferin-solid-fuel", "a")
order_data("recipe", luciferin_fuels, "luciferin-rocket-fuel", "b")
order_data("recipe", luciferin_fuels, "tenebris-luciferin-explosives", "c")

-- WEAPONRY
order_data("gun", weaponry, "tenebris-flare-gun", "a")
order_data("ammo", weaponry, "tenebris-flare-ammo", "b")

order_data("item", orbital_harvesting, "bismuth-ore", "a")

-- SPACE CRUSHING (centipede corpses, chitin, bismuth)
order_data("recipe", space_crushing, "tenebris-centipede-corpse-grinding", "a")
order_data("recipe", space_crushing, "tenebris-radiation-hardened-chitin-processing", "b")
order_data("recipe", space_crushing, "infected-carbonic-chunk-crushing", "c")
order_data("recipe", space_crushing, "bismuth-asteroid-crushing", "d")

order_data("recipe", casting, "bismuth-ore-melting", "a")
order_data("item", casting, "quartziferous-bismuthal-plate", "b")

order_data("recipe", waste_burning, "lucifunnel-burning", "a")
order_data("recipe", waste_burning, "chitin-burning", "b")

order_data("item", deep_space_sensing, "observation-satellite", "a")
order_data("recipe", deep_space_sensing, "observation-satellite", "b")

-- Lightning furnace moved to tenebris_machines

-- Technologies
order_data("technology", tenebris_tech, "deep-space-sensing", "aa")
order_data("technology", tenebris_tech, "planet-discovery-tenebris", "ab")
order_data("technology", tenebris_tech, "lucifunnel-processing", "ac")
order_data("technology", tenebris_tech, "tenecap-processing", "ad")
order_data("technology", tenebris_tech, "tenebris-flare-gun", "ae")
order_data("technology", tenebris_tech, "quartz-ore", "af")
order_data("technology", tenebris_tech, "quartz-crystal", "ag")
order_data("technology", tenebris_tech, "tenebris-atmosphere-separation", "ah")
order_data("technology", tenebris_tech, "chitin-processing", "ai")
order_data("technology", tenebris_tech, "piezoelectric-science-pack", "aj")
order_data("technology", tenebris_tech, "deep-space-discovery-tenespace", "ak")
order_data("technology", tenebris_tech, "lightless-beacons", "al")
order_data("technology", tenebris_tech, "luciferin-explosives", "am")
order_data("technology", tenebris_tech, "luciferin-rocketry-speed", "an")
order_data("technology", tenebris_tech, "quartz-crystal-reduction", "ao")
order_data("technology", tenebris_tech, "tenebris-soil-enrichment", "ap")
order_data("technology", tenebris_tech, "ammonic-acidification", "aq")
order_data("technology", tenebris_tech, "sulfuric-ketones", "ar")
order_data("technology", tenebris_tech, "bioluminescent-crystal", "as")
order_data("technology", tenebris_tech, "tenebris-bioinfusor", "at")
order_data("technology", tenebris_tech, "bioluminescent-science-pack", "au")
-- order_data("technology", tenebris_tech, "photonic-derangement", "av") -- Removed - tech doesn't exist
order_data("technology", tenebris_tech, "bismuthal-alloys", "aw")
order_data("technology", tenebris_tech, "tenebris-biobeacon", "ax")
order_data("technology", tenebris_tech, "tenebris-laser-cannon", "ay")
order_data("technology", tenebris_tech, "tenebris-laser-shooting-speed", "az")
order_data("technology", tenebris_tech, "tenebris-beacon-distribution-efficiency", "ba")
order_data("technology", tenebris_tech, "cloaking", "bb")
order_data("technology", tenebris_tech, "bioluminescent-robots", "bc")
order_data("technology", tenebris_tech, "worker-robot-battery-capacity", "bd")
order_data("technology", tenebris_tech, "bioluminescent-lamps", "bd")
order_data("technology", tenebris_tech, "deep-space-discovery-lightless-abyss", "be")
order_data("technology", tenebris_tech, "tenebris-lightning-furnace", "bf")

-- Space Locations
order_data("planet", tenebris_locations, constants.PLANET.TENEBRIS, "aa")
order_data("space-location", tenebris_locations, "iridescent-river", "ab")
order_data("space-location", tenebris_locations, "the-nest", "ac")
order_data("space-location", tenebris_locations, "lightless-gateway", "ad")
order_data("space-location", tenebris_locations, "lightless-abyss", "ae")

-- Space Connections
order_data("space-connection", tenebris_connections, "fulgora-tenebris", "aa")
order_data("space-connection", tenebris_connections, "tenebris-iridescent-river", "ab")
order_data("space-connection", tenebris_connections, "tenebris-the-nest", "ac")
order_data("space-connection", tenebris_connections, "iridescent-river-the-nest", "ad")
order_data("space-connection", tenebris_connections, "iridescent-river-lightless-gateway", "ae")
order_data("space-connection", tenebris_connections, "the-nest-lightless-gateway", "af")
order_data("space-connection", tenebris_connections, "lightless-gateway-lightless-abyss", "ag")