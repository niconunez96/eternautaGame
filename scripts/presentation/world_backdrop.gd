class_name WorldBackdrop
extends Node2D

@export_enum("chalet", "street") var setting := "chalet"

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if setting == "street":
		_draw_street()
		return
	_draw_chalet()

func _draw_chalet() -> void:
	draw_rect(Rect2(0, 0, 1280, 800), Color("1c2634"))
	draw_rect(Rect2(0, 110, 1280, 580), Color("3a2a28"))
	draw_rect(Rect2(0, 590, 1280, 120), Color("261b1c"))
	for x in range(0, 1280, 128):
		draw_rect(Rect2(x, 138, 6, 540), Color("2b2021"))
		draw_line(Vector2(x + 18, 470), Vector2(x + 108, 470), Color("684638"), 3.0)
	for x in range(0, 1280, 64):
		draw_rect(Rect2(x, 675, 60, 12), Color("704d3d"))
	draw_rect(Rect2(38, 500, 175, 12), Color("4a302c"))
	draw_rect(Rect2(52, 515, 30, 92), Color("4a302c"))
	draw_rect(Rect2(168, 515, 30, 92), Color("4a302c"))
	draw_rect(Rect2(250, 530, 120, 95), Color("3d2c29"))
	draw_rect(Rect2(264, 546, 92, 16), Color("b7844c"))
	draw_rect(Rect2(278, 570, 64, 40), Color("694735"))
	draw_circle(Vector2(960, 515), 68, Color(1.0, 0.55, 0.2, 0.10))

func _draw_street() -> void:
	draw_rect(Rect2(0, 0, 1280, 800), Color("172633"))
	draw_rect(Rect2(0, 270, 1280, 380), Color("2c4050"))
	for x in range(0, 1280, 180):
		draw_rect(Rect2(x, 230, 150, 300), Color("263746"))
		draw_rect(Rect2(x + 20, 270, 34, 46), Color("6e92a0"))
		draw_rect(Rect2(x + 86, 300, 34, 46), Color("6e92a0"))
	draw_rect(Rect2(0, 625, 1280, 175), Color("d9e6e9"))
	for y in [660, 710]:
		draw_line(Vector2(0, y), Vector2(1280, y), Color("b5cdd4"), 5.0)
	draw_rect(Rect2(760, 480, 230, 180), Color("263b43"))
	draw_rect(Rect2(785, 505, 180, 125), Color("5a4437"))
	draw_rect(Rect2(815, 530, 52, 60), Color("f1b655"))
	draw_rect(Rect2(885, 530, 52, 60), Color("f1b655"))
	draw_circle(Vector2(876, 555), 105, Color(1.0, 0.58, 0.24, 0.16))
	draw_rect(Rect2(615, 475, 12, 190), Color("111b24"))
	draw_line(Vector2(621, 475), Vector2(680, 430), Color("111b24"), 5.0)
	draw_circle(Vector2(680, 430), 12, Color("d48d4b"))
	for x in range(70, 1280, 130):
		draw_line(Vector2(x, 120), Vector2(x - 30, 600), Color(0.9, 0.96, 1.0, 0.35), 2.0)
