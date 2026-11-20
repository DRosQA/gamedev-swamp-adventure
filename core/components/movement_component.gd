class_name MovementComponent extends Node2D

@export var WALK_MOVE_SPEED: float = 100

var current_speed: float = WALK_MOVE_SPEED
var SPRINT_SPEED: float = WALK_MOVE_SPEED * 2
var SLIDE_SPEED: float = current_speed / 10
var can_airdrift: bool = true


func handle_movement(
	body: CharacterBody2D,
	can_move: bool,
	direction: float,
	is_airborne: bool,
	is_sprinting: bool
) -> void:
	_set_movespeed(is_sprinting)
	# direction is 0 if player is not currently holding movement keys
	if direction == 0:
		# adds slight braking slide to movement
		body.velocity.x = move_toward(body.velocity.x, 0, SLIDE_SPEED)
		#return
	if can_move and direction != 0 and (not is_airborne or can_airdrift):
		body.velocity.x = move_toward(body.velocity.x, direction * current_speed, SLIDE_SPEED)


func _set_movespeed(is_sprinting: bool) -> void:
	current_speed = SPRINT_SPEED if is_sprinting else WALK_MOVE_SPEED


func enable_airdrift(enabled: bool) ->void:
	can_airdrift = enabled
