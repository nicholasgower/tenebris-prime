-- Runtime FUnit scenario for tenebris-prime.
--
-- The scenario lives inside the development-only companion mod so it is not
-- included in release builds. Run it with the local runner as:
--   --start-server-load-scenario tenebris-prime-funit/__funit__tenebris
require("__base__/script/freeplay/control.lua")

local runner = require("__funit__.test_runner")
runner.register("tenebris-prime")
runner.report("tenebris")

local manifest = require("__tenebris-prime-funit__.tests.manifest")
for _, suite in ipairs(manifest) do
    require(suite)
end
