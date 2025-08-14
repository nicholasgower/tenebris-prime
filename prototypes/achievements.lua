data:extend(
{
    {
        type = "change-surface-achievement",
        name = "visit-tenebris",
        order = "a[progress]-g[visit-planet]-t[tenebris]",
        surface = "tenebris",
        icon = "__space-age__/graphics/achievement/visit-fulgora.png",
        icon_size = 128,
    },
    {
        type = "research-with-science-pack-achievement",
        name = "research-with-lightless",
        order = "e[research]-a[research-with]-t[lightless]",
        science_pack = "lightless-science-pack",
        icon = "__space-age__/graphics/achievement/research-with-promethium.png",
        icon_size = 128
      },
      {
        type = "research-with-science-pack-achievement",
        name = "research-with-bioluminscence",
        order = "e[research]-a[research-with]-tt[bioluminescent]",
        science_pack = "bioluminescent-science-pack",
        icon = "__space-age__/graphics/achievement/research-with-cryogenics.png",
        icon_size = 128
      },
      {
        type = "space-connection-distance-traveled-achievement",
        name = "traversing-lightless-abyss",
        order = "b[exploration]-t[tenebris-lightless-abyss]",
        distance = 9000000,
        reversed = false,
        tracked_connection = "tenebris-lightless-abyss",
        icon = "__space-age__/graphics/achievement/shattered-planet-1.png",
        icon_size = 128
      },
      {
        type = "produce-achievement",
        name = "shiny-objects",
        order = "d[production]-t[tenebris-shiny-objects]",
        item_product = { name = "quartziferous-bismuthal-plate" },
        amount = 1,
        limited_to_one_game = false,
        icon = "__space-age__/graphics/achievement/my-modules-are-legendary.png",
        icon_size = 128
      },
      {
        type = "produce-achievement",
        name = "shining-beacon",
        order = "d[production]-t[tenebris-shining-beacon]",
        item_product = { name = "tenebris-biobeacon", quality = "legendary" },
        amount = 1,
        limited_to_one_game = false,
        icon = "__space-age__/graphics/achievement/my-modules-are-legendary.png",
        icon_size = 128
      },
      {
        type = "produce-achievement",
        name = "wacky-racer",
        order = "d[production]-t[tenebris-wacky-racer]",
        item_product = { name = "tenebris-biobeacon" },
        amount = 1,
        within = 50 * hour,
        limited_to_one_game = false,
        icon = "__space-age__/graphics/achievement/my-modules-are-legendary.png",
        icon_size = 128,
        allowed_without_fight = false
      },
      {
        type = "player-damaged-achievement",
        name = "oooo-what-a-feast",
        order = "b[exploration]-t[tenebris-oooo-what-a-feast]",
        type_of_dealer = "segmented-unit",
        minimum_damage = 0,
        should_survive = false,
        icon = "__base__/graphics/achievement/watch-your-step.png",
        icon_size = 128
      },
})
