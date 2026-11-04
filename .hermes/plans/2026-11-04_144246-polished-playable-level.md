# Polished Playable Level Implementation Plan

> **For Hermes:** Use `spec-drive-development` task-by-task. Keep one writer, enforce RED → GREEN for every behavioral change, and review each milestone against this plan and visual captures.

**Goal:** Replace the current diagram-like prototype with one short, coherent 2D side-scrolling level: a readable chalet → dangerous snowy street → warm shelter and R-1 → physical safe/shortcut choice → route-specific ending.

**Architecture:** Preserve the deterministic `ChaletProgression`, `SurvivalState`, real-input QA, and no-combat scope. Recompose the existing `Chalet` and `VicenteLopezNorte` scenes around camera-driven segments, reusable atlas-region presentation helpers, contextual interactable affordances, and a compact Spanish HUD. Keep `Main` as scene-level coordinator, but move static art composition out of `_render_background()` and into authored scene nodes/components.

**Tech stack:** Godot 4.7, GDScript, GUT 9.7.1, vendored Godot QA, Kenney Platformer Art: Pixel Redux (`CC0 1.0`).

---

## Confirmed product contract

- Format: one polished **2D side-scrolling level**, not a top-down conversion and not a multi-level campaign.
- Visual direction: atmospheric narrative pixel art with clear warm/cold contrast.
- Player route: chalet preparation → snowy exterior → R-1 → shelter/route decision → terminal consequence.
- Core choice: the **covered route** is only physically available after entering the shelter and preserves the spare filter; the **exposed shortcut** consumes it once.
- Presentation must make locations and interactables understandable without room maps, permanent debug labels, or terms such as `Slice`.
- Non-goals: combat, enemies, generic inventory, procedural maps, downloadable art packs, audio systems, respawn/checkpoint systems, and campaign expansion.

## Evidence that drives the scope

- `scenes/world/chalet.tscn` is a 1280-wide floor with seven room-description labels rather than a place.
- `scenes/world/vicente_lopez_norte.tscn` is a stretched snow atlas tile and a linear row of radio/shelter/exits.
- `scripts/app/main.gd:_render_background()` stretches a single atlas rect across the full viewport.
- `scenes/ui/hud.tscn` exposes `SliceStateLabel` and a permanent controls legend.
- All current presentation uses the one CC0 atlas at `assets/kenney/characters/spritesheet.png`; no new pack is required.
- The atlas is RGB without alpha and has hand-authored `Rect2` regions. Pixel-art composition must use nearest filtering, integer scales, and avoid assuming transparent backgrounds.

## Visual acceptance criteria

1. A graphical capture of the chalet reads as a warm, enclosed interior with visible zones/props, a lit worktable, a window/door and people-like silhouettes; it must not show `RoomLabels` or `Slice:`.
2. A graphical capture of the exterior reads as a cold snowy street with layered depth, a visible chalet origin, a recognizable R-1 landmark, and a structurally visible warm shelter.
3. The player is legible against both interior and snow backgrounds and visibly changes when the insulated suit is fabricated.
4. Each collectable has a distinct visual/contextual identity; the radio, worktable, shelter, shortcut, and covered route are distinguishable before interaction.
5. Safe and shortcut paths occupy distinct, physical route segments. The safe route cannot complete before the player has entered the shelter.
6. Terminal presentation and text explain the actual outcome: safe route/filter kept, shortcut/filter spent, lethal exposure, or south exit.
7. GUT, all four input QA routes, import, export and a new recorded graphical demo pass from a clean worktree.

## Task 1: Lock presentation and route contracts before moving art

**Objective:** Capture the new public scene and behavior contracts with tests before changing scenes.

