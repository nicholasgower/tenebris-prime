function create_asteroid_chunk_parameter(number)
    data:extend(
    {
      {
        type = "asteroid-chunk",
        name = "parameter-" .. number,
        icon = "__base__/graphics/icons/parameter/parameter-" .. number .. ".png",
        localised_name = {"parameter-x", tostring(number)},
        subgroup = "parameters",
        order = "a",
        parameter = true
      }
    })
  end
  
  for n = 0, 9 do
    create_asteroid_chunk_parameter(n)
  end
  
  
  -- damage-type.lua must run first.
  --[[
  small asteroids: use lasers because they are free
  medium asteroids: use gun turrets
  big asteroids: use rockets or railgun
  huge asteroids: use railgun
  
  We need a new damage type for the final railgun shot, something like Armor Piercing High Explosive (APHE)
    but we need a shorter more general term for the damage type, representing internal inside-out damage.
  Potential names: internal, trojan, detonate, depth, siege
  
  // Asteroid normals:
  // Directions match factorio screen space.
  // red is x, 1 if facing east, 0 is facing west.
  // green is y, 1 is facing south, 0 is facing north
  // blue is z, 1 is facing up, 0 is a tangent.
  // Red and green must have a neutral value of 0.5 for faces facing the camera.
  // Blender output settings: color management: Override, display device: XYZ, View: Raw, Look:None, Exposure:0, Gamma: 1
  ]]
  
  local simulations = require("__space-age__.prototypes.factoriopedia-simulations")
  local tenebris_simulations = require("prototypes.factoriopedia-simulations")
  
  local sounds = require("__base__.prototypes.entity.sounds")
  local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")
  
  local asteroid_sizes = {"chunk", "small", "medium", "big", "huge"}
  local shared_resistances =
  {
    physical =
    {
      decrease = {0, 0, 0, 2000, 3000},
      percent = {0, 0, 10, 10, 10}
    },
    explosion =
    {
      decrease = {0, 0, 0, 0, 0},
      percent = {0, 50, 30, 10, 99}
    },
    laser =
    {
      decrease = {0, 0, 0, 0, 0},
      percent = {0, 20, 90, 95, 99}
    }
  }
  local shared_health = {0, 100, 400, 2000, 5000}
  local shared_mass = {0, 200000, 500000, 5000000, 100000000}
  local asteroids_data =
  {
    bismuth =
    {
      order = "a",
      mass = shared_mass,
      max_health = shared_health,
      resistances = shared_resistances,
      shading_data =
      {
        normal_strength = 1.4,
        light_width = 0.4,
        brightness = 0.4,
        specular_strength = 3.0,
        specular_power = 2.0,
        specular_purity = 0.3,  -- Higher purity for more vibrant reflections
        sss_contrast = 0.1,
        sss_amount = 0.2,
        -- Iridescent multi-colored lights to simulate bismuth's rainbow oxide layers
        lights = {
          { color = {1.0, 0.3, 0.5}, direction = {0.75, 0.22, -1} },    -- Magenta/pink from above-right
          { color = {0.3, 0.8, 1.0}, direction = {-0.5, 0.3, -0.8} },   -- Cyan from above-left
          { color = {1.0, 0.8, 0.2}, direction = {0.0, -0.5, -1} },     -- Gold/yellow from below
          { color = {0.5, 0.2, 1.0}, direction = {0.5, 0, 0.95} },      -- Purple rim light
        },
        ambient_light = {0.05, 0.03, 0.08},  -- Slight purple ambient
      }
    },
  }
  
  local collision_radiuses =
  {
    0.4, -- chunk
    0.5, -- small
    1, -- medium
    2, -- big
    4.5  -- huge
  }
  
  local graphics_scale =
  {
    0.5, -- chunk
    0.5, -- small
    0.5, -- medium
    0.6, -- big
    0.75 -- huge
  }
  
  local sizes_resolution = {
    {50,1}, -- chunk
    {128,1}, -- small
    {230,0}, -- medium
    {304,6}, -- big
    {512,0} -- huge
  }
  
  local letter = {"a","b","c","d","e"}
  
  local function asteroid_variation(asteroid_type, suffix, scale, size)
    return
    {
      color_texture =
      {
        filename = "__tenebris-prime__/graphics/entity/asteroid/".. asteroid_type .."/"..asteroid_sizes[size].."/".."asteroid-" .. asteroid_type .. "-" .. asteroid_sizes[size] .. "-colour-" .. suffix .. ".png",
        size =  sizes_resolution[size][1],
        scale = scale
      },
  
      shadow_shift = { 0.25 * size, 0.25 * size },
  
      normal_map =
      {
        filename = "__tenebris-prime__/graphics/entity/asteroid/".. asteroid_type .."/"..asteroid_sizes[size].."/".."asteroid-" .. asteroid_type .. "-" .. asteroid_sizes[size] .. "-normal-" .. suffix .. ".png",
        premul_alpha = false,
        size = sizes_resolution[size][1],
        scale = scale
      },
  
      roughness_map =
      {
        filename = "__tenebris-prime__/graphics/entity/asteroid/".. asteroid_type .."/"..asteroid_sizes[size].."/".."asteroid-" .. asteroid_type .. "-" .. asteroid_sizes[size] .. "-roughness-" .. suffix .. ".png",
        premul_alpha = false,
        size = sizes_resolution[size][1],
        scale = scale
      }
    }
  end
  
  local function asteroid_graphics_set(rotation_speed, shading_data, variations)
    local result = table.deepcopy(shading_data)
    result.rotation_speed = rotation_speed
    result.variations = variations
    return result
  end
  
  for asteroid_size, asteroid_size_name in pairs(asteroid_sizes) do
    for asteroid_type, asteroid_data in pairs(asteroids_data) do
  
      local graphics_scale = graphics_scale[asteroid_size]
      local collision_radius = collision_radiuses[asteroid_size]
      local selection_radius = collision_radius * 1.1 + 0.1
      local max_health = asteroid_data.max_health[asteroid_size] > 0 and asteroid_data.max_health[asteroid_size] or nil
      local asteroid_name, resistances, factoriopedia_sim
      local dying_trigger_effects =
      {
        {
          type = asteroid_size_name == "chunk" and "create-entity" or "create-explosion",
          entity_name = asteroid_type.."-asteroid-explosion-"..asteroid_size,
        }
      }
  
      if asteroid_size_name == "chunk" then
        asteroid_name = asteroid_type .. "-asteroid-chunk"
      else
        asteroid_name = asteroid_size_name .. "-"..asteroid_type.."-asteroid"
        -- Use tenebris simulations for bismuth, otherwise use space-age simulations
        if asteroid_type == "bismuth" then
          factoriopedia_sim = tenebris_simulations["factoriopedia_" .. asteroid_size_name .. "_" .. asteroid_type .. "_asteroid"]
        else
          factoriopedia_sim = simulations["factoriopedia_" .. asteroid_size_name .. "_" .. asteroid_type .. "_asteroid"]
        end
        local spread = collision_radius * 0.5
  
        if asteroid_size == 2 then
          table.insert(dying_trigger_effects,
          {
            type = "create-asteroid-chunk",
            asteroid_name = asteroid_type.."-asteroid-chunk",
            offset_deviation = {{-spread, -spread}, {spread, spread}},
            offsets =
            {
              {-spread/2, -spread/4},
              {spread/2, -spread/4}
            }
          })
        else
          table.insert(dying_trigger_effects,
          {
            type = "create-entity",
            entity_name = asteroid_sizes[asteroid_size-1] .. "-"..asteroid_type.."-asteroid",
            offset_deviation = {{-spread, -spread}, {spread, spread}},
            offsets =
            {
              {-spread, -spread/4},
              {0, -spread/2},
              {spread, -spread/4}
            }
          })
        end
  
        resistances = {}
        for damage_name, damage_type in pairs(data.raw["damage-type"]) do
          if asteroid_data.resistances[damage_name] then
            table.insert(resistances,
            {
              type = damage_name,
              decrease = asteroid_data.resistances[damage_name].decrease[asteroid_size],
              percent = asteroid_data.resistances[damage_name].percent[asteroid_size]
            })
          else
            if damage_name ~= "impact" and damage_name ~= "poison" and damage_name ~= "acid" then
              table.insert(resistances,
              {
                type = damage_name,
                percent = 100
              })
            end
          end
        end
      end
  
  
      local variations ={}
      if (asteroid_type == "bismuth") then
        if (asteroid_size_name == "chunk") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "small") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "medium") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "big") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "huge") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
        end
    elseif (asteroid_type == "metallic") then
        if (asteroid_size_name == "chunk") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "08", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "small") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "08", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "medium") then
       --   table.insert(variations, asteroid_variation("test", "00", graphics_scale, asteroid_size))
         -- table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "big") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "huge") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        end
      elseif (asteroid_type == "carbonic") then
        if (asteroid_size_name == "chunk") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "09", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "small") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
         elseif  (asteroid_size_name == "medium") then
        --  table.insert(variations, asteroid_variation("test", "00", graphics_scale, asteroid_size))
       --   table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "big") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
         elseif  (asteroid_size_name == "huge") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
        end
      elseif (asteroid_type == "oxide") then
        if (asteroid_size_name == "chunk") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "small") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
  
        elseif  (asteroid_size_name == "medium") then
        --   table.insert(variations, asteroid_variation("test", "00", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "big") then
         -- table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
         -- table.insert(variations, asteroid_variation("test", "03", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "huge") then
         -- table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
         -- table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
        end
      elseif (asteroid_type == "promethium") then
        if (asteroid_size_name == "chunk") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "small") then
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
  
        elseif  (asteroid_size_name == "medium") then
        --   table.insert(variations, asteroid_variation("test", "00", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif (asteroid_size_name == "big") then
         -- table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
         -- table.insert(variations, asteroid_variation("test", "03", graphics_scale, asteroid_size))
        --  table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
        elseif  (asteroid_size_name == "huge") then
         -- table.insert(variations, asteroid_variation("test", "01", graphics_scale, asteroid_size))
         -- table.insert(variations, asteroid_variation("test", "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "01", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "02", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "03", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "04", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "05", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "06", graphics_scale, asteroid_size))
          table.insert(variations, asteroid_variation(asteroid_type, "07", graphics_scale, asteroid_size))
        end
      end
  
      data:extend
      {
        {
          type = asteroid_size_name == "chunk" and "asteroid-chunk" or "asteroid",
          name = asteroid_name,
          overkill_fraction = asteroid_size_name ~= "chunk" and 0.01 or nil,
          localised_description = {"entity-description."..asteroid_type.."-asteroid"},
          icon = "__tenebris-prime__/graphics/icons/"..asteroid_name..".png",
          icon_size = 64,
          selection_box = asteroid_size_name ~= "chunk" and {{-selection_radius, -selection_radius}, {selection_radius, selection_radius}} or nil,
          collision_box = asteroid_size_name ~= "chunk" and {{-collision_radius, -collision_radius}, {collision_radius, collision_radius}} or nil,
          collision_mask = asteroid_size_name ~= "chunk" and {layers={object=true}, not_colliding_with_itself=true} or nil,
          graphics_set = asteroid_graphics_set(0.0003 * (6 - asteroid_size), asteroids_data[asteroid_type].shading_data, variations),
          dying_trigger_effect = dying_trigger_effects,
  
          subgroup = asteroid_size_name == "chunk" and "space-material" or "space-environment",
          order = asteroid_data.order .. "["..asteroid_type.."]-"..letter[asteroid_size].."["..asteroid_size_name.."]",
          factoriopedia_simulation = factoriopedia_sim,
  
          -- asteroid-chunk properties
          minable = asteroid_size_name == "chunk" and {mining_time = 0.2, result = asteroid_name, mining_particle = asteroid_type.."-asteroid-chunk-particle-medium" } or nil,
  
          -- asteroid properties
          flags = asteroid_size_name ~= "chunk" and {"placeable-enemy", "placeable-off-grid", "not-repairable", "not-on-map"} or nil,
          max_health = asteroid_size_name ~= "chunk" and asteroid_data.max_health[asteroid_size] or nil,
          mass = asteroid_size_name ~= "chunk" and asteroid_data.mass[asteroid_size] or nil,
          resistances = resistances,
        }
      }
    end
  end
  
  -- chunk backlight overrides - iridescent coloring for bismuth
  if data.raw["asteroid-chunk"]["bismuth-asteroid-chunk"] then
    data.raw["asteroid-chunk"]["bismuth-asteroid-chunk"].graphics_set.lights = {
      { color = {1.0, 0.3, 0.5}, direction = {0.75, 0.22, -1} },    -- Magenta/pink
      { color = {0.3, 0.8, 1.0}, direction = {-0.5, 0.3, -0.8} },   -- Cyan
      { color = {0.5, 0.2, 1.0}, direction = {-1, -0.45, 0.1} },    -- Purple backlight
    }
  end
  
--------------------------------------------------------------------------------
-- Infected Carbonic Chunk
-- Dropped by centipede eggroids, can be processed into lucifunnel and carbon
--------------------------------------------------------------------------------

local centipede_constants = require("lib.centipede_constants")
local infected_chunk_shading = centipede_constants.INFECTED_CHUNK_SHADING

data:extend{{
  type = "asteroid-chunk",
  name = "infected-carbonic-chunk",
  icons = {
    {
      icon = "__space-age__/graphics/icons/carbonic-asteroid-chunk.png",
      icon_size = 64,
      tint = centipede_constants.EGGROID_ICON_TINT,
    },
  },
  subgroup = "space-material",
  order = "b[carbonic]-z[infected]",
  minable = {
    mining_time = 0.2,
    result = "infected-carbonic-chunk",
    mining_particle = "carbonic-asteroid-chunk-particle-medium",
  },
  graphics_set = {
    normal_strength = infected_chunk_shading.normal_strength,
    light_width = infected_chunk_shading.light_width,
    brightness = infected_chunk_shading.brightness,
    specular_strength = infected_chunk_shading.specular_strength,
    specular_power = infected_chunk_shading.specular_power,
    specular_purity = infected_chunk_shading.specular_purity,
    sss_contrast = infected_chunk_shading.sss_contrast,
    sss_amount = infected_chunk_shading.sss_amount,
    lights = infected_chunk_shading.lights,
    ambient_light = infected_chunk_shading.ambient_light,
    variations = {
      {
        color_texture = {
          filename = "__space-age__/graphics/entity/asteroid/carbonic/chunk/asteroid-carbonic-chunk-colour-01.png",
          size = 50,
          scale = 0.5,
        },
        normal_map = {
          filename = "__space-age__/graphics/entity/asteroid/carbonic/chunk/asteroid-carbonic-chunk-normal-01.png",
          premul_alpha = false,
          size = 50,
          scale = 0.5,
        },
        roughness_map = {
          filename = "__space-age__/graphics/entity/asteroid/carbonic/chunk/asteroid-carbonic-chunk-roughness-01.png",
          premul_alpha = false,
          size = 50,
          scale = 0.5,
        },
        shadow_shift = {0.15, 0.15},
      },
    },
  },
}}

--------------------------------------------------------------------------------
-- Centipede Eggroid Asteroids
-- These spawn centipedes when destroyed
--------------------------------------------------------------------------------

-- centipede_constants already required above for infected chunk

-- Build eggroid definitions from constants
local eggroid_sizes = {}
for _, size in ipairs({"small", "medium", "large", "giant", "leviathan"}) do
  local config = centipede_constants.EGGROID[size]
  local eggroid = {
    name = centipede_constants.ENTITY_NAMES.EGGROID_PREFIX .. size,
    centipede = centipede_constants.ENTITY_NAMES.HEAD_PREFIX .. size,
    health = config.health,
    mass = config.mass,
    collision_radius = config.collision_radius,
    scale = config.graphics_scale,
    explosion_size = config.explosion_size,
    use_huge_graphic = config.use_huge_graphic,
    splits_into = config.splits_into and {
      name = centipede_constants.ENTITY_NAMES.EGGROID_PREFIX .. config.splits_into.type,
      count = config.splits_into.count,
    } or nil,
  }
  table.insert(eggroid_sizes, eggroid)
end

-- Use shading from centipede_constants
local eggroid_shading = centipede_constants.EGGROID_SHADING

for _, eggroid in pairs(eggroid_sizes) do
  local selection_radius = eggroid.collision_radius * 1.1 + 0.1
  
  -- Build dying trigger effect: explosion + chunks + optional child eggroids
  local dying_effects = {
    -- Explosion effect using carbonic asteroid explosions
    {
      type = "create-explosion",
      entity_name = "carbonic-asteroid-explosion-" .. eggroid.explosion_size,
    },
  }
  
  -- Drop infected carbonic chunks only from small and medium eggroids
  -- Extract size from eggroid name (e.g., "centipede-eggroid-small" -> "small")
  local eggroid_size = eggroid.name:match("centipede%-eggroid%-(%w+)")
  local chunk_count = centipede_constants.EGGROID_CHUNK_DROPS[eggroid_size]
  
  if chunk_count then
    local spread = eggroid.collision_radius * 0.5
    table.insert(dying_effects, {
      type = "create-asteroid-chunk",
      asteroid_name = "infected-carbonic-chunk",
      offset_deviation = {{-spread, -spread}, {spread, spread}},
      offsets = {{0, 0}},
      repeat_count = chunk_count,
    })
  end
  
  -- Add child eggroid spawns if this eggroid splits
  if eggroid.splits_into then
    table.insert(dying_effects, {
      type = "create-entity",
      entity_name = eggroid.splits_into.name,
      offset_deviation = centipede_constants.EGGROID_SPLIT_OFFSET,
      offsets = {{0, 0}},
      repeat_count = eggroid.splits_into.count,
      trigger_created_entity = true,
    })
  end
  
  -- Choose graphic path and size based on eggroid size (using carbonic asteroid graphics)
  local graphic_configs = {
    ["centipede-eggroid-small"] = { size_name = "small", pixel_size = 128, icon = "small-carbonic-asteroid" },
    ["centipede-eggroid-medium"] = { size_name = "medium", pixel_size = 230, icon = "medium-carbonic-asteroid" },
    ["centipede-eggroid-large"] = { size_name = "big", pixel_size = 304, icon = "big-carbonic-asteroid" },
    ["centipede-eggroid-giant"] = { size_name = "huge", pixel_size = 512, icon = "huge-carbonic-asteroid" },
    ["centipede-eggroid-leviathan"] = { size_name = "huge", pixel_size = 512, icon = "huge-carbonic-asteroid" },
  }
  local config = graphic_configs[eggroid.name] or { size_name = "big", pixel_size = 304, icon = "big-carbonic-asteroid" }
  local graphic_path = "__space-age__/graphics/entity/asteroid/carbonic/" .. config.size_name .. "/asteroid-carbonic-" .. config.size_name
  local graphic_size = config.pixel_size
  
  -- Get factoriopedia simulation for this eggroid
  local eggroid_sim_key = "factoriopedia_" .. eggroid.name:gsub("-", "_")
  local eggroid_factoriopedia_sim = tenebris_simulations[eggroid_sim_key]
  
  data:extend{{
    type = "asteroid",
    name = eggroid.name,
    icons = {
      {
        icon = "__space-age__/graphics/icons/" .. config.icon .. ".png",
        icon_size = 64,
        tint = centipede_constants.EGGROID_ICON_TINT,
      },
    },
    flags = {"placeable-enemy", "placeable-off-grid", "not-repairable", "not-on-map"},
    max_health = eggroid.health,
    mass = eggroid.mass,
    collision_box = {{-eggroid.collision_radius, -eggroid.collision_radius}, {eggroid.collision_radius, eggroid.collision_radius}},
    selection_box = {{-selection_radius, -selection_radius}, {selection_radius, selection_radius}},
    collision_mask = {layers = {object = true}, not_colliding_with_itself = true},
    subgroup = "space-environment",
    order = "z[centipede-eggroid]-" .. eggroid.name,
    factoriopedia_simulation = eggroid_factoriopedia_sim,
    
    -- Centipede spawning is handled by scripts/centipede_spawner/init.lua
    -- which spawns them at a distance (lure mechanic)
    
    dying_trigger_effect = dying_effects,
    
    -- Use carbonic asteroid graphics as base
    graphics_set = {
      rotation_speed = 0.001,
      normal_strength = eggroid_shading.normal_strength,
      light_width = eggroid_shading.light_width,
      brightness = eggroid_shading.brightness,
      specular_strength = eggroid_shading.specular_strength,
      specular_power = eggroid_shading.specular_power,
      specular_purity = eggroid_shading.specular_purity,
      sss_contrast = eggroid_shading.sss_contrast,
      sss_amount = eggroid_shading.sss_amount,
      lights = eggroid_shading.lights,
      ambient_light = eggroid_shading.ambient_light,
      variations = {
        {
          color_texture = {
            filename = graphic_path .. "-colour-01.png",
            size = graphic_size,
            scale = eggroid.scale,
          },
          normal_map = {
            filename = graphic_path .. "-normal-01.png",
            premul_alpha = false,
            size = graphic_size,
            scale = eggroid.scale,
          },
          roughness_map = {
            filename = graphic_path .. "-roughness-01.png",
            premul_alpha = false,
            size = graphic_size,
            scale = eggroid.scale,
          },
          shadow_shift = {0.5, 0.5},
        },
      },
    },
    
    resistances = {
      {type = "physical", decrease = 0, percent = 0},
      {type = "explosion", decrease = 0, percent = 0},
      {type = "laser", decrease = 0, percent = 0},
    },
  }}
end
