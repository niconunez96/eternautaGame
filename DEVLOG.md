# DEVLOG

## 2026-11-04 — Directed vertical-slice reset

**Decision:** Prioritize a playable survival loop over more content: active outdoor exposure, a clearly optional spare filter, one safe-vs-fast route choice, and restrained contextual UI.

**Why:** Baseline VN QA completes in 16.9 seconds and the snow is only a pre-suit lock. The existing collection/radio gates are deterministic but do not create pressure or consequence.

**Non-goals:** combat, enemies, generic inventory, open-ended crafting, new asset packs, and expansion of the south route until the core route is tense and legible.

### Fresh review after exposure increment

The review accepted the exposure model only as a first corrective increment. It found three blockers: the normal route is still shorter than the warning threshold, no shelter is wired, and the spare filter has no gameplay call site. The next implementation increment is limited to a marked shelter, a direct exposed shortcut that consumes the filter, and QA routes for shelter, shortcut and lethal exposure.

### Shelter and filter-route increment

Vicente López Norte now owns a warm shelter zone that lowers exposure and two R-1-gated exits. The covered detour preserves the spare filter; the exposed shortcut consumes it. The route outcome is exposed on `Main` for headless QA. Four input QA scenarios cover the safe route, shortcut, lethal exposure, and VS terminal.

### Final route verification

The final local run completed `make import`, `make verify`, two consecutive `make qa` executions, and `make export-linux-debug`. Both QA runs passed the four supported playthroughs. Xvfb captures also exercised both physical VN endings: the covered route closes at General Paz while preserving the filter; the exposed route closes there after consuming it.
