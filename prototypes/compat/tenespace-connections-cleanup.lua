--- Compatibility: Tenespace Connections Cleanup
--- Removes any external space connections to Tenebris locations
--- that were not defined by Tenebris Prime.
--- This prevents other mods from adding unwanted routes to our planets.
--- Our connections are tagged with tenebris_prime_connection = true.

local constants = require("lib.constants")

-- Build lookup table for Tenebris locations
local tenebris_locations = {}
for _, location in pairs(constants.ALL_TENEBRIS_LOCATIONS) do
    tenebris_locations[location] = true
end

-- Find and remove external connections to Tenebris locations
local connections_to_delete = {}

for name, connection in pairs(data.raw["space-connection"]) do
    -- Check if this connection involves a Tenebris location
    local involves_tenebris = tenebris_locations[connection.from] or tenebris_locations[connection.to]
    
    -- If it involves Tenebris but wasn't created by us, mark for deletion
    if involves_tenebris and not connection.tenebris_prime_connection then
        table.insert(connections_to_delete, name)
    end
end

-- Delete the unwanted connections
for _, name in pairs(connections_to_delete) do
    data.raw["space-connection"][name] = nil
    log(string.format("[Tenebris Prime] Removed external connection: %s", name))
end

if #connections_to_delete > 0 then
    log(string.format("[Tenebris Prime] Removed %d external connection(s) to Tenebris locations", #connections_to_delete))
end

