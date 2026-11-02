## Godot QA Pro — headless CI test runner (M1: logic mode).
## SceneTree-derived main script. No editor, no plugin registration needed.
##
## Usage:
##   godot --headless --path <project> -s res://addons/godot_qa/runner.gd -- \
##       --scenario tests/qa/smoke.json --report qa-report.json \
##       [--junit qa-report.xml] [--screenshots-dir qa-shots/] [--baseline-dir tests/qa/baseline/]
##
## Step execution semantics ported from Godot MCP Pro test_commands.gd
## (run_test_scenario); EditorInterface scene launching replaced by in-process
## PackedScene instantiation. Exit code 0 when all_passed, else 1.
extends SceneTree

const QAInput := preload("res://addons/godot_qa/qa_input.gd")
const QAInspector := preload("res://addons/godot_qa/qa_inspector.gd")
const QAScreenshot := preload("res://addons/godot_qa/qa_screenshot.gd")

const EXIT_OK := 0
const EXIT_FAILED := 1
const EXIT_USAGE := 2

var _input_service: Node
var _inspector: Node
var _screenshot: Node

var _scenario_path: String = ""
var _report_path: String = ""
var _junit_path: String = ""       # JUnit XML output (M4)
var _screenshots_dir: String = ""  # parsed, used only by screenshot steps (M2)
var _baseline_dir: String = ""     # parsed, used only by screenshot steps (M2)


func _initialize() -> void:
	_main()


func _main() -> void:
	var start_ms := Time.get_ticks_msec()

	if not _parse_args():
		quit(EXIT_USAGE)
		return

	var scenario: Variant = _load_scenario(_scenario_path)
	if scenario == null:
		quit(EXIT_USAGE)
		return

	# Services are plain Nodes held under root — no autoload injection needed.
	_input_service = QAInput.new()
	_input_service.name = "QAInput"
	_inspector = QAInspector.new()
	_inspector.name = "QAInspector"
	_screenshot = QAScreenshot.new()
	_screenshot.name = "QAScreenshot"
	root.add_child(_input_service)
	root.add_child(_inspector)
	root.add_child(_screenshot)

	var summary := await _run_scenario(scenario)
	summary["duration_ms"] = Time.get_ticks_msec() - start_ms
	summary["license_key"] = ""  # Reserved for Phase 2 (hosted); always empty in self-hosted builds.

	if not _report_path.is_empty():
		_write_report(summary)
	if not _junit_path.is_empty():
		_write_junit(summary)
	_print_summary(summary)

	quit(EXIT_OK if summary["all_passed"] else EXIT_FAILED)


# ── CLI args ──────────────────────────────────────────────────────────────────

func _parse_args() -> bool:
	var args := OS.get_cmdline_user_args()  # args after "--"
	var i := 0
	while i < args.size():
		var arg := args[i]
		match arg:
			"--scenario":
				i += 1
				if i >= args.size():
					printerr("[QA] --scenario requires a path")
					return false
				_scenario_path = args[i]
			"--report":
				i += 1
				if i >= args.size():
					printerr("[QA] --report requires a path")
					return false
				_report_path = args[i]
			"--junit":
				i += 1
				if i >= args.size():
					printerr("[QA] --junit requires a path")
					return false
				_junit_path = args[i]
			"--screenshots-dir":
				i += 1
				if i >= args.size():
					printerr("[QA] --screenshots-dir requires a path")
					return false
				_screenshots_dir = args[i]
			"--baseline-dir":
				i += 1
				if i >= args.size():
					printerr("[QA] --baseline-dir requires a path")
					return false
				_baseline_dir = args[i]
			_:
				printerr("[QA] Unknown argument: %s" % arg)
				return false
		i += 1

	if _scenario_path.is_empty():
		printerr("[QA] Usage: godot --headless -s res://addons/godot_qa/runner.gd -- --scenario <path> --report <path> [--junit <path>] [--screenshots-dir <dir>] [--baseline-dir <dir>]")
		return false
	return true


