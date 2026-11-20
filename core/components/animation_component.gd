class_name AnimationComponent extends Node2D

enum Animations {
	IDLE,
	WALK,
	RUN,
	JUMP,
	JUMP_END,
	CROAK,
}

@export var sprite: AnimatedSprite2D
# @export var silhouette_shaderUID = "uid://caibwgdf8urke"
#
#var silhouette: AnimatedSprite2D
#var apply_silhouette: bool = false
#
# @onready var silhouette_shader: Shader = load(silhouette_shaderUID)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if not silhouette_shaderUID.is_empty():
		#silhouette = sprite.duplicate()
		#silhouette.name = "SilhouetteSprite"
		#silhouette.z_index = 5
		#sprite.add_child(silhouette)
		## silhouette.material = ShaderMaterial.new()
		## silhouette.material.shader = silhouette_shader
		#apply_silhouette = true
	set_animation(Animations.IDLE)


func _manage_animations(	velocity: Vector2, is_airborne: bool) -> void:
	## flip the sprite according to x velocity IF the velocity is not 0
	## at 0, leave flip as it is, i.e. the last direction the sprite was facing
	#if apply_silhouette: silhouette.flip_h = sprite.flip_h
	if is_airborne:
		set_animation(Animations.JUMP)
		return
	if abs(velocity.x) > 100:
		set_animation(Animations.RUN)
		return
	if velocity.x != 0.0:
		set_animation(Animations.WALK)
		return
	set_animation(Animations.IDLE)


func animate_sprite(velocity: Vector2, is_airborne: bool) -> void:
	sprite.flip_h = sprite.flip_h if velocity.x == 0 else velocity.x < 0
	_manage_animations(velocity, is_airborne)
	sprite.play()


func set_animation(target_animation: Animations) -> void:
	if sprite.animation != Animations.keys()[target_animation]:
		if sprite.is_playing() and target_animation == Animations.IDLE:
				await sprite.animation_finished
		sprite.play(Animations.keys()[target_animation])
		#if apply_silhouette: silhouette.play(Animations.keys()[target_animation])
