# EternautaGame Bootstrap Implementation Plan

> **For Hermes:** Use spec-drive-development skill to implement this plan task-by-task.

**Goal:** Create a versioned, playable Godot 4 foundation for a 2D metroidvania that runs on Linux and is controller-first for Steam Deck.

**Architecture:** A Godot 4.6 GDScript project will use composition-oriented scenes (`Main`, `Player`, `TestArena`) and small typed scripts for player movement and health. Input actions remain semantic and configurable through Godot's InputMap. A deliberately small playable vertical slice proves controller movement, jumping, dash, attack, pause, and a Linux export path without committing to game narrative, art style, combat depth, or Steam integration yet.

**Tech Stack:** Godot 4.6 stable (pinned), GDScript, GUT 9.x for headless unit tests, gdtoolkit for formatting/linting, GitHub Actions for validation and Linux x86_64 export.

---

## Scope and acceptance criteria

### In scope
- Local git repository under `/home/hermes/development/eternautaGame`.
- Reproducible Godot editor/export-template bootstrap under `~/.local/opt` with a stable `godot` command in `~/.local/bin`.
- A controller-first Godot 4 project configured for 1280×800 (Steam Deck native) and Linux x86_64 export.
- A small placeholder-art playable test arena with movement, coyote-time jump, dash, attack pulse, a pause menu, keyboard fallback, and gamepad controls.
- Input, movement-rule, and health-rule unit tests run headlessly.
- A CI workflow to import, test, lint, and export Linux artifacts.
- Documentation for setup, controls, tests, export, and a manual Steam Deck QA checklist.

### Non-goals
- No Steamworks SDK, Steam store page, SteamPipe credentials, achievements, online features, final art, sound, map/content production, or full metroidvania progression system.
- No claim of Steam Deck Verified; hardware QA remains manual.

### Acceptance criteria
1. `godot --version` reports the pinned Godot version.
2. `godot --headless --path . --editor --quit` imports the project without parser errors.
3. GUT runs the unit suite headlessly and all tests pass.
4. The project exports a native Linux x86_64 debug build from committed export presets.
5. The game is playable locally with keyboard and controller-semantic input, including menus via controller.
6. CI configuration is present and syntactically reviewed; it is not claimed to have run until a remote repository exists.

---

### Task 1: Install and pin the Godot toolchain

**Objective:** Install one official Godot 4.6 stable Linux x86_64 editor and export templates in a deterministic user-scoped location.

**Files:**
- Create: `~/.local/opt/godot/4.6-stable/`
- Create: `~/.local/bin/godot` (symlink)
- Create: `docs/TOOLCHAIN.md`

**Step 1: Establish a failing precondition**

Run: `command -v godot`

Expected: no command installed (already observed during discovery).

**Step 2: Install the official editor and matching export templates**

Download the official Godot 4.6 stable Linux x86_64 archive and matching export templates into a temporary workspace, unpack under `~/.local/opt/godot/4.6-stable/`, install the templates where Godot expects them, then symlink the editor to `~/.local/bin/godot`.

**Step 3: Verify the install**

Run: `godot --version`

Expected: exact pinned `4.6.stable` version.

**Step 4: Document the toolchain**

Record version, locations, and upgrade procedure in `docs/TOOLCHAIN.md`.

---

### Task 2: Write tests for core player rules (RED)

**Objective:** Define testable, engine-light rules before gameplay implementation.

**Files:**
- Create: `tests/unit/test_player_motion.gd`
- Create: `tests/unit/test_player_health.gd`
- Create: `scripts/player/player_motion_rules.gd` (minimal placeholder only, if needed for parser)
- Create: `scripts/player/player_health.gd` (minimal placeholder only, if needed for parser)
- Create: `addons/gut/` (pinned GUT release)

**Step 1: Write failing motion tests**

Cover pure movement rules:
- horizontal acceleration approaches target speed without exceeding it;
- coyote timer permits a jump immediately after leaving floor;
- dash direction uses facing direction if input is neutral;
- dash cooldown prevents a second dash before expiry.

**Step 2: Write failing health tests**

Cover pure health rules:
- damage reduces health but cannot go below zero;
- invulnerability blocks repeated damage until it expires;
- healing cannot exceed maximum health.

**Step 3: Run tests to verify RED**

Run: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit`

Expected: failing tests because rule implementations do not exist or return placeholders.

---

### Task 3: Implement the minimal player-domain rules (GREEN)

**Objective:** Make the core player-rule tests pass with small typed GDScript classes.

**Files:**
- Modify: `scripts/player/player_motion_rules.gd`
- Modify: `scripts/player/player_health.gd`

**Step 1: Implement only the tested functions**

Use `RefCounted` classes with typed values, no scene-tree dependencies. Keep constants in named configuration values; no global mutable state.

**Step 2: Run the focused tests**

Run: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit`

Expected: all player-rule tests pass.

---

### Task 4: Configure the Godot project and semantic inputs

**Objective:** Establish controller-first display, renderer, and input defaults.

**Files:**
- Create: `project.godot`
- Create: `export_presets.cfg`
- Create: `scenes/app/main.tscn`
- Create: `scripts/app/main.gd`
- Create: `scripts/autoload/settings_service.gd`
- Create: `scripts/autoload/input_device_service.gd`
- Create: `icon.svg`

**Step 1: Add a smoke test first**

Create `tests/integration/test_main_scene.gd` to load `res://scenes/app/main.tscn`, assert it instantiates, and clean it up.

**Step 2: Verify RED**

Run the integration test via GUT. Expected: failure until the main scene exists.

**Step 3: Configure the project minimally**

