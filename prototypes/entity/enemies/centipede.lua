local meld = require("meld")

local function generate_frame_sequence(start)
    local result = {}
    for i = 1, 8 do
        result[i] = 1 + ((start + i) % 8)
    end
    return result
end

local function create_centipede_segment(health, still_frame, segment_overrides)
    local variant = meld(table.deepcopy(data.raw["segment"]["small-demolisher-segment-x0_64"]), segment_overrides)
    variant.name = "centipede-body-" .. health .. "-" .. still_frame
    variant.max_health = health
    variant.animation.layers[1].frame_sequence = generate_frame_sequence(still_frame)
    variant.animation.layers[2].frame_sequence = generate_frame_sequence(still_frame)
    return variant
end

local centipede_corpse = {
    name = "centipede-corpse",
    type = "simple-entity",
    collision_box = { { -3.0, -1.0 }, { 3.0, 1.0 } },
    selection_box = { { -3.0, -1.0 }, { 3.0, 1.0 } },
    minable =
    {
        mining_particle = "stone-particle",
        mining_time = 1,
        results =
        {
            { type = "item", name = "luciferin", amount_min = 30, amount_max = 50 },
            { type = "item", name = "chitin",    amount_min = 4,  amount_max = 16 }
        },
    },
    pictures = {
        filename = "__tenebris-prime__/graphics/entity/centipede/centipede-corpse.png",
        width = 410,
        height = 337,
        scale = 0.3,
        draw_as_glow = true,
    }
}

data:extend({ centipede_corpse })

local function create_centipede(name, scale, length, health, speed, damage, min_spawn_distance)
    local segments = {}
    for i = 0, length do
        table.insert(segments, { segment = "centipede-body-" .. health .. "-" .. (i % 8) })
    end

    table.insert(segments, { segment = "centipede-tail-" .. health })

    ---@type data.SegmentedUnitPrototype
    ---@diagnostic disable-next-line: missing-fields
    local head_overrides = {
        name = "centipede-head-" .. name,
        localised_name = { "entity-name.centipede-" .. name },
        update_effects = meld.overwrite {
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
            }
        },
        update_effects_while_enraged = meld.overwrite {
            {
                effect = {
                    type = "create-entity",
                    entity_name = "poison-cloud"
                },
                distance_cooldown = 15,
                initial_distance_cooldown = 10,
            }
        },
        dying_trigger_effect = meld.overwrite {
            {
                type = "create-entity",
                entity_name = "centipede-corpse"
            }
        },
        autoplace = meld.overwrite {
            control = "tenebris_enemies",
            order = "a[tenebris]-b[centipede]-"..name,
            force = "enemy",
            probability_expression = "clamp(distance - " .. min_spawn_distance .. ", 0, 1) * 0.00005",
        },
        resistances = meld.overwrite {
            {
                type = "poison",
                percent = 100,
            }
        },
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
        vision_distance = 6,
        enraged_duration = 300,
        revenge_attack_parameters = meld.delete(),
        forward_padding = 0,
        backward_padding = 0,
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        selection_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        patrolling_speed = speed,
        investigating_speed = speed,
        enraged_speed = speed * 2,
        attacking_speed = speed * 2,
        max_health = health,
        healing_per_tick = 1,
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
        }
    }

    ---@type data.SegmentPrototype
    ---@diagnostic disable-next-line: missing-fields
    local tail_segment_overrides = {
        name = "centipede-tail",
        localised_name = { "entity-name.centipede-" .. name },
        update_effects = meld.delete(),
        update_effects_while_enraged = meld.delete(),
        dying_trigger_effect = meld.delete(),
        revenge_attack_parameters = meld.delete(),
        forward_padding = 0.0,
        backward_padding = 0.0,
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        selection_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        collision_mask = { layers = { item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true } },
        render_layer = "object",
        max_health = 10000,
        healing_per_tick = 1,
        resistances = meld.overwrite {
            {
                type = "poison",
                percent = 100,
            }
        },
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
        name = "centipede-body",
        localised_name = { "entity-name.centipede-" .. name },
        update_effects = meld.delete(),
        update_effects_while_enraged = meld.delete(),
        dying_trigger_effect = meld.delete(),
        forward_padding = 0.0,
        backward_padding = 0.0,
        forward_overlap = 0,
        backward_overlap = 0,
        collision_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        selection_box = { { -1.5 * scale, -.8 * scale }, { 1.5 * scale, .8 * scale } },
        collision_mask = { layers = { item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true } },
        render_layer = "object",
        max_health = 10000,
        healing_per_tick = 1,
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
        resistances = meld.overwrite {
            {
                type = "poison",
                percent = 100,
            }
        },
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
        })
    }

    for i = 0, 8 do
        data:extend({ create_centipede_segment(health, i, segment_overrides) })
    end


    local centipede_tail = meld(table.deepcopy(data.raw["segment"]["small-demolisher-segment-x0_64"]),
        tail_segment_overrides)
    centipede_tail.name = "centipede-tail-" .. health
    centipede_tail.max_health = health
    data:extend({ centipede_tail })


    data:extend({ meld(table.deepcopy(data.raw["segmented-unit"]["small-demolisher"]), head_overrides) })
end

create_centipede("small", 0.2, settings.startup["tenebris-small-centipede-length"].value, 2000, 0.1, 100, 50)
create_centipede("medium", 0.3, settings.startup["tenebris-medium-centipede-length"].value, 5000, 0.15, 300, 300)
create_centipede("large", 0.5, settings.startup["tenebris-large-centipede-length"].value, 10000, 0.2, 500, 1000)
create_centipede("giant", 1.0, settings.startup["tenebris-giant-centipede-length"].value, 30000, 0.25, 1000, 2000)
