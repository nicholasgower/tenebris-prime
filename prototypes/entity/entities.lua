local hit_effects = require("__base__.prototypes.entity.hit-effects")
local meld = require("meld")
local sounds = require("__base__.prototypes.entity.sounds")
local tenebris = require("lib.tenebris")
local constants = require("lib.constants")
local bioluminescent = require("lib.bioluminescent")

-- Convenience alias
local make_bioluminescent_particle = bioluminescent.make_particle


local tenebris_bioluminescent_beacon = meld(table.deepcopy(data.raw["beacon"]["beacon"]), {
    name = "tenebris-biobeacon",
    bioluminescent = true,
    allowed_effects = meld.overwrite { "consumption", "speed", "pollution", "productivity" },
    minable = {
        mining_time = 0.2,
        result = "tenebris-biobeacon"
    },
    integration_patch_render_layer = "light-effect",
    integration_patch = meld.overwrite {
        filename = "__tenebris-prime__/graphics/icons/item-glow.png",
        size = 64,
        scale = 6,
        draw_as_light = true,
    },
    graphics_set = meld.overwrite {
        animation_list = {
            {
                animation = {
                    animation_speed = 0.2,
                    frame_count = 9,
                    scale = 0.3,
                    size = 512,
                    shift = {0,-0.5},
                    stripes = {
                        {
                            filename = "__tenebris-prime__/graphics/entity/biobeacon.png",
                            width_in_frames = 10,
                            height_in_frames = 1,
                        }
                    }
                },
            }
        }
    }
})

local tenebris_bioinfuser = {
    type = "furnace",
    name = "tenebris-bioinfusor",
    icon = "__tenebris-prime__/graphics/icons/tenebris-bioinfusor.png",
    bioluminescent = true,
    working_sound = {
        sound = { filename = "__tenebris-prime__/sound/bioinfusor.ogg", volume = 0.5 },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    crafting_categories = { "bioinfusion" },
    crafting_speed = 2.0,
    energy_usage = "300kW",
    source_inventory_size = 1,
    result_inventory_size = 1,
    module_slots = 2,
    allowed_effects = { "speed", "consumption" },
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2, -2}, {2, 2}},
    minable = {
        mining_time = 0.2,
        result = "tenebris-bioinfusor"
    },
    integration_patch_render_layer = "light-effect",
    integration_patch = {
        filename = "__tenebris-prime__/graphics/icons/item-glow.png",
        size = 64,
        scale = 8,
        draw_as_light = true,
    },
    graphics_set = {
        animation = {
            animation_speed = 0.2,
            frame_count = 16,
            scale = 0.3,
            size = 512,
            shift = util.by_pixel(0, -7),
            stripes = {
                {
                    filename = "__tenebris-prime__/graphics/entity/bioinfusor.png",
                    width_in_frames = 4,
                    height_in_frames = 4,
                }
            }
        }
    },
    energy_source =
    {
        type = "burner",
        fuel_categories = { "bioluminescent" },
        effectivity = 1,
        burner_usage = "bioluminescent-crystals",
        fuel_inventory_size = 1,
        light_flicker = require("__space-age__.prototypes.entity.biochamber-pictures").light_flicker
    },
}

