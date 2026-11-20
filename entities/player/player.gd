extends Node

enum Animations {
	IDLE,
	WALK,
	JUMP,
	JUMP_END,
	CROAK,
}

@export_category("Components")
@export var JUMP_COMPONENT: JumpComponent:
	set(value):
		JUMP_COMPONENT = value
		update_configuration_warnings()

@export var GRAVITY_COMPONENT: GravityComponent:
	set(value):
		GRAVITY_COMPONENT = value
		update_configuration_warnings()

@export var MOVEMENT_COMPONENT: MovementComponent:
	set(value):
		MOVEMENT_COMPONENT = value
		update_configuration_warnings()

@export var INPUT_COMPONENT: InputComponent:
	set(value):
		INPUT_COMPONENT = value
		update_configuration_warnings()

@export var ANIMATION_COMPONENT: AnimationComponent:
	set(value):
		ANIMATION_COMPONENT = value
		update_configuration_warnings()

@export var CHARACTER_BODY: CharacterBody2D:
	set(value):
		CHARACTER_BODY = value
		update_configuration_warnings()

@export var SPRITE: AnimatedSprite2D
@export_category("SFX")
@export var jump_sfx_uid: String = "uid://dkbb1j7xiso5h"
@export var croak_sfx_uid: String = "uid://dhgywv4kdhkpd"
@export var death_sfx_uid: String = "uid://jsdr6cdgcw3u"

var can_move: bool = false
var is_airborne: bool = false
var was_airborne: bool = false
var should_reverb: bool = false

@onready var CAMERA: Camera2D = %Camera2D


func _ready() -> void:
	can_move = true
	GRAVITY_COMPONENT.set_jump_gravity(
		JUMP_COMPONENT.JUMP_MAX_HEIGHT,
		JUMP_COMPONENT.jump_time_to_apex,
	)
	GRAVITY_COMPONENT.set_fall_gravity(
		JUMP_COMPONENT.JUMP_MAX_HEIGHT,
		JUMP_COMPONENT.jump_time_to_desc,
	)
	_connect_component_signals()


func _process(_delta: float) -> void:
	handle_croaking(INPUT_COMPONENT.get_interaction_input())
	ANIMATION_COMPONENT.animate_sprite(CHARACTER_BODY.velocity, is_airborne)


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	is_airborne = check_if_airborne()
	JUMP_COMPONENT.handle_landing(is_airborne)
	GRAVITY_COMPONENT.handle_gravity(CHARACTER_BODY, delta)
	MOVEMENT_COMPONENT.handle_movement(
		CHARACTER_BODY,
		can_move,
		INPUT_COMPONENT.input_horizontal_direction,
		is_airborne,
		INPUT_COMPONENT.get_sprint_input()
	)
	JUMP_COMPONENT.handle_jump(CHARACTER_BODY, is_airborne, INPUT_COMPONENT.get_jump_input())
	CHARACTER_BODY.move_and_slide()


func set_camera_limits(limits_array: Array[int]) -> void:
	CAMERA.set_limit(SIDE_LEFT, limits_array[0])
	#CAMERA.set_limit(SIDE_TOP, limits_array[1])
	CAMERA.set_limit(SIDE_RIGHT, limits_array[2])
	CAMERA.set_limit(SIDE_BOTTOM, limits_array[3])


func _connect_component_signals()-> void:
	JUMP_COMPONENT.has_jumped.connect(_on_player_jumped)
	JUMP_COMPONENT.has_landed.connect(_on_player_landed)


func _on_player_landed() -> void:
	ANIMATION_COMPONENT.set_animation(ANIMATION_COMPONENT.Animations.JUMP_END)


func _on_player_jumped() -> void:
	ANIMATION_COMPONENT.set_animation(ANIMATION_COMPONENT.Animations.JUMP)
	AudioManager.play_sound(jump_sfx_uid)


func check_if_airborne() -> bool:
	return not CHARACTER_BODY.is_on_floor() or CHARACTER_BODY.velocity.y < 0


func handle_croaking(want_to_croak: bool) -> void:
	if want_to_croak and not is_airborne:
		disable_movement()
		stop_movement()
		AudioManager.play_sound(croak_sfx_uid)
		ANIMATION_COMPONENT.set_animation(ANIMATION_COMPONENT.Animations.CROAK)
		await SPRITE.animation_finished
		enable_movement()


func stop_movement() -> void:
	CHARACTER_BODY.velocity.x = 0.0


func disable_movement() -> void:
	can_move = false


func enable_movement() -> void:
	can_move = true
