# Tenebris Prime

Tenebris Prime is a Factorio 2.1 (Space Age) mod that adds the dark planet
Tenebris. It is written in Lua: most files define prototypes, and `control.lua`
holds runtime scripting.

## Layout

- `data.lua`, `data-updates.lua`, `data-final-fixes.lua` — prototype load stages.
  Respect the stage: patching another mod's prototypes usually belongs in
  `data-updates.lua` or `data-final-fixes.lua`, not `data.lua`.
- `prototypes/` — prototype definitions grouped by kind (`entity/`, `item/`,
  `recipe.lua`, `technology.lua`, `tile/`, `planet/`, ...).
- `compat/` — compatibility shims for other mods.
- `control.lua` — runtime scripting (events, surface setup).
- `settings.lua` — mod settings.
- `locale/<lang>/` — localization.
- `migrations/` — save migrations.
- `util.lua` — shared helpers.
- `test-mods/tenebris-prime-funit/` — development-only FUnit suite, excluded
  from release zips. See its README for the runner and fixtures.

## Conventions

- Indentation is 4 spaces. Match the style of the file you are editing.
- Reuse helpers from `util.lua` (for example `contains`, `flatten`) instead of
  duplicating logic.
- Prefer adjusting or extending existing prototypes over creating duplicates.
- New content needs an entry in `locale/en/` (for example `entity-name`,
  `entity-description`, `item-name`, `recipe-name`, `technology-name`).
- Every prototype referenced by name (recipe, item, technology, entity) must
  actually exist and be defined in the right load stage.
- README.md is intended to be read by players, so agents should not modify it.

## Commits and releases

This repository publishes with semantic-release and conventional commits. The
allowed commit types are defined in `.releaserc` and include `fix`, `feat`,
`feature`, `gui`, `balance`, `perf`, `compat`, `graphics`, `sound`, `locale`,
`translate`, `control`, `info`, and `other`. Use a message such as
`fix(scope): summary` or `balance: summary`.

- Do **not** edit `changelog.txt` or the `version` field in `info.json`; the
  release workflow generates those from commit messages.
- Only use a breaking change (`!` or a `BREAKING CHANGE:` footer) when it is
  truly required.

## Verification

The FUnit suite in `test-mods/tenebris-prime-funit/` runs headless against the
current worktree:

```sh
test-mods/tenebris-prime-funit/run.sh
```

Add `WITH_MULUNA=1 MULUNA_DIR=<checkout>` to also test against the real Muluna
machines. `DATA_ONLY=1` stops after the data stage.

- Check Lua syntax when a Lua compiler is available: `luac -p <file>`.
- Trace every referenced prototype name to its definition.
- Live-testing requires Factorio with Space Age and PlanetsLib; if that is not
  possible, state clearly what was and was not verified.
- Do not add mod dependencies to `info.json` unless the change requires it.
