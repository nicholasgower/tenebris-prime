--- Deep Space Sensing Core Module
--- Manages satellite-based planet discovery mechanics.
---
--- @module deep_space_sensing

local planet_distance = require("scripts.deep_space_sensing.planet_distance")
local constants = require("scripts.deep_space_sensing.constants")

local deep_space_sensing = {}

-- Re-export constants for convenience
deep_space_sensing.constants = constants
deep_space_sensing.SCAN_INTERVAL_SECONDS = constants.SCAN_INTERVAL_SECONDS

--- Callbacks to notify when GUI should refresh (avoids circular dependency)
local refresh_callbacks = {}

--- Register a callback to be called when the GUI should refresh
--- @param callback function The callback function to call
function deep_space_sensing.register_refresh_callback(callback)
    table.insert(refresh_callbacks, callback)
end

--- Call all registered refresh callbacks
local function notify_refresh()
    for _, callback in ipairs(refresh_callbacks) do
        callback()
    end
end

--- Configuration for discoverable planets
--- Structure: { [planet_name] = { tech_name, hardness, options... } }
--- @type table<string, table>
local DISCOVERABLE_PLANETS = {}

--- Shorthand for storage keys
local KEYS = constants.STORAGE_KEYS


function deep_space_sensing.setup_satellites_counter()
    -- Initialize satellite counters for all forces
    if not storage[KEYS.ORBITAL_SATELLITES] then
        storage[KEYS.ORBITAL_SATELLITES] = {}
    end
    
    for _, force in pairs(game.forces) do
        if not storage[KEYS.ORBITAL_SATELLITES][force.name] then
            storage[KEYS.ORBITAL_SATELLITES][force.name] = {}
        end
        
        for planet_name, _ in pairs(game.planets) do
            if not storage[KEYS.ORBITAL_SATELLITES][force.name][planet_name] then
                storage[KEYS.ORBITAL_SATELLITES][force.name][planet_name] = 0
            end
        end
    end
end

-- Legacy alias
deep_space_sensing.setup_deep_space_sensing_satellites_counter = deep_space_sensing.setup_satellites_counter


function deep_space_sensing.setup_planetary_contribution(force_rebuild)
    if force_rebuild then
        storage[KEYS.CONTRIBUTION_PROBABILITIES] = nil
    end

    -- Ensure per-force container
    if not storage[KEYS.CONTRIBUTION_PROBABILITIES] then
        storage[KEYS.CONTRIBUTION_PROBABILITIES] = {}
    end

    -- Build contribution maps for all discoverable planets using dynamic distance calculation
    -- Pass each planet's custom config for contribution calculation
    local discoverable_list = {}
    for planet_name, config in pairs(DISCOVERABLE_PLANETS) do
        table.insert(discoverable_list, {
            name = planet_name,
            config = {
                base_scale = config.base_contribution_scale,
                decay_scale = config.decay_scale,
            }
        })
    end

    local maps = planet_distance.build_all_contribution_maps(discoverable_list)

    -- Store per-force so lookups always index by force first
    for _, force in pairs(game.forces) do
        storage[KEYS.CONTRIBUTION_PROBABILITIES][force.name] = maps
    end
end

-- Legacy alias
deep_space_sensing.setup_deep_space_sensing_planetary_contribution = deep_space_sensing.setup_planetary_contribution


