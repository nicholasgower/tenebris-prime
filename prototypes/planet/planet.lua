local tenebris_map_gen = require("__tenebris-prime__.prototypes.planet.tenebris_map_gen")
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

local meld = require("meld")

local tenebris = {
    type = "planet",
    name = "tenebris",
    icon = "__tenebris-prime__/graphics/icons/tenebris.png",
    starmap_icon = "__tenebris-prime__/graphics/icons/starmap-planet-tenebris.png",
    starmap_icon_size = 512,
    map_gen_settings = meld.overwrite(tenebris_map_gen()),
    gravity_pull = 10,
    distance = 30,
    orientation = 0.450,
    magnitude = 1.0,
    label_orientation = 0.15,
    order = "e[tenebris]",
    subgroup = "planets",
    pollutant_type = nil,
    solar_power_in_space = 60,
    surface_properties =
    {
        ["day-night-cycle"] = 20 * 60,
        ["magnetic-field"] = meld.delete(),
        pressure = 3000,
        ["solar-power"] = 0,
        gravity = 30
    },
    surface_render_parameters =
    {
        shadow_opacity = 0.0,
        day_night_cycle_color_lookup = {
            {0.0, "identity"},
            {0.35, "__tenebris-prime__/graphics/lut/night.png"},
        }
    },
    ticks_between_player_effects = 2
}

tenebris = meld(table.deepcopy(data.raw["planet"]["gleba"]), tenebris)

data:extend({
    tenebris,
    {
        type = "space-connection",
        name = "fulgora-tenebris",
        subgroup = "planet-connections",
        from = "fulgora",
        to = "tenebris",
        order = "b",
        length = 30000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.gleba_aquilo)
    },
    {
        type = "space-connection",
        name = "tenebris-solar-system-edge",
        subgroup = "planet-connections",
        from = "tenebris",
        to = "solar-system-edge",
        order = "c",
        length = 100000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.aquilo_solar_system_edge)
    }
})
