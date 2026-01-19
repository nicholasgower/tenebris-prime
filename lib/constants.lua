--- Tenebris Prime Shared Constants
--- Works in both data stage and control stage.
--- Use this for constants that need to be shared across stages.
---
--- For control-stage-only features (events, game functions), use lib/tenebris.lua
---
--- @module lib.constants

local constants = {}

--#region Planet and Location Names

--- Planet and location names
constants.PLANET = {
    TENEBRIS = "tenebris",
    -- Base game planets for reference
    NAUVIS = "nauvis",
    VULCANUS = "vulcanus",
    FULGORA = "fulgora",
    GLEBA = "gleba",
    AQUILO = "aquilo",
}

--- Space locations (routes and waypoints)
constants.SPACE_LOCATION = {
    TENEBRIS = "tenebris",
    IRIDESCENT_RIVER = "iridescent-river",
    THE_NEST = "the-nest",
    LIGHTLESS_GATEWAY = "lightless-gateway",
    LIGHTLESS_ABYSS = "lightless-abyss",
}

--- All Tenebris locations (for iteration)
constants.ALL_TENEBRIS_LOCATIONS = {
    "tenebris",
    "iridescent-river",
    "the-nest",
    "lightless-gateway",
    "lightless-abyss",
}

--#endregion

--#region Timing Constants

--- Timing constants
constants.TICKS = {
    PER_SECOND = 60,
    PER_MINUTE = 3600,
    PER_HOUR = 216000
}

--#endregion

--#region Color Tints

--- Color tints for graphics
constants.TINT = {
    HEAT = {r = 1.0, g = 0.6, b = 0.4, a = 1.0},  -- Reddish/orange for heated machines
    DARK_ORANGE = {r = 0.85, g = 0.5, b = 0.2, a = 1.0},  -- Dark orange for piezoelectric inserter
    DARK_ATMOSPHERE = {r = 0.4, g = 0.4, b = 0.5, a = 1.0},  -- Dark bluish-grey for atmosphere/gas
    HEAT_LIGHT = {r = 1.0, g = 0.8, b = 0.65, a = 1.0},  -- Subtle warm tint for less aggressive heating
    CHITOSAN = {r = 0.6, g = 0.45, b = 0.3, a = 1.0},  -- Brown for chitosan pipes
    PRASIOLITE = {r = 0.7, g = 0.85, b = 0.7, a = 1.0},  -- Pale/duller green for prasiolite
    ONYX = {r = 0.15, g = 0.15, b = 0.15, a = 1.0},  -- Near-black for onyx
    SAPPHIRE = {r = 0.4, g = 0.5, b = 1.0, a = 1.0},  -- Blue tint for sapphire agate
    CERAMIC = {r = 0.95, g = 0.9, b = 0.8, a = 1.0},  -- Off-white/cream for ceramic
    CYAN = {r = 0.3, g = 0.9, b = 1.0, a = 1.0},  -- Bright cyan for quartz ortet
    CYAN_DULL = {r = 0.2, g = 0.6, b = 0.7, a = 1.0},  -- Duller cyan for quartz buds
}

--#endregion

--#region Space Connection Constants

--- Space connection lengths
constants.SPACE_CONNECTION = {
    FULGORA_TENEBRIS_LENGTH = 75000,  -- Base length for fulgora-tenebris route
}

--#endregion

--#region Gameplay Constants

--- Pollution absorption rates for tenecap_spore_clearance
constants.ABSORPTION = {
    NEUTRAL = {tenecap_spore_clearance = 0.000002},
    LOW = {tenecap_spore_clearance = 0.000004},
    HIGH = {tenecap_spore_clearance = 0.00005},
    EXTREME = {tenecap_spore_clearance = 0.01},  -- Complete sink
}

--- Spore clearance configuration
constants.SPORE = {
    -- Entity manager thresholds
    POWER_THRESHOLD = 50,       -- Pollution above this enables entities
    PROTECTION_THRESHOLD = 100, -- Pollution above this protects from damage
}

--- Cargo corrosion configuration
constants.CARGO_CORROSION = {
    -- Battery explosion parameters (scales with battery count)
    EXPLOSION_RADIUS_MIN = 10,        -- Minimum explosion radius (tiles)
    EXPLOSION_RADIUS_MAX = 30,        -- Maximum explosion radius (tiles)
    EXPLOSION_RADIUS_PER_BATTERY = 0.1,  -- Additional radius per battery
    EXPLOSION_DAMAGE_MIN = 100,       -- Minimum explosion damage
    EXPLOSION_DAMAGE_MAX = 2000,      -- Maximum explosion damage
    EXPLOSION_DAMAGE_PER_BATTERY = 5, -- Additional damage per battery
}

