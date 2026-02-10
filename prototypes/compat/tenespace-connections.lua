--- Compatibility: Maraxsis / Paracelsin Space Connections
--- If Maraxsis or Paracelsin is present, creates a route from the closer planet to Tenebris
--- and removes the default fulgora-tenebris connection.
--- See CREDITS.md for third-party code attribution.

local constants = require("lib.constants")
local tenebris_asteroid_util = require("__tenebris-prime__.prototypes.planet.asteroid-spawn-definitions")

--- Calculate cartesian position from polar coordinates (distance, orientation)
--- @param distance number Distance from star
--- @param orientation number Orientation (0-1, where 1 = full circle)
--- @return number x, number y
local function polar_to_cartesian(distance, orientation)
    local angle = orientation * 2 * math.pi
    return distance * math.cos(angle), distance * math.sin(angle)
end

--- Calculate Euclidean distance between two points
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
local function euclidean_distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--- Get planet position from prototype
--- @param planet_name string
--- @return number|nil x, number|nil y
local function get_planet_position(planet_name)
    local planet = data.raw["planet"][planet_name] or data.raw["space-location"][planet_name]
    if not planet then
        return nil, nil
    end
    
    -- Handle PlanetsLib orbit format
    local distance, orientation
    if planet.orbit then
        distance = planet.orbit.distance
        orientation = planet.orbit.orientation or 0
    else
        distance = planet.distance
        orientation = planet.orientation or 0
    end
    
    if not distance then
        return nil, nil
    end
    
    return polar_to_cartesian(distance, orientation)
end

--- Build connection icon from two planet prototypes
--- Adapted from Redrawn Space Connections (GNU GPLv3)
--- @param from_prototype table The source planet prototype
--- @param to_prototype table The destination planet prototype
--- @return table icons The icons table for the connection
local function build_connection_icons(from_prototype, to_prototype)
    if from_prototype.icon and to_prototype.icon then
        return {
            {
                icon = "__space-age__/graphics/icons/planet-route.png",
                icon_size = 64,
            },
            {
                icon = from_prototype.icon,
                icon_size = from_prototype.icon_size or 64,
                scale = 0.333 * (64 / (from_prototype.icon_size or 64)),
                shift = { -6, -6 },
            },
            {
                icon = to_prototype.icon,
                icon_size = to_prototype.icon_size or 64,
                scale = 0.333 * (64 / (to_prototype.icon_size or 64)),
                shift = { 6, 6 },
            },
        }
    else
        return nil  -- Will use fallback icon
    end
end

-- Get baseline connection length (use constant since fulgora-tenebris may have been deleted by other mods)
local fulgora_tenebris = data.raw["space-connection"]["fulgora-tenebris"]
local fulgora_tenebris_length = fulgora_tenebris and fulgora_tenebris.length or constants.SPACE_CONNECTION.FULGORA_TENEBRIS_LENGTH
log(string.format("[Tenebris Prime] Using fulgora-tenebris length: %d (from %s)", 
    fulgora_tenebris_length, fulgora_tenebris and "prototype" or "constant"))

-- Get Tenebris position for distance calculations
local tenebris_x, tenebris_y = get_planet_position(constants.PLANET.TENEBRIS)
local tenebris_planet = data.raw["planet"][constants.PLANET.TENEBRIS]

log(string.format("[Tenebris Prime] Tenebris position: (%.2f, %.2f)", tenebris_x or 0, tenebris_y or 0))

if not tenebris_x then
    log("[Tenebris Prime] Could not get Tenebris position, skipping compat")
    return
end

-- Get Fulgora position for baseline distance calculation
local fulgora_x, fulgora_y = get_planet_position("fulgora")
local fulgora_to_tenebris_dist = nil
if fulgora_x then
    fulgora_to_tenebris_dist = euclidean_distance(fulgora_x, fulgora_y, tenebris_x, tenebris_y)
    log(string.format("[Tenebris Prime] Fulgora position: (%.2f, %.2f), distance to Tenebris: %.2f", fulgora_x, fulgora_y, fulgora_to_tenebris_dist))
end

-- Collect candidate planets and their distances
local candidates = {}

