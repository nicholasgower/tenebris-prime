--- Planet Distance Calculator
--- Calculates distances between planets using their star map positions.
--- Uses LuaSpaceLocationPrototype.position for Cartesian coordinates.
---
--- @module deep_space_sensing.planet_distance

local constants = require("scripts.deep_space_sensing.constants")

local planet_distance = {}

--- Calculates Euclidean distance between two Cartesian points
--- @param pos1 MapPosition First position {x: number, y: number}
--- @param pos2 MapPosition Second position {x: number, y: number}
--- @return number distance The Euclidean distance
local function euclidean_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Gets the position of a planet on the star map
--- @param planet_name string The name of the planet
--- @return MapPosition|nil position The position or nil if not found
function planet_distance.get_planet_position(planet_name)
    local planet = game.planets[planet_name]
    
    if not planet or not planet.prototype then
        return nil
    end
    
    return planet.prototype.position
end

--- Calculates the straight-line distance between two planets
--- @param planet1_name string Name of the first planet
--- @param planet2_name string Name of the second planet
--- @return number|nil distance Distance between planets, or nil if calculation failed
function planet_distance.calculate_distance(planet1_name, planet2_name)
    local pos1 = planet_distance.get_planet_position(planet1_name)
    local pos2 = planet_distance.get_planet_position(planet2_name)
    
    if not pos1 or not pos2 then
        return nil
    end
    
    return euclidean_distance(pos1, pos2)
end

--- Calculates sensing contribution based on distance from observer to target
--- Uses exponential decay for dramatic distance differentiation
--- @param distance number The distance between planets
--- @param config table|nil Optional configuration { base_scale: number, decay_scale: number }
--- @return number contribution The sensing contribution per satellite
function planet_distance.calculate_sensing_contribution(distance, config)
    if distance == nil or distance == 0 then
        return 0
    end
    
    local defaults = constants.DEFAULT_CONTRIBUTION_CONFIG
    config = config or defaults
    local base_scale = config.base_scale or defaults.base_scale
    local decay_scale = config.decay_scale or defaults.decay_scale or 25
    
    -- Exponential decay: contribution = base_scale * e^(-distance / decay_scale)
    -- At distance = decay_scale: contribution = base_scale * 0.368 (37% of base)
    -- At distance = 2*decay_scale: contribution = base_scale * 0.135 (13.5% of base)
    -- At distance = 3*decay_scale: contribution = base_scale * 0.05 (5% of base)
    local contribution = base_scale * math.exp(-distance / decay_scale)
    
    return contribution
end

--- Builds a contribution map for all planets relative to a target planet
--- @param target_planet_name string Name of the target planet to discover
--- @param config table|nil Optional configuration for contribution calculation
--- @return table contributions Map of observer_planet_name -> contribution_value
function planet_distance.build_contribution_map(target_planet_name, config)
    local contributions = {}
    
    -- Get all planets
    for observer_planet_name, planet in pairs(game.planets) do
        if observer_planet_name ~= target_planet_name then
            local distance = planet_distance.calculate_distance(observer_planet_name, target_planet_name)
            
            if distance then
                contributions[observer_planet_name] = planet_distance.calculate_sensing_contribution(distance, config)
            else
                -- Fallback to 0 if we can't calculate
                contributions[observer_planet_name] = 0
            end
        end
    end
    
    return contributions
end

--- Builds contribution maps for all discoverable planets
--- @param discoverable_planets table Array of planet names or {name, config} tuples
--- @return table maps Map of target_planet_name -> (observer_planet_name -> contribution_value)
function planet_distance.build_all_contribution_maps(discoverable_planets)
    local all_maps = {}
    
    for _, target_planet in ipairs(discoverable_planets) do
        -- Support both simple names and {name, config} tuples
        local planet_name, config
        if type(target_planet) == "table" then
            planet_name = target_planet.name
            config = target_planet.config
        else
            planet_name = target_planet
            config = nil
        end
        
        all_maps[planet_name] = planet_distance.build_contribution_map(planet_name, config)
    end
    
    return all_maps
end

--- Debug function to print all planet distances to a target planet
--- @param target_planet_name string The target planet to calculate distances to
function planet_distance.debug_print_distances(target_planet_name)
    game.print(string.format("=== Planet Distances to %s ===", target_planet_name))
    
    local target_pos = planet_distance.get_planet_position(target_planet_name)
    if target_pos then
        game.print(string.format("  Target position: (%.2f, %.2f)", target_pos.x, target_pos.y))
    end
    
    for planet_name, _ in pairs(game.planets) do
        if planet_name ~= target_planet_name then
            local observer_pos = planet_distance.get_planet_position(planet_name)
            local distance = planet_distance.calculate_distance(planet_name, target_planet_name)
            local contribution = planet_distance.calculate_sensing_contribution(distance)
            
            if distance and observer_pos then
                game.print(string.format("  %s: pos(%.2f,%.2f) dist=%.2f contrib=%.4f (%.2f%%)", 
                    planet_name, observer_pos.x, observer_pos.y, distance, contribution, contribution * 100))
            else
                game.print(string.format("  %s: Unable to calculate", planet_name))
            end
        end
    end
end

--- Debug function to print current contribution maps from storage
--- @param force LuaForce The force to print contributions for
--- @param target_planet_name string The target planet
function planet_distance.debug_print_stored_contributions(force, target_planet_name)
    local KEYS = constants.STORAGE_KEYS
    game.print(string.format("=== Stored Contributions for %s (force: %s) ===", target_planet_name, force.name))
    
    if not storage[KEYS.CONTRIBUTION_PROBABILITIES] then
        game.print("  No contribution maps in storage!")
        return
    end
    
    if not storage[KEYS.CONTRIBUTION_PROBABILITIES][force.name] then
        game.print("  No contribution maps for this force!")
        return
    end
    
    local map = storage[KEYS.CONTRIBUTION_PROBABILITIES][force.name][target_planet_name]
    if not map then
        game.print("  No contribution map for this planet!")
        return
    end
    
    for observer_planet, contribution in pairs(map) do
        game.print(string.format("  %s: %.6f (%.4f%%)", observer_planet, contribution, contribution * 100))
    end
end

return planet_distance

