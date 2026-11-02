# Double-Jump Traversal Micro-Slice Implementation Plan

> **For Hermes:** Use `spec-drive-development` with one implementation writer and a fresh reviewer.

**Goal:** Replace the access-key progression reward with a visible double-jump ability and a deterministic traversal loop: enemy → checkpoint → reward → double-jump-only obstacle → final objective.

**Architecture:** Keep jump eligibility in `PlayerMotionRules` so GUT owns deterministic rules; keep runtime counters/state in `PlayerController`; keep acquired ability, checkpoint, reward wiring, obstacle composition, reset behavior, and final-objective state scene-local in `Main`. The existing key/door loop is removed from the composed room because it no longer advances traversal and no inventory/key system is in scope.

**Tech Stack:** Godot `4.6.stable.official.89cea1439`, GDScript, Compatibility renderer, 1280×800 logical viewport, GUT 9.6.1, existing vendored Godot QA.

---

## Discovery and classification

- Existing root is `/home/hermes/development/eternautaGame`; `main` contains unrelated pre-existing local changes in `project.godot` plus untracked `.hermes/` plans. Do not modify, stage, or discard these from `main`.
- Existing clean worktree `/home/hermes/development/eternautaGame--feat-first-vertical-slice` at `feat/first-vertical-slice` is the implementation checkout. There is no remote; no fetch, push, PR, or publishing action is allowed.
- The current slice has runtime composition in `scripts/app/main.gd`, movement in `scripts/player/player_controller.gd`, pure movement rules in `scripts/player/player_motion_rules.gd`, pure key rules in `scripts/world/progression_rules.gd`, and a JSON semantic-input QA runner.
- This is **non-simple**: it changes movement state, progression reward/state, level collision geometry, HUD contracts, GUT, integration, and end-to-end QA. It requires a formal plan, one TDD writer, and fresh review.

## Scope and acceptance criteria

1. The base jump/coyote behavior remains intact. After double jump is acquired, exactly one additional airborne jump can be consumed before landing; neither a second air jump nor air jumping before acquisition is permitted.
2. The reward is a visible geometric double-jump pickup. No key, inventory, save, or new plugin/system is added.
3. The composed room orders and exposes stable names for `BasicEnemy`, `Checkpoint`, `DoubleJumpReward`, `TraversalObstacle`, and `ExitObjective`.
4. The obstacle has a horizontal gap plus elevated landing platform whose height is above the single-jump apex. The existing dash cannot produce extra vertical height, so the route requires the second jump.
5. Death/reset restores player locomotion state and position at the active checkpoint while preserving the run-local acquired double-jump ability and final objective state contract.
6. The HUD displays exactly `Double jump: acquired` when earned and a simple objective directing the player to the exit beyond the gap.
7. GUT, integration, and Godot QA are updated through RED → GREEN to prove rules, reset/state/composition, and the real ordered semantic-action loop.
8. `make verify`, `make export-linux-debug`, and `git diff --check` pass from the active implementation worktree. A local commit exists only after those checks and fresh review are green.

## Task 1: Specify deterministic jump rules (RED → GREEN)

**Files:**
- Modify: `tests/unit/test_player_motion.gd`
- Modify: `scripts/player/player_motion_rules.gd`

1. Add failing GUT tests for the two pure rules: a grounded/coyote base jump is allowed as today, and an extra jump is allowed only when the ability is acquired and its single airborne charge is available.
2. Add failing tests that consuming/clearing the available airborne charge prevents a second extra jump until landing refreshes it.
3. Run the focused unit suite and capture RED before implementation.
4. Add the minimum typed `PlayerMotionRules` predicates necessary for the tests; do not put scene state in the RefCounted helper.
5. Rerun the focused suite and verify GREEN.

## Task 2: Apply the rules in PlayerController (RED → GREEN)

**Files:**
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `scripts/player/player_controller.gd`

1. Add failing integration assertions for a player capability API, initially disabled, plus one resettable `air_jump_available` charge.
2. Add the smallest controller API (`set_double_jump_acquired` or equivalent) and state required to use the existing semantic `jump` action.
3. Preserve existing base-jump/coyote behavior. On base jump, clear coyote eligibility; when not eligible for a base jump, consume the one extra charge only if the ability exists. Refresh the charge only when grounded; reset only transient motion/charge state, not the acquired capability.
4. Expose only stable observable state required by tests/QA; no new raw key polling and no new InputMap action.
5. Run integration and focused GUT tests to GREEN.

