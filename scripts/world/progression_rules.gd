class_name ProgressionRules
extends RefCounted

static func collect_access_key(_already_collected: bool) -> bool:
	return true

static func can_unlock(has_access_key: bool) -> bool:
	return has_access_key
