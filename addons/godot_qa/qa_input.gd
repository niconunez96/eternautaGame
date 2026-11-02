## Godot QA Pro — input simulation service.
## Ported from Godot MCP Pro mcp_input_service.gd: the user:// file-polling
## transport is removed; callers invoke the simulate_* methods directly.
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# ── Public API ────────────────────────────────────────────────────────────────

## Simulate a key press/release. keycode is a string like "KEY_SPACE" or "Space".
func simulate_key(keycode: String, pressed: bool = true, shift: bool = false, ctrl: bool = false, alt: bool = false) -> bool:
	var data := {
		"type": "key",
		"keycode": keycode,
		"pressed": pressed,
		"shift": shift,
		"ctrl": ctrl,
		"alt": alt,
	}
	return _dispatch_data(data)


## Simulate an InputEventAction (project input map action).
func simulate_action(action: String, pressed: bool = true, strength: float = 1.0) -> bool:
	var data := {
		"type": "action",
		"action": action,
		"pressed": pressed,
		"strength": strength,
	}
	return _dispatch_data(data)


## Simulate a full mouse click (press + release) at viewport coordinates.
func simulate_mouse_click(position: Vector2, button: int = MOUSE_BUTTON_LEFT, double_click: bool = false) -> bool:
	var press := {
		"type": "mouse_button",
		"button": button,
		"pressed": true,
		"double_click": double_click,
		"position": {"x": position.x, "y": position.y},
	}
	var release := press.duplicate(true)
	release["pressed"] = false
	release["double_click"] = false
	var ok := _dispatch_data(press)
	ok = _dispatch_data(release) and ok
	return ok


## Simulate mouse motion to viewport coordinates.
func simulate_mouse_move(position: Vector2, relative: Vector2 = Vector2.ZERO, button_mask: int = 0) -> bool:
	var data := {
		"type": "mouse_motion",
		"position": {"x": position.x, "y": position.y},
		"relative": {"x": relative.x, "y": relative.y},
		"button_mask": button_mask,
	}
	return _dispatch_data(data)


## Dispatch a sequence of raw event dicts, waiting frame_delay process frames
## between events. Returns the number of events dispatched.
func simulate_sequence(events: Array, frame_delay: int = 1) -> int:
	var dispatched: int = 0
	var delay := maxi(frame_delay, 1)
	for event_data in events:
		if not event_data is Dictionary:
			push_warning("[QA Input] Sequence event is not a Dictionary: %s" % str(event_data))
			continue
		if _dispatch_data(event_data):
			dispatched += 1
		for _f in delay:
			await get_tree().process_frame
	return dispatched


# ── Event creation / dispatch (ported unchanged where possible) ───────────────

func _dispatch_data(event_data: Dictionary) -> bool:
	var event := _create_event(event_data)
	if event == null:
		return false
	_dispatch_event(event, event_data)
	return true


## Dispatch an input event using the appropriate method.
## Mouse drag motions (button_mask > 0) auto-promote to push_input to bypass
## GUI consumption and reach _unhandled_input. Respect an explicit
## "unhandled": false in the event payload — only auto-promote when the
## caller did NOT pass an "unhandled" key.
func _dispatch_event(event: InputEvent, event_data: Dictionary = {}) -> void:
	var force_unhandled: bool
	if event_data.has("unhandled"):
		force_unhandled = bool(event_data.get("unhandled"))
	else:
		force_unhandled = event is InputEventMouseMotion and event.button_mask != 0
	if force_unhandled:
		var vp := get_viewport()
		if vp:
			vp.push_input(event, true)
		else:
			Input.parse_input_event(event)
	else:
		Input.parse_input_event(event)


func _create_event(data: Dictionary) -> InputEvent:
	var type: String = data.get("type", "")
	match type:
		"key":
			return _create_key_event(data)
		"mouse_button":
			return _create_mouse_button_event(data)
		"mouse_motion":
			return _create_mouse_motion_event(data)
		"action":
			return _create_action_event(data)
		_:
			push_warning("[QA Input] Unknown event type: %s" % type)
			return null


## Convert viewport coordinates to window coordinates for Input.parse_input_event().
## Godot applies viewport.get_final_transform() to mouse events internally,
## so we must pass window-space coordinates (pre-transform).
func _viewport_to_window(viewport_pos: Vector2) -> Vector2:
	var vp := get_viewport()
	if vp == null:
		return viewport_pos
	var xform := vp.get_final_transform()
	return xform * viewport_pos


func _create_key_event(data: Dictionary) -> InputEventKey:
	var event := InputEventKey.new()
	var keycode_str: String = data.get("keycode", "")
	if keycode_str.begins_with("KEY_"):
		var constant_value = ClassDB.class_get_integer_constant("@GlobalScope", keycode_str)
		if constant_value != 0:
			event.keycode = constant_value
		else:
			event.keycode = OS.find_keycode_from_string(keycode_str.substr(4))
	else:
		event.keycode = OS.find_keycode_from_string(keycode_str)
	event.pressed = data.get("pressed", true)
	event.shift_pressed = data.get("shift", false)
	event.ctrl_pressed = data.get("ctrl", false)
	event.alt_pressed = data.get("alt", false)
	return event


func _extract_position(data: Dictionary) -> Vector2:
	# Support nested {"position": {"x": ..., "y": ...}} or flat {"x": ..., "y": ...}
	var pos = data.get("position", null)
	if pos is Dictionary:
		return Vector2(pos.get("x", 0.0), pos.get("y", 0.0))
	return Vector2(data.get("x", 0.0), data.get("y", 0.0))


func _create_mouse_button_event(data: Dictionary) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = data.get("button", MOUSE_BUTTON_LEFT)
	event.pressed = data.get("pressed", true)
	event.double_click = data.get("double_click", false)
	var window_pos := _viewport_to_window(_extract_position(data))
	event.position = window_pos
	event.global_position = window_pos
	return event


func _create_mouse_motion_event(data: Dictionary) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	var window_pos := _viewport_to_window(_extract_position(data))
	event.position = window_pos
	event.global_position = window_pos
	# Support nested {"relative": {"x": ..., "y": ...}} or flat {"relative_x": ..., "relative_y": ...}
	var rel_x: float = 0.0
	var rel_y: float = 0.0
	var rel = data.get("relative", null)
	if rel is Dictionary:
		rel_x = float(rel.get("x", 0.0))
		rel_y = float(rel.get("y", 0.0))
	else:
		rel_x = float(data.get("relative_x", 0.0))
		rel_y = float(data.get("relative_y", 0.0))
	# Scale relative movement by the same transform (scale only, no offset)
	var vp := get_viewport()
	if vp:
		var scale := vp.get_final_transform().get_scale()
		event.relative = Vector2(rel_x, rel_y) * scale
	else:
		event.relative = Vector2(rel_x, rel_y)
	# Set button_mask so drag detection works (e.g. camera pan checks button_mask)
	var button_mask: int = int(data.get("button_mask", 0))
	event.button_mask = button_mask
	return event


func _create_action_event(data: Dictionary) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = data.get("action", "")
	event.pressed = data.get("pressed", true)
	event.strength = data.get("strength", 1.0)
	return event
