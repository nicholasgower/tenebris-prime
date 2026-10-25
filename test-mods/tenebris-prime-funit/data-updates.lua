-- Data-updates stage for the Tenebris Prime FUnit fixtures.
--
-- Fixtures can use this stage to change prototypes after Tenebris Prime has
-- copied the machines made in data.lua, mimicking mods that update their own
-- machines in data-updates (for example Heat Management's radiators).
if settings.startup["tenebris-prime-funit-enable-data-fixtures"].value then
    local manifest = require("prototypes.fixtures.manifest")
    for _, fixture in ipairs(manifest.data_updates or {}) do
        require("prototypes.fixtures." .. fixture)
    end
end
