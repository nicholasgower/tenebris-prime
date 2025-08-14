local meld = require("meld")

_TENEBRIS = "tenebris"
_AQUILO = "aquilo"
_FULGORA = "fulgora"
_GLEBA = "gleba"
_NAUVIS = "nauvis"
_VULCANUS = "vulcanus"
_OBSERVATION_SATELLITE = "observation-satellite"

local function technology_bfs_enabler(starting_tech, should_enable)
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

local function setup_deep_space_sensing_satellites_counter()
    -- Forcibly reset all the satellites around every planet. Engineer pressing the interplanetary self-destruct button.
    storage.tenebris_orbital_observation_satellites = {}
    for planet_name, _ in pairs(game.planets) do
        storage.tenebris_orbital_observation_satellites[planet_name] = 0
    end
end

local function setup_deep_space_sensing_planetary_contribution()
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

local function on_satellite_launched(event)
    local cargo_pod = event.cargo_pod 

    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if inventory == nil then
        return
    end

    if inventory.find_item_stack(_OBSERVATION_SATELLITE) == nil then
        return
    end

    -- This shouldn't happen, but I don't want to crash a save over it.
    if storage.tenebris_orbital_observation_satellites == nil then
        setup_deep_space_sensing_satellites_counter()
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

local function discover_tenebris()
    game.print(string.format("Observation Satellite Network Message: Distant celestial body discovered. Name: Tenebris, the Dark World"))

    local tenebris_technology = game.forces.player.technologies["planet-discovery-tenebris"]
    technology_bfs_enabler(tenebris_technology, true)

    script.on_event(defines.events.on_tick, nil)
end

local function progress_deep_space_sensing()
    local sensing_fidelity = 0
    for planet_name, planetary_fidelity in pairs(storage.tenebris_orbital_satellite_contribution_probabilities) do
        sensing_fidelity = sensing_fidelity + storage.tenebris_orbital_observation_satellites[planet_name] * planetary_fidelity
    end

    -- Attempt to roll to find Tenebris.
    local sensing_roll = math.random()
    if sensing_roll < 1 - sensing_fidelity then
        game.print(string.format("Observation Satellite Network Message: No objects of interest located."))
        return
    end

    discover_tenebris()
end

local function on_progress_deep_space_sensing_tick(event)
    if event.tick % 3600 ~= 0 then
        return
    end

    if game.forces.player.technologies["deep-space-sensing"].researched then
        progress_deep_space_sensing()
    end
end

local function on_deep_space_sensing_researched(event)
    if event.research.name ~= "deep-space-sensing" then
        return
    end

    setup_deep_space_sensing_satellites_counter()
    setup_deep_space_sensing_planetary_contribution()
end

script.on_event(defines.events.on_research_finished, on_deep_space_sensing_researched)
script.on_event(defines.events.on_cargo_pod_finished_ascending, on_satellite_launched)
script.on_event(defines.events.on_tick, on_progress_deep_space_sensing_tick)

script.on_init(
    function()
        local tenebris_technology = game.forces.player.technologies["planet-discovery-tenebris"]

        technology_bfs_enabler(tenebris_technology, false)
    end
)