local tenebris_heated_pumpjack = meld(table.deepcopy(data.raw["mining-drill"]["pumpjack"]), {
    name = "tenebris-heated-pumpjack",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 0.5, result = "tenebris-heated-pumpjack" },
    fast_replaceable_group = "pumpjack",
    max_health = 300,
    mining_speed = 2,
    resistances = { { type = "fire", percent = 70 } },
    damaged_trigger_effect = hit_effects.entity(),
    module_slots = 3,
    allowed_effects = { "consumption", "speed", "productivity" },
    -- Normal pumpjack uses 90kW, we use 180kW (2x) via heat
    energy_usage = "270kW",
    energy_source = {
      type = "heat",
      max_temperature = 2000,
      specific_heat = "500kJ",
      max_transfer = "500kW",
      min_working_temperature = 500,
      minimum_glow_temperature = 350,
      emissions_per_minute = {
        tenecap_spore_clearance = 40,
      },
      connections =
      {
        {
          position = {0, 1},
          direction = defines.direction.south
        },
        {
          position = {0, -1},
          direction = defines.direction.north
        },
        {
          position = {1, 0},
          direction = defines.direction.east
        },
        {
          position = {-1, 0},
          direction = defines.direction.west
        },
      },
      pipe_covers =
        make_4way_animation_from_spritesheet(
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
      heat_pipe_covers =
        make_4way_animation_from_spritesheet(
        apply_heat_pipe_glow{
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
    },
})

-- Apply tint to animation graphics
local function apply_tint_to_animation(animation, tint)
    if not animation then return end
    if animation.layers then
        for _, layer in pairs(animation.layers) do
            -- Don't tint shadows
            if not layer.draw_as_shadow then
                layer.tint = tint
            end
        end
    elseif animation.filename then
        animation.tint = tint
    end
end

local heat_tint = tenebris.TINT.HEAT
local heat_tint_light = tenebris.TINT.HEAT_LIGHT

-- Apply tint to all animation directions
if tenebris_heated_pumpjack.graphics_set then
    local gs = tenebris_heated_pumpjack.graphics_set
    if gs.animation then
        if gs.animation.north then apply_tint_to_animation(gs.animation.north, heat_tint) end
        if gs.animation.east then apply_tint_to_animation(gs.animation.east, heat_tint) end
        if gs.animation.south then apply_tint_to_animation(gs.animation.south, heat_tint) end
        if gs.animation.west then apply_tint_to_animation(gs.animation.west, heat_tint) end
    end
end

local tenebris_air_scrubber = meld(table.deepcopy(data.raw["furnace"]["atan-air-scrubber"]), {
    name = "tenebris-heated-atmosphere-scrubber",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 0.2, result = "tenebris-heated-atmosphere-scrubber" },
    fast_replaceable_group = nil,
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "big-explosion",
    resistances = { { type = "fire", percent = 70 } },
    collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
    selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    module_slots = 0,
    allowed_effects = { "consumption", "speed" },
    crafting_categories = { "atmospheric-filtration" },
    crafting_speed = 2,
    source_inventory_size = 1,
    result_inventory_size = 1,
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    energy_source = {
      type = "heat",
      max_temperature = 2000,
      specific_heat = "2MJ",
      max_transfer = "2GW",
      min_working_temperature = 600,
      minimum_glow_temperature = 850,
      emissions_per_minute = {
        tenecap_spore_clearance = 300,
      },
      connections =
      {
        {
          position = {0, 1.2},
          direction = defines.direction.south
        },
        {
          position = {0, -1.2},
          direction = defines.direction.north
        },
        {
          position = {1.2, 0},
          direction = defines.direction.east
        },
        {
          position = {-1.2, 0},
          direction = defines.direction.west
        },
      },
      pipe_covers =
        make_4way_animation_from_spritesheet(
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
      heat_pipe_covers =
        make_4way_animation_from_spritesheet(
        apply_heat_pipe_glow{
          filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
          width = 64,
          height = 64,
          direction_count = 4,
          scale = 0.5
        }),
      heat_picture =
      {
        north = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-N-heated.png",
          priority = "extra-high",
          width = 44,
          height = 96,
          shift = util.by_pixel(-0.5, 8.5),
          scale = 0.5
        },
        east = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-E-heated.png",
          priority = "extra-high",
          width = 80,
          height = 80,
          shift = util.by_pixel(-21, -13),
          scale = 0.5
        },
        south = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-S-heated.png",
          priority = "extra-high",
          width = 28,
          height = 40,
          shift = util.by_pixel(-1, -30),
          scale = 0.5
        },
        west = apply_heat_pipe_glow
        {
          filename = "__base__/graphics/entity/heat-exchanger/heatex-W-heated.png",
          priority = "extra-high",
          width = 64,
          height = 76,
          shift = util.by_pixel(23, -13),
          scale = 0.5
        }
      }
    },
    energy_usage = "5MW",
})

-- Apply subtle warm tint to the air scrubber graphics
if tenebris_air_scrubber.graphics_set then
    local gs = tenebris_air_scrubber.graphics_set
    -- Handle non-directional animation (layers array)
    if gs.animation then
        apply_tint_to_animation(gs.animation, heat_tint_light)
    end
    -- Handle directional animations if present
    if gs.animation and gs.animation.north then
        apply_tint_to_animation(gs.animation.north, heat_tint_light)
        apply_tint_to_animation(gs.animation.east, heat_tint_light)
        apply_tint_to_animation(gs.animation.south, heat_tint_light)
        apply_tint_to_animation(gs.animation.west, heat_tint_light)
    end
    if gs.working_visualisations then
        for _, vis in pairs(gs.working_visualisations) do
            if vis.animation then apply_tint_to_animation(vis.animation, heat_tint_light) end
            if vis.north_animation then apply_tint_to_animation(vis.north_animation, heat_tint_light) end
            if vis.east_animation then apply_tint_to_animation(vis.east_animation, heat_tint_light) end
            if vis.south_animation then apply_tint_to_animation(vis.south_animation, heat_tint_light) end
            if vis.west_animation then apply_tint_to_animation(vis.west_animation, heat_tint_light) end
        end
    end
