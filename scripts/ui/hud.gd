extends CanvasLayer

@onready var status_label: Label = $StatusLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var exposure_label: Label = $ExposureLabel
@onready var interaction_label: Label = $InteractionLabel
@onready var terminal_overlay: ColorRect = $TerminalOverlay
@onready var terminal_title: Label = $TerminalOverlay/TerminalTitle
@onready var terminal_subtitle: Label = $TerminalOverlay/TerminalSubtitle

func set_status(message: String) -> void:
	status_label.text = message

func set_objective(message: String) -> void:
	objective_label.text = message

func set_exposure(value: float, risk: String, active: bool) -> void:
	exposure_label.visible = active
	exposure_label.text = "EXPOSICIÓN %d%% · %s" % [roundi(value), risk.to_upper()]

func set_interaction_prompt(message: String) -> void:
	interaction_label.visible = not message.is_empty()
	interaction_label.text = message

func show_terminal(title: String, consequence: String) -> void:
	terminal_title.text = title
	terminal_subtitle.text = consequence
	terminal_overlay.show()
