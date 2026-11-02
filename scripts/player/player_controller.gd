extends CharacterBody2D

const SPEED := 360.0
const ACCELERATION := 2200.0
const JUMP_VELOCITY := -560.0
const DASH_SPEED := 760.0
const DASH_DURATION := 0.15
const DASH_COOLDOWN := 0.45
var facing := 1
var coyote_remaining := 0.0
var dash_remaining := 0.0
var dash_cooldown := 0.0
var dash_direction := 1

func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	coyote_remaining = 0.12 if is_on_floor() else maxf(0.0, coyote_remaining - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	if Input.is_action_just_pressed("jump") and PlayerMotionRules.can_jump(is_on_floor(), coyote_remaining, 0.12):
		velocity.y = JUMP_VELOCITY
		coyote_remaining = 0.0
	var axis := Input.get_axis("move_left", "move_right")
	if absf(axis) > 0.01: facing = 1 if axis > 0.0 else -1
	if Input.is_action_just_pressed("dash") and PlayerMotionRules.can_dash(dash_cooldown):
		dash_direction = PlayerMotionRules.resolve_dash_direction(axis, facing)
		dash_remaining = DASH_DURATION
		dash_cooldown = DASH_COOLDOWN
	if dash_remaining > 0.0:
		dash_remaining -= delta
		velocity = Vector2(dash_direction * DASH_SPEED, 0.0)
	else:
		velocity.x = PlayerMotionRules.accelerate(velocity.x, axis * SPEED, ACCELERATION, delta)
	move_and_slide()
