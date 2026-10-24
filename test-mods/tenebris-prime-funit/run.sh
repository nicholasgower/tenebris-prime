#!/usr/bin/env bash
# Headless FUnit runner for tenebris-prime.
#
# Usage:
#   test-mods/tenebris-prime-funit/run.sh
#   WITH_MULUNA=1 test-mods/tenebris-prime-funit/run.sh
#
# Environment:
#   FACTORIO_BIN   Factorio executable (default: /opt/factorio_space_age_21/bin/x64/factorio)
#   FACTORIO_MODS  Source mod directory containing dependencies
#   MULUNA_DIR     planet-muluna checkout used when WITH_MULUNA=1
#   WITH_MULUNA    Set to 1 to run the real Muluna compatibility checks
#   TMP_ROOT       Scratch directory (default: /tmp/opencode/tenebris-funit)
#   TIMEOUT        Maximum run time in seconds (default: 900)
#   DATA_ONLY      Set to 1 to run --dump-data instead of the FUnit scenario
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

FACTORIO_BIN="${FACTORIO_BIN:-/opt/factorio_space_age_21/bin/x64/factorio}"
FACTORIO_MODS="${FACTORIO_MODS:-/opt/factorio_space_age_21/mods}"
MULUNA_DIR="${MULUNA_DIR:-}"
WITH_MULUNA="${WITH_MULUNA:-0}"
TMP_ROOT="${TMP_ROOT:-/tmp/opencode/tenebris-funit}"
TIMEOUT="${TIMEOUT:-900}"
FACTORIO_PORT="${FACTORIO_PORT:-34199}"
DATA_ONLY="${DATA_ONLY:-0}"

if [[ ! -x "$FACTORIO_BIN" ]]; then
  echo "Factorio binary not found: $FACTORIO_BIN" >&2
  exit 1
fi
if [[ ! -d "$FACTORIO_MODS" ]]; then
  echo "Factorio mod directory not found: $FACTORIO_MODS" >&2
  exit 1
fi

rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT/mods" "$TMP_ROOT/write-data/script-output" "$TMP_ROOT/write-data/saves"

link_mod() {
  local name="$1"
  local source="$2"
  if [[ ! -e "$source" ]]; then
    echo "Required dependency missing: $source" >&2
    exit 1
  fi
  ln -sfn "$source" "$TMP_ROOT/mods/$name"
}

# Newest matching zip for dependencies that are distributed as zips.
link_zip() {
  local pattern="$1"
  local source
  source="$(find "$FACTORIO_MODS" -maxdepth 1 -name "$pattern" -type f | sort -V | tail -n 1)"
  if [[ -z "$source" ]]; then
    echo "Required dependency missing: $pattern" >&2
    exit 1
  fi
  ln -sfn "$source" "$TMP_ROOT/mods/$(basename "$source")"
}

# PlanetsLib and funit may be installed as a directory or as a zip.
link_planetslib() {
  if [[ -d "$FACTORIO_MODS/PlanetsLib" ]]; then
    link_mod "PlanetsLib" "$FACTORIO_MODS/PlanetsLib"
  else
    link_zip 'PlanetsLib_*.zip'
  fi
}

link_mod "tenebris-prime" "$REPO_DIR"
link_mod "tenebris-prime-funit" "$SCRIPT_DIR"
link_planetslib
link_zip 'funit_*.zip'

MOD_NAMES=(
  base elevated-rails quality recycler space-age
  tenebris-prime tenebris-prime-funit funit PlanetsLib
)

if [[ "$WITH_MULUNA" == "1" ]]; then
  if [[ -z "$MULUNA_DIR" ]]; then
    if [[ -d "$REPO_DIR/../planet-muluna" ]]; then
      MULUNA_DIR="$REPO_DIR/../planet-muluna"
    else
      echo "Set MULUNA_DIR to a planet-muluna checkout to run WITH_MULUNA=1." >&2
      exit 1
    fi
  fi

  link_mod "planet-muluna" "$MULUNA_DIR"
  link_mod "muluna-graphics" "$FACTORIO_MODS/muluna-graphics"
  link_zip 'flib_*.zip'
  link_zip 'bplib_*.zip'
  link_zip 'rigor-module_*.zip'
  link_zip 'item-request-proxy-events_*.zip'
  link_zip 'module-category-defaults_*.zip'
  link_zip 'space-exploration-graphics_*.zip'
  link_zip 'space-exploration-graphics-4_*.zip'
  link_zip 'space-exploration-graphics-5_*.zip'
  link_zip 'alien-biomes-graphics_*.zip'

  for name in planet-muluna muluna-graphics flib bplib rigor-module \
    item-request-proxy-events module-category-defaults space-exploration-graphics \
    space-exploration-graphics-4 space-exploration-graphics-5 alien-biomes-graphics; do
    MOD_NAMES+=("$name")
  done
fi

