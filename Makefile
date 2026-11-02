SHELL := /bin/bash
GODOT := godot
TEST := $(GODOT) --headless --path . -s res://addons/gut/gut_cmdln.gd

.PHONY: import test lint format-check export-linux-debug export-linux-release verify
import:
	$(GODOT) --headless --path . --editor --quit

test: import
	$(TEST) -gdir=res://tests/unit -gexit
	$(TEST) -gdir=res://tests/integration -gexit

lint:
	@echo "GDScript parser validated by import"

format-check:
	@echo "No formatter configured; preserve tabs in GDScript"

export-linux-debug: import
	mkdir -p build
	$(GODOT) --headless --path . --export-debug "Linux x86_64" build/eternauta-game.x86_64

export-linux-release: import
	mkdir -p build
	$(GODOT) --headless --path . --export-release "Linux x86_64" build/eternauta-game.x86_64

verify: test lint format-check
