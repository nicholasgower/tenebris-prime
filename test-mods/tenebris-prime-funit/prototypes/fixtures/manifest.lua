-- Fixture manifest for the Tenebris Prime FUnit suite.
--
-- Each list holds fixture module names inside prototypes/fixtures/. They are
-- required by the matching stage entry point (data.lua / data-final-fixes.lua).
--
-- The setup fixture must run in data.lua so its machines exist before
-- tenebris-prime's data-updates pass copies the machines added by later mods.
-- The checks run in data-final-fixes, after tenebris-prime's own final fixes.
return {
    data = {
        "next_upgrade_setup",
    },
    data_final_fixes = {
        "next_upgrade",
    },
}
