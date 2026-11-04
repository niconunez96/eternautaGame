# Survival-Tension Vertical Slice Implementation Plan

> **For Hermes:** Use spec-drive-development skill to implement this plan task-by-task.

**Goal:** Transform the current 17-second item-collection route into a concise, replayable 5–10 minute survival slice where exposure to lethal snowfall creates understandable pressure, one meaningful route decision, and clear consequences.

**Architecture:** Keep the existing deterministic `ChaletProgression` state machine and single-scene composition. Add a small, pure survival/exposure model that only advances outside shelter; let `Main` own scene-level transitions and HUD updates. Replace the generic three-item scavenger sequence with a bounded preparation loop, an exterior exposure loop, and a shelter-vs-shortcut decision. Preserve no-combat scope and headless QA.

**Tech Stack:** Godot 4.7, GDScript, GUT 9.7.1, vendored Godot QA.

---

## Current context / constraints

- Baseline `make verify` passes; QA currently replays VN in 16.9 s and VS in 9.3 s.
- The current project contains only the Kenney Pixel Redux spritesheet. The first implementation must reuse code/primitive presentation; it must not start by adding asset packs.
- The worktree is `/home/hermes/development/eternautaGame--feat-survival-tension-slice` on `feat/survival-tension-slice`.
- Non-goals: combat, enemies, generic inventory, open-ended crafting, health pickups, procedural content, or a full campaign.

## Chosen design

1. **Preparation is compact and legible.** The chalet offers two explicit preparation choices instead of three generic pickups: a sealed suit (mandatory) and one spare filter (optional). Text and visual prompts say what each does.
2. **Snow is an active threat.** Outside, exposure drains continuously. A clear, restrained HUD meter and escalating status communicate danger; protected shelter resets/halts danger.
3. **One real trade-off.** After receiving R-1’s signal, the player chooses a nearby exposed shortcut (fast but costs their spare filter / worsens exposure) or a longer sheltered detour (safe but delayed). The outcome is narrated and affects terminal text/state.
4. **Route has 30–60 second beats.** Each exterior stage has a landmark, signal, decision, and result. Walking time, interaction framing, and reads will be calibrated by QA instead of hard-coded assumptions.
5. **Atmosphere serves legibility.** Add code-driven snow particles, dim exterior lighting, shelter warm light, distance haze, and tension statuses; no dense effect may obscure interaction affordances.

## Task 1: Record the baseline audit

**Objective:** Store the evidence-led diagnosis and acceptance contract before behavior changes.

**Files:**
- Create: `GAME_AUDIT.md`
- Create: `DEVLOG.md`

**Step 1:** Write `GAME_AUDIT.md`, ordered Critical → Low, naming concrete evidence (including 16.9 s VN QA runtime), preserved strengths, loop diagnosis, and the target loop.

**Step 2:** Add a brief initial decision entry to `DEVLOG.md` describing the chosen minimal direction: exposure pressure + one filter trade-off, no combat/new art pack.

**Step 3: Verify**

Run: `git diff --check -- GAME_AUDIT.md DEVLOG.md`

Expected: no whitespace errors.

## Task 2: Establish survival state with pure tests first

**Objective:** Make outdoor exposure, shelter, and filter consumption deterministic and testable without scene coupling.

**Files:**
- Create: `scripts/app/survival_state.gd`
- Create: `tests/unit/test_survival_state.gd`
- Modify: `scripts/app/chalet_progression.gd`
- Modify: `tests/unit/test_chalet_progression.gd`

**Step 1: Write failing tests**

Cover: exposure does not rise in shelter; it rises outside; warning/critical/dead thresholds are stable; a spare filter can be consumed only once; and the selected resolution is recorded.

**Step 2: Run RED**

Run: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit`

Expected: a real behavioral failure due to absent survival model API.

**Step 3: Minimal implementation**

Add a typed `RefCounted` model with named thresholds and no node calls. Extend `ChaletProgression` only with explicit route-resolution state, avoiding duplicate timing logic.

**Step 4: Run GREEN**

Run the same focused GUT command.

Expected: all unit tests pass.

## Task 3: Replace generic prep with clear affordances

**Objective:** Make a first-time player understand immediate objective, interaction range, required suit, and optional filter without an instruction wall.

**Files:**
- Modify: `scenes/world/chalet.tscn`
- Modify: `scenes/world/suit_material.tscn`
- Modify: `scripts/world/suit_material.gd`
- Modify: `scripts/app/main.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `tests/integration/test_main_scene.gd`

