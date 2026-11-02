# Steam Deck QA

Before release, validate in SteamOS Game Mode: cold launch, controller-only menu traversal, correct prompts after device changes, 1280×800 and 1280×720 layouts, suspend/resume, settings persistence, and a sustained 30-minute play session. CI cannot establish Steam Deck Verified status.

Godot QA replays a smoke scenario in CI, but it is not a hardware substitute: it cannot validate Steam Input glyphs, Game Mode, suspend/resume, or controller feel on a Steam Deck.
