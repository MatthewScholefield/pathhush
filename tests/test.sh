#!/bin/sh
set -eu

ROOT=$(mktemp -d "${TMPDIR:-/tmp}/pathhush-test.XXXXXX")
trap 'chmod -R u+rwx "$ROOT" 2>/dev/null || true; rm -rf "$ROOT"' EXIT HUP INT TERM
export PATHHUSH_ROOT="$ROOT/vault"
BIN="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/pathhush"

"$BIN" init >/dev/null
VAULT="$PATHHUSH_ROOT/u$(id -u)"
[ -x "$VAULT" ] && [ -w "$VAULT" ]

if [ "$(id -u)" -ne 0 ]; then
  [ ! -r "$VAULT" ]
  if ls "$VAULT" >/dev/null 2>&1; then
    echo "FAIL: vault should not be listable" >&2
    exit 1
  fi
fi

PATH_VALUE=$(printf '%s\n' 'test-secret-value' | "$BIN" create OPENAI_API_KEY --stdin 2>/dev/null)
[ -f "$PATH_VALUE" ]
[ "$(cat "$PATH_VALUE")" = 'test-secret-value' ]

ARG_PATH=$("$BIN" create ARG_SECRET "from-argument" 2>/dev/null)
[ "$(cat "$ARG_PATH")" = 'from-argument' ]

ENVFILE="$ROOT/.env"
printf 'OTHER=value\n' > "$ENVFILE"
ENV_PATH=$(printf '%s\n' 'env-value' | "$BIN" create ENV_SECRET --stdin --env-file "$ENVFILE" 2>/dev/null)
grep -F "ENV_SECRET_FILE=$ENV_PATH" "$ENVFILE" >/dev/null

if [ "$(id -u)" -ne 0 ]; then
  if "$BIN" list >/dev/null 2>&1; then echo "FAIL: list should require root" >&2; exit 1; fi
  if "$BIN" remove OPENAI_API_KEY >/dev/null 2>&1; then echo "FAIL: remove should require root" >&2; exit 1; fi
fi

if "$BIN" path OPENAI_API_KEY >/dev/null 2>&1; then echo "FAIL: path command should not exist" >&2; exit 1; fi
if "$BIN" env OPENAI_API_KEY >/dev/null 2>&1; then echo "FAIL: env command should not exist" >&2; exit 1; fi

# Root CI can exercise administrative enumeration/removal directly.
if [ "$(id -u)" -eq 0 ]; then
  "$BIN" list | grep -F "$(basename "$PATH_VALUE")" >/dev/null
  "$BIN" remove OPENAI_API_KEY >/dev/null
  [ ! -e "$PATH_VALUE" ]
fi

echo "All Pathhush tests passed."