## Task 3: Replace reward/gate loop with traversal composition (RED → GREEN)

**Files:**
- Rename/replace: `scripts/world/access_reward.gd`, `scenes/world/access_reward.tscn`
- Modify: `scripts/world/progression_rules.gd` and `tests/unit/test_progression_rules.gd` only if a pure idempotent acquisition rule remains useful
- Modify: `scripts/app/main.gd`
- Modify: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`
- Modify: `tests/integration/test_main_scene.gd`
- Add only if needed for a stable state assertion: `scripts/world/exit_objective.gd`, `scenes/world/exit_objective.tscn`
- Remove dead door/key composition references; delete obsolete files only when no remaining reference exists.

1. Add RED integration assertions for named `DoubleJumpReward`, `TraversalObstacle`, and `ExitObjective`, with no `AccessReward`/`LockedDoor` dependency in the composed loop.
2. Evolve the visible pickup to emit a stable double-jump ability id once. `Main` owns `has_double_jump`, applies it to `Player`, updates HUD, and preserves it through checkpoint respawn.
3. Use two floor sections and an elevated exit platform so the vertical landing height exceeds the base jump apex but is reachable with the second jump. Name the assembled obstacle `TraversalObstacle`; include a safe fall/reset boundary only if necessary to prevent bypassing or soft-locking.
4. Place the final objective after the elevated landing. It becomes active only by physically reaching it; it updates `ObjectiveLabel`/status without a door/key/inventory interaction.
5. Update HUD’s ability string to `Double jump: acquired` / missing and set a simple traversal objective. Keep the existing controller-first control reminder, adding a distinct label only if needed.
6. Run integration tests to GREEN.

## Task 4: Drive the real loop with Godot QA (RED → GREEN)

**Files:**
- Modify: `tests/qa/smoke.json`
- Modify: `README.md` only where its QA loop description still says access key/door.

1. Replace the old door interactions in the QA scenario with semantic actions that prove, in order: player health/spawn, enemy defeat, checkpoint activation, reward collection, `Double jump: acquired`, two timed `jump` presses while crossing the named obstacle, and final objective completion.
2. Assert stable node properties/text for ability acquisition, obstacle/exit objective state, and final objective text. Do not use screenshots or physical inputs.
3. Run `make qa` and capture RED while the old room remains.
4. Tune only deterministic geometry/timings/waits needed to make the semantic scenario pass headlessly; maintain controller-first InputMap semantics.
5. Run `make qa` again and verify GREEN.

## Task 5: Fresh review, full verification, local commit

1. Fresh reviewer checks the diff against scope, especially exactly-one extra jump, obstacle reachability logic, removal of obsolete key/door flow, and absence of Steamworks, saves, inventory, plugins, artwork/audio, remote actions, or a Steam Deck Verified claim.
2. From `/home/hermes/development/eternautaGame--feat-first-vertical-slice`, run exactly:
   ```bash
   make verify
   make export-linux-debug
   git diff --check
   ```
3. Confirm the implementation worktree’s status and diff contain only intended micro-slice files (the pre-existing dirty `main` remains untouched).
4. If and only if all checks are green, create one clear local conventional commit such as:
   ```bash
   git commit -m "feat: add double jump traversal slice"
   ```
5. Do not push, open a PR, publish, claim Steam Deck Verified, or perform manual Steam Deck QA.

## Risks and decisions

- Existing `dash` is horizontal and therefore cannot satisfy the elevated landing’s vertical requirement; the obstacle must be measured/tuned against the current `JUMP_VELOCITY` and gravity so a single jump cannot land on it.
- Physics-based QA is timing-sensitive. Assertions target named node state and HUD text rather than pixels, and action timing must be tuned only as far as required for deterministic headless runs.
- Door/key code is intentionally not kept in the active loop because it duplicates progression without adding traversal. Avoid adding a replacement inventory/key abstraction.
- Headless/Linux verification and export prove build health only. Steam Deck Game Mode, physical controller feel, suspend/resume, and Valve verification remain manual/out of scope.