if mods["maraxsis"] then
    log("[Tenebris Prime] Maraxsis mod detected")
    local mx, my = get_planet_position("maraxsis")
    if mx then
        local dist = euclidean_distance(mx, my, tenebris_x, tenebris_y)
        local has_existing = data.raw["space-connection"]["maraxsis-tenebris"] ~= nil
        table.insert(candidates, {
            name = "maraxsis",
            distance = dist,
            planet = data.raw["planet"]["maraxsis"],
            existing_connection = data.raw["space-connection"]["maraxsis-tenebris"],
        })
        log(string.format("[Tenebris Prime] Maraxsis position: (%.2f, %.2f), distance to Tenebris: %.2f, existing connection: %s", 
            mx, my, dist, tostring(has_existing)))
    else
        log("[Tenebris Prime] Maraxsis mod present but planet position not found")
    end
else
    log("[Tenebris Prime] Maraxsis mod NOT detected")
end

if mods["Paracelsin"] then
    log("[Tenebris Prime] Paracelsin mod detected")
    local px, py = get_planet_position("paracelsin")
    if px then
        local dist = euclidean_distance(px, py, tenebris_x, tenebris_y)
        local has_existing = data.raw["space-connection"]["paracelsin-tenebris"] ~= nil
        table.insert(candidates, {
            name = "paracelsin",
            distance = dist,
            planet = data.raw["planet"]["paracelsin"],
            existing_connection = data.raw["space-connection"]["paracelsin-tenebris"],
        })
        log(string.format("[Tenebris Prime] Paracelsin position: (%.2f, %.2f), distance to Tenebris: %.2f, existing connection: %s", 
            px, py, dist, tostring(has_existing)))
    else
        log("[Tenebris Prime] Paracelsin mod present but planet position not found")
    end
else
    log("[Tenebris Prime] Paracelsin mod NOT detected")
end

-- No candidates, nothing to do
if #candidates == 0 then
    log("[Tenebris Prime] No alternative planet candidates found")
    return
end

-- Log all candidates
log(string.format("[Tenebris Prime] Found %d candidates:", #candidates))
for i, c in ipairs(candidates) do
    log(string.format("[Tenebris Prime]   %d. %s: distance = %.2f", i, c.name, c.distance))
end

-- Create connections for ALL candidates
for _, candidate in ipairs(candidates) do
    -- Calculate scaled route length based on distance
    local new_length = fulgora_tenebris_length
    if fulgora_to_tenebris_dist and fulgora_to_tenebris_dist > 0 then
        local scale_factor = candidate.distance / fulgora_to_tenebris_dist
        new_length = math.max(fulgora_tenebris_length, fulgora_tenebris_length * scale_factor)
    end

    local connection_name = candidate.name .. "-tenebris"

    -- Delete any existing connection (it might be incomplete from the other mod)
    if candidate.existing_connection then
        log(string.format("[Tenebris Prime] Deleting existing %s connection to recreate it", connection_name))
        data.raw["space-connection"][connection_name] = nil
    end

    -- Create our own connection
    local icons = build_connection_icons(candidate.planet, tenebris_planet)

    local new_connection = {
        type = "space-connection",
        name = connection_name,
        subgroup = "planet-connections",
        from = candidate.name,
        to = constants.PLANET.TENEBRIS,
        length = math.floor(new_length),
        asteroid_spawn_definitions = tenebris_asteroid_util.spawn_definitions(tenebris_asteroid_util.fulgora_tenebris),
        tenebris_prime_connection = true,
        redrawn_connections_keep = true,
    }

    if icons then
        new_connection.icons = icons
    else
        new_connection.icon = "__space-age__/graphics/icons/planet-route.png"
        new_connection.icon_size = 64
    end

    data:extend({ new_connection })
    log(string.format("[Tenebris Prime] Created %s connection (length: %d, redrawn_connections_keep=%s)", 
        connection_name, math.floor(new_length), tostring(new_connection.redrawn_connections_keep)))

    -- Verify the connection was actually added with the property
    local verify = data.raw["space-connection"][connection_name]
    if verify then
        log(string.format("[Tenebris Prime] Verified %s exists, redrawn_connections_keep=%s", 
            connection_name, tostring(verify.redrawn_connections_keep)))
    else
        log(string.format("[Tenebris Prime] ERROR: %s was not added to data.raw!", connection_name))
    end
end

-- Delete fulgora-tenebris since we have alternatives
if data.raw["space-connection"]["fulgora-tenebris"] then
    data.raw["space-connection"]["fulgora-tenebris"] = nil
    log("[Tenebris Prime] Deleted fulgora-tenebris (alternative routes exist)")
end
