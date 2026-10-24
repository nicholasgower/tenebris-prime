-- Data-stage checks for the upgrade chain of the bioluminescent copies (#39).
--
-- By this stage tenebris-prime has created its copies (data.lua) and has run
-- its own final fixes, which is where a copy's dangling next_upgrade is
-- cleared. Without that fix Factorio aborts the data stage before these checks
-- can run, so a successful load is already part of the regression test.

local results = require("lib.results")

local SUITE = "bioluminescent"

results.check(SUITE, "fixture-shape-matches-issue-39", function()
    local crusher = data.raw["assembling-machine"]["crusher"]
    assert(crusher, "the Space Age crusher is missing")

    -- If the crusher ever gets a copy, this fixture no longer reproduces #39.
    assert(
        not data.raw["assembling-machine"]["bioluminescent-crusher"],
        "bioluminescent-crusher now exists; update next_upgrade_setup for #39"
    )

    local base = data.raw["assembling-machine"]["funit-steam-crusher"]
    assert(base, "funit-steam-crusher is missing")
    assert(base.next_upgrade == "crusher", "the fixture base should still upgrade to the crusher")
end)

results.check(SUITE, "copy-does-not-upgrade-to-excluded-crusher", function()
    local copy = data.raw["assembling-machine"]["bioluminescent-funit-steam-crusher"]
    assert(copy, "bioluminescent-funit-steam-crusher was not created")
    assert(
        copy.next_upgrade == nil,
        "copy upgrades to missing " .. tostring(copy.next_upgrade) .. " (issue #39)"
    )
end)

results.check(SUITE, "copy-keeps-an-upgrade-that-exists", function()
    local source = data.raw["assembling-machine"]["bioluminescent-funit-upgrade-source"]
    local target = data.raw["assembling-machine"]["bioluminescent-funit-upgrade-target"]
    assert(source, "bioluminescent-funit-upgrade-source was not created")
    assert(target, "bioluminescent-funit-upgrade-target was not created")
    assert(
        source.next_upgrade == "bioluminescent-funit-upgrade-target",
        "a copy that upgrades to another copy should keep that upgrade, got " .. tostring(source.next_upgrade)
    )
end)

results.check(SUITE, "every-next-upgrade-resolves", function()
    for type_name, entries in pairs(data.raw) do
        if type(entries) == "table" then
            for name, prototype in pairs(entries) do
                if type(prototype) == "table" and prototype.next_upgrade then
                    assert(
                        entries[prototype.next_upgrade],
                        type_name .. "." .. name .. " upgrades to missing " .. tostring(prototype.next_upgrade)
                    )
                end
            end
        end
    end
end)

-- When the test profile also loads Muluna, check the real machine from the
-- issue instead of only the fixture that imitates it.
if mods["planet-muluna"] then
    results.check(SUITE, "real-muluna-steam-crusher", function()
        local base = data.raw["assembling-machine"]["muluna-steam-crusher"]
        assert(base, "muluna-steam-crusher is missing although planet-muluna is active")
        assert(base.next_upgrade == "crusher", "muluna-steam-crusher should upgrade to the crusher")

        local copy = data.raw["assembling-machine"]["bioluminescent-muluna-steam-crusher"]
        assert(copy, "bioluminescent-muluna-steam-crusher was not created")
        assert(
            copy.next_upgrade == nil,
            "copy upgrades to missing " .. tostring(copy.next_upgrade) .. " (issue #39)"
        )
    end)
end
