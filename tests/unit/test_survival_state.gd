extends GutTest

const SurvivalState = preload("res://scripts/app/survival_state.gd")

func test_exposure_only_rises_outside_shelter() -> void:
	var survival = SurvivalState.new()
	survival.tick(10.0, true)
	assert_eq(survival.exposure, 0.0)
	survival.tick(10.0, false)
	assert_eq(survival.exposure, 10.0)

func test_exposure_reports_warning_critical_and_lethal_thresholds() -> void:
	var survival = SurvivalState.new()
	survival.tick(50.0, false)
	assert_eq(survival.risk_label(), "warning")
	survival.tick(25.0, false)
	assert_eq(survival.risk_label(), "critical")
	survival.tick(25.0, false)
	assert_true(survival.is_lethal())

func test_spare_filter_can_be_used_once_to_reduce_exposure() -> void:
	var survival = SurvivalState.new()
	survival.tick(80.0, false)
	assert_true(survival.use_spare_filter())
	assert_eq(survival.exposure, 30.0)
	assert_false(survival.use_spare_filter())

func test_shelter_reduces_exposure_after_the_player_reaches_safety() -> void:
	var survival = SurvivalState.new()
	survival.tick(80.0, false)
	survival.tick(10.0, true)
	assert_eq(survival.exposure, 60.0)
