## Godot QA Pro — screenshot capture + pixel-diff service.
## Ported from Godot MCP Pro mcp_screenshot_service.gd (capture, request-file
## transport removed) and editor_commands.gd _compare_screenshots (pixel diff).
##
## M1 note: under --headless the viewport has no rendered image, so capture()
## returns an explicit error (per DESIGN.md — never silently save an empty
## image). Visual mode (xvfb / windowed) is M2.
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## True when running under a headless DisplayServer (no GPU rendering).
func is_headless() -> bool:
	return DisplayServer.get_name() == "headless"


# ── Capture ───────────────────────────────────────────────────────────────────

## Capture the current viewport to save_path (PNG).
## Returns {"saved": true, "path": ..., "width": ..., "height": ...} or {"error": ...}.
func capture(save_path: String) -> Dictionary:
	if is_headless():
		return {
			"error": "Screenshot capture is not possible under --headless (no rendered image). " +
				"Run in visual mode (xvfb + software GL on CI, or windowed locally).",
		}

	# Wait so the viewport has a fully rendered image
	await get_tree().create_timer(0.05).timeout

	var viewport := get_viewport()
	if viewport == null:
		return {"error": "No viewport available"}

	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		return {"error": "Viewport returned an empty image"}

	var err := image.save_png(save_path)
	if err != OK:
		return {"error": "Failed to save PNG to '%s': %s" % [save_path, error_string(err)]}

	return {
		"saved": true,
		"path": save_path,
		"width": image.get_width(),
		"height": image.get_height(),
	}


# ── Image loading ─────────────────────────────────────────────────────────────

## Load an Image from a file path (res://, user://, or absolute OS path) or
## raw base64 PNG data. Returns [Image, null] on success, [null, error_string].
func load_image_from_param(value: String, label: String) -> Array:
	var img := Image.new()
	if value.begins_with("res://") or value.begins_with("user://") or FileAccess.file_exists(value):
		var err := img.load(value)
		if err != OK:
			return [null, "Failed to load %s from path '%s': %s" % [label, value, error_string(err)]]
		return [img, null]
	# Treat as base64 PNG
	var buf := Marshalls.base64_to_raw(value)
	var err := img.load_png_from_buffer(buf)
	if err != OK:
		return [null, "Failed to decode %s from base64: %s" % [label, error_string(err)]]
	return [img, null]


# ── Pixel diff ────────────────────────────────────────────────────────────────

## Compare two images per-pixel. A pixel counts as changed when the max RGB
## channel delta exceeds threshold (0-255). Returns stats + a diff Image
## (changed pixels highlighted red, unchanged dimmed).
func compare_images(img_a: Image, img_b: Image, threshold: int = 10) -> Dictionary:
	if img_a == null or img_b == null:
		return {"error": "compare_images requires two valid images"}
	if img_a.get_size() != img_b.get_size():
		return {"error": "Image sizes differ: %s vs %s" % [str(img_a.get_size()), str(img_b.get_size())]}

	var width := img_a.get_width()
	var height := img_a.get_height()
	var diff_image := Image.create(width, height, false, Image.FORMAT_RGBA8)

	var changed_pixels: int = 0
	var total_pixels: int = width * height

	for y in height:
		for x in width:
			var ca: Color = img_a.get_pixel(x, y)
			var cb: Color = img_b.get_pixel(x, y)
			var dr := absi(int(ca.r8) - int(cb.r8))
			var dg := absi(int(ca.g8) - int(cb.g8))
			var db := absi(int(ca.b8) - int(cb.b8))
			var max_diff := maxi(dr, maxi(dg, db))
			if max_diff > threshold:
				changed_pixels += 1
				# Red highlight for changed pixels
				diff_image.set_pixel(x, y, Color(1, 0, 0, clampf(float(max_diff) / 255.0, 0.3, 1.0)))
			else:
				# Dim version of original
				diff_image.set_pixel(x, y, Color(ca.r * 0.3, ca.g * 0.3, ca.b * 0.3, 1.0))

	var diff_percentage: float = (float(changed_pixels) / float(total_pixels)) * 100.0

	return {
		"identical": changed_pixels == 0,
		"changed_pixels": changed_pixels,
		"total_pixels": total_pixels,
		"diff_percentage": snappedf(diff_percentage, 0.01),
		"threshold": threshold,
		"width": width,
		"height": height,
		"diff_image": diff_image,
	}


## Convenience: compare two image files, optionally saving the diff image.
func compare_files(path_a: String, path_b: String, threshold: int = 10, diff_out_path: String = "") -> Dictionary:
	var load_a := load_image_from_param(path_a, "image_a")
	if load_a[1] != null:
		return {"error": load_a[1]}
	var load_b := load_image_from_param(path_b, "image_b")
	if load_b[1] != null:
		return {"error": load_b[1]}

	var result := compare_images(load_a[0], load_b[0], threshold)
	if result.has("error"):
		return result

	if not diff_out_path.is_empty():
		var diff_image: Image = result["diff_image"]
		var err := diff_image.save_png(diff_out_path)
		if err == OK:
			result["diff_path"] = diff_out_path
	result.erase("diff_image")  # Not JSON-serializable
	return result
