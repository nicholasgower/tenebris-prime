# tenebris-prime-funit

Development-only FUnit test suite for **tenebris-prime**. This companion mod is
not part of a normal install: `test-mods` is marked `export-ignore` in
`.gitattributes`, so it is excluded from release zips.

The suite has two parts:

1. **Data-stage fixtures** in `prototypes/fixtures/` inspect the final prototype
   set and record pass/fail results in the `tenebris-prime-funit-results`
   mod-data prototype. They are controlled by the
   `tenebris-prime-funit-enable-data-fixtures` startup setting (enabled by
   default); the runtime suite fails if it is disabled, so fixtures cannot be
   skipped silently.
2. **Runtime tests** in `tests/suites/` read those results and re-check the final
   prototypes through the runtime `prototypes` table.

`scenarios/__funit__tenebris/control.lua` starts FUnit, converts the recorded
data fixtures into FUnit tests, and loads every runtime suite in
`tests/manifest.lua`.

## What it covers

The first suite is the regression test for
[#39](https://github.com/nicholasgower/tenebris-prime/issues/39): a
bioluminescent copy kept its base's `next_upgrade`, prefixed with
`bioluminescent-`, even when the target had no copy. Muluna's
`muluna-steam-crusher` upgrades to `crusher`, which Tenebris Prime deliberately
leaves out of the copies, so the load failed with:

```text
Error in assignID: entity with name 'bioluminescent-crusher' does not exist.

At ROOT.assembling-machine.bioluminescent-muluna-steam-crusher.next_upgrade
```

The fixtures reproduce that shape without requiring Muluna
(`funit-steam-crusher` upgrades to `crusher`), then assert in
data-final-fixes that:

- the copy exists and its `next_upgrade` was cleared;
- the base machine still upgrades to the crusher;
- a copy-to-copy upgrade that does exist is preserved;
- every `next_upgrade` in the final prototype set names an existing entity.

If the fix is removed, the data stage aborts with the original error before
FUnit can run, so a successful run is already part of the regression test. With
the fix disabled, the fixture also reports the missing
`bioluminescent-crusher` explicitly.

When `planet-muluna` is active, the suite additionally checks the real
`muluna-steam-crusher` and its copy.

The second suite is the regression test for the Heat Management conflict with
TFMG Thermal's radiators. TFMG Thermal makes `ground-radiator` with the fixed
recipe `TFMG-heat-radiation` in the `radiator` category. Heat Management, in
data-updates, clears that fixed recipe and moves the radiator to the
`radiator-coolant` category with fluid boxes. Tenebris Prime had already copied
the radiator, and its data-final-fixes took only the new categories, so the
copy kept a fixed recipe its categories no longer allowed:

```text
Error while running setup for entity prototype "bioluminescent-ground-radiator" (assembling-machine):
fixed_recipe="TFMG-heat-radiation" cannot be used on this machine. Reason=DifferentCategory
```

The fixtures reproduce that shape without requiring either mod. A fixture
machine is made in data.lua with a fixed recipe, a data-updates fixture then
clears it and changes the categories and fluid boxes, and data-final-fixes
asserts that:

- the copy no longer has the fixed recipe its base dropped;
- the copy takes the categories and fluid boxes of its base;
- every bioluminescent copy with a fixed recipe allows a category of that recipe.

If the fix is removed, the data stage aborts with the error above before FUnit
can run.

## Running

From the repository root:

```sh
test-mods/tenebris-prime-funit/run.sh
```

To also run the real Muluna checks:

```sh
WITH_MULUNA=1 MULUNA_DIR=/path/to/planet-muluna test-mods/tenebris-prime-funit/run.sh
```

To stop after the data stage (faster when editing fixtures):

```sh
DATA_ONLY=1 test-mods/tenebris-prime-funit/run.sh
```

The runner is headless and self-contained:

- links the **current worktree** as `tenebris-prime` (not the installed mod);
- links `PlanetsLib` and `funit` from `FACTORIO_MODS`;
- writes a scratch mod directory, config and logs under `TMP_ROOT`;
- disables server auto-pause so FUnit can advance ticks without a player;
- detects whether the Factorio binary supports `--disable-audio`, so it works
  with both the full client and the dedicated headless server build;
- stops Factorio after FUnit prints `====END====`;
- exits non-zero on any FUnit `FAILURE` or `ERROR`.

Useful environment variables:

| Variable | Default | Meaning |
| --- | --- | --- |
| `FACTORIO_BIN` | `/opt/factorio_space_age_21/bin/x64/factorio` | Factorio executable |
| `FACTORIO_MODS` | `/opt/factorio_space_age_21/mods` | Directory containing dependency mods |
| `WITH_MULUNA` | `0` | Also load `planet-muluna` and its dependencies |
| `MULUNA_DIR` | `../planet-muluna` when it exists | planet-muluna checkout for `WITH_MULUNA=1` |
| `TMP_ROOT` | `/tmp/opencode/tenebris-funit` | Scratch mod directory, config and logs |
| `TIMEOUT` | `900` | Seconds to wait for `====END====` |
| `FACTORIO_PORT` | `34199` | Local server port used by the headless instance |
| `DATA_ONLY` | `0` | Run `--dump-data` instead of the scenario |

The full log is `$TMP_ROOT/stdout.log`; on failure the runner prints the
relevant FUnit lines and the tail of the log.

## Requirements

- Factorio 2.1 with Space Age.
- The `funit` mod.
- `PlanetsLib`.
- For `WITH_MULUNA=1`: a `planet-muluna` checkout plus its dependencies
  (`muluna-graphics`, `flib`, `bplib`, `rigor-module`,
  `item-request-proxy-events`, `module-category-defaults`, the
  space-exploration graphics mods and `alien-biomes-graphics`).
- `factorio` must be able to bind `FACTORIO_PORT` (or set another port).

The scenario is started with:

```text
--start-server-load-scenario tenebris-prime-funit/__funit__tenebris
```

## Layout

```text
info.json, settings.lua     companion-mod metadata and fixture setting
data.lua                    creates the result bag, runs data.lua fixtures
data-updates.lua            runs data-updates fixtures (after Tenebris Prime's copy pass)
data-final-fixes.lua        data-final-fixes fixtures (after Tenebris Prime)
prototypes/fixtures/        prototype-level checks, grouped by feature
lib/results.lua             records fixture results in mod-data
scenarios/__funit__tenebris/FUnit scenario entry point
tests/manifest.lua          runtime suite load order
tests/suites/               runtime behavioral suites
run.sh                      headless runner
```

## Adding a test

1. **Prototype-only check:** add `results.check("suite", "id", function() ... end)`
   to a file in `prototypes/fixtures/` and list it in that stage's array in
   `prototypes/fixtures/manifest.lua`.
2. **Runtime behavior:** add a suite under `tests/suites/`, register it in
   `tests/manifest.lua`, and use `runner.test` / `runner.assert`.
3. Fixtures that **define** prototypes must run in `data.lua` so
   tenebris-prime's data-updates pass (which copies machines added by later
   mods) sees them. A fixture that changes such a machine afterwards, the way a
   mod changes its own prototypes in data-updates, belongs in `data-updates.lua`.
   Assertions about the final state belong in `data-final-fixes.lua`, after
   tenebris-prime's own final fixes.
4. Prefix every test prototype with `funit-`, and verify the suite passes both
   with and without `WITH_MULUNA=1` before opening a pull request.

## CI

The runner works locally with the installed game. It is not wired into GitHub
Actions yet: downloading dependencies from the mod portal needs a Factorio
**player** token, which is separate from the ModPortal upload key used by the
release workflow.
