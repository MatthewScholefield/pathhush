#!/bin/sh
set -eu
ROOT=$(mktemp -d "${TMPDIR:-/tmp}/pathhush-test.XXXXXX")
trap 'chmod -R u+rwx "$ROOT" 2>/dev/null || true; rm -rf "$ROOT"' EXIT HUP INT TERM
export PATHHUSH_ROOT="$ROOT/vault"
export PATHHUSH_STATE_DIR="$ROOT/state"
BIN="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/pathhush"

"$BIN" init >/dev/null
VAULT="$PATHHUSH_ROOT/u$(id -u)"
[ -x "$VAULT" ] && [ -w "$VAULT" ]

if [ "$(id -u)" -ne 0 ]; then
  [ ! -r "$VAULT" ]
  if ls "$VAULT" >/dev/null 2>&1; then echo "FAIL: vault should not be listable" >&2; exit 1; fi
fi

OUT=$(printf '%s\n' 'test-secret-value' | "$BIN" create OPENAI_API_KEY --stdin)
PATH_VALUE=${OUT#OPENAI_API_KEY_FILE=}
[ -f "$PATH_VALUE" ]
[ "$(cat "$PATH_VALUE")" = 'test-secret-value' ]
[ "$("$BIN" path OPENAI_API_KEY)" = "$PATH_VALUE" ]
[ "$("$BIN" env OPENAI_API_KEY)" = "OPENAI_API_KEY_FILE=$PATH_VALUE" ]

ENVFILE="$ROOT/.env"
printf 'OTHER=value\n' > "$ENVFILE"
printf '%s\n' 'rotated-value' | "$BIN" create OPENAI_API_KEY --stdin --env "$ENVFILE" >/dev/null
NEW_PATH=$("$BIN" path OPENAI_API_KEY)
[ "$NEW_PATH" != "$PATH_VALUE" ]
[ ! -e "$PATH_VALUE" ]
[ "$(cat "$NEW_PATH")" = 'rotated-value' ]
grep -F "OPENAI_API_KEY_FILE=$NEW_PATH" "$ENVFILE" >/dev/null

"$BIN" remove OPENAI_API_KEY >/dev/null
[ ! -e "$NEW_PATH" ]
echo "All Pathhush tests passed."
