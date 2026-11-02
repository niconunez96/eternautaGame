# Toolchain

- Editor: Godot `4.6.stable.official.89cea1439`
- Editor command: `~/.local/bin/godot`
- Linux templates: `~/.local/share/godot/export_templates/4.6.stable/`
- Test runner: GUT `9.6.1` (`c80954f47bed74a0a2c471d472c0389f98e0a8f6`), vendored under `addons/gut`.

Keep Godot and export templates on the same version. To upgrade, install the matching official editor/templates first, update this document, then validate `make verify` and `make export-linux-debug`.