--- Priority ranges for event subscriptions
constants.PRIORITY = {
    CRITICAL = 10,      -- Core infrastructure (0-99)
    NORMAL = 50,        -- Normal operations
    GAMEPLAY = 100,     -- Gameplay mechanics (100-199)
    UI = 200,           -- UI and effects (200-299)
    LOGGING = 900       -- Logging and debugging (900-999)
}

--#endregion

--#region Quartz Forest Constants

--- Quartz forest constants
constants.QUARTZ_FOREST = {
    -- Entity names
    BUD_ENTITY = "tenebris-quartz-ortet-bud",
    BUD_SPAWNER_ENTITY = "tenebris-quartz-ortet-bud-spawner",
    ORTET_ENTITY = "tenebris-quartz-forest-ortet",
    BUD_CAPTURE_PROXY = "tenebris-quartz-ortet-bud-capture-proxy",
    ORTET_CAPTURE_PROXY = "tenebris-quartz-ortet-capture-proxy",
    HIDDEN_SPAWN_UNIT = "tenebris-quartz-ortet-bud-hidden-spawn-unit",
    
    -- Growth timing
    GROWTH_TICKS = 5 * 60 * 60,  -- 5 minutes to full maturity
    
    -- Spawn distance from ortet (tiles)
    BUD_SPAWN_MIN_RADIUS = 20,
    BUD_SPAWN_MAX_RADIUS = 40,
    
    -- Storage keys
    STORAGE_BUD_SPAWN_TIMES = "tenebris_bud_spawn_times",
    STORAGE_BUD_BY_POS = "tenebris_bud_by_position",  -- stores {spawn_tick, composite_id}
}

--- Crystal types (quartz variants)
constants.CRYSTAL_TYPES = {
    CITRINE = "citrine",
    ONYX = "onyx",
    PRASIOLITE = "prasiolite",
    AMETHYST = "amethyst",
    RUBY_AGATE = "ruby-agate",
    SAPPHIRE_AGATE = "sapphire-agate"
}

--- Ordered list of crystal types for iteration
constants.CRYSTAL_TYPES_LIST = {
    "citrine",
    "onyx",
    "prasiolite",
    "amethyst",
    "ruby-agate",
    "sapphire-agate"
}

--#endregion

--#region Item Names

--- Item names
constants.ITEM = {
    -- Science packs
    PIEZOELECTRIC_SCIENCE_PACK = "piezoelectric-science-pack",
    BIOLUMINESCENT_SCIENCE_PACK = "bioluminescent-science-pack",
    
    -- Biomaterials
    LUCIFUNNEL = "lucifunnel",
    LUCIFUNNEL_SEED = "lucifunnel-seed",
    TENECAP = "tenecap",
    TENECAP_SPORE = "tenecap-spore",
    SULFURIC_WASTE_SPORES = "sulfuric-waste-spores",
    CHITIN = "chitin",
    CHITOSAN = "chitosan",
    LUCIFERIN = "luciferin",
    
    -- Ores and minerals
    QUARTZ_ORE = "quartz-ore",
    BISMUTH_ORE = "bismuth-ore",
    BISMUTH_ASTEROID_CHUNK = "bismuth-asteroid-chunk",
    
    -- Crystals
    QUARTZ_CRYSTAL = "quartz-crystal",
    QUARTZ_CRYSTAL_SEEDLING = "quartz-crystal-seedling",
    PHOTONIC_CRYSTAL = "photonic-crystal",
    BIOLUMINESCENT_CRYSTAL = "bioluminescent-crystal",
    
    -- Waste products
    FERRIC_WASTE = "tenebris-ferric-waste",
    CUPRIC_WASTE = "tenebris-cupric-waste",
    CIRCUIT_WASTE = "tenebris-circuit-waste",
    
    -- Processed materials
    QUARTZIFEROUS_BISMUTHAL_PLATE = "quartziferous-bismuthal-plate",
    
    -- Equipment and machines
    OBSERVATION_SATELLITE = "observation-satellite",
    TENEBRIS_BIOINFUSOR = "tenebris-bioinfusor",
    TENEBRIS_BIOBEACON = "tenebris-biobeacon",
    TENEBRIS_HEATED_ATMOSPHERE_SCRUBBER = "tenebris-heated-atmosphere-scrubber",
    TENEBRIS_SPORE_FILTER = "tenebris-spore-filter",
    TENEBRIS_USED_SPORE_FILTER = "tenebris-used-spore-filter",
    LIGHTLESS_BEACON = "lightless-beacon",
    
    -- Modules
    SPORE_REMOVAL_MODULE = "spore-removal-module"
}

--#endregion

--#region Entity Names

