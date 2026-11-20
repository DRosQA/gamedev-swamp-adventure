class_name JumpComponent extends Node

signal has_jumped
signal has_landed

@export var JUMP_MAX_HEIGHT: float = 70 ## in pixels, I believe, since velocity is in px/sec

var can_air_jump: bool = true
var current_consecutive_jumps: int = 0
var max_air_jumps: int = 1
var currently_landing: bool

## these are just magic numbers. They feel good and juicy
@onready var jump_time_to_apex: float = JUMP_MAX_HEIGHT / 150 ## in seconds, I think
@onready var jump_time_to_desc: float = 0.8 * jump_time_to_apex ## in seconds, I think
## the (2* x)/y is the math formula for the jump physics taken from the internet
## Godot Y points down, so upwarde velocity has to be negative
@onready var jump_velocity: float = ((2.0 * JUMP_MAX_HEIGHT) / jump_time_to_apex) * -1.0


func handle_jump(body: CharacterBody2D, is_airborne: bool, want_to_jump: bool) -> void:
	if (want_to_jump
			and (not is_airborne or (can_air_jump and current_consecutive_jumps < max_air_jumps))):
		current_consecutive_jumps += 1
		has_jumped.emit()
		body.velocity.y = jump_velocity


func handle_landing(is_airborne: bool)-> void:
	if not is_airborne:
		if currently_landing:
			has_landed.emit()
			currently_landing = false
	else:
		if not currently_landing:
			current_consecutive_jumps = 0
			currently_landing = true


func enable_air_jumps(enabled: bool = true) -> void:
	can_air_jump = enabled


func set_max_air_jumps(max_airjumps: int) -> void:
	max_air_jumps = max_airjumps
