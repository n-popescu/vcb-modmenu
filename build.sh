#!/usr/bin/env bash
# Build the Mod Menu into a Godot Mod Loader .zip.
#
# The zip mounts into the game's res:// under mods-unpacked/, so the Mod Loader finds the mod at
# res://mods-unpacked/npopescu-ModMenu/. Drop the resulting zip into the game's
# mods/ folder (see the launcher's "Runtime modding" tab).
set -euo pipefail
cd "$(dirname "$0")"

OUT="npopescu-ModMenu.zip"
rm -f "$OUT"

# Zip the mods-unpacked/ tree so internal paths are exactly:
#   mods-unpacked/npopescu-ModMenu/manifest.json
#   mods-unpacked/npopescu-ModMenu/mod_main.gd
#   …
zip -r "$OUT" mods-unpacked \
	-x '*.DS_Store' -x '*/.*' >/dev/null

echo "Wrote $(pwd)/$OUT"
unzip -l "$OUT" | sed -n '1,40p'
