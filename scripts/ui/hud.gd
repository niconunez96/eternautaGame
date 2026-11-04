extends CanvasLayer

@onready var status_label: Label = $StatusLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var exposure_label: Label = $ExposureLabel
@onready var terminal_overlay: ColorRect = $TerminalOverlay
@onready var terminal_title: Label = $TerminalOverlay/TerminalTitle

func set_status(message: String) -> void:
	status_label.text = message

func set_objective(message: String) -> void:
	objective_label.text = message

func set_exposure(value: float, risk: String, active: bool) -> void:
	exposure_label.visible = active
	exposure_label.text = "EXPOSICIÓN %d%% · %s" % [roundi(value), risk.to_upper()]

func show_terminal(title: String) -> void:
	terminal_title.text = title
	terminal_overlay.show()
