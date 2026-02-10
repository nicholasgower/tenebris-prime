local meld = require("meld")
local tenebris = require("lib.tenebris")

-- Thermal Diode - One-way heat flow controlled by temperature threshold
-- 1x2 design with swappable endpoints
-- Below threshold: single-sided endpoints (no connection between input/output)
-- Above threshold: double-sided endpoints (heat flows through)

local base_heat_pipe = data.raw["heat-pipe"]["heat-pipe"]
local base_combinator = data.raw["decider-combinator"]["decider-combinator"]

-- Heat buffer configurations
local STEEL_HEAT_BUFFER = {
    max_temperature = 1000,
    specific_heat = "1MJ",
    max_transfer = "1GW",
    min_temperature_gradient = 1,
    minimum_glow_temperature = 350,
}

local CERAMIC_HEAT_BUFFER = {
    max_temperature = 1000,
    specific_heat = "2MJ",
    max_transfer = "10GW",
    min_temperature_gradient = 1,
    minimum_glow_temperature = 350,
}

-- Helper to create an endpoint prototype with custom heat buffer
local function make_endpoint(name, connections, heat_config)
    return meld(table.deepcopy(base_heat_pipe), {
        name = name,
        flags = {"placeable-neutral", "not-on-map", "not-deconstructable", "not-blueprintable", "hide-alt-info"},
        hidden = true,
        hidden_in_factoriopedia = true,
        collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
        collision_mask = {layers = {}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        selectable_in_game = false,
        heat_buffer = meld.overwrite({
            max_temperature = heat_config.max_temperature,
            specific_heat = heat_config.specific_heat,
            max_transfer = heat_config.max_transfer,
            min_temperature_gradient = heat_config.min_temperature_gradient,
            minimum_glow_temperature = heat_config.minimum_glow_temperature,
            connections = connections,
        }),
    })
end

-- Helper to create tinted sprites
local function make_tinted_sprites(tint)
    local tinted = table.deepcopy(base_combinator.sprites)
    for _, dir in pairs({"north", "east", "south", "west"}) do
        if tinted[dir] then
            tinted[dir].tint = tint
        end
    end
    return tinted
end

-- Helper to create the interface entity (decider combinator)
local function make_interface(name, item_name, tint)
    return meld(table.deepcopy(base_combinator), {
        name = name,
        icons = {
            {
                icon = "__base__/graphics/icons/decider-combinator.png",
                icon_size = 64,
                tint = tint,
            }
        },
        minable = {mining_time = 0.5, result = item_name},
        max_health = 200,
        -- Swap input/output bounding boxes so heat flow direction matches circuit flow
        input_connection_bounding_box = base_combinator.output_connection_bounding_box,
        output_connection_bounding_box = base_combinator.input_connection_bounding_box,
        input_connection_points = base_combinator.output_connection_points,
        output_connection_points = base_combinator.input_connection_points,
        sprites = meld.overwrite(make_tinted_sprites(tint)),
    })
end

-- Connection definitions
local CONN_N = {{ position = {0, 0}, direction = defines.direction.north }}
local CONN_S = {{ position = {0, 0}, direction = defines.direction.south }}
local CONN_E = {{ position = {0, 0}, direction = defines.direction.east }}
local CONN_W = {{ position = {0, 0}, direction = defines.direction.west }}
local CONN_NS = {
    { position = {0, 0}, direction = defines.direction.north },
    { position = {0, 0}, direction = defines.direction.south },
}
local CONN_EW = {
    { position = {0, 0}, direction = defines.direction.east },
    { position = {0, 0}, direction = defines.direction.west },
}

-- ============================================================================
-- STEEL THERMAL DIODE (base values: 1MJ specific_heat, 1GW max_transfer)
-- ============================================================================
local steel_endpoints = {
    make_endpoint("tenebris-steel-thermal-diode-endpoint-closed-n", CONN_N, STEEL_HEAT_BUFFER),
    make_endpoint("tenebris-steel-thermal-diode-endpoint-closed-s", CONN_S, STEEL_HEAT_BUFFER),
    make_endpoint("tenebris-steel-thermal-diode-endpoint-closed-e", CONN_E, STEEL_HEAT_BUFFER),
    make_endpoint("tenebris-steel-thermal-diode-endpoint-closed-w", CONN_W, STEEL_HEAT_BUFFER),
    make_endpoint("tenebris-steel-thermal-diode-endpoint-open-ns", CONN_NS, STEEL_HEAT_BUFFER),
    make_endpoint("tenebris-steel-thermal-diode-endpoint-open-ew", CONN_EW, STEEL_HEAT_BUFFER),
}

local steel_interface = make_interface(
    "tenebris-steel-thermal-diode",
    "tenebris-steel-thermal-diode",
    tenebris.TINT.HEAT_LIGHT
)

-- ============================================================================
-- CERAMIC THERMAL DIODE (ceramic values: 2MJ specific_heat, 10GW max_transfer)
-- ============================================================================
local ceramic_endpoints = {
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-closed-n", CONN_N, CERAMIC_HEAT_BUFFER),
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-closed-s", CONN_S, CERAMIC_HEAT_BUFFER),
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-closed-e", CONN_E, CERAMIC_HEAT_BUFFER),
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-closed-w", CONN_W, CERAMIC_HEAT_BUFFER),
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-open-ns", CONN_NS, CERAMIC_HEAT_BUFFER),
    make_endpoint("tenebris-ceramic-thermal-diode-endpoint-open-ew", CONN_EW, CERAMIC_HEAT_BUFFER),
}

local ceramic_interface = make_interface(
    "tenebris-ceramic-thermal-diode",
    "tenebris-ceramic-thermal-diode",
    tenebris.TINT.CERAMIC
)

-- Extend all prototypes
data:extend(steel_endpoints)
data:extend({steel_interface})
data:extend(ceramic_endpoints)
data:extend({ceramic_interface})
