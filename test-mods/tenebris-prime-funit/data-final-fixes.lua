-- Final data-stage fixtures for the Tenebris Prime FUnit suite.
--
-- This runs after tenebris-prime's data-final-fixes, so the fixtures see the
-- final prototype state that ships to players.
if settings.startup["tenebris-prime-funit-enable-data-fixtures"].value then
    local manifest = require("prototypes.fixtures.manifest")
    for _, fixture in ipairs(manifest.data_final_fixes or {}) do
        require("prototypes.fixtures." .. fixture)
    end
end