**Files:**
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/integration/test_survival_presentation.gd`
- Modify: `tests/qa/chalet_vn.json`
- Modify: `tests/qa/chalet_vn_shortcut.json`
- Modify: `tests/qa/chalet_vn_lethal.json`
- Modify: `tests/qa/chalet_vs.json` only if the south terminal presentation changes

**Step 1: Write failing integration contracts.**
- Assert `Player/Camera2D`, a `Chalet/Presentation` root, and an exterior presentation root exist.
- Assert `HUD/SliceStateLabel` and permanent controls text do not exist.
- Assert the chalet has no `RoomLabels` root and retains all existing gameplay node paths/groups used by QA.
- Assert `VicenteLopezNorte` exposes distinct visual nodes for shelter structure, R-1 landmark, covered route and shortcut.
- Assert fabricating the suit changes a visible player presentation state.
- Assert safe-route completion is rejected until `in_shelter` has been true at least once after R-1.
- Assert each terminal title/subtitle identifies its consequence.

**Step 2: Run RED.**
```bash
make import
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -ginclude_subdirs -gexit
```
Expected: focused contract failures for missing camera/presentation roots, legacy HUD/debug nodes, missing shelter prerequisite and generic terminal copy.

**Step 3: Keep all existing progression contracts.**
Do not relax `ChaletProgression` or survival unit tests merely to fit new art. Add only the narrow state necessary to remember that shelter has been reached.

**Step 4: Commit the red contract.**
```bash
git add tests/integration tests/qa
git commit -m "test: define polished level presentation contract"
```

## Task 2: Create reusable pixel-art presentation primitives

**Objective:** Stop scattering ambiguous atlas rects and non-integer stretched sprites across scenes.

**Files:**
- Create: `scripts/presentation/pixel_atlas.gd`
- Create: `tests/unit/test_pixel_atlas.gd`
- Create: `scenes/presentation/pixel_prop.tscn` only if a small reusable scene improves authored composition
- Modify: `scenes/player/player.tscn`

**Step 1: Write failing unit tests.**
Test stable named atlas regions for player, suited-player overlay/variant, worktable, radio landmark, door/window, snow ground, roof, interior wall/furniture, shelter facade, and route marker. Test that every declared region has positive dimensions and uses integer render scale policy.

**Step 2: Run RED.**
```bash
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
```
Expected: test script executes and fails because `PixelAtlas` does not exist.

**Step 3: Implement the smallest data-only atlas catalog.**
- Use named `Rect2i`/`Rect2` constants and narrow constructors for `AtlasTexture`/sprite regions.
- Preserve `TEXTURE_FILTER_NEAREST` and use only integer sprite scales in new composition.
- Do not create a generalized tile engine; this is a small curated catalog for this level.

**Step 4: Run GREEN and update the player scene.**
- Keep `Player/Visual` and collision paths stable.
- Add a suited visual child or overlay that can be toggled by `Main` without replacing player physics.

**Step 5: Commit.**
```bash
git add scripts/presentation scenes/player tests/unit
git commit -m "feat: add reusable pixel presentation catalog"
```

## Task 3: Turn the chalet into a readable warm opening segment

**Objective:** Make preparation feel like movement through an inhabited refuge rather than a labeled checklist.

**Files:**
- Modify: `scenes/world/chalet.tscn`
- Modify: `scenes/world/suit_material.tscn`
- Modify: `scenes/world/fabrication_station.tscn`
- Modify: `scenes/world/suit_exit.tscn`
- Modify: `scripts/world/suit_material.gd` only for narrow visual state/configuration
- Modify: `scripts/world/fabrication_station.gd` only for narrow visual state/configuration
- Modify: `scripts/app/main.gd`
- Modify: `tests/integration/test_main_scene.gd`

**Step 1: Write failing scene contracts.**
Assert three different material visual roles and a light/visual state on fabrication. Assert fabrication toggles the suited player visual and updates the worktable state without changing progression semantics.

**Step 2: Run RED.**
Run the targeted integration test file and preserve the failing output.

**Step 3: Compose the scene.**
- Remove `RoomLabels`; replace them with authored wall/floor/roof strips, windows, interior furniture, a door, and static family/Favalli silhouettes using the existing atlas.
- Retain existing gameplay roots: `MaterialLona`, `MaterialSelladoGuantes`, `MaterialMascaraFiltro`, `FavalliFabrication`, `ExitVN`, `ExitVS`.
- Give materials distinct silhouette/color/context (kitchen fabric, tools/gloves, elevated mask/filter); keep free-order collection behavior.
- Make Favalli’s station the dominant warm focal point after all materials are collected.
- Add a `Camera2D` as a child of `Player`; size the authored layout wider than a static viewport only if the current movement and QA remain tractable.
- Remove `_render_background()` once its replacement is authored in the scene.

**Step 4: Run GREEN and capture the graphical chalet.**
```bash
make import
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -ginclude_subdirs -gexit
```
Then run under Xvfb, capture the logical 1280×800 frame, and inspect it for legibility, pixel scaling and overlaps.

**Step 5: Commit.**
```bash
git add scenes/world scenes/player scripts/app scripts/world tests/integration
git commit -m "feat: compose readable chalet opening"
```

## Task 4: Build the cold street, landmark and refuge as spatial gameplay

**Objective:** Make the exterior feel like a short dangerous street, not a flat testing board.

**Files:**
- Modify: `scenes/world/vicente_lopez_norte.tscn`
- Modify: `scripts/world/vicente_lopez_norte.gd`
- Modify: `scripts/app/main.gd`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/integration/test_survival_presentation.gd`