function deep_space_sensing.on_satellite_launched(cargo_pod)
    -- Get the force that launched the satellite
    local launching_force = cargo_pod.force
    if not launching_force then
        return
    end
    
    local force_name = launching_force.name
    local origin_planet = cargo_pod.cargo_pod_origin.surface.planet.name

    -- Get the satellite item stack to determine quality
    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    local stack = inventory and inventory.find_item_stack(constants.OBSERVATION_SATELLITE_ITEM)
    
    -- Determine strength based on quality level (0-4, clamped)
    local quality_level = 0
    local quality_name = "normal"
    if stack and stack.quality then
        quality_level = math.min(stack.quality.level, 4)  -- Clamp to max tier
        quality_name = stack.quality.name  -- Keep name for display
    end
    local strength = constants.QUALITY_STRENGTH[quality_level] or 1.0

    -- Initialize if needed
    if not storage[KEYS.ORBITAL_SATELLITES] then
        deep_space_sensing.setup_satellites_counter()
    end
    
    if not storage[KEYS.ORBITAL_SATELLITES][force_name] then
        storage[KEYS.ORBITAL_SATELLITES][force_name] = {}
    end

    if not storage[KEYS.ORBITAL_SATELLITES][force_name][origin_planet] then
        storage[KEYS.ORBITAL_SATELLITES][force_name][origin_planet] = 0
    end

    -- Add strength (not just count) to the total
    storage[KEYS.ORBITAL_SATELLITES][force_name][origin_planet] = (
        storage[KEYS.ORBITAL_SATELLITES][force_name][origin_planet] + strength
    )

    -- Log satellite deployment
    log(string.format("[Deep Space Sensing] %s satellite deployed in %s orbit. Total strength: %.1f",
        quality_name,
        origin_planet,
        storage[KEYS.ORBITAL_SATELLITES][force_name][origin_planet]))
    
    -- Notify any registered GUI refresh callbacks
    notify_refresh()
end


--- Gets the list of discoverable planets
--- @return table Map of planet_name -> config (includes tech_name, display_name)
function deep_space_sensing.get_discoverable_planets()
    -- Return a map with config info for the GUI
    local result = {}
    for planet_name, config in pairs(DISCOVERABLE_PLANETS) do
        result[planet_name] = {
            tech_name = config.tech_name,
            display_name = config.display_name or planet_name,
        }
    end
    return result
end

--- Gets the display name for a planet
--- @param planet_name string The planet name
--- @return string display_name The display name (or planet_name if not set)
function deep_space_sensing.get_display_name(planet_name)
    local config = DISCOVERABLE_PLANETS[planet_name]
    if config and config.display_name then
        return config.display_name
    end
    return planet_name
end

--- Gets the full configuration for a discoverable planet
--- @param planet_name string The planet name
--- @return table|nil config The planet configuration or nil if not registered
function deep_space_sensing.get_planet_config(planet_name)
    return DISCOVERABLE_PLANETS[planet_name]
end

--- Checks if a force has any satellites in orbit
--- @param force LuaForce The force to check
--- @return boolean has_satellites True if at least one satellite is in orbit
function deep_space_sensing.has_any_satellites(force)
    local force_name = force.name
    
    if not storage[KEYS.ORBITAL_SATELLITES] or
       not storage[KEYS.ORBITAL_SATELLITES][force_name] then
        return false
    end
    
    for _, count in pairs(storage[KEYS.ORBITAL_SATELLITES][force_name]) do
        if count > 0 then
            return true
        end
    end
    
    return false
end


--- Calculates the current discovery chance for a planet for a given force
--- Takes into account the planet's hardness multiplier
--- @param force LuaForce The force to calculate for
--- @param planet_name string The target planet
--- @return number chance The discovery chance (0 to 1)
function deep_space_sensing.calculate_discovery_chance(force, planet_name)
    local force_name = force.name
    
    if not storage[KEYS.CONTRIBUTION_PROBABILITIES] or
       not storage[KEYS.ORBITAL_SATELLITES] or
       not storage[KEYS.ORBITAL_SATELLITES][force_name] or
       not storage[KEYS.CONTRIBUTION_PROBABILITIES][force_name] then
        return 0
    end
    
    local sensing_fidelity = 0
    local contribution_map = storage[KEYS.CONTRIBUTION_PROBABILITIES][force_name][planet_name]
    
    if contribution_map then
        for observer_planet, contribution in pairs(contribution_map) do
            local satellite_count = storage[KEYS.ORBITAL_SATELLITES][force_name][observer_planet] or 0
            sensing_fidelity = sensing_fidelity + satellite_count * contribution
        end
    end
    
    -- Apply hardness multiplier (higher hardness = lower chance)
    local config = DISCOVERABLE_PLANETS[planet_name]
    if config and config.hardness then
        sensing_fidelity = sensing_fidelity / config.hardness
    end
    
    return sensing_fidelity
end


