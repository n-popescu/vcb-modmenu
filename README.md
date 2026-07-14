# VCB Mod Menu — an in-game "installed mods" list

A small **runtime [Godot Mod Loader](https://github.com/GodotModding/godot-mod-loader) mod** for
[Virtual Circuit Board](https://store.steampowered.com/app/1885690/Virtual_Circuit_Board/) that
adds a **Mods** button to the game's **Options** menu (next to Fullscreen / Settings / Shortcuts
/ Changelog). Clicking it opens a stock-styled window that lists every mod the loader has loaded.

A clickable left column shows each mod's **name, version and author**; selecting one expands its
**details** on the right — description, repository URL (with an **Open repository** button),
dependencies, and an **update-available** check against the mod's GitHub releases. It only
*reads* the loader's registry; it changes nothing.

This is the **open-source home of the Mod Menu**. It's the same package the
[vcb-launcher](https://github.com/n-popescu/vcb-launcher) installs for you — the launcher fetches
this repo's **latest release** at runtime, so updating the Mod Menu is just a new release here (no
launcher rebuild).

## Install & run

The easiest path is the launcher — enable **Runtime modding** in the
[vcb-launcher](https://github.com/n-popescu/vcb-launcher) and it drops the latest Mod Menu into
the game's `mods/` folder for you. To install it by hand:

1. Enable **Runtime modding** in the launcher (patches `vcb.pck` once with the Mod Loader).
2. Grab `npopescu-ModMenu.zip` from the
   [latest release](https://github.com/n-popescu/vcb-modmenu/releases/latest), or build it
   yourself: `./build.sh`.
3. Drop that zip into the game's `mods/` folder (**📁 Mods folder** in the launcher) and
   **▶ Launch game**.
4. In-game: **Options ▸ Mods**.

## How it works

```
mods-unpacked/npopescu-ModMenu/
├── manifest.json        Mod Loader manifest (id = npopescu-ModMenu)
├── mod_main.gd          waits for the scene, then adds the button + window
└── scripts/
    └── mods_window.gd   the master/detail Popup that lists the mods + checks for updates
```

- **`mod_main.gd`** waits (in `_process`) for the Main scene, then adds a **Mods** `Button`
  (with the game's `FluxModButton` hover styling) to the Options button column, plus a
  `ModsWindow` on the GUI layer, and wires the button to open it. It also suffixes the header
  version readout with `-modded` so a successful load is visible at a glance. It does **not**
  extend the main-scene root script (`main.gd`) — extending the main scene's script crashes the
  Mod Loader on this game.
- **`scripts/mods_window.gd`** is a `Popup` styled like the game's built-in dialogs. On open it
  reads `ModLoaderStore.mod_data` and builds one clickable entry per mod (plus the Mod Loader
  itself). Selecting one shows its details; for any mod whose manifest `website_url` is a
  `github.com/<owner>/<repo>` URL it queries `api.github.com/repos/<owner>/<repo>/releases/latest`
  and compares the tag to the installed version. All reads are guarded and every failure is
  graceful.

## Building

```bash
./build.sh          # → npopescu-ModMenu.zip
```

CI (`.github/workflows/build.yml`) builds the zip on every push/PR and **auto-publishes a GitHub
Release** when `version_number` in `mods-unpacked/npopescu-ModMenu/manifest.json` is bumped on
`main` (version-gated). A manual `v*` tag push also publishes. The launcher downloads the latest
release asset, so a bump here is what updates the Mod Menu for everyone.

## Caveat — needs on-device testing

There's **no Godot binary in CI**, so this GDScript can't be run/parse-checked automatically; it
was written to the game's own UI patterns and reviewed. Verify in-game (**Options ▸ Mods**) that
the list shows every installed mod with its details and the update-check line.
