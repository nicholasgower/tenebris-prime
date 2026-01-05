--- Centipede (Pentapod) Constants
--- Used by both prototypes and runtime scripts
--- 
--- To buff centipedes, modify the values here.
--- Changes require mod reload to take effect.

local centipede = {}

--- Centipede variant definitions
--- Each variant has: scale, health, speed, damage, segment_count, etc.
centipede.VARIANTS = {
    premature = {
        scale = 0.2,             -- Very small
        health = 10000,          -- HP of head segment
        segment_health = 2000,   -- HP of body/tail segments
        speed = 0.12,            -- Fast and erratic
        enraged_speed_mult = 1.5,-- Gets even faster when enraged
        damage = 500,            -- Low contact damage
        vision_distance = 50,
        enraged_duration = 108000,  -- Half enraged duration
        healing_per_tick = 1,
        segment_count = 5,       -- 5 body segments as requested
    },
    small = {
        scale = 0.8,
        health = 80000,          -- HP of head segment
        segment_health = 16000,  -- HP of body/tail segments
        speed = 0.05,            -- Movement speed
        enraged_speed_mult = 1,  -- Speed multiplier when enraged
        damage = 2000,           -- Contact damage
        vision_distance = 100,
        enraged_duration = 216000,  -- Ticks enraged after taking damage
        healing_per_tick = 2,
        segment_count = 10,      -- Number of body segments (can be overridden by mod settings)
    },
    medium = {
        scale = 1.6,
        health = 210000,
        segment_health = 42000,
        speed = 0.07,
        enraged_speed_mult = 1,
        damage = 5000,
        vision_distance = 100,
        enraged_duration = 216000,
        healing_per_tick = 5,
        segment_count = 15,
    },
    large = {
        scale = 2.0,
        health = 500000,
        segment_health = 100000,
        speed = 0.08,
        enraged_speed_mult = 1,
        damage = 10000,
        vision_distance = 100,
        enraged_duration = 216000,
        healing_per_tick = 10,
        segment_count = 20,
    },
    giant = {
        scale = 3.0,
        health = 1000000,
        segment_health = 200000,
        speed = 0.09,
        enraged_speed_mult = 1,
        damage = 20000,
        vision_distance = 100,
        enraged_duration = 216000,
        healing_per_tick = 20,
        segment_count = 25,
    },
    leviathan = {
        scale = 5.0,
        health = 2500000,
        segment_health = 500000,
        speed = 0.12,
        enraged_speed_mult = 1,
        damage = 50000,
        vision_distance = 100,
        enraged_duration = 216000,
        healing_per_tick = 50,
        segment_count = 30,
    },
}

--- Entity name patterns
centipede.ENTITY_NAMES = {
    HEAD_PREFIX = "centipede-head-",
    BODY_PREFIX = "centipede-body-",
    TAIL_PREFIX = "centipede-tail-",
    CORPSE = "centipede-corpse",
    EGGROID_PREFIX = "centipede-eggroid-",
}

--- Chitin drop amounts when mining corpses
centipede.CHITIN_DROP = {
    MIN = 4,
    MAX = 16,
}

--- Corpse drop configuration per variant
--- Each entry in the drops array becomes a dying_trigger_effect
centipede.DROPS = {
    small = {
        {
            type = "create-asteroid-chunk",
            asteroid_name = "centipede-corpse",
            offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
            repeat_count = 1,
        },
    },
    medium = {
        {
            type = "create-asteroid-chunk",
            asteroid_name = "centipede-corpse",
            offset_deviation = {{-0.8, -0.8}, {0.8, 0.8}},
            repeat_count = 2,
        },
    },
    large = {
        {
            type = "create-asteroid-chunk",
            asteroid_name = "centipede-corpse",
            offset_deviation = {{-1.0, -1.0}, {1.0, 1.0}},
            repeat_count = 4,
        },
    },
    giant = {
        {
            type = "create-asteroid-chunk",
            asteroid_name = "centipede-corpse",
            offset_deviation = {{-1.2, -1.2}, {1.2, 1.2}},
            repeat_count = 8,
        },
    },
    leviathan = {
        {
            type = "create-asteroid-chunk",
            asteroid_name = "centipede-corpse",
            offset_deviation = {{-1.5, -1.5}, {1.5, 1.5}},
            repeat_count = 20,
        },
    },
}

--- Resistances per variant
--- Each resistance has: percent (damage reduction %) and optionally decrease (flat reduction)
centipede.RESISTANCES = {
    premature = {
        { type = "physical", percent = 30, decrease = 5 },
        { type = "impact", percent = 60, decrease = 500 },
        { type = "explosion", percent = 20, decrease = 100 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 10, decrease = 2 },
        { type = "laser", percent = 10, decrease = 5 },
    },
    small = {
        { type = "physical", percent = 50, decrease = 10 },
        { type = "impact", percent = 80, decrease = 2000 },
        { type = "explosion", percent = 30, decrease = 500 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 15, decrease = 5 },
        { type = "laser", percent = 20, decrease = 10 },
    },
    medium = {
        { type = "physical", percent = 60, decrease = 20 },
        { type = "impact", percent = 85, decrease = 40 },
        { type = "explosion", percent = 40, decrease = 10 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 15, decrease = 10 },
        { type = "laser", percent = 20, decrease = 10 },
    },
    large = {
        { type = "physical", percent = 70, decrease = 40 },
        { type = "impact", percent = 90, decrease = 80 },
        { type = "explosion", percent = 50, decrease = 20 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 15, decrease = 20 },
        { type = "laser", percent = 20, decrease = 15 },
    },
    giant = {
        { type = "physical", percent = 80, decrease = 200 },
        { type = "impact", percent = 95, decrease = 150 },
        { type = "explosion", percent = 60, decrease = 40 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 15, decrease = 40 },
        { type = "laser", percent = 25, decrease = 25 },
    },
    leviathan = {
        { type = "physical", percent = 90, decrease = 1000 },
        { type = "impact", percent = 98, decrease = 300 },
        { type = "explosion", percent = 90, decrease = 80 },
        { type = "fire", percent = 100 },
        { type = "acid", percent = 100 },
        { type = "poison", percent = 100 },
        { type = "electric", percent = 20, decrease = 80 },
        { type = "laser", percent = 30, decrease = 40 },
    },
}

