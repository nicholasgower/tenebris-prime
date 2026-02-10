local procession_graphic_catalogue = require("__base__/prototypes/planet/procession-graphic-catalogue-types")

return
{
  -- CLOUDS (using Gleba's dark storm clouds)
  {
    index = procession_graphic_catalogue.planet_cloudscape,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/gleba-cloudscape.png",
      width = 960,
      height = 960,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.15, g = 0.1, b = 0.2, a = 1},  -- Dark purple tint
    }
  },
  {
    index = procession_graphic_catalogue.planet_cloudscape_mask,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/mask-cloudscape.png",
      width = 960,
      height = 960,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    }
  },

  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl0,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/gleba-cloudscape-layered-0.png",
      width = 2000,
      height = 1500,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.1, g = 0.15, b = 0.2, a = 1},  -- Dark cyan-ish
    }
  },
  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl0_mask,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/mask-cloudscape-layered-0.png",
      width = 2000,
      height = 1500,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    }
  },

  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl1,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/gleba-cloudscape-layered-1.png",
      width = 1600,
      height = 1200,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.08, g = 0.12, b = 0.18, a = 1},  -- Darker
    }
  },
  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl1_mask,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/mask-cloudscape-layered-1.png",
      width = 1600,
      height = 1200,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    }
  },

  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl2,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/gleba-cloudscape-layered-2.png",
      width = 1400,
      height = 1050,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.05, g = 0.08, b = 0.12, a = 1},  -- Even darker
    }
  },
  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl2_mask,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/mask-cloudscape-layered-2.png",
      width = 1400,
      height = 1050,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    }
  },

  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl3,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/gleba-cloudscape-layered-3.png",
      width = 1200,
      height = 900,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.03, g = 0.05, b = 0.08, a = 1},  -- Nearly black
    }
  },
  {
    index = procession_graphic_catalogue.planet_cloudscape_lvl3_mask,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/mask-cloudscape-layered-3.png",
      width = 1200,
      height = 900,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    }
  },

  -- SPACE (dark space background)
  {
    index = procession_graphic_catalogue.planet_stars_background,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/space-rear-star.png",
      width = 1024,
      height = 1024,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.3, g = 0.3, b = 0.4, a = 1},  -- Dimmed stars
    }
  },
  
  -- Sky tint (using Fulgora's stormy tint as base)
  {
    index = procession_graphic_catalogue.planet_tint,
    type = "sprite",
    sprite = {
      filename = "__space-age__/graphics/procession/clouds/fulgora-sky-tint.png",
      width = 16,
      height = 16,
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
      tint = {r = 0.2, g = 0.3, b = 0.4, a = 1},  -- Dark cyan overlay
    }
  },

  -- Hatches (reusing standard hatch emissions)
  {
    index = procession_graphic_catalogue.hatch_emission_bay,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/shared-cargo-bay-pod-emission", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(10.24, 48),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},  -- Cyan glow
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_out_1,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-lower-hatch-pod-emission-A", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(56, -16),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_out_2,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-lower-hatch-pod-emission-B", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(16, -32),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_out_3,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-lower-hatch-pod-emission-C", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(64, -48),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_in_1,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-upper-hatch-pod-emission-A", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-16, 96),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_in_2,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-upper-hatch-pod-emission-B", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-64, 96),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.hatch_emission_in_3,
    sprite = util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-upper-hatch-pod-emission-C", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-40, 64),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.planet_hatch_emission_in_1,
    sprite = util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/planet-lower-hatch-pod-emission-A", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-16, 96),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.planet_hatch_emission_in_2,
    sprite = util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/planet-lower-hatch-pod-emission-B", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-64, 96),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  },
  {
    index = procession_graphic_catalogue.planet_hatch_emission_in_3,
    sprite = util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/planet-lower-hatch-pod-emission-C", {
      priority = "medium",
      draw_as_glow = true,
      blend_mode = "additive",
      scale = 0.5,
      shift = util.by_pixel(-40, 64),
      tint = {r = 0.3, g = 0.8, b = 1.0, a = 1},
    })
  }
}

