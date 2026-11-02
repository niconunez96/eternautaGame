# EternautaGame

Godot 4.6 prototype foundation for a 2D metroidvania targeting Linux and Steam Deck.

## Local setup

```bash
godot --version       # 4.6.stable.official.89cea1439
make verify
make export-linux-debug
```

## Controls

- Move: WASD/arrows or left stick/D-pad
- Jump/confirm: Space or controller South (A)
- Dash/cancel: Shift or controller East (B)
- Attack/interact: J/K or controller West (X)
- Pause: Escape or Start

The prototype has placeholder geometry only. It intentionally excludes Steamworks, store integration, final content, art and audio.

## Steam Deck note

This is controller-first and exports native Linux x86_64. It is **not** Steam Deck Verified: Game Mode, suspend/resume and physical-controller QA remain manual.