--- Space spawn configuration (for centipede eggroids)
centipede.SPACE_SPAWN = {
    -- Probability multipliers for egg rafts during space travel
    -- Higher = more spawns
    small = {
        start_distance = 0.3,   -- When eggs start appearing (0-1 journey progress)
        peak_distance = 0.9,    -- Peak spawn rate
        start_probability = 0,
        peak_probability = 0.002,
        speed = 0.015,          -- Approach speed
    },
    medium = {
        start_distance = 0.4,
        peak_distance = 0.9,
        start_probability = 0,
        peak_probability = 0.001,
        speed = 0.012,
    },
    large = {
        start_distance = 0.5,
        peak_distance = 0.9,
        start_probability = 0,
        peak_probability = 0.0005,
        speed = 0.01,
    },
    giant = {
        start_distance = 0.7,
        peak_distance = 0.95,
        start_probability = 0,
        peak_probability = 0.0002,
        speed = 0.008,
    },
    leviathan = {
        start_distance = 0.85,
        peak_distance = 0.95,
        start_probability = 0,
        peak_probability = 0.00005,
        speed = 0.005,
    },
}

--- Spawn behavior configuration
centipede.SPAWN = {
    DISTANCE = 80,  -- Tiles away from egg raft to spawn centipede
}

--- Debris spawning when centipede is damaged
centipede.DEBRIS = {
    PROBABILITY = 0.1,  -- Chance to spawn asteroid debris per hit
    OFFSET = {{-3, -3}, {3, 3}},  -- Spawn area around centipede
}

--- Eggroid asteroid configuration
--- splits_into: what eggroid type this splits into on death, and how many
--- explosion_size: 1-4 (uses bismuth-asteroid-explosion-N)
centipede.EGGROID = {
    small = {
        health = 200,
        mass = 100000,
        collision_radius = 0.8,
        graphics_scale = 0.4,
        explosion_size = 1,
        splits_into = nil,  -- No split
    },
    medium = {
        health = 800,
        mass = 300000,
        collision_radius = 1.2,
        graphics_scale = 0.5,
        explosion_size = 2,
        splits_into = nil,  -- No split
    },
    large = {
        health = 2000,
        mass = 800000,
        collision_radius = 1.8,
        graphics_scale = 0.6,
        explosion_size = 3,
        splits_into = { type = "small", count = 2 },
    },
    giant = {
        health = 5000,
        mass = 2000000,
        collision_radius = 2.5,
        graphics_scale = 0.7,
        explosion_size = 4,
        splits_into = { type = "medium", count = 2 },
    },
    leviathan = {
        health = 30000,
        mass = 5000000,
        collision_radius = 4.0,  -- 1.4x giant's 2.5 ≈ 3.5, slightly larger
        graphics_scale = 0.98,  -- 1.4x giant's 0.7
        explosion_size = 4,  -- Huge explosion
        use_huge_graphic = true,
        splits_into = { type = "large", count = 3 },
    },
}

--- Offset deviation for eggroid splitting
centipede.EGGROID_SPLIT_OFFSET = {{-3, -3}, {3, 3}}

--- Cyan icon tint for eggroids and infected chunks
centipede.EGGROID_ICON_TINT = {r = 0.7, g = 0.95, b = 1.0, a = 1.0}

--- Infected carbonic chunk drop counts per eggroid size
--- Only small and medium eggroids drop chunks directly
centipede.EGGROID_CHUNK_DROPS = {
    small = 3,
    medium = 7,
}

--- Eggroid shading configuration (high contrast carbonic with sharp cyan)
centipede.EGGROID_SHADING = {
    normal_strength = 1.3,  -- Enhanced surface detail
    light_width = 0,
    brightness = 0.5,  -- Lower brightness for darker base
    specular_strength = 4.0,  -- Strong specular for sharp highlights
    specular_power = 2.5,  -- Sharp specular falloff
    specular_purity = 0.7,  -- Colored specular for cyan highlights
    sss_contrast = 1.5,  -- Higher contrast
    sss_amount = 0,
    lights = {
        { color = {0.7, 0.85, 0.9}, direction = {0.7, 0.6, -1} },  -- Dimmer, cyan-tinted main
        { color = {0.0, 0.7, 0.85}, direction = {-1, -1, 1} },  -- Vivid cyan fill
    },
    ambient_light = {0.0, 0.02, 0.03},  -- Low ambient to keep darks dark
}

--- Infected carbonic chunk shading configuration (high contrast with sharp cyan)
centipede.INFECTED_CHUNK_SHADING = {
    normal_strength = 1.3,
    light_width = 0,
    brightness = 0.5,
    specular_strength = 4.0,
    specular_power = 2.5,
    specular_purity = 0.7,
    sss_contrast = 1.5,
    sss_amount = 0,
    lights = {
        { color = {0.7, 0.85, 0.9}, direction = {0.7, 0.6, -1} },  -- Dimmer, cyan-tinted main
        { color = {0.0, 0.65, 0.8}, direction = {-1, -1, 1} },  -- Vivid cyan fill
    },
    ambient_light = {0.0, 0.02, 0.03},  -- Low ambient to keep darks dark
}

return centipede