function deep_space_sensing.discover_planet(planet_name, discovery_tech_name, force)
    -- Automatically research the technology (no science pack cost)
    local discovery_technology = force.technologies[discovery_tech_name]
    if discovery_technology then
        discovery_technology.researched = true
        
        -- Notify all players in the force (use display name)
        local display_name = deep_space_sensing.get_display_name(planet_name)
        force.print({"deep-space-sensing.planet-discovered-notification", display_name})
    else
        log(string.format("[Deep Space Sensing] Warning: Technology '%s' not found for planet '%s'", discovery_tech_name, planet_name))
    end
    
    -- Clear the target for this force
    if storage[KEYS.DISCOVERY_TARGETS] then
        storage[KEYS.DISCOVERY_TARGETS][force.name] = nil
    end
    
    -- Notify any registered GUI refresh callbacks
    notify_refresh()
end


function deep_space_sensing.progress_for_force(force)
    local force_name = force.name
    
    if not storage[KEYS.CONTRIBUTION_PROBABILITIES] or 
       not storage[KEYS.ORBITAL_SATELLITES] or
       not storage[KEYS.ORBITAL_SATELLITES][force_name] then
        deep_space_sensing.setup_planetary_contribution()
        deep_space_sensing.setup_satellites_counter()
    end

    -- Get the currently targeted planet for this force
    if not storage[KEYS.DISCOVERY_TARGETS] then
        storage[KEYS.DISCOVERY_TARGETS] = {}
    end
    
    local target_planet = storage[KEYS.DISCOVERY_TARGETS][force_name]
    if not target_planet then
        return  -- No target selected, nothing to scan for
    end
    
    local planet_config = DISCOVERABLE_PLANETS[target_planet]
    if not planet_config then
        return  -- Invalid target
    end
    
    local discovery_tech_name = planet_config.tech_name
    
    -- Check if already discovered
    local tech = force.technologies[discovery_tech_name]
    if not tech or tech.researched then
        storage[KEYS.DISCOVERY_TARGETS][force_name] = nil
        return
    end
    
    -- Check prerequisites
    if tech.prerequisites then
        for _, prereq_tech in pairs(tech.prerequisites) do
            if not prereq_tech.researched then
                return  -- Prerequisites not met
            end
        end
    end
    
    -- Calculate sensing fidelity for this planet
    local sensing_fidelity = deep_space_sensing.calculate_discovery_chance(force, target_planet)
    
    -- Attempt to discover
    local sensing_roll = math.random()
    if sensing_roll < sensing_fidelity then
        deep_space_sensing.discover_planet(target_planet, discovery_tech_name, force)
    end
end

-- Legacy alias
deep_space_sensing.progress_deep_space_sensing_for_force = deep_space_sensing.progress_for_force


--- Ensures last scan tick is initialized
--- @return number last_scan_tick The tick of the last scan
local function ensure_last_scan_tick()
    if not storage[KEYS.LAST_SCAN_TICK] then
        -- If scanning was just started and this wasn't set yet, start "now"
        storage[KEYS.LAST_SCAN_TICK] = game.tick
    end
    return storage[KEYS.LAST_SCAN_TICK]
end

function deep_space_sensing.on_progress_tick(event)
    -- Only do scan work while at least one force has an active target.
    if not storage[KEYS.DISCOVERY_TARGETS] then
        return
    end
    
    local did_scan = false

    -- Process for each force that is actively scanning
    for _, force in pairs(game.forces) do
        if not force.technologies[constants.UNLOCK_TECHNOLOGY] or 
           not force.technologies[constants.UNLOCK_TECHNOLOGY].researched then
            goto continue_force
        end
        
        -- Check if this force has a target selected
        if storage[KEYS.DISCOVERY_TARGETS][force.name] then
            deep_space_sensing.progress_for_force(force)
            did_scan = true
        end
        
        ::continue_force::
    end
    
    if did_scan then
        -- Record the tick when this scan happened (for progress bars)
        storage[KEYS.LAST_SCAN_TICK] = game.tick

        -- Notify GUIs to refresh after scan
        notify_refresh()
    end
end

-- Legacy alias
deep_space_sensing.on_progress_deep_space_sensing_tick = deep_space_sensing.on_progress_tick


