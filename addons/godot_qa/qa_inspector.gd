## Godot QA Pro — game state inspection service.
## Ported from Godot MCP Pro mcp_game_inspector_service.gd — only the
## assert_node_state / find_ui_elements / wait_for_node parts. File-IPC removed;
## methods return their result Dictionary directly.
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# ── assert_node_state ─────────────────────────────────────────────────────────

## Assert a node's property against an expected value.
## Operators: eq, neq, gt, lt, gte, lte, contains, type_is.
## Indexed properties supported via "prop:sub" (get_indexed).
## Returns {"error": ...} on bad params, else the assertion result dict.
func assert_node_state(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	if node_path.is_empty():
		return {"error": "node_path is required"}

	var property: String = params.get("property", "")
	if property.is_empty():
		return {"error": "property is required"}

	var node := get_node_or_null(NodePath(node_path))
	if node == null:
		return {"error": "Node not found: %s" % node_path}

	var actual: Variant
	if ":" in property:
		actual = node.get_indexed(NodePath(property))
	else:
		actual = node.get(property)
	var expected: Variant = params.get("expected", null)
	var operator: String = params.get("operator", "eq")
	var passed: bool = false

	match operator:
		"eq":
			passed = (str(actual) == str(expected)) or (actual == expected)
		"neq":
			passed = (actual != expected) and (str(actual) != str(expected))
		"gt":
			passed = float(actual) > float(expected)
		"lt":
			passed = float(actual) < float(expected)
		"gte":
			passed = float(actual) >= float(expected)
		"lte":
			passed = float(actual) <= float(expected)
		"contains":
			passed = str(actual).contains(str(expected))
		"type_is":
			passed = typeof(actual) == int(expected) or type_string(typeof(actual)) == str(expected)
		_:
			return {"error": "Unknown operator: %s" % operator}

	return {
		"assertion": "node_state",
		"node_path": node_path,
		"property": property,
		"operator": operator,
		"expected": _serialize_value(expected),
		"actual": _serialize_value(actual),
		"passed": passed,
	}


# ── find_ui_elements ──────────────────────────────────────────────────────────

## Collect visible UI elements (Button/Label/LineEdit/TextEdit/OptionButton/
## CheckBox/sliders) under the current scene. Backs screen-text assertions.
func find_ui_elements(type_filter: String = "") -> Dictionary:
	var root := get_tree().current_scene
	if root == null:
		return {"error": "No current scene"}

	var elements: Array = []
	_find_ui_recursive(root, type_filter, elements)
	return {"elements": elements, "count": elements.size()}


func _find_ui_recursive(node: Node, type_filter: String, results: Array) -> void:
	if node is Control and node.visible:
		var ctrl: Control = node
		var entry: Dictionary = {}
		var include := false

		if ctrl is Button:
			var btn: Button = ctrl
			entry["type"] = "Button"
			entry["text"] = btn.text
			entry["disabled"] = btn.disabled
			include = true
		elif ctrl is Label:
			var lbl: Label = ctrl
			entry["type"] = "Label"
			entry["text"] = lbl.text
			include = true
		elif ctrl is LineEdit:
			var le: LineEdit = ctrl
			entry["type"] = "LineEdit"
			entry["text"] = le.text
			entry["placeholder"] = le.placeholder_text
			include = true
		elif ctrl is TextEdit:
			var te: TextEdit = ctrl
			entry["type"] = "TextEdit"
			entry["text"] = te.text.left(200)
			include = true
		elif ctrl is OptionButton:
			var ob: OptionButton = ctrl
			entry["type"] = "OptionButton"
			entry["text"] = ob.text
			entry["selected"] = ob.selected
			include = true
		elif ctrl is CheckBox:
			var cb: CheckBox = ctrl
			entry["type"] = "CheckBox"
			entry["text"] = cb.text
			entry["checked"] = cb.button_pressed
			include = true
		elif ctrl is HSlider or ctrl is VSlider:
			var sl: Range = ctrl
			entry["type"] = "HSlider" if ctrl is HSlider else "VSlider"
			entry["value"] = sl.value
			entry["min"] = sl.min_value
			entry["max"] = sl.max_value
			include = true

		if include:
			if not type_filter.is_empty() and entry.get("type", "") != type_filter:
				pass  # Skip non-matching types
			else:
				var rect := ctrl.get_global_rect()
				entry["name"] = str(ctrl.name)
				entry["path"] = str(ctrl.get_path())
				entry["rect"] = {
					"x": rect.position.x,
					"y": rect.position.y,
					"width": rect.size.x,
					"height": rect.size.y,
				}
				entry["center"] = {
					"x": rect.position.x + rect.size.x / 2.0,
					"y": rect.position.y + rect.size.y / 2.0,
				}
				results.append(entry)

	for child in node.get_children():
		_find_ui_recursive(child, type_filter, results)


# ── wait_for_node ─────────────────────────────────────────────────────────────

## Poll until a node exists at node_path or the wall-clock timeout elapses.
## Polls every poll_frames process frames.
func wait_for_node(node_path: String, timeout_sec: float = 5.0, poll_frames: int = 5) -> Dictionary:
	if node_path.is_empty():
		return {"error": "'node_path' is required"}

	var poll_interval := maxi(poll_frames, 1)
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)

	while true:
		var node := get_node_or_null(NodePath(node_path))
		if node != null:
			var result := {
				"found": true,
				"node_path": str(node.get_path()),
				"type": node.get_class(),
				"name": str(node.name),
			}
			var script: Script = node.get_script()
			if script:
				result["script"] = script.resource_path
			return result

		if Time.get_ticks_msec() >= deadline:
			break

		# Wait poll_interval frames
		for _f in poll_interval:
			await get_tree().process_frame

	return {
		"found": false,
		"node_path": node_path,
		"error": "Node not found after %.1fs" % timeout_sec,
	}


# ── Value serialization (for JSON reports) ────────────────────────────────────

func _serialize_value(value: Variant) -> Variant:
	if value == null:
		return null
	match typeof(value):
		TYPE_VECTOR2:
			var v: Vector2 = value
			return {"x": v.x, "y": v.y}
		TYPE_VECTOR2I:
			var v: Vector2i = value
			return {"x": v.x, "y": v.y}
		TYPE_VECTOR3:
			var v: Vector3 = value
			return {"x": v.x, "y": v.y, "z": v.z}
		TYPE_VECTOR3I:
			var v: Vector3i = value
			return {"x": v.x, "y": v.y, "z": v.z}
		TYPE_RECT2:
			var r: Rect2 = value
			return {"x": r.position.x, "y": r.position.y, "width": r.size.x, "height": r.size.y}
		TYPE_COLOR:
			var c: Color = value
			return {"r": c.r, "g": c.g, "b": c.b, "a": c.a, "html": "#" + c.to_html()}
		TYPE_NODE_PATH:
			return str(value)
		TYPE_OBJECT:
			if value is Resource:
				var res: Resource = value
				return {"type": res.get_class(), "path": res.resource_path}
			return str(value)
		TYPE_ARRAY:
			var arr: Array = value
			var result: Array = []
			for item in arr:
				result.append(_serialize_value(item))
			return result
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			var result: Dictionary = {}
			for key in dict:
				result[str(key)] = _serialize_value(dict[key])
			return result
		_:
			return value