{
  echo '{'
  echo '  "mods": ['
  for i in "${!MOD_NAMES[@]}"; do
    comma=","
    if [[ "$i" -eq $((${#MOD_NAMES[@]} - 1)) ]]; then
      comma=""
    fi
    echo "    { \"name\": \"${MOD_NAMES[$i]}\", \"enabled\": true }$comma"
  done
  echo '  ]'
  echo '}'
} > "$TMP_ROOT/mods/mod-list.json"

SERVER_SETTINGS_EXAMPLE="$(dirname "$FACTORIO_BIN")/../../data/server-settings.example.json"
if [[ -f "$SERVER_SETTINGS_EXAMPLE" ]]; then
  sed 's/"auto_pause": true/"auto_pause": false/' "$SERVER_SETTINGS_EXAMPLE" > "$TMP_ROOT/server-settings.json"
else
  cat > "$TMP_ROOT/server-settings.json" <<'JSON'
{
  "name": "tenebris-prime FUnit",
  "description": "Headless tenebris-prime FUnit run",
  "max_players": 1,
  "visibility": { "public": false, "lan": false },
  "auto_pause": false,
  "auto_pause_when_players_connect": false,
  "autosave_interval": 0
}
JSON
fi

cat > "$TMP_ROOT/config.ini" <<EOF
; version=13
[path]
read-data=__PATH__executable__/../../data
write-data=$TMP_ROOT/write-data

[general]
locale=en

[other]
; verbose-logging=false
EOF

LOG="$TMP_ROOT/stdout.log"
if [[ "$DATA_ONLY" == "1" ]]; then
  echo "Running Tenebris Prime data-stage probe..."
  echo "  binary: $FACTORIO_BIN"
  echo "  mods:   $TMP_ROOT/mods"
  echo "  log:    $LOG"

  set +e
  if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT}s" "$FACTORIO_BIN" \
      --config "$TMP_ROOT/config.ini" \
      --mod-directory "$TMP_ROOT/mods" \
      --dump-data \
      --no-log-rotation \
      >"$LOG" 2>&1
  else
    "$FACTORIO_BIN" \
      --config "$TMP_ROOT/config.ini" \
      --mod-directory "$TMP_ROOT/mods" \
      --dump-data \
      --no-log-rotation \
      >"$LOG" 2>&1
  fi
  FACTORIO_STATUS=$?
  set -e

  if [[ "$FACTORIO_STATUS" -ne 0 ]]; then
    echo "Data-stage probe failed (Factorio exit $FACTORIO_STATUS)." >&2
    tail -n 80 "$LOG" >&2 || true
  fi
  exit "$FACTORIO_STATUS"
fi

echo "Running Tenebris Prime FUnit suite..."
echo "  binary: $FACTORIO_BIN"
echo "  mods:   $TMP_ROOT/mods"
echo "  muluna: $WITH_MULUNA"
echo "  log:    $LOG"

# The dedicated headless server build has no audio subsystem and rejects
# --disable-audio, while the full client accepts it. Only pass the flag when
# the binary advertises it so the same runner works with either install.
FACTORIO_ARGS=(
  --config "$TMP_ROOT/config.ini"
  --mod-directory "$TMP_ROOT/mods"
  --start-server-load-scenario tenebris-prime-funit/__funit__tenebris
  --port "$FACTORIO_PORT"
  --server-settings "$TMP_ROOT/server-settings.json"
  --no-log-rotation
)
if "$FACTORIO_BIN" --help 2>&1 | grep -q -- '--disable-audio'; then
  FACTORIO_ARGS+=(--disable-audio)
fi

set +e
"$FACTORIO_BIN" \
  "${FACTORIO_ARGS[@]}" \
  >"$LOG" 2>&1 &
FACTORIO_PID=$!
set -e

finished=0
for ((i = 0; i < TIMEOUT; i++)); do
  if grep -q '====END====' "$LOG" 2>/dev/null; then
    finished=1
    break
  fi
  if ! kill -0 "$FACTORIO_PID" 2>/dev/null; then
    break
  fi
  sleep 1
done

if kill -0 "$FACTORIO_PID" 2>/dev/null; then
  kill "$FACTORIO_PID" 2>/dev/null || true
fi
wait "$FACTORIO_PID" 2>/dev/null || true

if [[ ! -f "$LOG" ]]; then
  echo "No Factorio log was produced at $LOG." >&2
  exit 1
fi

if [[ "$finished" -ne 1 ]]; then
  echo "FUnit did not reach ====END==== within ${TIMEOUT}s." >&2
  grep -nE '__FUNIT__|Error|error|FAILURE|ERROR' "$LOG" | tail -n 80 >&2 || true
  tail -n 80 "$LOG" >&2 || true
  exit 1
fi

if grep -qE '__FUNIT__.*(FAILURE__|ERROR__)' "$LOG"; then
  echo "FUnit reported failures:" >&2
  grep -nE '__FUNIT__.*(FAILURE__|ERROR__)' "$LOG" >&2
  exit 1
fi

echo "FUnit suite passed."
grep -oE '__FUNIT__[^ ]*====BEGIN [0-9]+ TESTS====' "$LOG" | tail -n 1 || true
grep -c '__FUNIT__.*SUCCESS__' "$LOG" | sed 's/^/SUCCESS lines: /' || true
