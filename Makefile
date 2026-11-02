SHELL := /bin/bash
GODOT := godot
TEST := $(GODOT) --headless --path . -s res://addons/gut/gut_cmdln.gd

.PHONY: import test qa qa-visual lint format-check export-linux-debug export-linux-release verify
import:
	$(GODOT) --headless --path . --editor --quit

test: import
	$(TEST) -gdir=res://tests/unit -gexit
	$(TEST) -gdir=res://tests/integration -gexit

qa: import
	mkdir -p build
	$(GODOT) --headless --path . -s res://addons/godot_qa/runner.gd -- --scenario res://tests/qa/chalet_vn.json --report build/qa-chalet-vn.json --junit build/qa-chalet-vn.xml
	$(GODOT) --headless --path . -s res://addons/godot_qa/runner.gd -- --scenario res://tests/qa/chalet_vs.json --report build/qa-chalet-vs.json --junit build/qa-chalet-vs.xml

qa-visual: import
	@echo "Run under Xvfb/real display and capture CI baselines before enabling visual diffs."

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

verify: test qa lint format-check
