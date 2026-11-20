class_name InputComponent extends Node2D

@export var INPUT_INTERACTION: String

var input_horizontal_direction: float = 0.0


func _process(_delta: float) -> void:
	input_horizontal_direction = Input.get_axis("move_left", "move_right")


func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")


func get_sprint_input() -> bool:
	return Input.is_action_pressed("sprint")


func get_interaction_input() -> bool:
	return Input.is_action_just_pressed(INPUT_INTERACTION)
