local particle_animations = require("__base__/prototypes/particle-animations")


particle_animations.get_bismuth_asteroid_particle_small_pictures = function(options)
    local options = options or {}
    return
    {
      sheet =
      {
        filename = "__tenebris-prime__/graphics/particle/asteroid-particle/bismuth-asteroid-particle-small.png",
        priority = "extra-high",
        width = 12,
        height = 12,
        frame_count = 12,
        animation_speed = 0.3,
        variation_count = 10,
        tint = options.tint,
        shift = util.add_shift(util.by_pixel(0.0,0.5), options.shift),
        scale = 0.5
      }
    }
  end
  
  particle_animations.get_bismuth_asteroid_particle_medium_pictures = function(options)
    local options = options or {}
    return
    {
      sheet =
      {
        filename = "__tenebris-prime__/graphics/particle/asteroid-particle/bismuth-asteroid-particle-medium.png",
        priority = "extra-high",
        width = 18,
        height = 16,
        frame_count = 12,
        animation_speed = 0.3,
        variation_count = 10,
        tint = options.tint,
        shift = util.add_shift(util.by_pixel(0.0,0.5), options.shift),
        scale = 0.5
      }
    }
  end
  
  particle_animations.get_bismuth_asteroid_particle_big_pictures = function(options)
    local options = options or {}
    return
    {
      sheet =
      {
        filename = "__tenebris-prime__/graphics/particle/asteroid-particle/bismuth-asteroid-particle-big.png",
        priority = "extra-high",
        width = 38,
        height = 36,
        frame_count = 12,
        animation_speed = 0.3,
        variation_count = 10,
        tint = options.tint,
        shift = util.add_shift(util.by_pixel(0.0,0.5), options.shift),
        scale = 0.5
      }
    }
  end
  particle_animations.get_bismuth_asteroid_particle_top_small_pictures = function(options)
    local options = options or {}
    return
    {
      sheet =
      {
        filename = "__tenebris-prime__/graphics/particle/asteroid-particle/bismuth-asteroid-particle-top-small.png",
        priority = "extra-high",
        width = 32,
        height = 36,
        frame_count = 16,
        animation_speed = 0.2,
        variation_count = 6,
        tint = options.tint,
        shift = util.add_shift(util.by_pixel(0.0, 0.0), options.shift),
        scale = 0.5
      }
    }
  end
  particle_animations.get_bismuth_asteroid_particle_top_big_pictures = function(options)
    local options = options or {}
    return
    {
      sheet =
      {
        filename = "__tenebris-prime__/graphics/particle/asteroid-particle/bismuth-asteroid-particle-top-big.png",
        priority = "extra-high",
        width = 82,
        height = 84,
        frame_count = 16,
        animation_speed = 0.2,
        variation_count = 6,
        tint = options.tint,
        shift = util.add_shift(util.by_pixel(0.0, 1.0), options.shift),
        scale = options.scale or 0.5
      }
    }
  end

  return particle_animations