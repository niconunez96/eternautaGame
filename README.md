# EternautaGame

Godot 4.6 vertical slice: Chalet → fabricate an insulated suit → first step into the snowfall.

## Local setup

```bash
godot --version       # 4.6.stable.official.89cea1439
make verify
make qa
make export-linux-debug
```

## Controls

- Move: WASD/arrows or left stick/D-pad
- Jump: Space or controller South (A); one human jump only
- Interact: K or controller West (X)
- Pause: Escape or Start

## Chalet slice

Juan begins enclosed in the chalet. Collect `lona`, `sellado_guantes`, and `mascara_filtro` in any order, then interact with Favalli's fabrication table to equip the insulated suit. Until then, both exits remain blocked by the snowfall. After fabrication, choose the north window/low roof (`VN`) or south front door (`VS`); the slice closes with `Vicente López norte` or `Vicente López sur` respectively.

The slice intentionally has no combat, health, respawn/checkpoints, dash, double jump, wall jump, radio, map, generic inventory, or open-ended crafting.

## Automated playtests

`make qa` launches two real headless input playthroughs of the main scene: `tests/qa/chalet_vn.json` and `tests/qa/chalet_vs.json`. Each verifies the initial weather block, free-order materials, suit fabrication, and its route-specific closing title. Reports are written as `build/qa-chalet-vn.{json,xml}` and `build/qa-chalet-vs.{json,xml}`.

`make qa-visual` is intentionally a placeholder until screenshots are captured in CI. Visual baselines must come from CI (not local drivers/fonts), then Godot QA can diff them under Xvfb/Mesa.

## Steam Deck note

This is controller-first and exports native Linux x86_64. It is **not** Steam Deck Verified: Game Mode, suspend/resume and physical-controller QA remain manual.
