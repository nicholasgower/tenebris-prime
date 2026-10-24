-- Reproduces the prototype shape of issue #39 without requiring Muluna.
--
-- Muluna's "muluna-steam-crusher" is an assembling machine that upgrades to
-- the Space Age "crusher". Tenebris Prime deliberately leaves the crusher out
-- of its bioluminescent copies, so prefixing the upgrade target produced a
-- copy that pointed at a "bioluminescent-crusher" that does not exist and the
-- game refused to load.
--
-- These fixtures are made in data.lua so that tenebris-prime's data-updates
-- pass (which copies machines added by mods that load after Tenebris Prime)
-- sees them, exactly as it sees Muluna's machine.

local crusher = data.raw["assembling-machine"]["crusher"]
local crusher_item = data.raw["item"]["crusher"]

assert(crusher, "tenebris-prime-funit needs the Space Age crusher prototype")
assert(crusher_item, "tenebris-prime-funit needs the Space Age crusher item")

local function make_machine(name, next_upgrade)
    local entity = table.deepcopy(crusher)
    entity.name = name
    entity.localised_name = { "entity-name.crusher" }
    entity.minable = { mining_time = 0.2, result = name }
    entity.next_upgrade = next_upgrade
    -- Factorio requires an upgrade target in the same fast-replace group. The
    -- copy of the crusher keeps the crusher's group, as Muluna's machine does.

    local item = table.deepcopy(crusher_item)
    item.name = name
    item.localised_name = { "item-name.crusher" }
    item.place_result = name
    item.order = "z[funit-" .. name .. "]"

    data:extend({ entity, item })
end

-- The Muluna shape: a machine that upgrades to the excluded crusher.
make_machine("funit-steam-crusher", "crusher")

-- A chain between two machines that both get copies. The fix must keep this
-- upgrade instead of clearing every next_upgrade on a copy.
make_machine("funit-upgrade-target", nil)
make_machine("funit-upgrade-source", "funit-upgrade-target")
