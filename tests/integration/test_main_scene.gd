extends GutTest

func test_main_scene_instantiates() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	assert_not_null(packed_scene)
	var instance := packed_scene.instantiate()
	assert_not_null(instance)
	instance.queue_free()
