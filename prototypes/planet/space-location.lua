local meld = require("meld")
local constants = require("lib.constants")
local tenebris_asteroid_util = require("__tenebris-prime__.prototypes.planet.asteroid-spawn-definitions")
local tenebris_map_gen = require("__tenebris-prime__.prototypes.planet.tenebris_map_gen")
local planet_catalogue_tenebris = require("__tenebris-prime__.prototypes.planet.procession-catalogue-tenebris")

-- Surface property for innate energy luminosity
-- Only Tenebris has significant deposits of piezoelectric quartz crystals
data:extend({
    {
        type = "surface-property",
        name = "innate-energy-luminosity",
        default_value = 0,
        localised_name = {"surface-property-name.innate-energy-luminosity"},
        localised_description = {"surface-property-description.innate-energy-luminosity"},
    }
})

local tenebris = meld(table.deepcopy(data.raw["planet"]["gleba"]), {
    type = "planet",
    name = constants.PLANET.TENEBRIS,
    icon = "__tenebris-prime__/graphics/icons/starmap-icon-tenebris.png",
    icon_size = 3840,
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-icon-tenebris.png",
    starmap_icon_size = 3840,
    map_gen_settings = meld.overwrite(tenebris_map_gen()),
    gravity_pull = 10,
    orbit = {
        type = "planet",
        parent = {
            type = "space-location",
            name ="star",
            },
        distance = 45,
        orientation = 0.60,
    },
    magnitude = 1.2,
    label_orientation = 0.15,
    subgroup = "planets",
    pollutant_type = "tenecap_spore_clearance",
    solar_power_in_space = 25,
    surface_properties =
    {
        ["day-night-cycle"] = 20 * 60,
        ["magnetic-field"] = meld.delete(),
        pressure = 18000,
        ["solar-power"] = 0,
        gravity = 30,
        ["innate-energy-luminosity"] = 100,  -- High innate energy from piezoelectric quartz
    },
    surface_render_parameters =
    {
        shadow_opacity = 0.1,
        day_night_cycle_color_lookup = {
            {0.0, "identity"},
            {0.35, "__tenebris-prime__/graphics/lut/night.png"},
        },
        fog = {
          fog_type = "gleba",
          shape_noise_texture = {
            filename = "__core__/graphics/clouds-noise.png",
            size = 2048
          },
          detail_noise_texture = {
            filename = "__core__/graphics/clouds-detail-noise.png",
            size = 2048
          },
          color1 = {0.133, 0.137, 0.153, 1.0}, -- #222327
          color2 = {0.2, 0.169, 0.212, 1.0}, -- #332b36
          tick_factor = 0.001,
        },
    },
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.fulgora_tenebris, 0.9),
    procession_graphic_catalogue = planet_catalogue_tenebris,
    draw_orbit = false,
    redrawn_connections_exclude = true,  -- Exclude from Redrawn Space Connections mod
    player_effects =
    { -- TODO: replace with shader & find a way to have rain appear and disappear with weather system.
      type = "cluster",
      cluster_count = 100,
      distance = 2,
      distance_deviation = 2,
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          type = "create-trivial-smoke",
          smoke_name = "gleba-raindrops",
          speed = {-0.2, 0.7},
          initial_height = 1,
          speed_multiplier = 0.2,
          speed_multiplier_deviation = 0.05,
          starting_frame = 2,
          starting_frame_deviation = 10,
          offset_deviation = {{-96, -56}, {96, 40}},
          speed_from_center = 0.01,
          speed_from_center_deviation = 0.02
        }
      },
    },
    ticks_between_player_effects = 2
})
tenebris.distance = nil
tenebris.orientation = nil

PlanetsLib:extend({tenebris})

local iridescent_river = { -- Bismuth harvesting route
    type = "space-location",
    name = "iridescent-river",
    icon = "__tenebris-prime__/graphics/icons/starmap-icon-iridescent-river.png",
    icon_size = 4096,
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-icon-iridescent-river.png",
    starmap_icon_size = 4096,
    subgroup = "planets",
    gravity_pull = -10,
    magnitude = 0.8,
    distance = 47,
    orientation = 0.64,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.tenebris_iridescent_river, 0.9),
    solar_power_in_space = 1,
    redrawn_connections_exclude = true,  -- Exclude from Redrawn Space Connections mod
}

local the_nest = { -- Leviathan centipede spawning grounds
    type = "space-location",
    name = "the-nest",
    icon = "__tenebris-prime__/graphics/icons/starmap-icon-nest.png",
    icon_size = 3840,
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-icon-nest.png",
    starmap_icon_size = 3840,
    subgroup = "planets",
    gravity_pull = -20,
    magnitude = 0.6,
    distance = 61,
    orientation = 0.63,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.the_nest_route, 0.9),
    solar_power_in_space = 1,
    redrawn_connections_exclude = true,  -- Exclude from Redrawn Space Connections mod
}

local lightless_gateway = { -- Deep space endurance challenge on limited resources
    type = "space-location",
    name = "lightless-gateway",
    icon = "__tenebris-prime__/graphics/icons/starmap-icon-lightless-gateway.png",
    icon_size = 4096,
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-icon-lightless-gateway.png",
    starmap_icon_size = 4096,
    subgroup = "planets",
    gravity_pull = -50,
    magnitude = 0.8,
    distance = 71,
    orientation = 0.64,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = {},
    solar_power_in_space = 0,
    redrawn_connections_exclude = true,  -- Exclude from Redrawn Space Connections mod
}

local lightless_abyss = { -- Deep space endurance challenge on limited resources
    type = "space-location",
    name = "lightless-abyss",
    icon = "__tenebris-prime__/graphics/icons/starmap-icon-tenebris.png",
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-planet-tenebris.png",
    starmap_icon_size = 512,
    subgroup = "planets",
    gravity_pull = -80,
    magnitude = 0.84,
    distance = 112,
    orientation = 0.71,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    asteroid_spawn_influence = 0,
    asteroid_spawn_definitions = {},
    solar_power_in_space = 0,
    redrawn_connections_exclude = true,  -- Exclude from Redrawn Space Connections mod
}

PlanetsLib:extend({tenebris})
data:extend({
    iridescent_river,
    the_nest,
    lightless_gateway,
    lightless_abyss,
})