end

-- ========================================
-- CHITOSAN PIPES
-- ========================================
local chitosan_tint = tenebris.TINT.CHITOSAN

local function apply_tint_recursive(obj)
    if not obj then return end
    if type(obj) ~= "table" then return end
    
    -- Apply tint to this object if it has a filename (sprite)
    if obj.filename and not obj.draw_as_shadow then
        obj.tint = chitosan_tint
    end
    
    -- Recurse into nested tables
    for _, v in pairs(obj) do
        if type(v) == "table" then
            apply_tint_recursive(v)
        end
    end
end

local tenebris_biopipe = meld(table.deepcopy(data.raw["pipe"]["pipe"]), {
    name = "tenebris-biopipe",
    minable = { mining_time = 0.1, result = "tenebris-biopipe" },
    fast_replaceable_group = "pipe",
    max_health = 150,
})
apply_tint_recursive(tenebris_biopipe.pictures)

local tenebris_biopipe_to_ground = meld(table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"]), {
    name = "tenebris-biopipe-to-ground",
    minable = { mining_time = 0.1, result = "tenebris-biopipe-to-ground" },
    fast_replaceable_group = "pipe-to-ground",
    max_health = 200,
    fluid_box = meld.overwrite {
        volume = 100,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            { direction = defines.direction.north, position = { 0, 0 } },
            {
                connection_type = "underground",
                direction = defines.direction.south,
                position = { 0, 0 },
                max_underground_distance = 12,
            },
        },
        hide_connection_info = true,
    },
})
apply_tint_recursive(tenebris_biopipe_to_ground.pictures)

-- Piezoelectric Inserter: Bulk inserter capacity, burner inserter speed, no power required
-- Supports toggling between normal and long-handed reach via GUI
local piezoelectric_inserter = meld(table.deepcopy(data.raw["inserter"]["bulk-inserter"]), {
    name = "piezoelectric-inserter",
    minable = { mining_time = 0.1, result = "piezoelectric-inserter" },
    max_health = 120,
    -- Burner inserter speed (slower than bulk inserter)
    extension_speed = 0.0214,
    rotation_speed = 0.01,
    -- No power required - uses void energy source
    energy_source = meld.overwrite {
        type = "void",
    },
    energy_per_movement = "1J",
    energy_per_rotation = "1J",
    -- Enable runtime pickup/drop position changes for long-handed toggle
    allow_custom_vectors = true,
})

-- Apply dark orange tint to all graphics
local function apply_tint_to_inserter(inserter, tint)
    local function apply_to_layers(obj)
        if type(obj) ~= "table" then return end
        if obj.layers then
            for _, layer in ipairs(obj.layers) do
                layer.tint = tint
                apply_to_layers(layer)
            end
        end
        if obj.filename then
            obj.tint = tint
        end
        for _, v in pairs(obj) do
            if type(v) == "table" then
                apply_to_layers(v)
            end
        end
    end
    
    if inserter.hand_base_picture then apply_to_layers(inserter.hand_base_picture) end
    if inserter.hand_closed_picture then apply_to_layers(inserter.hand_closed_picture) end
    if inserter.hand_open_picture then apply_to_layers(inserter.hand_open_picture) end
    if inserter.platform_picture then apply_to_layers(inserter.platform_picture) end
end

apply_tint_to_inserter(piezoelectric_inserter, tenebris.TINT.DARK_ORANGE)

-- ============================================================================
-- HEATED AGRICULTURAL TOWER
-- Heat-powered version with extended range and faster operation
-- ============================================================================

-- Create modified crane with doubled speeds
local heated_crane = table.deepcopy(require("__space-age__.prototypes.entity.agricultural-tower-crane"))
heated_crane.speed.arm.turn_rate = 0.004           -- 2x (was 0.002)
heated_crane.speed.arm.extension_speed = 0.01     -- 2x (was 0.005)
heated_crane.speed.grappler.vertical_turn_rate = 0.004   -- 2x (was 0.002)
heated_crane.speed.grappler.horizontal_turn_rate = 0.02  -- 2x (was 0.01)
heated_crane.speed.grappler.extension_speed = 0.02       -- 2x (was 0.01)