**Step 1: Write failing tests.**
- Assert a cold layered exterior composition: background/midground/foreground presentation roots, a R-1 landmark child, and an authored shelter facade/light.
- Assert `safe_route_requested` does not complete the route unless R-1 is active and shelter has been entered.
- Assert the exterior HUD exposure is visible only in the cold/open state and is reduced in shelter.

**Step 2: Run RED.**
Run targeted integration tests and confirm actual assertions fail.

**Step 3: Implement the scene and narrow state change.**
- Replace stretched background/snowbank with repeated, integer-scaled atlas strips: distant facades/trees, midground street/roofs, foreground snow/drifts.
- Show the chalet’s lit origin at exterior left, a central R-1 radio landmark (post/antenna/light/context), and a structurally legible shelter (wall, awning/roof, door/window, amber `PointLight2D`).
- Use low-density code/scene-driven snow only if it remains behind interaction affordances and performs headlessly; do not add a VFX framework.
- Record `shelter_visited` at the first true shelter entry. Require it in `_take_safe_route()` and provide a Spanish contextual response if the player tries early.
- Keep the exposure model pure and route-specific terminal behavior intact.

**Step 4: Run GREEN and capture exterior states.**
Capture: exterior entry, R-1 activated, player in refuge, and exposure-warning state. Inspect for contrast, clipping, visual path clarity, and player readability.

**Step 5: Commit.**
```bash
git add scenes/world scripts/app scripts/world tests/integration
git commit -m "feat: build atmospheric street and shelter"
```

## Task 5: Make the route choice physical and consequences visible

**Objective:** Turn two immediate terminal buttons into two short, visually distinct final route beats.

**Files:**
- Modify: `scenes/world/vicente_lopez_norte.tscn`
- Modify: `scripts/world/filter_shortcut.gd`
- Modify: `scripts/world/general_paz_exit.gd`
- Modify: `scripts/app/main.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/qa/chalet_vn.json`
- Modify: `tests/qa/chalet_vn_shortcut.json`
- Modify: `tests/qa/chalet_vn_lethal.json`

**Step 1: Write failing behavior/presentation tests.**
- Shortcut requires the spare filter and shows it being consumed exactly once.
- Covered route requires past shelter entry, has a different visual route marker, and keeps the filter.
- Each terminal exposes a route-specific subtitle/consequence, including lethal exposure.
- After terminal, interaction/movement can no longer alter route state.

**Step 2: Run RED.**
Run the targeted GUT suite and preserve the failure evidence.

**Step 3: Implement a bounded route beat.**
- Keep the level short: each exit leads through a brief visible segment/camera reveal before terminal rather than ending at a generic adjacent icon.
- Put the open shortcut on an exposed, white/cold visual lane with a filter/air affordance.
- Put the safe route under a covered/amber lane leaving the refuge toward a visible distant General Paz cue.
- Use no permanent `BLOQUEADO` labels; draw context prompt only near the relevant interactable.
- Extend `HUD.show_terminal(...)` to accept a title and route-specific Spanish consequence, and remove static “Fin de la primera vertical slice”.