- Pin feature tags for Godot 4.6.
- Set logical viewport to `1280×800`, stretch mode `canvas_items`, and aspect `expand`.
- Use Compatibility (`gl_compatibility`) rendering; no HDR/advanced effects by default.
- Define semantic keyboard/gamepad InputMap actions: movement, jump, dash, attack, interact, map, pause, accept/cancel, UI tabs.
- Configure controller deadzones between 0.20 and 0.25 for movement.
- Add Linux/X11 x86_64 debug and release export presets; make `build/` the ignored local output directory.

**Step 4: Verify GREEN**

Run headless import and the main-scene integration test. Expected: import and test pass.

---

### Task 5: Build the playable arena and player scene

**Objective:** Produce a local vertical slice that proves the platforming controls and gameplay shell.

**Files:**
- Create: `scenes/player/player.tscn`
- Create: `scripts/player/player_controller.gd`
- Create: `scenes/world/test_arena.tscn`
- Create: `scripts/world/test_arena.gd`
- Create: `scenes/ui/hud.tscn`
- Create: `scripts/ui/hud.gd`
- Create: `scenes/ui/pause_menu.tscn`
- Create: `scripts/ui/pause_menu.gd`
- Modify: `scenes/app/main.tscn`
- Modify: `scripts/app/main.gd`

**Step 1: Extend tests before scene implementation**

Add test coverage for the player controller's calls into `PlayerMotionRules` (neutral dash chooses facing direction; jump consumes coyote time). Keep tests focused on deterministic behavior, not animation/frame-perfect physics.

**Step 2: Verify RED**

Run the new focused tests. Expected: fail because the controller is not implemented.

**Step 3: Implement the smallest playable slice**

- `CharacterBody2D` player with collision shape and placeholder `Polygon2D` art.
- Accelerated left/right movement, coyote-time jumping, buffered jump, one directional dash, and an attack-pulse placeholder.
- Test arena made from simple `StaticBody2D` collision/platform shapes; no imported art dependency.
- HUD explaining current inputs and health; visible active-device mode.
- Controller-operable pause menu with Resume, Settings placeholder, and Quit to Desktop. Ensure focus is explicitly assigned when opened.
- Keep player/world state local to scenes; only settings/input device detection may be autoload services.

**Step 4: Verify GREEN**

Run GUT suite headlessly, then launch the game locally and manually validate keyboard play. If a controller is available in the environment, validate it too; otherwise leave the controller manual checklist as pending hardware validation.

---

### Task 6: Add repo hygiene, local commands, CI, and documentation

**Objective:** Make the scaffold maintainable for future development and testable on a clean Linux runner.

**Files:**
- Create: `.gitignore`
- Create: `.gitattributes`
- Create: `.editorconfig`
- Create: `Makefile`
- Create: `.github/workflows/ci.yml`
- Create: `README.md`
- Create: `docs/ARCHITECTURE.md`
- Create: `docs/STEAM_DECK_QA.md`
- Create: `docs/TOOLCHAIN.md`

**Step 1: Add command/documentation checks first**

Create a shell-level verification sequence that fails if required tracked files or export preset name are absent:

```bash
test -f project.godot
test -f export_presets.cfg
grep -Fq 'name="Linux x86_64"' export_presets.cfg
make test
```

**Step 2: Verify RED**

Run the guard before all documentation/hygiene files exist. Expected: failure.

**Step 3: Implement hygiene and automation**

- `.gitignore`: `.godot/`, `.import/`, `build/`, editor temp files, and GUT local reports.
- `Makefile`: `import`, `test`, `lint`, `format-check`, `export-linux-debug`, `export-linux-release`, `verify`.
- CI: install pinned Godot and GUT-compatible dependencies, import, lint/format check, test headlessly, and create a Linux debug export artifact.
- README: concise setup, control map, local run/test/export commands, scope/nongame-content boundary.
- Architecture doc: scene composition, service boundaries, input policy, and testing policy.
- Steam Deck QA doc: game-mode cold launch, controller-only navigation, suspend/resume, 1280×800 & 1280×720, rebind/settings persistence, and 30-minute performance check.

**Step 4: Verify GREEN**

Run:

```bash
make verify
make export-linux-debug
```

Expected: imports, tests, lint/format checks, and Linux x86_64 debug export pass locally.

---

### Task 7: Review, commit, and handoff

**Objective:** Ensure the new repository is coherent and ready for ongoing game work.

**Files:**
- Modify: all created project files only if review identifies an actual defect.

**Step 1: Fresh-context spec review**

Review the final diff against this plan. Block closure for missing controller paths, unpinned engine/addons, tests that never run headlessly, absent export presets, or misleading Steam Deck claims.

**Step 2: Code-quality review**

Review naming, scene/script boundaries, static analysis output, ignored generated files, and README reproducibility.

**Step 3: Final verification and commit**

Run from `/home/hermes/development/eternautaGame`:

```bash
git status --short
make verify
make export-linux-debug
git diff --check
git add .
git commit -m "feat: bootstrap Linux Steam Deck metroidvania"
```

Expected: only intentional tracked project files, green verification, one initial local commit.

---

## Risks and follow-ups

- The scaffold is Steam Deck-oriented but cannot demonstrate "Verified" without actual Deck/Game Mode QA and a Steam review.
- Compatibility rendering minimizes Linux risk for 2D; any later requirement for advanced 3D/Vulkan effects needs a deliberate renderer decision and target-hardware profiling.
- Godot editor/export templates must remain version-aligned. CI must use the same pinned version.
- Rebinding, glyph artwork, Steam Input integration, accessibility, saves/migrations, and real combat need product decisions in later milestones.
- The local repo will not be published remotely unless explicitly requested; remote visibility (private/public) must be chosen by the user.
