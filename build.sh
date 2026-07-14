#!/usr/bin/env bash
# Build the Mod Menu into a Godot Mod Loader .zip. Drop the result into the game's mods/
# folder (runtime modding must be enabled — see the vcb-launcher "Runtime modding" tab).
set -euo pipefail
cd "$(dirname "$0")"

OUT="npopescu-ModMenu.zip"
rm -f "$OUT"
zip -r "$OUT" mods-unpacked -x '*.DS_Store' -x '*/.*' >/dev/null

echo "Wrote $(pwd)/$OUT"
unzip -l "$OUT"
