class_name InteriorProp
extends Node2D

@export_enum("door", "window", "worktable", "family", "canvas", "gloves", "filter") var role := "door"

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	match role:
		"door":
			draw_rect(Rect2(-42, -108, 84, 216), Color("33241f"))
			draw_rect(Rect2(-34, -100, 68, 200), Color("6d4630"))
			draw_rect(Rect2(-26, -88, 52, 70), Color("9d6a42"))
			draw_circle(Vector2(22, 18), 5, Color("d7a65a"))
		"window":
			draw_rect(Rect2(-76, -58, 152, 116), Color("342b2a"))
			draw_rect(Rect2(-66, -48, 132, 96), Color("8eacb4"))
			draw_rect(Rect2(-60, -42, 120, 84), Color("cbe4e6"))
			draw_line(Vector2(0, -42), Vector2(0, 42), Color("53676d"), 6.0)
			draw_line(Vector2(-60, 0), Vector2(60, 0), Color("53676d"), 6.0)
		"worktable":
			draw_rect(Rect2(-105, -35, 210, 22), Color("d49b58"))
			draw_rect(Rect2(-96, -26, 192, 14), Color("845139"))
			for x in [-78, 78]:
				draw_rect(Rect2(x, -12, 14, 74), Color("4b302b"))
			draw_rect(Rect2(-54, -62, 44, 24), Color("416371"))
			draw_rect(Rect2(4, -62, 58, 24), Color("bd7441"))
		"family":
			for x in [-28, 4, 34]:
				draw_circle(Vector2(x, -42), 16, Color("202833"))
				draw_rect(Rect2(x - 14, -25, 28, 66), Color("2d3c4a"))
		"canvas":
			draw_rect(Rect2(-48, -26, 96, 52), Color("7e9c72"))
			draw_line(Vector2(-42, -16), Vector2(42, -16), Color("bed0a5"), 4.0)
		"gloves":
			draw_circle(Vector2(-18, 0), 19, Color("bd7441"))
			draw_circle(Vector2(18, 0), 19, Color("bd7441"))
			draw_rect(Rect2(-42, 12, 84, 18), Color("704434"))
		"filter":
			draw_rect(Rect2(-38, -28, 76, 56), Color("3b5865"))
			draw_circle(Vector2(0, 0), 19, Color("c8d2bf"))
			draw_circle(Vector2(0, 0), 11, Color("718a78"))
