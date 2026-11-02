# Architecture

`scenes/app/main.tscn` is the composition root. The player is a `CharacterBody2D`; deterministic movement and health rules live in typed `RefCounted` classes under `scripts/player/` and are covered by GUT.

Input is semantic (`InputMap` actions), never hard-coded in gameplay logic. `InputDeviceService` and `SettingsService` are intentionally narrow autoload candidates; player and world state remain scene-local.

Use Compatibility rendering and a 1280×800 logical viewport. Test platforming rules/headless scene loading in CI; test controller feel and SteamOS behavior on hardware.
