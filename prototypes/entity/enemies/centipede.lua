local meld = require("meld")
local centipede_constants = require("lib.centipede_constants")

local function generate_frame_sequence(start)
    local result = {}
    for i = 1, 8 do
        result[i] = 1 + ((start + i) % 8)
    end
    return result
end

local function create_centipede_segment(segment_health, still_frame, segment_overrides)
    local variant = meld(table.deepcopy(data.raw["segment"]["small-demolisher-segment-x0_64"]), segment_overrides)
    variant.name = centipede_constants.ENTITY_NAMES.BODY_PREFIX .. segment_health .. "-" .. still_frame
    variant.max_health = segment_health
    variant.animation.layers[1].frame_sequence = generate_frame_sequence(still_frame)
    variant.animation.layers[2].frame_sequence = generate_frame_sequence(still_frame)
    return variant
end

-- Centipede corpse is an asteroid-chunk so it can be collected by asteroid collectors
local centipede_corpse = {
    name = centipede_constants.ENTITY_NAMES.CORPSE,
    type = "asteroid-chunk",
    icon = "__tenebris-prime__/graphics/icons/centipede-corpse.png",
    icon_size = 64,
    subgroup = "space-material",
    order = "z[centipede-corpse]",
    minable = {
        mining_particle = "stone-particle",
        mining_time = 1,
        results = {
            { type = "item", name = "tenebris-centipede-corpse", amount = 1 }
        },
    },
    graphics_set = {
        rotation_speed = 0.002,
        normal_strength = 1.0,
        light_width = 0.3,
        brightness = 0.4,
        specular_strength = 1.5,
        specular_power = 2.0,
        specular_purity = 0.3,
        sss_contrast = 0.1,
        sss_amount = 0.2,
        lights = {
            { color = {0.3, 0.5, 0.4}, direction = {0.75, 0.22, -1} },  -- Bioluminescent glow
            { color = {0.15, 0.25, 0.2}, direction = {0.5, 0, 0.95} },
        },
        ambient_light = {0.05, 0.08, 0.06},
        variations = {
            {
                color_texture = {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-corpse.png",
                    width = 410,
                    height = 337,
                    scale = 0.3,
    },
                normal_map = {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-corpse.png",
                    width = 410,
                    height = 337,
                    scale = 0.3,
                    premul_alpha = false,
                },
                roughness_map = {
        filename = "__tenebris-prime__/graphics/entity/centipede/centipede-corpse.png",
        width = 410,
        height = 337,
        scale = 0.3,
                    premul_alpha = false,
                },
                shadow_shift = {0.3, 0.3},
            },
        },
    },
}

data:extend({ centipede_corpse })

