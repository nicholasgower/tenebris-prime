local meld = require("meld")

data:extend(
{
    {
        type = "fluid",
        name = "tenebris-atmosphere",
        icon = "__muluna-graphics__/graphics/icons/atmosphere.png",
        subgroup = "fluid",
        order = "t[tenebris]-a[tenebris-atmosphere]",
        default_temperature = 30,
        max_temperature = 100,
        heat_capacity = "1kJ",
        base_flow_rate = data.raw.fluid.steam.base_flow_rate,
        base_color = {1, 1, 1},
        flow_color = {0.5, 0.5, 1},
        icon_size = 64,
        gas_temperature = 25,
    },
    {
        type = "fluid",
        name = "nitrogen",
        icon = "__tenebris-prime__/graphics/icons/fluid/nitrogen.png",
        subgroup = "fluid",
        order = "t[tenebris]-b[nitrogen]",
        default_temperature = 600,
        max_temperature = 2000,
        heat_capacity = "0.01kJ",
        base_color = {0.45, 0.61, 0.58},
        flow_color = {0.93, 0.729, 0.23},
        auto_barrel = false
    },
    {
        type = "fluid",
        name = "nitric-acid",
        subgroup = "fluid",
        default_temperature = 15,
        max_temperature = 120,
        base_color = { 0.384, 0.271, 0.792 },
        flow_color = { 0.384, 1, 0.792 },
        icon = "__tenebris-prime__/graphics/icons/fluid/nitric-acid.png",
        icon_size = 64,
        icon_mipmaps = 4,
        order = "t[tenebris]-c[nitric-acid]",
        auto_barrel = false
    },
    meld(table.deepcopy(data.raw["fluid"]["steam"]), {
        name = "tenebris-heat",
        icon = "__core__/graphics/arrows/heat-exchange-indication.png",
        icon_size = 48,
        heat_capacity = "0.2kJ",
    }),
    {
        type = "fluid",
        name = "molten-quartziferous-bismuth",
        icon = "__space-age__/graphics/icons/fluid/molten-copper.png",
        subgroup = "fluid",
        order = "t[tenebris]-d[molten-quartziferous-bismuth]",
        default_temperature = 600,
        max_temperature = 2000,
        heat_capacity = "0.01kJ",
        base_color = {0.45, 0.61, 0.58},
        flow_color = {0.93, 0.729, 0.23},
        auto_barrel = false
    },
})