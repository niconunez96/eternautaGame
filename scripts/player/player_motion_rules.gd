class_name PlayerMotionRules
extends RefCounted

static func accelerate(current: float, target: float, rate: float, delta: float) -> float:
	return move_toward(current, target, rate * delta)

static func can_jump(is_on_floor: bool, coyote_remaining: float, _coyote_window: float) -> bool:
	return is_on_floor or coyote_remaining > 0.0

static func can_second_air_jump() -> bool:
	return false