--- Gets the progress toward the next scan (0 to 1)
--- @return number progress Progress from 0 (just scanned) to 1 (about to scan)
function deep_space_sensing.get_scan_progress()
    local last_scan_tick = ensure_last_scan_tick()
    local ticks_since_scan = game.tick - last_scan_tick
    local scan_interval_ticks = constants.SCAN_INTERVAL_SECONDS * 60
    
    return math.min(ticks_since_scan / scan_interval_ticks, 1)
end

--- Gets the seconds until the next scan
--- @return number seconds Seconds until the next scan
function deep_space_sensing.get_seconds_until_scan()
    local last_scan_tick = ensure_last_scan_tick()
    local ticks_since_scan = game.tick - last_scan_tick
    local scan_interval_ticks = constants.SCAN_INTERVAL_SECONDS * 60
    local ticks_remaining = math.max(scan_interval_ticks - ticks_since_scan, 0)
    
    return math.ceil(ticks_remaining / 60)
end


--- Registers a planet as discoverable via deep space sensing
--- @param config table Planet configuration:
---   - planet_name: string (required) - The name of the planet in game.planets
---   - tech_name: string (required) - The technology that unlocks this planet
---   - hardness: number (optional, default 1.0) - Discovery difficulty multiplier (higher = harder)
---   - base_contribution_scale: number (optional) - Affects distance contribution calculation
---   - max_contribution: number (optional) - Maximum contribution per satellite
--- @return boolean success True if registered successfully
--- @return string|nil error_message Error message if registration failed
function deep_space_sensing.register_discoverable_planet(config, legacy_tech_name)
    -- Handle legacy call signature: (planet_name, tech_name)
    if type(config) == "string" then
        local planet_name = config
        config = {
            planet_name = planet_name,
            tech_name = legacy_tech_name
        }
    end
    
    -- Validate required fields
    if not config.planet_name or type(config.planet_name) ~= "string" then
        return false, "planet_name is required and must be a string"
    end
    
    if not config.tech_name or type(config.tech_name) ~= "string" then
        return false, "tech_name is required and must be a string"
    end
    
    local defaults = constants.DEFAULT_PLANET_CONFIG
    
    -- Apply defaults
    local planet_config = {
        tech_name = config.tech_name,
        display_name = config.display_name or config.planet_name,  -- Fallback to planet_name if not provided
        hardness = config.hardness or defaults.hardness,
        base_contribution_scale = config.base_contribution_scale or defaults.base_contribution_scale,
        decay_scale = config.decay_scale or defaults.decay_scale,
    }
    
    DISCOVERABLE_PLANETS[config.planet_name] = planet_config
    
    return true, nil
end

--- Gets the default configuration values
--- @return table defaults The default configuration
function deep_space_sensing.get_default_config()
    return constants.DEFAULT_PLANET_CONFIG
end

--- Checks if any planets are registered for discovery
--- @return boolean has_planets True if at least one planet is registered
function deep_space_sensing.has_registered_planets()
    return next(DISCOVERABLE_PLANETS) ~= nil
end

--- Gets the current discovery target for a force
--- @param force LuaForce The force
--- @return string|nil target_planet The target planet name or nil
function deep_space_sensing.get_discovery_target(force)
    if not storage[KEYS.DISCOVERY_TARGETS] then
        return nil
    end
    return storage[KEYS.DISCOVERY_TARGETS][force.name]
end

--- Sets the discovery target for a force
--- @param force LuaForce The force
--- @param planet_name string|nil The target planet name (nil to clear)
function deep_space_sensing.set_discovery_target(force, planet_name)
    if not storage[KEYS.DISCOVERY_TARGETS] then
        storage[KEYS.DISCOVERY_TARGETS] = {}
    end
    storage[KEYS.DISCOVERY_TARGETS][force.name] = planet_name

    -- When scanning starts, reset the scan timer immediately so progress begins at 0.
    if planet_name ~= nil then
        storage[KEYS.LAST_SCAN_TICK] = game.tick
    end

    notify_refresh()
end

--- Gets satellite counts for a force
--- @param force LuaForce The force
--- @return table|nil counts Map of planet_name -> satellite_count
function deep_space_sensing.get_satellite_counts(force)
    if not storage[KEYS.ORBITAL_SATELLITES] then
        return nil
    end
    return storage[KEYS.ORBITAL_SATELLITES][force.name]
end


return deep_space_sensing