local tenebris_heated_agricultural_tower = meld(table.deepcopy(data.raw["agricultural-tower"]["agricultural-tower"]), {
    name = "tenebris-heated-agricultural-tower",
    minable = { mining_time = 0.5, result = "tenebris-heated-agricultural-tower" },
    fast_replaceable_group = nil,
    max_health = 750,  -- Increased durability
    radius = 4,  -- Extended range (was 3)
    heating_energy = "300kW",      -- 3x (was 100kW)
    energy_usage = "300kW",        -- 3x (was 100kW)
    crane_energy_usage = "300kW",  -- 3x (was 100kW)
    crane = meld.overwrite(heated_crane),
    surface_conditions = meld.overwrite({}),  -- Works on any planet
    resistances = meld.overwrite({
        { type = "fire", percent = 100 },
        { type = "acid", percent = 80 },
    }),
    energy_source = meld.overwrite({
        type = "heat",
        max_temperature = 2000,
        specific_heat = "5MJ",
        max_transfer = "2GW",
        min_working_temperature = 500,
        minimum_glow_temperature = 350,
        emissions_per_minute = {
            tenecap_spore_clearance = 70,
        },
        connections = {
            { position = {0, 1.2}, direction = defines.direction.south },
            { position = {0, -1.2}, direction = defines.direction.north },
            { position = {1.2, 0}, direction = defines.direction.east },
            { position = {-1.2, 0}, direction = defines.direction.west },
        },
        pipe_covers =
            make_4way_animation_from_spritesheet(
            {
                filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
                width = 64,
                height = 64,
                direction_count = 4,
                scale = 0.5
            }),
        heat_pipe_covers =
            make_4way_animation_from_spritesheet(
            apply_heat_pipe_glow{
                filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
                width = 64,
                height = 64,
                direction_count = 4,
                scale = 0.5
            }),
    }),
})

-- Apply warm tint to heated agricultural tower graphics
local heat_tint = tenebris.TINT.HEAT_LIGHT
if tenebris_heated_agricultural_tower.graphics_set then
    local gs = tenebris_heated_agricultural_tower.graphics_set
    if gs.animation and gs.animation.layers then
        for _, layer in ipairs(gs.animation.layers) do
            if not layer.draw_as_shadow then
                layer.tint = heat_tint
            end
        end
    end
end

