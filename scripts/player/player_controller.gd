extends CharacterBody2D

const SPEED := 300.0
const ACCELERATION := 2200.0
const JUMP_VELOCITY := -500.0
const COYOTE_WINDOW := 0.12

var facing := 1
var coyote_remaining := 0.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	coyote_remaining = COYOTE_WINDOW if is_on_floor() else maxf(0.0, coyote_remaining - delta)
	if Input.is_action_just_pressed("jump"):
		request_jump()
	var axis := Input.get_axis("move_left", "move_right")
	if absf(axis) > 0.01:
		facing = 1 if axis > 0.0 else -1
	velocity.x = PlayerMotionRules.accelerate(velocity.x, axis * SPEED, ACCELERATION, delta)
	move_and_slide()

func request_jump() -> bool:
	if not PlayerMotionRules.can_jump(is_on_floor(), coyote_remaining, COYOTE_WINDOW):
		return false
	velocity.y = JUMP_VELOCITY
	coyote_remaining = 0.0
	return true
