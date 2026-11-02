class_name PlayerMotionRules
extends RefCounted

static func accelerate(current: float, target: float, rate: float, delta: float) -> float:
	return move_toward(current, target, rate * delta)

static func can_jump(is_on_floor: bool, coyote_remaining: float, _coyote_window: float) -> bool:
	return is_on_floor or coyote_remaining > 0.0

static func resolve_dash_direction(input_axis: float, facing_direction: int) -> int:
	if absf(input_axis) < 0.01:
		return facing_direction
	return 1 if input_axis > 0.0 else -1

static func can_dash(cooldown_remaining: float) -> bool:
	return cooldown_remaining <= 0.0
