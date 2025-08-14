local tenebris_map_gen = require("__tenebris-prime__.prototypes.planet.tenebris_map_gen")
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local tenebris_asteroid_util = require("__tenebris-prime__.prototypes.planet.asteroid-spawn-definitions")

local meld = require("meld")
local tenebris = meld(table.deepcopy(data.raw["planet"]["gleba"]), {
    type = "planet",
    name = "tenebris",
    icon = "__tenebris-prime__/graphics/icons/tenebris.png",
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-planet-tenebris.png",
    starmap_icon_size = 512,
    map_gen_settings = meld.overwrite(tenebris_map_gen()),
    gravity_pull = 10,
    orbit = {
        type = "planet",
        parent = {
            type = "space-location",
            name ="star",
            },
        distance = 45,
        orientation = 0.450,
    },
    magnitude = 1.2,
    label_orientation = 0.15,
    order = "e[tenebris]",
    subgroup = "planets",
    pollutant_type = "light",
    solar_power_in_space = 25,
    surface_properties =
    {
        ["day-night-cycle"] = 20 * 60,
        ["magnetic-field"] = meld.delete(),
        pressure = 18000,
        ["solar-power"] = 0,
        gravity = 30
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
      }
    },
    ticks_between_player_effects = 2
})
tenebris.distance = nil
tenebris.orientation = nil
PlanetsLib:extend({tenebris})

local iridescent_river = { -- Bismuth harvesting route
    type = "space-location",
    name = "iridescent-river",
    icon = "__tenebris-prime__/graphics/icons/iridescent-river.png",
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-planet-tenebris.png",
    starmap_icon_size = 512,
    order = "f[iridescent-river]",
    subgroup = "planets",
    gravity_pull = -10,
    magnitude = 0.8,
    distance = 52,
    orientation = 0.48,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    solar_power_in_space = 1,
}

local lightless_abyss = { -- Deep space endurance challenge on limited resources
    type = "space-location",
    name = "lightless-abyss",
    icon = "__tenebris-prime__/graphics/icons/tenebris.png",
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-planet-tenebris.png",
    starmap_icon_size = 512,
    order = "f[lightless-abyss]",
    subgroup = "planets",
    gravity_pull = -50,
    magnitude = 0.8,
    distance = 92,
    orientation = 0.44,
    draw_orbit = false,
    fly_condition = true,
    label_orientation = 0.15,
    solar_power_in_space = 0,
}


data:extend({
    iridescent_river,
    lightless_abyss,
    {
        type = "space-connection",
        name = "fulgora-tenebris",
        subgroup = "planet-connections",
        from = "fulgora",
        to = "tenebris",
        order = "b",
        length = 75000,
        asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.fulgora_tenebris)
    },
    {
        type = "space-connection",
        name = "tenebris-iridescent-river",
        subgroup = "planet-connections",
        from = "tenebris",
        to = "iridescent-river",
        order = "d",
        length = 62000,
        asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.tenebris_iridescent_river)
    },
    {
        type = "space-connection",
        name = "tenebris-lightless-abyss",
        subgroup = "planet-connections",
        from = "tenebris",
        to = "lightless-abyss",
        order = "e",
        length = 9000000,
        asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.tenebris_lightless_abyss)
    },
})
