extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var checkpoint_label: Label = $CheckpointLabel
@onready var ability_label: Label = $AbilityLabel
@onready var status_label: Label = $StatusLabel
@onready var objective_label: Label = $ObjectiveLabel

func set_health(current: int, maximum: int) -> void:
	health_label.text = "Health: %d / %d" % [current, maximum]

func set_checkpoint(active: bool) -> void:
	checkpoint_label.text = "Checkpoint: active" if active else "Checkpoint: start"

func set_ability(acquired: bool) -> void:
	ability_label.text = "Double jump: acquired" if acquired else "Double jump: missing"

func set_status(message: String) -> void:
	status_label.text = message

func set_objective(message: String) -> void:
	objective_label.text = message