--- Creates a centipede variant using constants from centipede_constants
--- @param variant_name string The variant name (small, medium, large, giant, leviathan)
--- @param length number The number of body segments (from settings)
local function create_centipede(variant_name, length)
    local variant = centipede_constants.VARIANTS[variant_name]
    if not variant then
        error("Unknown centipede variant: " .. variant_name)
    end
    
    local scale = variant.scale
    local health = variant.health
    local segment_health = variant.segment_health
    local speed = variant.speed
    local damage = variant.damage
    local vision_distance = variant.vision_distance
    local enraged_duration = variant.enraged_duration
    local healing_per_tick = variant.healing_per_tick
    local enraged_speed_mult = variant.enraged_speed_mult
    local resistances = centipede_constants.RESISTANCES[variant_name]
    
    -- Asteroid debris size based on centipede variant
    local debris_asteroid = {
        small = "small-carbonic-asteroid",
        medium = "small-carbonic-asteroid",
        large = "medium-carbonic-asteroid",
        giant = "medium-carbonic-asteroid",
        leviathan = "big-carbonic-asteroid",
    }
    local asteroid_name = debris_asteroid[variant_name] or "small-carbonic-asteroid"
    
    local segments = {}
    for i = 0, length do
        table.insert(segments, { segment = centipede_constants.ENTITY_NAMES.BODY_PREFIX .. segment_health .. "-" .. (i % 8) })
    end

    table.insert(segments, { segment = centipede_constants.ENTITY_NAMES.TAIL_PREFIX .. segment_health })

    ---@type data.SegmentedUnitPrototype
    ---@diagnostic disable-next-line: missing-fields
    local head_overrides = {
        name = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. variant_name,
        localised_name = { "entity-name.centipede-" .. variant_name },
        update_effects = meld.overwrite {
            -- Contact damage
            {
                distance_cooldown = 5,
                effect =
                {
                    type = "nested-result",
                    action =
                    {
                        type = "area",
                        radius = 1,
                        force = "not-same",
                        collision_mask = { layers = { player = true, train = true, rail = true, transport_belt = true, is_object = true } },
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = { amount = damage, type = "impact" }
                                },
                            }
                        }
                    }
                }
            },
        },
        update_effects_while_enraged = meld.delete(),
        -- Spawn asteroid debris when taking damage
        damaged_trigger_effect = meld.overwrite {
            {
                    type = "create-entity",
                entity_name = asteroid_name,
                offset_deviation = centipede_constants.DEBRIS.OFFSET,
                trigger_created_entity = true,
                probability = centipede_constants.DEBRIS.PROBABILITY,
            }
        },
        dying_trigger_effect = meld.overwrite {
            {
                type = "create-asteroid-chunk",
                asteroid_name = centipede_constants.ENTITY_NAMES.CORPSE,
                offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
            }
        },
        autoplace = meld.delete(),
        resistances = meld.overwrite(resistances),
        working_sound = meld.overwrite {
            sound =
            {
                category = "enemy",
                filename = "__base__/sound/creatures/biter-walk-4.ogg",
                volume = 0.25,
                advanced_volume_control = { attenuation = "exponential" },
            },
            max_sounds_per_type = 4,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        vision_distance = vision_distance,
        enraged_duration = enraged_duration,
        revenge_attack_parameters = meld.delete(),
        forward_padding = 0,
        backward_padding = 0,
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        selection_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        patrolling_speed = speed,
        investigating_speed = speed,
        enraged_speed = speed * enraged_speed_mult,
        attacking_speed = speed * enraged_speed_mult,
        max_health = health,
        healing_per_tick = healing_per_tick,
        turn_radius = 4 * scale,
        acceleration_rate = 1,
        render_layer = "object",
        collision_mask = { layers = { item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true } },
        segment_engine = meld.overwrite {
            segments = segments
        },
        animation = meld.overwrite {
            layers = {
                {
                    direction_count = 64,
                    animation_speed = 0.1,
                    frame_count = 8,
                    dice = 0,
                    scale = scale,
                    usage = "enemy",
                    width = 512,
                    height = 512,
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-1.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-2.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-3.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-4.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                    }
                },
                {
                    direction_count = 64,
                    animation_speed = 0.1,
                    frame_count = 8,
                    dice = 0,
                    scale = scale,
                    usage = "enemy",
                    width = 512,
                    height = 512,
                    draw_as_light = true,
                    blend_mode = "additive",
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-light-1.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-light-2.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-light-3.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-head-light-4.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                    }
                }
            }
        },
        -- Negative backward_padding makes segments overlap (like demolishers)
        backward_padding = -3.0 * scale,
    }

    ---@type data.SegmentPrototype
    ---@diagnostic disable-next-line: missing-fields
    local tail_segment_overrides = {
        name = centipede_constants.ENTITY_NAMES.TAIL_PREFIX,
        localised_name = { "entity-name.centipede-" .. variant_name },
        update_effects = meld.delete(),
        update_effects_while_enraged = meld.delete(),
        dying_trigger_effect = meld.overwrite {
            {
                type = "create-asteroid-chunk",
                asteroid_name = centipede_constants.ENTITY_NAMES.CORPSE,
                offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
            }
        },
        revenge_attack_parameters = meld.delete(),
        forward_padding = 0,
        backward_padding = -2.0 * scale,  -- Overlap with previous segment
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        selection_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        collision_mask = { layers = { item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true } },
        render_layer = "object",
        max_health = segment_health,
        healing_per_tick = healing_per_tick,
        resistances = meld.overwrite(resistances),
        working_sound = meld.overwrite {
            sound =
            {
                category = "enemy",
                filename = "__base__/sound/creatures/biter-walk-4.ogg",
                volume = 0.25,
                advanced_volume_control = { attenuation = "exponential" },
            },
            max_sounds_per_type = 4,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        animation = meld.overwrite {
            direction_count = 64,
            frame_count = 5,
            dice = 0,
            scale = scale,
            animation_speed = 0.1,
            usage = "enemy",
            width = 512,
            height = 512,
            stripes = {
                {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-tail-1.png",
                    width_in_frames = 5,
                    height_in_frames = 16,
                },
                {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-tail-2.png",
                    width_in_frames = 5,
                    height_in_frames = 16,
                },
                {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-tail-3.png",
                    width_in_frames = 5,
                    height_in_frames = 16,
                },
                {
                    filename = "__tenebris-prime__/graphics/entity/centipede/centipede-tail-4.png",
                    width_in_frames = 5,
                    height_in_frames = 16,
                },
            }
        }
    }

    ---@type data.SegmentPrototype
    ---@diagnostic disable-next-line: missing-fields
    local segment_overrides = {
        name = centipede_constants.ENTITY_NAMES.BODY_PREFIX,
        localised_name = { "entity-name.centipede-" .. variant_name },
        update_effects = meld.delete(),
        update_effects_while_enraged = meld.delete(),
        dying_trigger_effect = meld.overwrite {
            {
                type = "create-asteroid-chunk",
                asteroid_name = centipede_constants.ENTITY_NAMES.CORPSE,
                offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
            }
        },
        forward_padding = 0,
        backward_padding = -2.5 * scale,  -- Negative padding for segment overlap
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        selection_box = { { -2.5 * scale, -1.5 * scale }, { 2.5 * scale, 1.5 * scale } },
        collision_mask = { layers = { item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true } },
        render_layer = "object",
        max_health = segment_health,
        healing_per_tick = healing_per_tick,
        working_sound = meld.overwrite {
            sound =
            {
                category = "enemy",
                filename = "__base__/sound/creatures/biter-walk-4.ogg",
                volume = 0.25,
                advanced_volume_control = { attenuation = "exponential" },
            },
            max_sounds_per_type = 4,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        resistances = meld.overwrite(resistances),
        animation = meld.overwrite({
            layers = {
                {
                    animation_speed = 0.4,
                    direction_count = 64,
                    frame_count = 8,
                    dice = 0,
                    scale = scale,
                    usage = "enemy",
                    width = 512,
                    height = 512,
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-1.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-2.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-3.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-4.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                    }
                },
                {
                    animation_speed = 0.4,
                    direction_count = 64,
                    frame_count = 8,
                    dice = 0,
                    scale = scale,
                    usage = "enemy",
                    width = 512,
                    height = 512,
                    draw_as_light = true,
                    blend_mode = "additive",
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-light-1.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-light-2.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-light-3.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                        {
                            filename = "__tenebris-prime__/graphics/entity/centipede/centipede-body-light-4.png",
                            width_in_frames = 8,
                            height_in_frames = 16,
                        },
                    }
                }
            }
        }),
        -- Negative backward_padding makes segments overlap
        backward_padding = -2.5 * scale,
    }

    for i = 0, 8 do
        data:extend({ create_centipede_segment(segment_health, i, segment_overrides) })
    end


    local centipede_tail = meld(table.deepcopy(data.raw["segment"]["small-demolisher-segment-x0_64"]),
        tail_segment_overrides)
    centipede_tail.name = centipede_constants.ENTITY_NAMES.TAIL_PREFIX .. segment_health
    centipede_tail.max_health = segment_health
    data:extend({ centipede_tail })


    data:extend({ meld(table.deepcopy(data.raw["segmented-unit"]["small-demolisher"]), head_overrides) })
end
-- Create all centipede variants using centralized constants
-- To buff centipedes, modify lib/centipede_constants.lua
create_centipede("premature", settings.startup["tenebris-premature-centipede-length"].value)
create_centipede("small", settings.startup["tenebris-small-centipede-length"].value)
create_centipede("medium", settings.startup["tenebris-medium-centipede-length"].value)
create_centipede("large", settings.startup["tenebris-large-centipede-length"].value)
create_centipede("giant", settings.startup["tenebris-giant-centipede-length"].value)
create_centipede("leviathan", settings.startup["tenebris-leviathan-centipede-length"].value)
