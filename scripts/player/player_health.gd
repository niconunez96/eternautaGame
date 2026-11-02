class_name PlayerHealth
extends RefCounted

static func apply_damage(current_health: int, damage: int, invulnerable: bool = false) -> int:
	if invulnerable:
		return current_health
	return maxi(0, current_health - maxi(0, damage))

static func heal(current_health: int, maximum_health: int, amount: int) -> int:
	return mini(maximum_health, current_health + maxi(0, amount))
