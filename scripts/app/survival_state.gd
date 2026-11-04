class_name SurvivalState
extends RefCounted

const WARNING_EXPOSURE := 50.0
const CRITICAL_EXPOSURE := 75.0
const LETHAL_EXPOSURE := 100.0
const FILTER_RELIEF := 50.0

var exposure := 0.0
var has_spare_filter := true

func tick(delta: float, in_shelter: bool) -> void:
	if in_shelter:
		exposure = maxf(0.0, exposure - delta * 2.0)
	else:
		exposure = minf(LETHAL_EXPOSURE, exposure + delta)

func risk_label() -> String:
	if exposure >= LETHAL_EXPOSURE:
		return "lethal"
	if exposure >= CRITICAL_EXPOSURE:
		return "critical"
	if exposure >= WARNING_EXPOSURE:
		return "warning"
	return "stable"

func is_lethal() -> bool:
	return exposure >= LETHAL_EXPOSURE

func use_spare_filter() -> bool:
	if not has_spare_filter:
		return false
	has_spare_filter = false
	exposure = maxf(0.0, exposure - FILTER_RELIEF)
	return true