# ── Scenario loading ──────────────────────────────────────────────────────────

## Load and parse the scenario JSON. Accepts res://, user://, or absolute OS paths.
func _load_scenario(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		printerr("[QA] Scenario file not found: %s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("[QA] Could not open scenario file: %s" % path)
		return null
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		printerr("[QA] Scenario is not valid JSON (object expected): %s" % path)
		return null

	var scenario: Dictionary = parsed
	if not scenario.get("steps", null) is Array or (scenario["steps"] as Array).is_empty():
		printerr("[QA] Scenario requires a non-empty 'steps' array")
		return null
	return scenario


# ── Scenario execution ────────────────────────────────────────────────────────

func _run_scenario(scenario: Dictionary) -> Dictionary:
	var steps: Array = scenario["steps"]
	var results: Array[Dictionary] = []
	var pass_count: int = 0
	var fail_count: int = 0
	var errors: Array[String] = []

	# Load the scene in-process (replaces EditorInterface play_* calls).
	var scene_path: String = str(scenario.get("scene_path", "main"))
	var scene_error := await _load_scene(scene_path)
	if not scene_error.is_empty():
		errors.append(scene_error)
		return _build_summary(steps.size(), results, pass_count, fail_count, errors)

	for i in steps.size():
		var step: Variant = steps[i]
		if not step is Dictionary or not (step as Dictionary).has("type"):
			results.append({"step": i, "error": "Missing 'type' field"})
			errors.append("step %d: missing 'type' field" % i)
			continue

		var step_type: String = str(step["type"])
		var step_result: Dictionary = {"step": i, "type": step_type}
		var step_start_ms := Time.get_ticks_msec()

		match step_type:
			"input":
				var input_result := await _execute_input_step(step)
				step_result.merge(input_result)
				if input_result.has("error"):
					errors.append("step %d (input): %s" % [i, str(input_result["error"])])

			"wait":
				var wait_result := await _execute_wait_step(step)
				step_result.merge(wait_result)
				if wait_result.has("error"):
					errors.append("step %d (wait): %s" % [i, str(wait_result["error"])])

			"assert":
				var assert_result := await _execute_assert_step(step)
				step_result.merge(assert_result)
				if assert_result.get("passed", false):
					pass_count += 1
				else:
					fail_count += 1

			"screenshot":
				var screenshot_result := await _execute_screenshot_step(step, i)
				step_result.merge(screenshot_result)
				if screenshot_result.has("error"):
					errors.append("step %d (screenshot): %s" % [i, str(screenshot_result["error"])])
				elif screenshot_result.has("passed"):
					# baseline comparison counts as an assertion
					if screenshot_result["passed"]:
						pass_count += 1
					else:
						fail_count += 1

			_:
				step_result["error"] = "Unknown step type: %s" % step_type
				errors.append("step %d: unknown step type '%s'" % [i, step_type])

		step_result["duration_ms"] = Time.get_ticks_msec() - step_start_ms
		results.append(step_result)

		# In-process equivalent of the "game stopped unexpectedly" check.
		if current_scene == null or not is_instance_valid(current_scene):
			results.append({"step": i + 1, "error": "Scene was freed unexpectedly"})
			errors.append("scene was freed unexpectedly after step %d" % i)
			break

	return _build_summary(steps.size(), results, pass_count, fail_count, errors)


func _build_summary(total_steps: int, results: Array[Dictionary], pass_count: int, fail_count: int, errors: Array[String]) -> Dictionary:
	return {
		"total_steps": total_steps,
		"completed_steps": results.size(),
		"assertions_passed": pass_count,
		"assertions_failed": fail_count,
		"errors": errors,
		"all_passed": fail_count == 0 and errors.is_empty(),
		"results": results,
	}


## Load the scenario scene in-process. "main" resolves the project main scene.
## Returns "" on success or an error message.
func _load_scene(scene_path: String) -> String:
	var path := scene_path
	if path == "main" or path.is_empty():
		path = str(ProjectSettings.get_setting("application/run/main_scene", ""))
		if path.is_empty():
			return "scene_path is 'main' but the project has no main scene configured"

	if not ResourceLoader.exists(path, "PackedScene"):
		return "Scene file not found: %s" % path

	var packed: PackedScene = load(path)
	if packed == null:
		return "Failed to load scene: %s" % path

	var instance := packed.instantiate()
	if instance == null:
		return "Failed to instantiate scene: %s" % path

	root.add_child(instance)
	current_scene = instance

	# Let the scene settle (_ready, first physics/process ticks).
	await physics_frame
	for _f in 3:
		await process_frame
	return ""


# ── Step executors (ported from test_commands.gd) ─────────────────────────────

func _execute_input_step(step: Dictionary) -> Dictionary:
	## Execute an input step: simulate action or key press.
	var events: Array = []

	if step.has("action"):
		var pressed: bool = step.get("pressed", true) as bool
		events.append({
			"type": "action",
			"action": str(step["action"]),
			"pressed": pressed,
			"strength": float(step.get("strength", 1.0)),
		})
		# Auto-release if pressed
		if pressed and step.get("auto_release", true):
			events.append({
				"type": "action",
				"action": str(step["action"]),
				"pressed": false,
				"strength": 0.0,
			})
	elif step.has("keycode"):
		var pressed: bool = step.get("pressed", true) as bool
		events.append({
			"type": "key",
			"keycode": str(step["keycode"]),
			"pressed": pressed,
			"shift": step.get("shift", false),
			"ctrl": step.get("ctrl", false),
			"alt": step.get("alt", false),
		})
	else:
		return {"error": "Input step requires 'action' or 'keycode'"}

	var dispatched: int = await _input_service.simulate_sequence(events, int(step.get("frame_delay", 1)))
	if dispatched != events.size():
		return {"error": "Failed to dispatch input events (%d/%d sent)" % [dispatched, events.size()]}
	return {"sent": true, "event_count": dispatched}


func _execute_wait_step(step: Dictionary) -> Dictionary:
	## Execute a wait step: wait for seconds or wait for a node to appear.
	if step.has("node_path"):
		var timeout: float = float(step.get("timeout", 5.0))
		var result: Dictionary = await _inspector.wait_for_node(
			str(step["node_path"]), timeout, int(step.get("poll_frames", 5)))
		if result.has("error"):
			return {"error": "Wait for node failed: %s" % str(result["error"])}
		return {"waited_for": str(step["node_path"]), "found": true}
	else:
		var seconds: float = float(step.get("seconds", 1.0))
		await create_timer(seconds).timeout
		return {"waited_seconds": seconds}


func _execute_assert_step(step: Dictionary) -> Dictionary:
	## Execute an assertion step within a scenario.
	if step.has("text"):
		# Screen text assertion
		var ui_result: Dictionary = _inspector.find_ui_elements()
		if ui_result.has("error"):
			return {"passed": false, "error": "Could not get UI elements: %s" % str(ui_result["error"])}

		var elements: Array = ui_result.get("elements", [])
		var expected_text: String = str(step["text"])
		var partial: bool = step.get("partial", true) as bool
		for element: Dictionary in elements:
			var element_text: String = str(element.get("text", ""))
			if partial and element_text.contains(expected_text):
				return {"passed": true, "assertion": "screen_text", "expected": expected_text, "found_in": element_text}
			elif not partial and element_text == expected_text:
				return {"passed": true, "assertion": "screen_text", "expected": expected_text, "found_in": element_text}

		return {"passed": false, "assertion": "screen_text", "expected": expected_text, "error": "Text not found on screen"}

	elif step.has("node_path") and step.has("property"):
		# Node state assertion
		var result: Dictionary = _inspector.assert_node_state({
			"node_path": str(step["node_path"]),
			"property": str(step["property"]),
			"expected": step.get("expected", null),
			"operator": str(step.get("operator", "eq")),
		})
		if result.has("error"):
			return {"passed": false, "error": str(result["error"])}
		return result

	else:
		return {"passed": false, "error": "Assert step requires 'text' or 'node_path'+'property'"}


func _execute_screenshot_step(step: Dictionary, index: int) -> Dictionary:
	## CI extension: save named screenshot, compare against baseline if present.
	## M1: explicit error under --headless (per DESIGN.md). Visual mode is M2.
	if _screenshot.is_headless():
		return {"error": "Scenario contains a 'screenshot' step but the runner is headless. " +
			"Use visual mode (xvfb + software GL) or remove the step."}

	var shot_name: String = str(step.get("name", "step_%d" % index))
	var dir := _screenshots_dir if not _screenshots_dir.is_empty() else "user://qa-shots"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var shot_path := dir.path_join(shot_name + ".png")

	var capture_result: Dictionary = await _screenshot.capture(shot_path)
	if capture_result.has("error"):
		return capture_result

	var result := {"captured": true, "path": shot_path}

	# Baseline comparison (assert-like) when a same-named baseline exists.
	if not _baseline_dir.is_empty():
		var baseline_path := _baseline_dir.path_join(shot_name + ".png")
		if FileAccess.file_exists(baseline_path):
			var threshold: int = int(step.get("threshold", 10))
			var max_diff_pct: float = float(step.get("max_diff_percentage", 0.0))
			var diff_path := dir.path_join(shot_name + ".diff.png")
			var diff: Dictionary = _screenshot.compare_files(shot_path, baseline_path, threshold, diff_path)
			if diff.has("error"):
				result["error"] = str(diff["error"])
				return result
			result.merge(diff)
			result["passed"] = float(diff.get("diff_percentage", 100.0)) <= max_diff_pct
	return result


# ── Report output ─────────────────────────────────────────────────────────────

func _write_report(summary: Dictionary) -> void:
	var file := FileAccess.open(_report_path, FileAccess.WRITE)
	if file == null:
		printerr("[QA] Could not write report to: %s" % _report_path)
		return
	file.store_string(JSON.stringify(summary, "\t"))
	file.close()
	print("[QA] Report written: %s" % _report_path)


## Write a JUnit XML report (GitHub/GitLab test UI integration, M4).
## Mapping: one <testsuite> per scenario file; each assert / screenshot baseline
## diff result becomes a <testcase> (failures as <failure>); runner errors
## (scene load, input/wait/screenshot errors, ...) become <testcase>/<error>.
func _write_junit(summary: Dictionary) -> void:
	var suite_name := _scenario_path.get_file().get_basename()
	var total_time := float(summary.get("duration_ms", 0)) / 1000.0
	var cases: Array[String] = []
	var tests: int = 0
	var failures: int = 0
	var error_count: int = 0

	for result: Dictionary in summary["results"]:
		var step_type: String = str(result.get("type", ""))
		var is_assert := step_type == "assert"
		var is_shot_diff := step_type == "screenshot" and result.has("passed")
		if not is_assert and not is_shot_diff:
			continue

		tests += 1
		var case_name := _junit_case_name(result)
		var time_s := float(result.get("duration_ms", 0)) / 1000.0
		if result.get("passed", false):
			cases.append("\t\t<testcase name=\"%s\" classname=\"%s\" time=\"%.3f\"/>" % [
				_xml_escape(case_name), _xml_escape(suite_name), time_s])
		else:
			failures += 1
			var message := _junit_failure_message(result)
			cases.append("\t\t<testcase name=\"%s\" classname=\"%s\" time=\"%.3f\">\n\t\t\t<failure message=\"%s\"/>\n\t\t</testcase>" % [
				_xml_escape(case_name), _xml_escape(suite_name), time_s, _xml_escape(message)])

	var errors: Array = summary["errors"]
	for i in errors.size():
		tests += 1
		error_count += 1
		cases.append("\t\t<testcase name=\"%s\" classname=\"%s\" time=\"0.000\">\n\t\t\t<error message=\"%s\"/>\n\t\t</testcase>" % [
			_xml_escape("runner error %d" % i), _xml_escape(suite_name), _xml_escape(str(errors[i]))])

	var xml := "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	xml += "<testsuites tests=\"%d\" failures=\"%d\" errors=\"%d\" time=\"%.3f\">\n" % [tests, failures, error_count, total_time]
	xml += "\t<testsuite name=\"%s\" tests=\"%d\" failures=\"%d\" errors=\"%d\" time=\"%.3f\">\n" % [
		_xml_escape(suite_name), tests, failures, error_count, total_time]
	for case_xml in cases:
		xml += case_xml + "\n"
	xml += "\t</testsuite>\n</testsuites>\n"

	var file := FileAccess.open(_junit_path, FileAccess.WRITE)
	if file == null:
		printerr("[QA] Could not write JUnit XML to: %s" % _junit_path)
		return
	file.store_string(xml)
	file.close()
	print("[QA] JUnit XML written: %s" % _junit_path)


func _junit_case_name(result: Dictionary) -> String:
	var step: int = int(result.get("step", -1))
	if str(result.get("type", "")) == "screenshot":
		return "step %d: screenshot '%s' baseline diff" % [step, str(result.get("path", "")).get_file().get_basename()]
	if result.get("assertion", "") == "screen_text":
		return "step %d: screen text '%s'" % [step, str(result.get("expected", ""))]
	if result.has("node_path"):
		return "step %d: %s.%s %s %s" % [step, str(result.get("node_path", "")),
			str(result.get("property", "")), str(result.get("operator", "eq")), str(result.get("expected", ""))]
	return "step %d: assert" % step


func _junit_failure_message(result: Dictionary) -> String:
	if result.has("error"):
		return str(result["error"])
	if str(result.get("type", "")) == "screenshot":
		return "diff_percentage %s exceeds max_diff_percentage (baseline mismatch)" % str(result.get("diff_percentage", "?"))
	return "expected %s %s, actual %s" % [str(result.get("operator", "eq")),
		str(result.get("expected", "")), str(result.get("actual", "?"))]


func _xml_escape(text: String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") \
		.replace("\"", "&quot;").replace("'", "&apos;")


func _print_summary(summary: Dictionary) -> void:
	print("[QA] scenario : %s" % _scenario_path)
	print("[QA] steps    : %d/%d completed" % [summary["completed_steps"], summary["total_steps"]])
	print("[QA] asserts  : %d passed, %d failed" % [summary["assertions_passed"], summary["assertions_failed"]])
	var errors: Array = summary["errors"]
	print("[QA] errors   : %d" % errors.size())
	for err in errors:
		print("[QA]   - %s" % str(err))
	for result: Dictionary in summary["results"]:
		if result.get("type", "") == "assert" and not result.get("passed", false):
			if result.get("assertion", "") == "screen_text":
				print("[QA]   FAIL step %d: screen text '%s' not found" % [
					result.get("step", -1), str(result.get("expected", ""))])
			else:
				print("[QA]   FAIL step %d: %s.%s %s %s, actual %s" % [
					result.get("step", -1),
					str(result.get("node_path", "")),
					str(result.get("property", "")),
					str(result.get("operator", "")),
					str(result.get("expected", "")),
					str(result.get("actual", result.get("error", "?"))),
				])
	print("[QA] duration : %d ms" % summary["duration_ms"])
	print("[QA] RESULT   : %s" % ("PASS" if summary["all_passed"] else "FAIL"))
