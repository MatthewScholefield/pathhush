#!/bin/sh
set -eu
REPO="${PATHHUSH_REPO:-MatthewScholefield/pathhush}"
REF="${PATHHUSH_REF:-main}"
PREFIX="${PATHHUSH_PREFIX:-/usr/local}"
DEST="$PREFIX/bin/pathhush"
URL="https://raw.githubusercontent.com/$REPO/$REF/pathhush"

command -v curl >/dev/null 2>&1 || { printf 'Pathhush installer requires curl.\n' >&2; exit 1; }

tmp=$(mktemp "${TMPDIR:-/tmp}/pathhush.XXXXXX")
trap 'rm -f "$tmp"' EXIT HUP INT TERM
curl -fsSL "$URL" > "$tmp"
chmod +x "$tmp"

install_file() { mkdir -p "$(dirname "$DEST")"; cp "$tmp" "$DEST"; chmod 755 "$DEST"; }

if [ -w "$(dirname "$DEST")" ] 2>/dev/null; then
  install_file
elif [ "$(id -u)" -eq 0 ]; then
  install_file
elif command -v sudo >/dev/null 2>&1; then
  sudo mkdir -p "$(dirname "$DEST")"
  sudo cp "$tmp" "$DEST"
  sudo chmod 755 "$DEST"
else
  printf 'Cannot write %s and sudo is unavailable.\n' "$DEST" >&2
  printf 'Set PATHHUSH_PREFIX to a writable prefix, e.g. PATHHUSH_PREFIX="$HOME/.local".\n' >&2
  exit 1
fi

printf 'Installed %s\n' "$DEST"
"$DEST" init
printf '\nTry: pathhush create OPENAI_API_KEY --env .env\n'
