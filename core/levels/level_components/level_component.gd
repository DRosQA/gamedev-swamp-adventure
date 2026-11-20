extends Node

@export var player_spawn: Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(AudioManager.level_music_uid)
	AudioManager.play_sound(AudioManager.level_ambiance_uid, "Ambiance")


func get_level_bounds() -> Array[int]:
	var tilemap_rect = %Ground.get_used_rect()
	var tilemap_cell_size = %Ground.tile_set.tile_size
	return [tilemap_rect.position.x * tilemap_cell_size.x,
	tilemap_rect.position.y * tilemap_cell_size.y,
	tilemap_rect.end.x * tilemap_cell_size.x,
	tilemap_rect.end.y * tilemap_cell_size.y]
	# going clockwise, left top right bottom
