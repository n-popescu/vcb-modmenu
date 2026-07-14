# CLAUDE.md — agent context for `vcb-modmenu`

Read this first. Dense on purpose, for an AI coding agent. If it conflicts with the code, the
code wins — but verify before assuming this file is stale.

---

## 0. What this repo is

- The **public, open-source home of the runtime [Godot Mod Loader](https://github.com/GodotModding/godot-mod-loader)
  build** of the VCB **Mod Menu** — the in-game *Options ▸ Mods* list. It loads at runtime from
  the game's `mods/` folder and **never replaces `vcb.pck`**, so it coexists with other mods.
- It is **pure GDScript**. It adds a button + window and only *reads* the loader's registry — it
  contains **none of the original game's source**, which is why it's safe to publish here.
- It runs on the **original, closed-source VCB engine** (Godot 3.5.1). The native `Transistor*`
  classes are provided by the game at runtime; the editor's "unknown class" warning is EXPECTED.

## 1. ⚠️ THE ONE RULE: keep the copies in lockstep

The exact same mod payload lives in **two places**:

| Repo | Visibility | Contains |
|---|---|---|
| **`vcb-modmenu` (this)** | public | the runtime Mod Loader build (dev + release home) |
| `vcb-mp` (`mod-menu/`) | private | a copy kept alongside the multiplayer mod's builds |

> **Any functional change here MUST be mirrored into `vcb-mp/mod-menu/` in the same unit of work,
> and vice-versa. The `mods-unpacked/npopescu-ModMenu/` tree must stay byte-identical between the
> two.** (This repo's `build.sh` / `.github/` / `README` / `CLAUDE` are repo-level plumbing and
> differ; everything under `mods-unpacked/` is shared.)

**The launcher no longer vendors this mod.** The [vcb-launcher](https://github.com/n-popescu/vcb-launcher)
used to embed a copy under `vendor/mod-menu/`; it now **downloads this repo's latest release
asset (`npopescu-ModMenu.zip`) at runtime** and installs it into the game's `mods/` folder. So a
release here is what updates the Mod Menu for launcher users — no launcher rebuild, no third copy
to keep in sync.

**Versioning:** every functional change bumps `version_number` (semver) in
`mods-unpacked/npopescu-ModMenu/manifest.json` — in the same unit of work, and equal to
`vcb-mp/mod-menu/…/manifest.json`. A bump landing on `main` here auto-cuts a Release (which the
launcher then picks up). Keep `website_url` pointed at this repo so the Mod Menu can update-check
itself.

## 2. Layout

```
.github/workflows/build.yml   zips the package + auto-releases on version bump
build.sh                      → npopescu-ModMenu.zip
mods-unpacked/npopescu-ModMenu/
├── manifest.json             Mod Loader manifest (id = npopescu-ModMenu)
├── mod_main.gd               waits for Main, adds the Options ▸ Mods button + window; does NOT
│                             extend main.gd (that crashes the Mod Loader on this game)
└── scripts/
    └── mods_window.gd        master/detail Popup: mod list + details + GitHub update-check
```

The GitHub update-check compares each mod's installed version to its newest release. **The Godot
Mod Loader entry is special-cased** (`godot3_only`): the loader ships a Godot 3.x line (6.x) and a
Godot 4.x line (7.x+), and GitHub's "latest release" is the 4.x build — the wrong engine for this
Godot 3.5.1 game — so that entry fetches the whole `/releases` list and picks the newest release
with major `<= GODOT3_MAX_MAJOR` (see `_latest_godot3_tag`). The launcher's `modloader.rs` applies
the same Godot-3.x rule when it downloads/updates the loader baked into `vcb.pck`.

## 3. Engine / GDScript constraints

- **Godot 3.5.1**, GDScript 3.5 semantics — **not** Godot 4. No Godot-4 syntax.
- **Tabs, not spaces**, in every `.gd`. Quick check: `grep -nP '^\t* +\S' <file>` must be empty
  for lines you add.
- Do **not** extend `main.gd` (the main-scene root script) — it hard-crashes the Mod Loader on
  this game. Build nodes from `mod_main.gd` after the Main scene appears instead.
- Reference `C` / `E` as globals (always present). Look up `ModLoaderStore` / other mods'
  singletons via `get_node_or_null` — they may be absent — and guard every read.
- You **cannot run or parse-check GDScript** in CI here — review carefully and verify in-game
  (Options ▸ Mods). Mod Loader logs go to the game's `user://ModLoader.log`.

## 4. Git / PR workflow for agents

- Branch from `origin/main` (`git fetch origin main` first).
- **Branch names MUST start with `claude/` and END WITH the current session id**, or `git push`
  fails with HTTP 403. Example: `claude/<topic>-<sessionid>`.
- Commits are auto-signed (ssh). Don't disable signing/hooks.
- Open PRs against `main`; squash-merge. Note in the PR that it's unverified in-engine and give a
  test recipe. A merge to `main` that bumps `version_number` auto-cuts a Release.
