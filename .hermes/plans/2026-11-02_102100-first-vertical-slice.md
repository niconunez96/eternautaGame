# First Vertical Slice Implementation Plan

> **For Hermes:** Use spec-drive-development skill to implement this plan task-by-task.

**Goal:** Deliver a small, controller-first playable loop in the initial room: defeat one basic enemy, activate a checkpoint, collect an access ability, unlock a door, and expose health/progress in the HUD.

**Architecture:** Keep deterministic health and progression rules as typed `RefCounted` helpers with GUT coverage. Keep scene-local runtime state in `Main`: it composes a placeholder room and entities, holds the current checkpoint and acquired ability, connects gameplay signals, and resets the existing player at the active checkpoint after death. Use small reusable `Area2D`/`StaticBody2D` scenes for enemy, checkpoint, reward, and door; no global gameplay autoloads.

**Tech Stack:** Godot `4.6.stable.official.89cea1439`, GDScript, Compatibility renderer, GUT 9.6.1, vendored Godot QA, native Linux x86_64 debug export.

---

## Scope

### In scope
- One 1280×800 placeholder starting room with floor and elevated platforms.
- One stationary/basic geometric enemy that damages by contact and can be defeated by the player's attack.
- Player health state, temporary damage immunity, death signal, and reset at the current checkpoint.
- A checkpoint, an access-key-style ability reward, and a door opened through semantic `interact` only after reward acquisition.
- Minimal HUD labels for health, checkpoint status, acquired ability, and short objective/status feedback.
- GUT coverage for deterministic health/progression behavior and scene wiring.
- Godot QA scenario that executes and asserts the full player → enemy → checkpoint → reward → unlock flow.

### Non-goals
- Steamworks, remote publishing, push/PR, final art/audio, maps beyond this room, save persistence, animations, complex combat, multiple enemy types, narrative, or a Steam Deck Verified claim.
- Replacing GUT or Godot QA.

## Acceptance criteria

1. The level has visible placeholder floor/elevated platforms and all content is geometric/color-only.
2. Pressing semantic `attack` defeats the basic enemy while it is in range; surviving contact damage changes HUD health.
3. Repeated damage can cause death; death restores full health and places the player at the most recently activated checkpoint (or initial spawn before one).
4. Collecting the reward shows `Access key: acquired`; interacting at the door unlocks it only with the reward.
5. `make qa` executes an ordered full-loop scenario with stable node/UI assertions.
6. `make verify`, `make export-linux-debug`, and `git diff --check` pass from the active worktree.
7. A clear local commit exists only after all required checks are green; no remote action occurs.

---

### Task 1: Add deterministic health and progression tests (RED)

**Objective:** Specify player state changes and ability-gated unlocking before adding scene behavior.

**Files:**
- Modify: `tests/unit/test_player_health.gd`
- Create: `tests/unit/test_progression_rules.gd`
- Create: `scripts/world/progression_rules.gd`

**Step 1: Write failing health tests**

Cover health-state helpers needed by runtime player code:
- Damage reduces health exactly once while invulnerable state is false.
- A lethal result is zero.
- Reset/heal returns maximum health.

**Step 2: Write failing progression tests**

Cover pure functions:
- a missing access key cannot unlock;
- an acquired access key can unlock;
- collecting the key is idempotent.

**Step 3: Run focused tests to verify RED**

Run:
```bash
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit
```

Expected: progression tests fail because `ProgressionRules` does not exist (and any newly specified health helper fails until implemented).

**Step 4: Implement minimal pure rules (GREEN)**

Create `ProgressionRules` as a typed `RefCounted`; extend `PlayerHealth` only with the pure operation required by the failing tests.

**Step 5: Re-run the focused unit suite**

Expected: all existing and new unit tests pass.

---

### Task 2: Specify the player combat/health lifecycle (RED)

**Objective:** Define scene-facing player contracts before connecting enemies or UI.

**Files:**
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `scripts/player/player_controller.gd`
- Modify: `scenes/player/player.tscn`