--- Entity names
constants.ENTITY = {
    -- Plant entities
    QUARTZ_ORTET_BUD = "tenebris-quartz-ortet-bud",
    QUARTZ_NODE = "quartz-node",
    LUCIFUNNEL = "lucifunnel",
    TENECAP = "tenecap",
    
    -- Quartz forest entities
    QUARTZ_FOREST_ORTET = "tenebris-quartz-forest-ortet",
    
    -- Piezoelectric generator composite (main = interface, hidden = generator + pole)
    PIEZOELECTRIC_INTERFACE_TIER_1 = "tenebris-piezoelectric-interface-tier-1",
    PIEZOELECTRIC_INTERFACE_TIER_2 = "tenebris-piezoelectric-interface-tier-2",
    PIEZOELECTRIC_INTERFACE_TIER_3 = "tenebris-piezoelectric-interface-tier-3",
    PIEZOELECTRIC_INTERFACE_TIER_4 = "tenebris-piezoelectric-interface-tier-4",
    PIEZOELECTRIC_GENERATOR_HIDDEN_TIER_1 = "tenebris-piezoelectric-generator-hidden-tier-1",
    PIEZOELECTRIC_GENERATOR_HIDDEN_TIER_2 = "tenebris-piezoelectric-generator-hidden-tier-2",
    PIEZOELECTRIC_GENERATOR_HIDDEN_TIER_3 = "tenebris-piezoelectric-generator-hidden-tier-3",
    PIEZOELECTRIC_GENERATOR_HIDDEN_TIER_4 = "tenebris-piezoelectric-generator-hidden-tier-4",
    PIEZOELECTRIC_POLE_HIDDEN_TIER_1 = "tenebris-piezoelectric-pole-hidden-tier-1",
    PIEZOELECTRIC_POLE_HIDDEN_TIER_2 = "tenebris-piezoelectric-pole-hidden-tier-2",
    PIEZOELECTRIC_POLE_HIDDEN_TIER_3 = "tenebris-piezoelectric-pole-hidden-tier-3",
    PIEZOELECTRIC_POLE_HIDDEN_TIER_4 = "tenebris-piezoelectric-pole-hidden-tier-4",
    
    -- Machines
    BIOBEACON = "tenebris-biobeacon",
    BIOINFUSOR = "tenebris-bioinfusor",
    LIGHTNING_FURNACE = "tenebris-lightning-furnace",
    LIGHTNING_COLLECTOR_HIDDEN = "tenebris-lightning-collector-hidden"
}

--#endregion

--#region Tenespace Effects Configuration

--- Tenespace effects and corrosion configuration
constants.TENESPACE = {
    -- How often to check for platforms and spawn effects (ticks)
    UPDATE_INTERVAL = 10,
    
    -- How often to rebuild chunk cache while in tenespace (ticks) - 1 minute
    -- Catches platform changes during travel
    CACHE_REBUILD_INTERVAL = 3600,
    
    -- How many chunks to process per tick during incremental cache rebuild
    CHUNKS_PER_REBUILD_TICK = 20,
    
    -- How many chunks to process for corrosion per tick
    CORROSION_CHUNKS_PER_TICK = 2,
    
    -- How many random chunks to spawn effects in per update
    CHUNKS_PER_UPDATE = 5,
    
    -- Corrosion damage configuration (max_entities uses same setting as ground system)
    CORROSION = {
        -- Damage amount per check (acid damage, applied every 30 seconds by default)
        damage_amount = 20,
        -- Damage type
        damage_type = "acid",
    },
    
    -- Cyan glow dots (small scattered particles)
    CYAN_GLOW = {
        spawn_chance = 0.25,           -- Always spawn
        count_min = 4,
        count_max = 8,
        speed_min = 0.002,
        speed_max = 0.01,
    },
    
    -- Brighter cyan dots (fewer, slightly larger)
    CYAN_BRIGHT = {
        spawn_chance = 0.05,
        count_min = 2,
        count_max = 5,
        speed_min = 0.001,
        speed_max = 0.008,
    },
    
    -- Small spore clouds (reduced)
    SPORE_SMALL = {
        spawn_chance = 0.0025,
        count_min = 1,
        count_max = 1,
        speed_min = 0.002,
        speed_max = 0.008,
    },
    
    -- Large spore clouds (rare)
    SPORE_LARGE = {
        spawn_chance = 0.0005,
        count_min = 1,
        count_max = 1,
        speed_min = 0.001,
        speed_max = 0.003,
    },
    
    -- Wispy tendrils (reduced)
    SPORE_WISP = {
        spawn_chance = 0.005,
        count_min = 1,
        count_max = 2,
        speed_min = 0.015,
        speed_max = 0.04,
    },
}

--#endregion

return constants

