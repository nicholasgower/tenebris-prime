local _TENEBRIS = "tenebris"
local _AQUILO = "aquilo"
local _FULGORA = "fulgora"
local _GLEBA = "gleba"
local _NAUVIS = "nauvis"
local _VULCANUS = "vulcanus"
local _OBSERVATION_SATELLITE = "observation-satellite"


local deep_space_sensing = {}


function deep_space_sensing.technology_bfs_enabler(starting_tech, should_enable)
    local tech_queue = {}
    local visited_techs = {}

    -- Initialize tables
    table.insert(tech_queue, starting_tech)
    visited_techs[starting_tech] = true

    while #tech_queue > 0 do
        local current_tech = table.remove(tech_queue, 1)

        current_tech.enabled = should_enable

        for _, tech in pairs(current_tech.successors) do
            if string.find(tech.order, "tenebris") then
                if not visited_techs[tech] then
                    visited_techs[tech] = true
                    table.insert(tech_queue, tech)
                end
            end
        end
    end
end


function deep_space_sensing.setup_deep_space_sensing_satellites_counter()
    -- Forcibly reset all the satellites around every planet. Engineer pressing the interplanetary self-destruct button.
    storage.tenebris_orbital_observation_satellites = {}
    for planet_name, _ in pairs(game.planets) do
        storage.tenebris_orbital_observation_satellites[planet_name] = 0
    end
end


function deep_space_sensing.setup_deep_space_sensing_planetary_contribution()
    -- Ideally this should compute the distance from Tenebris to every other planet, but that's hard to think about doing in Factorio Lua, for now set fixed contributions.
    -- Fixed contributions also mean that additional planets from other mods won't impact the research chance.
    storage.tenebris_orbital_satellite_contribution_probabilities = {
        [_AQUILO] = 0.002,
        [_FULGORA] = 0.005,
        [_NAUVIS] = 0.0001,
        [_GLEBA] = 0.0012,
        [_VULCANUS] = 0
    }
end


function deep_space_sensing.on_satellite_launched(cargo_pod)
    -- This shouldn't happen, but I don't want to crash a save over it.
    if storage.tenebris_orbital_observation_satellites == nil then
        deep_space_sensing.setup_deep_space_sensing_satellites_counter()
    end

    -- To account for planets added retroactively to the save...
    if storage.tenebris_orbital_observation_satellites[cargo_pod.cargo_pod_origin.surface.planet.name] == nil then
        storage.tenebris_orbital_observation_satellites[cargo_pod.cargo_pod_origin.surface.planet.name] = 0
    end

    storage.tenebris_orbital_observation_satellites[cargo_pod.cargo_pod_origin.surface.planet.name] = (
        storage.tenebris_orbital_observation_satellites[cargo_pod.cargo_pod_origin.surface.planet.name] + 1
    )

    game.print(storage.tenebris_orbital_observation_satellites[cargo_pod.cargo_pod_origin.surface.planet.name])
end


function deep_space_sensing.discover_tenebris()
    game.print(string.format("Observation Satellite Network Message: Distant celestial body discovered. Name: Tenebris, the Dark World"))

    local tenebris_technology = game.forces.player.technologies["planet-discovery-tenebris"]
    -- technology_bfs_enabler(tenebris_technology, true)
end


function deep_space_sensing.progress_deep_space_sensing()
    local sensing_fidelity = 0

    if storage.tenebris_orbital_satellite_contribution_probabilities == nil and storage.tenebris_orbital_observation_satellites == nil then
        deep_space_sensing.setup_deep_space_sensing_planetary_contribution()
        deep_space_sensing.setup_deep_space_sensing_satellites_counter()
    end

    for planet_name, planetary_fidelity in pairs(storage.tenebris_orbital_satellite_contribution_probabilities) do
        sensing_fidelity = sensing_fidelity + storage.tenebris_orbital_observation_satellites[planet_name] * planetary_fidelity
    end

    -- Attempt to roll to find Tenebris.
    local sensing_roll = math.random()
    if sensing_roll < 1 - sensing_fidelity then
        game.print(string.format("Observation Satellite Network Message: No objects of interest located."))
        return
    end

    deep_space_sensing.discover_tenebris()
end


function deep_space_sensing.on_progress_deep_space_sensing_tick(event)
    if game.forces.player.technologies["deep-space-sensing"].researched then
        deep_space_sensing.progress_deep_space_sensing()
    end
end


return deep_space_sensing