-- Piezoelectric Lamp - void-powered, twice as bright as base lamp
local piezoelectric_lamp = {
    type = "lamp",
    name = "piezoelectric-lamp",
    icon = "__base__/graphics/icons/small-lamp.png",
    flags = {"placeable-neutral", "player-creation"},
    fast_replaceable_group = "lamp",
    minable = {mining_time = 0.1, result = "piezoelectric-lamp"},
    max_health = 100,
    corpse = "lamp-remnants",
    dying_explosion = "lamp-explosion",
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    impact_category = "glass",
    open_sound = {filename = "__base__/sound/open-close/electric-small-open.ogg", volume = 0.7},
    close_sound = {filename = "__base__/sound/open-close/electric-small-close.ogg", volume = 0.7},
    energy_source = {
        type = "void"
    },
    energy_usage_per_tick = "1W",
    darkness_for_all_lamps_on = 0.5,
    darkness_for_all_lamps_off = 0.3,
    -- Twice as bright: intensity 0.9 -> 1.8, size 40 -> 80
    light = {intensity = 1.8, size = 80, color = {1, 1, 0.75}},
    light_when_colored = {intensity = 0, size = 12, color = {1, 1, 0.75}},
    glow_size = 12,
    glow_color_intensity = 1,
    glow_render_mode = "multiplicative",
    picture_off = {
        layers = {
            {
                filename = "__base__/graphics/entity/small-lamp/lamp.png",
                priority = "high",
                width = 83,
                height = 70,
                shift = util.by_pixel(0.25, 3),
                scale = 0.5
            },
            {
                filename = "__base__/graphics/entity/small-lamp/lamp-shadow.png",
                priority = "high",
                width = 76,
                height = 47,
                shift = util.by_pixel(4, 4.75),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    },
    picture_on = {
        filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
        priority = "high",
        width = 90,
        height = 78,
        shift = util.by_pixel(0, -7),
        scale = 0.5
    },
    signal_to_color_mapping = {
        {type = "virtual", name = "signal-red",    color = {1, 0, 0}},
        {type = "virtual", name = "signal-green",  color = {0, 1, 0}},
        {type = "virtual", name = "signal-blue",   color = {0, 0, 1}},
        {type = "virtual", name = "signal-yellow", color = {1, 1, 0}},
        {type = "virtual", name = "signal-pink",   color = {1, 0, 1}},
        {type = "virtual", name = "signal-cyan",   color = {0, 1, 1}},
        {type = "virtual", name = "signal-white",  color = {1, 1, 1}},
        {type = "virtual", name = "signal-grey",   color = {0.5, 0.5, 0.5}},
        {type = "virtual", name = "signal-black",  color = {0, 0, 0}}
    },
    default_red_signal = { type = "virtual", name = "signal-red" },
    default_green_signal = { type = "virtual", name = "signal-green" },
    default_blue_signal = { type = "virtual", name = "signal-blue" },
    default_rgb_signal = { type = "virtual", name = "signal-white" },
    circuit_connector = circuit_connector_definitions["lamp"],
    circuit_wire_max_distance = default_circuit_wire_max_distance
}

-- =============================================================================
-- HEATED BIG MINING DRILL
-- Heat-powered version of big mining drill for remote lichen deposit mining
-- Faster with extra module slot, but less beneficial resource drain
-- =============================================================================

local tenebris_heated_big_mining_drill = meld(table.deepcopy(data.raw["mining-drill"]["big-mining-drill"]), {
    name = "tenebris-heated-big-mining-drill",
    icon = "__space-age__/graphics/icons/big-mining-drill.png",
    minable = { mining_time = 0.5, result = "tenebris-heated-big-mining-drill" },
    fast_replaceable_group = "big-mining-drill",
    mining_speed = 3.5,  -- 40% faster than base (2.5)
    module_slots = 4,    -- One extra slot
    resource_drain_rate_percent = 100,  -- No preservation at normal quality, quality reduces drain
    resource_searching_radius = 4.49,  -- Smaller base area, scales with quality
    quality_affects_mining_radius = true,  -- Higher quality = larger mining area
    quality_affects_module_slots = true,  -- Quality does NOT add extra module slots
    energy_usage = "500kW",
    resistances = meld.overwrite({
        { type = "fire", percent = 100 },
        { type = "acid", percent = 80 },
    }),
    energy_source = meld.overwrite({
        type = "heat",
        max_temperature = 2000,
        specific_heat = "5MJ",
        max_transfer = "2GW",
        min_working_temperature = 650,
        minimum_glow_temperature = 500,
        emissions_per_minute = {
            tenecap_spore_clearance = 30,
        },
        connections = {
            { position = {-2, 0}, direction = defines.direction.west },
            { position = {2, 0}, direction = defines.direction.east },
        },
        pipe_covers = make_4way_animation_from_spritesheet({
            filename = "__base__/graphics/entity/heat-exchanger/heatex-endings.png",
            width = 64,
            height = 64,
            direction_count = 4,
            scale = 0.5
        }),
        heat_pipe_covers = make_4way_animation_from_spritesheet(
            apply_heat_pipe_glow({
                filename = "__base__/graphics/entity/heat-exchanger/heatex-endings-heated.png",
                width = 64,
                height = 64,
                direction_count = 4,
                scale = 0.5
            })
        ),
    }),
})

-- Apply heat tint to the big mining drill graphics
local function apply_tint_recursive_drill(obj, tint)
    if type(obj) ~= "table" then return end
    -- Don't tint shadows
    if obj.draw_as_shadow then return end
    -- Apply tint if this looks like a sprite
    if obj.filename and not obj.draw_as_shadow then
        obj.tint = tint
    end
    -- Recurse into child tables
    for _, v in pairs(obj) do
        if type(v) == "table" then
            apply_tint_recursive_drill(v, tint)
        end
    end
end

apply_tint_recursive_drill(tenebris_heated_big_mining_drill.graphics_set, heat_tint)
apply_tint_recursive_drill(tenebris_heated_big_mining_drill.wet_mining_graphics_set, heat_tint)

data:extend({
    tenebris_bioluminescent_beacon,
    tenebris_bioinfuser,
    tenebris_heated_pumpjack,
    tenebris_air_scrubber,
    tenebris_biopipe,
    tenebris_biopipe_to_ground,
    piezoelectric_inserter,
    tenebris_heated_agricultural_tower,
    piezoelectric_lamp,
    tenebris_heated_big_mining_drill,
})
