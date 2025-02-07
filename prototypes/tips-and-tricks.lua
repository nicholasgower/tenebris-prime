data:extend({
    {
        type = "tips-and-tricks-item",
        name = "tenebris-briefing",
        tag = "[planet=tenebris]",
        category = "space-age",
        order = "d-k",
        trigger =
        {
            type = "research",
            technology = "planet-discovery-tenebris"
        },
        skip_trigger =
        {
            type = "or",
            triggers =
            {
                {
                    type = "change-surface",
                    surface = "tenebris"
                },
                {
                    type = "sequence",
                    triggers =
                    {
                        {
                            type = "research",
                            technology = "planet-discovery-tenebris"
                        },
                        {
                            type = "time-elapsed",
                            ticks = 15 * minute
                        },
                        {
                            type = "time-since-last-tip-activation",
                            ticks = 15 * minute
                        }
                    }
                }
            }
        },
        simulation = {
            planet = "tenebris",
            init = [[
            game.surfaces[1].daytime = 0.35
            game.simulation.camera_position = {0, 0}
            game.simulation.camera_alt_info = true

            game.forces.player.technologies["lucifunnel-processing"].researched = true
            game.forces.player.technologies["bioluminescent-crystal"].researched = true

            for x = -5, 4, 1 do
            for y = -5, 4 do
                game.surfaces[1].set_chunk_generated_status({x, y}, defines.chunk_generated_status.entities)
            end
            end

            for x = -11, 11, 1 do
            for y = -11, 11 do
                game.surfaces[1].set_tiles{{position = {x, y}, name = "lowland-cream-cauliflower"}}
            end
            end

            game.surfaces[1].create_entities_from_blueprint_string {
                string = "0eNqlmN2OmzAQhd/F17DC5j9Sn6RaIYc4WUvGprbZNo149xrS0GwC1di5JEy+ORnmeIZc0F4MrNdcWrS7IN4qadDu+wUZfpJUTJ9J2jG0Q1ZTaXqlbbxnwqIxQlwe2C+0w2O0Er7nSgwdl8y0TNqYGsO6veDyFHe0/XCfx+kdg4zvEXJx3HJ2zT9fnBs5dHumXZJoC3zSvB2EHTQVsVU/XXCEemUcSclJj6PHyVseobNLU77l4yT3gU626EdqbMylYdqugfE9N0IHrll7vY3JSpo08qnOU7b0azaXi/cTTAwtPw5SMhH3WrXMGAdCt4Dmx0CFU+ECpdKde0gryrLAAuT/KUCEjly4b12f561ZlkSzauYaz1GfJEaoVV1PNbXKqUPf0NQfg2HNgrR6YCs/JI82+vVJerkpPVvhFmBu4cUtAwtf+3VeBZZfecmvX+tojDda+oHW6rOxc1t49DROQl2detUAY3Bxce732DCBozNPdApHl57oDI4uPNFwf2NPi2C4xXHliS7BaJJ4ouHOJp7TCtdwNPFDkwSOTj3RcDcST8sQuBuJp9EJ3I3E0zIE7kbiaXTyz41cHrl09+L2g5k19IMbb/GNYda6KWGmOM069cmaQV6nPDs03LLO3TpSYdjXfeJvXjcItP19NyBaNUyrrOuCTh2mCGpjweisaVlY31eXwCJwXhC/mUnKV7fNCpSmCk2zmLne2JbhB8PCSvGj5mptQU4CyAmIjAPIKYhMAsgERE4DyDmInAWQMxA5DyCXIHIRQC5A5PJVp6QbTkmrAM0VSHMNPnoXcpYEHL3ze9b09jVdTxVa/i6I0Kc7jOc8eUHqrK7zLEuyNC/G8Q/bSWt6",
                position = {2, 5}
            }

            for x=-10,-5,3 do
                for y=10,-5,-3 do
                    plant = game.surfaces[1].create_entity {name = "lucifunnel", position = {x, y} }
                    plant.tick_grown = 0
                end
            end

            enemy = game.surfaces[1].create_entity{name = "centipede-head-small", position = {0, 15}}
        ]]
        }
    }
})