**Step 1: Extend the integration test**

Instantiate `Main`, add it to the test tree, and assert the `Player` exposes a maximum/current health contract plus an attack signal/path used by the world. Exercise `take_damage` and verify it reaches a lethal state/signals death.

**Step 2: Run integration test to verify RED**

Run:
```bash
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -gexit
```

Expected: failure because player combat/health API does not exist.

**Step 3: Implement minimal player lifecycle**

In `player_controller.gd`:
- add `maximum_health`, `current_health`, a short contact-damage immunity timer, and typed `health_changed`, `died`, and `attack_requested` signals;
- consume semantic `attack` only when not paused; emit `attack_requested` with the facing direction;
- add `take_damage(damage)` delegating numerical calculation to `PlayerHealth`, and `reset_at(spawn_position)` restoring health/velocity/position;
- add only geometric attack feedback/hitbox behavior needed by the enemy contract.

In `player.tscn`, add a named, disabled-by-default short-range `Area2D` attack hitbox (collision shape and colored geometric placeholder), or keep collision resolution in `Main` only if the test establishes a simpler signal contract. Prefer named scene components for stable QA/debugging.

**Step 4: Re-run integration test (GREEN)**

Expected: test can observe player health transitions and death contract without engine errors.

---

### Task 3: Create composable placeholder world entities (TDD)

**Objective:** Give combat/progression concrete, signal-driven scene components.

**Files:**
- Create: `scenes/world/basic_enemy.tscn`
- Create: `scripts/world/basic_enemy.gd`
- Create: `scenes/world/checkpoint.tscn`
- Create: `scripts/world/checkpoint.gd`
- Create: `scenes/world/access_reward.tscn`
- Create: `scripts/world/access_reward.gd`
- Create: `scenes/world/locked_door.tscn`
- Create: `scripts/world/locked_door.gd`
- Modify: `tests/integration/test_main_scene.gd`

**Step 1: Write failing integration assertions**

After adding Main to the tree, assert named `BasicEnemy`, `Checkpoint`, `AccessReward`, and `LockedDoor` children exist. Assert the door starts locked and the reward/enemy expose their signal-driven state contracts.

**Step 2: Run integration test to verify RED**

Expected: missing-node/component failures.

**Step 3: Implement simple scene contracts**

- **Enemy:** colored `Area2D` with contact damage, one hit point, `defeated` signal, and no advanced AI/physics.
- **Checkpoint:** colored `Area2D`, activates once for the player, emits its respawn position.
- **Reward:** colored `Area2D`, emits `collected("access_key")` once then hides/disables itself.
- **Door:** geometric `StaticBody2D` plus proximity `Area2D`; emits interaction request, unlocks only when instructed, removes collision and visibly changes color when open.

All player checks must use group/type-safe checks rather than hard-coded root paths. Interaction has explicit priority over attack when the player is in a door range.

**Step 4: Re-run integration test (GREEN)**

Expected: all named entities load and initial states are asserted.

---

### Task 4: Compose the starting room, reset flow, and HUD (TDD)

**Objective:** Connect player/entity signals into one scene-local game loop with clear UI feedback.

**Files:**
- Modify: `scripts/app/main.gd`
- Modify: `scenes/world/test_arena.tscn` (promote to the actual placeholder room) or remove its unused role and document `Main` as composition root; prefer promoting it to avoid dead scene structure.
- Modify: `scenes/ui/hud.tscn`
- Create: `scripts/ui/hud.gd` if signal/update methods need scene-local logic
- Modify: `tests/integration/test_main_scene.gd`

**Step 1: Add failing composition/reset test**

Set/check a checkpoint, cause a player death through the public contract, and assert the same/new player has full health at that checkpoint position. Assert HUD named labels exist and update methods can show health/checkpoint/ability state.

**Step 2: Run integration test to verify RED**

Expected: reset, world composition, or HUD contract assertions fail.

**Step 3: Implement the smallest composition**

