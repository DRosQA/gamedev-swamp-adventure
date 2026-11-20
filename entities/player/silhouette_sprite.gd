extends AnimatedSprite2D

@export var silhouette_sprite: AnimatedSprite2D


func _ready() -> void:
	silhouette_sprite.offset = offset
	silhouette_sprite.flip_v = flip_v
	silhouette_sprite.flip_h = flip_h
	silhouette_sprite.animation = animation
	silhouette_sprite.frame = frame
	silhouette_sprite.play(animation)


func _set(property: StringName, value: Variant) -> bool:
	if is_instance_valid(silhouette_sprite):
		match property:
			"offset":
				offset = value
			"flip_v":
				flip_v = value
			"flip_h":
				flip_h = value
			# "hframes":
				#hframes = value
			# "vframes":
				#vframes = value
			"animation":
				animation = value
			"sprite_frames":
				sprite_frames = value
			"frame":
				frame = value
	return false
