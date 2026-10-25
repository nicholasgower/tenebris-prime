-- Fixture manifest for the Tenebris Prime FUnit suite.
--
-- Each list holds fixture module names inside prototypes/fixtures/. They are
-- required by the matching stage entry point (data.lua / data-updates.lua /
-- data-final-fixes.lua).
--
-- The setup fixture must run in data.lua so its machines exist before
-- tenebris-prime's data-updates pass copies the machines added by later mods.
-- The update fixture runs in data-updates, after that copy, to imitate mods
-- that change their own machines in that stage. The checks run in
-- data-final-fixes, after tenebris-prime's own final fixes.
return {
    data = {
        "next_upgrade_setup",
        "fixed_recipe_setup",
    },
    data_updates = {
        "fixed_recipe_update",
    },
    data_final_fixes = {
        "next_upgrade",
        "fixed_recipe",
    },
}