- Render background, floor, and two/few elevated `StaticBody2D` platforms in the real arena scene using rectangles and colors.
- Place initial player spawn, enemy, checkpoint, reward, and door left-to-right so one uninterrupted traversal reaches each.
- Keep `checkpoint_position` and `has_access_key` local to `Main`; connect all entity/player signals there.
- On player death, reset at the active checkpoint (initial spawn before activation), restoring health and clearing temporary movement/combat state. Do not reload the full scene, so earned ability/door state is not accidentally lost.
- Expand HUD with stable labels: `HealthLabel`, `CheckpointLabel`, `AbilityLabel`, `StatusLabel`, and `ObjectiveLabel`. Preserve control reminder text.
- Avoid unrelated pause-menu refactoring; ensure death/reset does not leave a paused tree/menu active.

**Step 4: Re-run integration tests (GREEN)**

Expected: scene instantiates, loop components are present, and reset/UI behavior is deterministic.

---

### Task 5: Replace smoke QA with the real vertical-loop scenario (RED → GREEN)

**Objective:** Drive named InputMap actions through the live scene and prove the ordered gameplay loop.

**Files:**
- Modify: `tests/qa/smoke.json`
- Optionally create: `tests/qa/vertical_slice.json` and adjust `Makefile` only if the runner already supports multi-scenario invocation; otherwise retain one canonical `smoke.json`.
- Modify: `Makefile` only if necessary to preserve `make qa` as the real-loop target.

**Step 1: Write the scenario before final wiring**

Use waits, semantic action input, node-property assertions, and text assertions to prove, in order:
1. player spawns with full health;
2. player reaches and defeats `BasicEnemy` with `attack`;
3. player activates `Checkpoint`;
4. player collects `AccessReward` and sees acquired ability text;
5. player reaches `LockedDoor`, uses `interact`, and observes unlocked/open state plus `Door unlocked` UI text.

Include a focused assertion that the HUD displays health and checkpoint status. Keep timeouts conservative for headless physics, avoid screenshot checks.

**Step 2: Run QA to verify RED**

Run:
```bash
make qa
```

Expected: it fails until the scene geometry, entity names, signal wiring, and HUD contract are complete.

**Step 3: Complete minimal wiring/coordinates until QA passes**

Tune only placeholder placement/timings needed for deterministic semantic-input traversal. Do not add visual regression or controller-hardware claims.

**Step 4: Run QA to verify GREEN**

Expected: report gives zero errors and all ordered assertions pass.

---

### Task 6: Review, full verification, and local commit

**Objective:** Close only after repository validation and a fresh diff/spec review.

**Files:**
- Modify only files required by Tasks 1–5.
- Do not add generated `build/`, `.godot/`, or existing untracked `.hermes/plans/` files to the commit.

**Step 1: Fresh review**

Review the diff against acceptance criteria and verify no Steamworks, final media, global gameplay autoload, unauthorized push/PR, or Steam Deck Verified claim entered the change.

**Step 2: Required commands from the active worktree**

```bash
make verify
make export-linux-debug
git diff --check
git status --short
```

**Step 3: Commit locally only when green**

```bash
git add project.godot Makefile scenes scripts tests docs README.md .github  # only paths actually changed
git commit -m "feat: add first playable vertical slice"
```

No `git push`, no PR, and no publishing action.

---

## Risks and decisions

- The existing `attack` and `interact` bindings both map to J/X. The vertical slice resolves this contextually: an unlocked-door interaction is handled while the player is inside its interaction area; attack resolves otherwise. This preserves controller-first bindings without inventing new controls.
- This slice validates desktop Linux/headless behavior and packaging only. Steam Deck Game Mode, controller feel, suspend/resume, performance, and Valve compatibility remain manual QA.
- Reset preserves run-local reward/door progression by resetting player state rather than reloading `Main`; persistent saves are intentionally deferred.
- Keep dimensions/coordinates intentionally simple and write QA around observable state/UI, not fragile pixel rendering.
