class_name GravityComponent extends Node2D

var jump_gravity: float
var fall_gravity:  float


func calculate_gravity(jump_height: float, jump_target_time: float) -> float:
	## reverse-engineer gravity based on exact height desired
	return (2.0 * jump_height) / pow(jump_target_time, 2)


func set_jump_gravity(jump_height: float, jump_apex_time: float) -> void:
	jump_gravity = calculate_gravity(jump_height, jump_apex_time)


func set_fall_gravity(jump_height: float, jump_descent_time: float) -> void:
	fall_gravity = calculate_gravity(jump_height, jump_descent_time)


## variable gravity so you fall faster than you ascend
func get_gravity(velocityY: float) -> float:
	return jump_gravity if velocityY < 0.0  else fall_gravity


func handle_gravity(body: CharacterBody2D, delta: float) -> void:
		body.velocity.y += get_gravity(body.velocity.y) * delta
