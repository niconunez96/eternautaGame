# Toolchain

- Editor: Godot `4.7.stable.official.5b4e0cb0f`
- Editor command: `~/.local/bin/godot`
- Linux templates: `~/.local/share/godot/export_templates/4.7.stable/`
- Test runner: GUT `9.7.1` (`aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`), vendored under `addons/gut`.

Keep Godot and export templates on the same version. To upgrade, install the matching official editor/templates first, update this document, then validate `make verify` and `make export-linux-debug`.