**Step 1: Write failing integration contract**

Assert player-facing interaction prompt is visible when nearest interactable is in range; assert initial objective names suit preparation and status does not expose debug `Slice:` state.

**Step 2: Run RED**

Run: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -gexit`

Expected: failed assertions for absent prompt / legacy state label.

**Step 3: Minimal implementation**

Introduce explicit item labels/roles (suit components required, spare filter optional), context prompt from nearest interaction, and concise HUD hierarchy: objective, transient status, exposure state. Remove raw internal state from player UI.

**Step 4: Run GREEN**

Run the same integration suite.

Expected: all integration tests pass.

## Task 4: Build the exterior survival loop and decision

**Objective:** Deliver the core 30–60 second loop: leave shelter, read threat/resource, reach R-1, choose safe shelter route or exposed shortcut, receive an explained consequence, and reach the terminal state.

**Files:**
- Modify: `scripts/app/main.gd`
- Modify: `scripts/app/chalet_progression.gd`
- Modify: `scenes/world/vicente_lopez_norte.tscn`
- Modify: `scripts/world/vicente_lopez_norte.gd`
- Modify: `scripts/world/neighborhood_radio.gd`
- Modify: `scripts/world/general_paz_exit.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/qa/chalet_vn.json`

**Step 1: Write failing progression and scene tests**

Cover: exterior exposure begins only after VN; R-1 unlocks two explicitly labeled choices; shortcut requires/consumes spare filter; shelter route remains valid without it; terminal state reports the chosen consequence; player cannot progress after death/terminal.

**Step 2: Run RED**

Run focused unit + integration GUT tests.

Expected: test failures for unknown resolution/exposure APIs or old direct General Paz transition.

**Step 3: Minimal implementation**

Keep one exterior scene but place a warm marked shelter and a cold shortcut as distinct interactables. `Main` ticks survival, updates HUD, and transitions to a terminal failure when exposure reaches lethal threshold. Animate snow code-side and place visibility/lighting cues in scene nodes.

**Step 4: Run GREEN**

Run focused unit + integration GUT tests.

Expected: all focused tests pass.

**Step 5: Update input QA**

Drive both choices through real semantic input and assert each named consequence, not only state mutation. Add waits after interactions.

**Step 6: Run QA**

Run: `make qa`

Expected: each scenario passes with report artifacts under `build/`.

## Task 5: Calibrate pacing, presentation, and documentation

**Objective:** Ensure the actual route meets the 5–10 minute intended experience without sacrificing clarity and record the verified result.

**Files:**
- Modify: `README.md`
- Modify: `GAME_AUDIT.md`
- Modify: `DEVLOG.md`
- Modify: `Makefile` only if a necessary focused QA target is missing
- Modify: `tests/qa/*.json` only as needed to represent stable routes

**Step 1:** Run import, all GUT tests, both QA routes, and export.

**Step 2:** Launch the graphical game under a display server; capture the chalet, exterior, decision, failure/terminal states at logical resolution and inspect them for contrast, labels, overlap, particles and obscured affordances.

**Step 3:** Tune only measured timings/positions/text that fail the stated loop and legibility goals. Record what was tested in `DEVLOG.md` and reconcile any audit items fixed vs deferred.

**Step 4: Final verification**

Run:
```bash
make import
make verify
make export-linux-debug
git diff --check
git diff --cached --check
```

Expected: all checks pass; no generated `.godot/` artifacts are staged.

## Risks and mitigations

- **Five-to-ten minute target vs automation:** QA should stay a compact deterministic smoke route; it verifies correctness, not total intended player pace. Record the distinction openly.
- **Godot visual QA:** current `qa-visual` is a placeholder. Capture and inspect states manually in this environment; do not claim automated visual baselines.
- **Scope creep:** no enemy/combat system unless the exposure-and-decision loop is proven insufficient; current evidence says it is not.
- **Legibility loss from snow:** cap particles and keep affordance labels/contrast testable via scene contracts and screenshots.
