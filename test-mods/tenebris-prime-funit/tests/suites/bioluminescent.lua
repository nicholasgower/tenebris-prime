-- Runtime checks for the bioluminescent copies' upgrade chains (#39).
--
-- The data fixtures already assert the final prototype state. These tests read
-- the same state from the runtime prototypes table, so a successful game load
-- and the report itself prove the data stage accepted every next_upgrade.
--
-- At runtime next_upgrade is a LuaEntityPrototype reference rather than the
-- string used in the data stage, so the tests compare names.
local runner = require("__funit__.test_runner")

local function upgrade_name(prototype)
    local target = prototype.next_upgrade
    if target == nil then
        return nil
    end
    return target.name or tostring(target)
end

runner.test("BL-1 every next_upgrade names an existing entity", function()
    for name, prototype in pairs(prototypes.entity) do
        local target = upgrade_name(prototype)
        if target then
            runner.assert(
                prototypes.entity[target],
                name .. " upgrades to missing " .. tostring(target)
            )
        end
    end
end)

runner.test("BL-2 copy of a machine that upgrades to the crusher has no upgrade", function()
    local copy = prototypes.entity["bioluminescent-funit-steam-crusher"]
    runner.assert(copy, "bioluminescent-funit-steam-crusher is missing")
    runner.assert(
        upgrade_name(copy) == nil,
        "copy upgrades to missing " .. tostring(upgrade_name(copy)) .. " (issue #39)"
    )
end)

runner.test("BL-3 base machine keeps its upgrade", function()
    local base = prototypes.entity["funit-steam-crusher"]
    runner.assert(base, "funit-steam-crusher is missing")
    runner.assert(
        upgrade_name(base) == "crusher",
        "the base machine should still upgrade to the crusher, got " .. tostring(upgrade_name(base))
    )
end)

runner.test("BL-4 valid copy-to-copy upgrade is preserved", function()
    local source = prototypes.entity["bioluminescent-funit-upgrade-source"]
    runner.assert(source, "bioluminescent-funit-upgrade-source is missing")
    runner.assert(
        upgrade_name(source) == "bioluminescent-funit-upgrade-target",
        "a copy that upgrades to another copy should keep that upgrade, got " .. tostring(upgrade_name(source))
    )
end)

if script.active_mods["planet-muluna"] then
    runner.test("BL-5 real Muluna steam crusher copy has no upgrade", function()
        local copy = prototypes.entity["bioluminescent-muluna-steam-crusher"]
        runner.assert(copy, "bioluminescent-muluna-steam-crusher is missing")
        runner.assert(
            upgrade_name(copy) == nil,
            "copy upgrades to missing " .. tostring(upgrade_name(copy)) .. " (issue #39)"
        )
    end)
end
