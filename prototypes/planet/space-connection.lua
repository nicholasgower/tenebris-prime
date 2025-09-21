local tenebris_asteroid_util = require("__tenebris-prime__.prototypes.planet.asteroid-spawn-definitions")

data:extend({
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
        name = "tenebris-lightless-gateway",
        subgroup = "planet-connections",
        from = "tenebris",
        to = "lightless-gateway",
        order = "e",
        length = 90000,
        asteroid_spawn_definitions = {}
    },
    {
        type = "space-connection",
        name = "lightless-gateway-lightless-abyss",
        subgroup = "planet-connections",
        from = "lightless-gateway",
        to = "lightless-abyss",
        order = "f",
        length = 9000000,
        asteroid_spawn_definitions = {}
    },
})
