-- Factoriopedia simulations for Tenebris Prime asteroids and eggroids

local simulations = {}

-- Helper function to create asteroid simulation (mirrors Space Age's approach)
local function make_asteroid_simulation(name, wait)
  wait = wait or "7"
  return [[
    require("__core__/lualib/story")
    game.simulation.camera_position = {0, 0}

    for x = -8, 8, 1 do
      for y = -3, 3 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "empty-space"}}
      end
    end

    for x = -1, 0, 1 do
      for y = -1, 0 do
        game.surfaces[1].set_chunk_generated_status({x, y}, defines.chunk_generated_status.entities)
      end
    end

    local story_table =
    {
      {
        {
          name = "start",
          action = function() game.surfaces[1].create_entity{name="]] .. name .. [[", position = {0, 0}, velocity = {0, 0.011}} end
        },
        {
          condition = story_elapsed_check(]] .. wait .. [[),
          action = function() story_jump_to(storage.story, "start") end
        }
      }
    }
    tip_story_init(story_table)
  ]]
end

-- Bismuth asteroid simulations (wait times match Space Age pattern: small=7, medium=9, big=11, huge=18)
simulations.factoriopedia_small_bismuth_asteroid = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("small-bismuth-asteroid", "7") }
simulations.factoriopedia_medium_bismuth_asteroid = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("medium-bismuth-asteroid", "9") }
simulations.factoriopedia_big_bismuth_asteroid = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("big-bismuth-asteroid", "11") }
simulations.factoriopedia_huge_bismuth_asteroid = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("huge-bismuth-asteroid", "18") }

-- Centipede eggroid simulations
simulations.factoriopedia_centipede_eggroid_small = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("centipede-eggroid-small", "7") }
simulations.factoriopedia_centipede_eggroid_medium = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("centipede-eggroid-medium", "9") }
simulations.factoriopedia_centipede_eggroid_large = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("centipede-eggroid-large", "11") }
simulations.factoriopedia_centipede_eggroid_giant = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("centipede-eggroid-giant", "14") }
simulations.factoriopedia_centipede_eggroid_leviathan = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("centipede-eggroid-leviathan", "18") }

return simulations

