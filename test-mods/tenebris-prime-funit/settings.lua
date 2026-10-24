-- Startup setting for the Tenebris Prime FUnit data fixtures.
--
-- The fixtures are gated so a save can still be loaded with them disabled.
data:extend({
    {
        type = "bool-setting",
        setting_type = "startup",
        name = "tenebris-prime-funit-enable-data-fixtures",
        default_value = true,
        order = "a",
    },
})
