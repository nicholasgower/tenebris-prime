--- Phase 1 Tenebris Technologies
--- Clean redesign of all technologies for the Tenebris planet

local constants = require("__tenebris-prime__.prototypes.constants")
local tenebris = require("__tenebris-prime__.lib.tenebris")

data:extend({
    -- ========================================
    -- DEEP SPACE EXPLORATION
    -- ========================================
    {
        type = "technology",
        name = "deep-space-sensing",
        icon = "__base__/graphics/icons/satellite.png",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "observation-satellite"
            },
            {
                type = "nothing",
                use_icon_overlay_constant = true,
                icon = "__base__/graphics/icons/satellite.png",
                icon_size = 64,
                effect_description = "Launch [item=observation-satellite] to locate celestial bodies in deep space."
            },
        },
        unit = {
            count = 5000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 },
            },
            time = 60
        },
        prerequisites = { 
            "metallurgic-science-pack", 
            "electromagnetic-science-pack",
            "utility-science-pack",
            "production-science-pack",
        },
    },
    {
        type = "technology",
        name = "planet-discovery-tenebris",
        icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/starmap-icon-tenebris.png", 3840),
        effects = {
            {
                type = "unlock-space-location",
                space_location = tenebris.PLANET.TENEBRIS,
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-repair-pack-from-waste"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-centipede-corpse-grinding"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-radiation-hardened-chitin-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "infected-carbonic-chunk-crushing"
            }
        },
        localised_description = {"space-location-description.tenebris"},
        prerequisites = { "deep-space-sensing", "railgun", "overgrowth-soil" },
        research_trigger = {
            type = "scripted",
            icon = "__base__/graphics/icons/satellite.png",
            icon_size = 64,
            trigger_description = {"", "Launch [item=observation-satellite] and scan for ", "[planet=tenebris]", " via Deep Space Sensing."}
        }
    },
    
    -- ========================================
    -- TENEBRIS MECH ARMOR ADAPTATION
    -- ========================================
    {
        type = "technology",
        name = "tenebris-mech-adaptation",
        icons = {
            { icon = "__space-age__/graphics/technology/mech-armor.png", icon_size = 256 },
            { icon = "__tenebris-prime__/graphics/icons/starmap-icon-tenebris.png", icon_size = 3840, scale = 0.025, shift = {0, 60} },
        },
        effects = {
            {
                type = "nothing",
                icon = "__space-age__/graphics/icons/mech-armor.png",
                icon_size = 64,
                effect_description = {"tenebris-mech-adaptation.effect-description"}
            }
        },
        localised_description = {"technology-description.tenebris-mech-adaptation"},
        prerequisites = { "tenebris-atmospheric-distillation" },
        unit = {
            count = 100000,
            ingredients = {
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "electromagnetic-science-pack", 1 },
            },
            time = 60
        },
    },
    
    -- ========================================
    -- TENEBRIS BIOLOGICAL PROCESSING
    -- ========================================
    {
        type = "technology",
        name = "tenecap-processing",
        icon = "__tenebris-prime__/graphics/icons/tenecap-processing.png",
        icon_size = 64,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenecap-processing"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-chitin-nutrients"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-heated-atmosphere-scrubber"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-biopipe"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-biopipe-to-ground"
            }
        },
        prerequisites = { "planet-discovery-tenebris" },
        research_trigger = {
            type = "mine-entity",
            entity = "tenecap"
        }
    },
    {
        type = "technology",
        name = "lucifunnel-processing",
        icon = "__tenebris-prime__/graphics/icons/lucifunnel-processing.png",
        icon_size = 64,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "lucifunnel-processing"
            }
        },
        prerequisites = { "planet-discovery-tenebris" },
        research_trigger = {
            type = "mine-entity",
            entity = "lucifunnel"
        }
    },
    {
        type = "technology",
        name = "lichen-deposit-harvesting",
        icon = "__base__/graphics/technology/mining-productivity.png", -- Placeholder
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-stone-centrifuging"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-carbon-spore-filter"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-carbon-spore-filter-cleaning"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-scrubbing-carbon"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-heated-big-mining-drill"
            }
        },
        prerequisites = { "planet-discovery-tenebris" },
        research_trigger = {
            type = "mine-entity",
            entity = "tenebris-exposed-lichen-deposit"
        }
    },
    {
        type = "technology",
        name = "piezoelectric-interfacing",
        icon = "__tenebris-prime__/graphics/technology/piezoelectric-interfacing.png",
        icon_size = 1024,
        effects = {
            { type = "unlock-recipe", recipe = "piezoelectric-converter-capture-bot-rocket" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-citrine" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-onyx" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-prasiolite" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-amethyst" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-ruby-agate" },
            { type = "unlock-recipe", recipe = "tenebris-heated-agricultural-tower-sapphire-agate" },
        },
        prerequisites = { "tenecap-processing", "lichen-deposit-harvesting" },
        -- TODO: This should trigger on mining a quartz geode entity, not crafting the item
        -- Need to create a mineable quartz-geode entity in the world
        research_trigger = {
            type = "mine-entity",
            entity = "quartz-node"
        }
    },
    {
        type = "technology",
        name = "tenebris-atmospheric-distillation",
        icons = {
            { icon = "__tenebris-prime__/graphics/technology/filter-simple.png", icon_size = 1024, scale = 0.2 },
            { icon = "__tenebris-prime__/graphics/technology/gas-cloud-clean-air.png", icon_size = 1024, scale = 0.5, tint = tenebris.TINT.DARK_ATMOSPHERE },
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-separation-carbon"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-separation-ceramic"
            },
            {
                type = "unlock-recipe",
                recipe = "tenecap-spore-purification"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-hydrofluoric-acid"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-heated-pumpjack"
            },
            {
                type = "unlock-recipe",
                recipe = "luciferin-solid-fuel"
            }
        },
        prerequisites = { "lichen-deposit-harvesting", "tenecap-processing", "lucifunnel-processing" },
        research_trigger = {
            type = "craft-item",
            item = "tenebris-used-carbon-spore-filter"
        }
    },
    {
        type = "technology",
        name = "chitosan",
        icon = "__tenebris-prime__/graphics/technology/chitosan.png",
        icon_size = 1024,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-chitosan"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-quartz-slurry"
            },
            {
                type = "unlock-recipe",
                recipe = "chitosan-carbon-fiber"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-lubricant"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-biopipe-from-chitosan"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-biopipe-to-ground-from-chitosan"
            }
        },
        prerequisites = { "tenebris-atmospheric-distillation" },
        research_trigger = {
            type = "craft-fluid",
            fluid = "tenebris-hydrofluoric-acid"
        }
    },
    {
        type = "technology",
        name = "mercury-harvesting",
        icon = "__base__/graphics/technology/oil-gathering.png", -- Placeholder
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-cupric-mercury-amalgam"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-cinnabar"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-battery"
            }
        },
        prerequisites = { "piezoelectric-interfacing" },
        research_trigger = {
            type = "craft-fluid",
            fluid = "tenebris-mercury"
        }
    },
    {
        type = "technology",
        name = "metal-waste-reprocessing",
        icons = {
            { icon = "__tenebris-prime__/graphics/technology/metal-waste-copper.png", icon_size = 1024, shift = {-32, 0} },
            { icon = "__tenebris-prime__/graphics/technology/metal-waste-gear.png", icon_size = 1024 },
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-circuit-waste-recycling"
            },
            {
                type = "unlock-recipe",
                recipe = "molten-iron-from-ferric-waste"
            },
            {
                type = "unlock-recipe",
                recipe = "molten-copper-from-cupric-waste"
            }
        },
        prerequisites = { "piezoelectric-interfacing" },
        research_trigger = {
            type = "scripted",
            icon = "__tenebris-prime__/graphics/icons/electronic-waste.png",
            icon_size = 64,
            trigger_description = {"", "Produce 10,000 [item=tenebris-circuit-waste]. Drop circuits from orbit onto [planet=tenebris] to corrode them into [item=tenebris-circuit-waste]."}
        },
    },
    {
        type = "technology",
        name = "ceramics",
        icons = {
            { icon = "__tenebris-prime__/graphics/technology/ceramics-base.png", icon_size = 256, scale = 0.7, shift = {-24, -24} },
            { icon = "__tenebris-prime__/graphics/technology/ceramics.png", icon_size = 1024, scale = 0.15, shift = {32, 32} },
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-plate"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-circuitry"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-filter"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-filter-cleaning"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-atmosphere-scrubbing-ceramic"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-plated-heat-pipe"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-resonance-chamber"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-seedling"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-quartz-geode"
            },
        },
        prerequisites = { "chitosan", "mercury-harvesting" },
        research_trigger = {
            type = "craft-item",
            item = "tenebris-ceramic-plate"
        }
    },
    
    -- ========================================
    -- DEEP SPACE EXPLORATION - CONTINUED
    -- ========================================
    {
        type = "technology",
        name = "deep-space-discovery-tenespace",
        -- Composite icon: Iridescent River (left) + The Nest (right) with planet discovery symbol
        icons = {
            {
                icon = "__tenebris-prime__/graphics/icons/starmap-icon-iridescent-river.png",
                icon_size = 4096,
                scale = 0.7 * (256 / 4096),  -- Scale to fit left half
                shift = {-32, 32},
            },
            {
                icon = "__tenebris-prime__/graphics/icons/starmap-icon-nest.png",
                icon_size = 3840,
                scale = 0.7 * (256 / 3840),  -- Scale to fit right half
                shift = {32, -32},
            },
            {
                icon = "__core__/graphics/icons/technology/constants/constant-planet.png",
                icon_size = 128,
                scale = 0.5,
                shift = {80, 80},
            },
        },
        effects = {
            {
                type = "unlock-space-location",
                space_location = "iridescent-river",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-space-location",
                space_location = "the-nest",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-recipe",
                recipe = "bismuth-asteroid-crushing"
            },
        },
        research_trigger = {
            type = "scripted",
            icon = "__base__/graphics/icons/satellite.png",
            icon_size = 64,
            trigger_description = {"", "Launch [item=observation-satellite] and scan for Tenespace via Deep Space Sensing."}
        },
        prerequisites = { "piezoelectric-science-pack", "tenebris-rocket-silo" },
    },
    {
        type = "technology",
        name = "tenebris-bismuth-smelting",
        icon = "__space-age__/graphics/technology/foundry.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-molten-bismuth"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-plate-from-molten-bismuth"
            }
        },
        unit = {
            count = 1500,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "deep-space-discovery-tenespace" },
    },
    {
        type = "technology",
        name = "tenebris-luciferin-terraforming",
        icon = "__space-age__/graphics/technology/overgrowth-soil.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "overgrowth-luciferin-soil"
            },
            {
                type = "unlock-recipe",
                recipe = "overgrowth-tenecap-soil"
            }
        },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "deep-space-discovery-tenespace", "overgrowth-soil" },
    },
    {
        type = "technology",
        name = "tenebris-end-of-demo",
        icon = "__base__/graphics/icons/signal/signal-question-mark.png",
        icon_size = 64,
        effects = {},
        research_trigger = {
            type = "scripted",
            icon = "__base__/graphics/icons/signal/signal-question-mark.png",
            icon_size = 64,
            trigger_description = {"", "You have reached the end of the Tenebris Prime demo. More content coming soon!"}
        },
        prerequisites = { 
            "deep-space-discovery-tenespace", 
            "quartz-crystal-sedimentation", 
            "tenebris-rocket-silo" 
        },
    },
    {
        type = "technology",
        name = "deep-space-discovery-lightless-abyss",
        icons = PlanetsLib.technology_icon_planet("__tenebris-prime__/graphics/icons/starmap-icon-lightless-gateway.png", 4096),
        effects = {
            {
                type = "unlock-space-location",
                space_location = "lightless-gateway",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-space-location",
                space_location = "lightless-abyss",
                use_icon_overlay_constant = true
            },
        },
        research_trigger = {
            type = "scripted",
            icon = "__base__/graphics/icons/satellite.png",
            icon_size = 64,
            trigger_description = {"", "Launch [item=observation-satellite] and scan for the Lightless Gateway via Deep Space Sensing."}
        },
        prerequisites = { "tenebris-end-of-demo" },
    },
    {
        type = "technology",
        name = "luciferin-explosives",
        icon = "__tenebris-prime__/graphics/technology/luciferin-explosives.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-luciferin-explosives"
            },
            {
                type = "unlock-recipe",
                recipe = "luciferin-rocket-fuel"
            }
        },
        prerequisites = { "tenebris-atmospheric-distillation", "explosive-rocketry" },
        research_trigger = {
            type = "scripted",
            icon = "__tenebris-prime__/graphics/technology/luciferin-explosives.png",
            icon_size = 256,
            trigger_description = {"", "Destroy a [entity=tenebris-quartz-forest-ortet] Quartz Forest Ortet."}
        },
    },
    {
        type = "technology",
        name = "piezoelectric-science-pack",
        icon = "__tenebris-prime__/graphics/technology/piezoelectric-science-pack.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-citrine"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-onyx"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-prasiolite"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-amethyst"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-ruby-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-science-pack-sapphire-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-citrine"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-onyx"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-prasiolite"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-amethyst"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-ruby-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-motor-sapphire-agate"
            }
        },
        prerequisites = { "ceramics", "metal-waste-reprocessing" },
        research_trigger = {
            type = "craft-item",
            item = "tenebris-ceramic-plate",
            count = 100
        }
    },
    {
        type = "technology",
        name = "piezoelectric-inserter",
        icon = "__space-age__/graphics/technology/stack-inserter.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-citrine"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-onyx"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-prasiolite"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-amethyst"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-ruby-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-inserter-sapphire-agate"
            }
        },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack" },
    },
    {
        type = "technology",
        name = "thermal-logistics",
        icon = "__space-age__/graphics/technology/heating-tower.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-thermal-battery"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-steel-thermal-diode"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-thermal-diode"
            }
        },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack" },
    },
    {
        type = "technology",
        name = "inserter-capacity-bonus-8",
        icon = "__base__/graphics/technology/inserter-capacity.png",
        icon_size = 256,
        effects = {
            {
                type = "inserter-stack-size-bonus",
                modifier = 1  -- Regular inserters: result of 4 (base 1 + 1 from lvl2 + 1 from lvl7 + 1 from lvl8)
            },
            {
                type = "bulk-inserter-capacity-bonus",
                modifier = 4  -- Bulk inserters: result of 16 (base 2 + cumulative bonuses)
            }
        },
        unit = {
            count = 2500,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-inserter", "inserter-capacity-bonus-7" },
    },
    {
        type = "technology",
        name = "tenebris-rocket-silo",
        icon = "__base__/graphics/technology/rocket-silo.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-concrete"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-reinforced-concrete"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-rocket-silo"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-rocket-part"
            }
        },
        unit = {
            count = 5000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack", "luciferin-explosives" },
    },
    {
        type = "technology",
        name = "piezoelectric-lamps",
        icon = "__base__/graphics/technology/lamp.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "piezoelectric-lamp"
            }
        },
        unit = {
            count = 1000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack" },
    },
    {
        type = "technology",
        name = "tenebris-robo-logistics",
        icon = "__base__/graphics/technology/logistic-robotics.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-quartz-ortet-robo-interface"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-robot-frame"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-construction-robot"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-ceramic-logistic-robot"
            }
        },
        unit = {
            count = 3000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack", "logistic-robotics" },
    },
    {
        type = "technology",
        name = "quartz-crystal-sedimentation",
        icons = {
            {
                icon = "__tenebris-prime__/graphics/icons/quartz-crystal.png",
                icon_size = 64,
                scale = 4,
            },
            {
                icon = "__PlanetsLib__/graphics/icons/reprocessing-arrow.png",
                icon_size = 64,
                scale = 4,
            },
        },
        effects = {

            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-citrine"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-onyx"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-prasiolite"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-amethyst"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-ruby-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-crystal-reprocess-sapphire-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-citrine"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-onyx"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-prasiolite"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-amethyst"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-ruby-agate"
            },
            {
                type = "unlock-recipe",
                recipe = "crystal-seedling-from-sapphire-agate"
            }
        },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        prerequisites = { "piezoelectric-science-pack" },
    },
    {
        type = "technology",
        name = "mercurial-biota",
        icon = "__space-age__/graphics/technology/overgrowth-soil.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "mercurial-archaea-cultivation"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-mercurial-lattice"
            }
        },
        unit = {
            count = 3000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 },
                { "promethium-science-pack",      1 }
            },
            time = 60
        },
        prerequisites = { "tenebris-end-of-demo", "overgrowth-soil" },
    },
    {
        type = "technology",
        name = "luciferin-rocket-speed",
        icon = "__tenebris-prime__/graphics/technology/rocket-speed.png",
        icon_size = 256,
        effects = {
            {
                type = "gun-speed",
                ammo_category = "rocket",
                modifier = 0.5
            }
        },
        unit = {
            count_formula = "5000*(L^1.5)",
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        max_level = 4,
        prerequisites = { "tenebris-rocket-silo", "weapon-shooting-speed-6" },
    },
    {
        type = "technology",
        name = "tenebris-worker-robot-battery",
        icons = {
            { icon = "__base__/graphics/technology/worker-robots-speed.png", icon_size = 256 },
            { icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-battery.png", icon_size = 64, shift = {32, 32}, scale = 1 },
        },
        effects = {
            {
                type = "worker-robot-battery",
                modifier = 0.1
            }
        },
        unit = {
            count_formula = "1000*(L^1.5)",
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 }
            },
            time = 60
        },
        max_level = "infinite",
        prerequisites = { "tenebris-rocket-silo", "tenebris-robo-logistics" },
    },
    {
        type = "technology",
        name = "tenebris-high-energy-potential-forging",
        icon = "__base__/graphics/technology/advanced-material-processing.png",
        icon_size = 256,
        effects = (function()
            local effects = {}
            for _, crystal in ipairs(constants.CRYSTAL_TYPES) do
                table.insert(effects, {
                    type = "unlock-recipe",
                    recipe = "tenebris-lightning-furnace-" .. crystal
                })
            end
            -- Add high-energy forging recipes
            table.insert(effects, {
                type = "unlock-recipe",
                recipe = "tenebris-mercury-vii-plate"
            })
            return effects
        end)(),
        prerequisites = {
            "mercurial-biota",
            "lightning-collector",
        },
        unit = {
            count = 4000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 },
                { "promethium-science-pack",      1 }
            },
            time = 60
        }
    },
    -- ========================================
    -- BIOLUMINESCENT TECHNOLOGY (behind end-of-demo)
    -- ========================================
    {
        type = "technology",
        name = "tenebris-lightless-beacons",
        icon = "__tenebris-prime__/graphics/technology/biobeacon.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tenebris-bioinfusor"
            },
            {
                type = "unlock-recipe",
                recipe = "tenebris-biobeacon"
            }
        },
        prerequisites = { "tenebris-end-of-demo" },
        unit = {
            count = 3000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 },
                { "promethium-science-pack",      1 }
            },
            time = 60
        }
    },
    -- ========================================
    -- BEACON EFFICIENCY INFINITE TECH
    -- ========================================
    {
        type = "technology",
        name = "tenebris-beacon-distribution-efficiency",
        icons = {
            { icon = "__tenebris-prime__/graphics/technology/biobeacon.png", icon_size = 256 },
                { icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-movement-speed.png", icon_size = 64, shift = {32, 32}, scale = 1 },
        },
        effects = {
            {
                type = "beacon-distribution",
                modifier = 0.02
            }
        },
        prerequisites = { 
            "deep-space-discovery-lightless-abyss", 
            "tenebris-lightless-beacons" 
        },
        unit = {
            count_formula = "6^L*5000",
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 },
                { "piezoelectric-science-pack",   1 },
                { "promethium-science-pack",      1 }
            },
            time = 60
        },
        max_level = "infinite",
        upgrade = true,
    },
})