**Step 4: Run GREEN, then recalibrate QA.**
Update waits only after real QA reports show new distances. Ensure all four JSON scenarios use real inputs and assert consequence text/state.

**Step 5: Run the QA target twice consecutively.**
```bash
make qa
make qa
```
Expected: all four routes pass twice with no timing flake.

**Step 6: Commit.**
```bash
git add scenes/world scripts/app scripts/world scenes/ui scripts/ui tests
 git commit -m "feat: dramatize route choice consequences"
```

## Task 6: Simplify HUD and complete visual validation

**Objective:** Let scene composition communicate the level while HUD remains concise, Spanish and player-facing.

**Files:**
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `scripts/app/main.gd`
- Modify: `README.md`
- Modify: `DEVLOG.md`
- Modify: `tests/integration/test_survival_presentation.gd`

**Step 1: Write failing HUD tests.**
Assert no debug state label, no always-on controls label, one contextual interaction/status affordance, and compact exposure display only outdoors.

**Step 2: Run RED then implement.**
- Consolidate objective/status into a restrained Spanish player-facing line.
- Reveal a nearby interaction prompt only when a valid interactable is in range.
- Remove `set_slice_state()` and legacy `SliceStateLabel` contract completely.
- Preserve terminal paths and QA-visible semantic state on `Main`; only player presentation changes.

**Step 3: Visual review.**
At logical 1280×800 capture and inspect: initial chalet, all-materials/worktable, exterior entry, R-1 decision, shelter, safe ending, shortcut ending, lethal ending and VS ending. Reject overlaps, blue RGB-box artifacts, fractional scaling blur, unreadable player silhouettes, and hidden affordances.

**Step 4: Document truthful scope.**
- Update `README.md` with the actual route and controls.
- Update `DEVLOG.md` with what graphical captures and QA proved.
- Do not claim a 5–10 minute player session from smoke-test duration.

**Step 5: Commit.**
```bash
git add scenes/ui scripts/ui scripts/app tests README.md DEVLOG.md
git commit -m "feat: polish playable level presentation"
```

## Task 7: Full verification, fresh review and shareable demo

**Objective:** Prove behavior, appearance and export are all valid before a PR.

**Files:**
- No planned source changes unless verification finds a defect.
- Create durable captures outside the repo: `~/.exports/eternauta-polished-level/<ISO_DATETIME>/`.

**Step 1: Run full automated verification from this worktree.**
```bash
make import
make verify
make qa
make qa
make export-linux-debug
git diff --check
git diff --cached --check
```

**Step 2: Record graphical evidence.**
- Under Xvfb, replay the safe and shortcut QA routes in graphical mode.
- Record one short MP4 that visibly shows chalet → exterior → R-1 → route choice → route-specific ending.
- Keep screenshots and reports alongside the video in the durable export folder.

**Step 3: Fresh-context review.**
A reviewer must inspect the final diff, all QA reports and captured images/video against the confirmed contract. Resolve actionable defects before PR.

**Step 4: PR closeout only after explicit request.**
- Commit coherent milestones, push `feat/polished-playable-level`, open a PR with actual verification output.
- Merge only with explicit user authorization after remote checks are green.

## Risks and mitigations

- **RGB atlas background boxes:** avoid isolated atlas crops over mismatched backgrounds; compose them on compatible colored layers or create a documented narrow chroma-key/transparent derivative only if captures prove it is needed.
- **Scope explosion:** no new art pack, audio system, tilemap engine or campaign. The deliverable is one strong level.
- **QA movement flake after spatial expansion:** recalibrate each real-input route against reports and run QA twice.
- **Visual regressions missed headlessly:** graphical screenshots/video are a release gate, not optional polish.
- **Lore/IP:** Kenney art is CC0; publication/commercial use of *El Eternauta* material remains a separate rights validation documented in `docs/LORE_ORIGINAL_EL_ETERNAUTA.md`.
