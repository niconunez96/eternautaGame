# GAME AUDIT — El Eternauta vertical slice

**Baseline audited:** `main` at `344c035` (2026-11-04)

## Executive diagnosis

The prototype is technically coherent and playable, but it currently communicates **a guided interaction checklist**, not survival under a lethal snowfall. Its deterministic VN input route completes in **16.9 s** (19 assertions); the VS route completes in **9.3 s** (9 assertions). That is an automated smoke duration, not a player-session measurement, but it exposes the absence of sustained pressure, observation, route planning, or meaningful consequence.

### Current loop

1. Walk right/left across a single flat chalet.
2. Press `K` close to three interchangeable material icons.
3. Press `K` at Favalli's table.
4. Press `K` at one of two exits.
5. On VN, walk to a radio, then walk to General Paz.
6. A terminal overlay closes the slice.

The loop has clear state gates but almost no decision: all three items are mandatory, exits have unequal content, the radio is a binary key, and exposure to the snow never changes play.

## Critical — prevents the intended experience

1. **The snowfall is only a gate, not an active threat.**
   - Evidence: the only consequence is the status string `The snowfall is lethal without the insulated suit.` before `suit_equipped`; after that, there is no weather timer, failure state, shelter, resource drain, visibility behavior, or survival decision.
   - Impact: removes the requested permanent environmental danger and makes the suit an ordinary access key.

2. **The playable route is far below the 5–10 minute target and has no pressure cycle.**
   - Evidence: `build/qa-chalet-vn.json` passed in 16,899 ms across 65 scripted steps; interactions and transitions immediately resolve state.
   - Impact: no time exists to explore cautiously, listen, anticipate danger, recover in shelter, or evaluate a route.

3. **No meaningful trade-off exists.**
   - Evidence: all materials are required; VN is the only continuation; VS immediately shows a terminal. `GeneralPazExit.available` changes a label but imposes no cost after R-1.
   - Impact: the player cannot choose advance/refuge/resource/route with a consequence.

4. **Primary affordances are unclear in spatial play.**
   - Evidence: `Area2D` interactions use a global nearest-node scan with a 92 px radius and no active proximity prompt. The chalet labels describe rooms/items as map annotations, but do not identify the current interactable or required button in context.
   - Impact: a new player can be close enough to act without knowing it, or see dense labels without understanding priority.

## High — damages loop or atmosphere

1. **The UI exposes implementation state and repeats instructions rather than creating tension.**
   - Evidence: HUD permanently displays `Slice: <internal_state>`, status and objective are long text lines, and the bottom control legend lists every input all the time. English and Spanish are mixed.
   - Impact: breaks immersion and hierarchy; it tells state-machine vocabulary instead of player-relevant risk.

2. **The chalet is a flat checklist corridor, not a refuge under siege.**
   - Evidence: all objects sit on one horizontal floor from x=300 to x=1210; room labels enumerate the route; no environmental signs, shelter behavior, or meaningful return path exists.
   - Impact: walking is transit, not exploration; Favalli, Elena and Martita are text labels rather than an emotionally legible situation.

3. **Exterior lacks atmospheric and navigational contrast.**
   - Evidence: one static snowfield region, a roof, a radio, and the exit; no snow particles, sound, visibility falloff, warm safe landmark, weather escalation, or distant signal behavior.
   - Impact: the exterior reads as a generic platform backdrop rather than dangerous, incomplete space.

4. **The visual source is usable but presently under-directed.**
   - Evidence: the CC0 Kenney sheet offers cold tiles, snow, props, silhouettes and color variation, but current scenes use a few stretched regions and mostly default labels.
   - Impact: basic legibility exists, but composition and contrast do not guide attention or establish a threatening Buenos Aires.

5. **No audio system exists.**
   - Evidence: no authored audio assets or audio nodes appear in the project.
   - Impact: silence is not designed silence; no distant signal, wind, or transition rhythm supports isolation.

## Medium — polish, UX, or content

1. **Interaction feedback is mostly text-only.** Collected materials simply disappear; fabrication flips a boolean; blocked exit feedback is a sentence. There is no highlight, pulse, sound, or distinct danger feedback.
2. **Controls are responsive in code but not fully discoverable.** Acceleration and coyote time are covered by GUT, but the all-screen legend is noisy and there is no device-aware prompt despite `InputDeviceService`.
3. **The pause scene and settings autoload are incomplete/unwired.** `pause_menu.tscn` is not composed by `Main`; settings says “coming soon”.
4. **The conclusion is abrupt.** General Paz and VS terminal overlays give a location title but little acknowledgement of the cost or discovery that ended the slice.
5. **No automated visual baseline exists.** `make qa-visual` is deliberately a placeholder; logical QA cannot catch overlap, contrast, or snow-obscured interaction points.

## Low — optional improvements

1. Replace default labels with a consistent custom theme once interaction hierarchy is proven.
2. Add controller glyphs that react to the active device.
3. Add audio only after confirming rights, mix targets, and the core loop; it should reinforce the loop, not mask its absence.
4. Expand the south route only if it becomes a distinct, meaningful choice rather than extra content.

## Technical debt / systems at risk

- `Main` owns rendering, input selection, scene composition, progression, terminal state and HUD copy. It is acceptable for this small slice but will become brittle if weather, audio, multiple shelters, or routes are added without extracting narrow collaborators.
- `GeneralPazExit.available` only changes text; `interact()` still emits regardless. Progression blocks the action indirectly, which makes intent less local.
- World `Area2D`s have no collision shapes because interaction is distance-scanned; this is intentional but undocumented and easy to misread as incomplete setup.
- QA relies on absolute timed walks. It proves a deterministic happy path but can become brittle when pacing/level geometry changes.
- Existing tests strongly protect state transitions, but do not test player-facing prompt hierarchy, visual readability, exposure danger, death, decision cost, or route consequence.

## Preserve

- **No-combat baseline.** Avoiding a generic shooter is the right constraint for this slice.
- **Simple, human movement.** Single jump, acceleration and coyote time are appropriately bounded and already tested.
- **Small deterministic progression model.** `ChaletProgression` is a sound seam for testable gates.
- **Semantic input and controller support.** InputMap actions and controller mappings are correct foundations.
- **Real input QA.** The QA runner sends actual actions and verifies state/text; it should be extended, not replaced.
- **Chalet → exterior premise.** The first step into lethal snow is the strongest available dramatic transition.
- **Curated CC0 asset provenance.** Keep source-art discipline and do not add an uncontrolled art-pack dependency.

## Directed improvement contract

The next slice should prove this loop in 30–60 second beats:

1. Read an immediate objective inside a visibly safe chalet.
2. Prepare a sealed suit, with an optional spare filter whose purpose is explicit.
3. Enter low-visibility snow and see exposure rise outside shelter.
4. Locate/activate R-1 from a landmark or signal.
5. Choose a warm shelter detour (slow/safe) or a direct exposed route (fast/costs the filter).
6. Receive a legible result: survival, loss, discovery, or terminal failure, with the reason communicated in-world and in restrained UI.

**Scope guard:** implement exposure, shelter, one consumable filter, one real route trade-off, presentation/UX improvements, and tests. Do not add combat, enemies, broad inventory, new downloadable assets, or campaign systems unless this loop demonstrably fails without them.
