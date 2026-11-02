extends CanvasLayer

@onready var status_label: Label = $StatusLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var slice_state_label: Label = $SliceStateLabel
@onready var terminal_overlay: ColorRect = $TerminalOverlay
@onready var terminal_title: Label = $TerminalOverlay/TerminalTitle

func set_status(message: String) -> void:
	status_label.text = message

func set_objective(message: String) -> void:
	objective_label.text = message

func set_slice_state(value: String) -> void:
	slice_state_label.text = "Slice: %s" % value

func show_terminal(title: String) -> void:
	terminal_title.text = title
	terminal_overlay.show()
