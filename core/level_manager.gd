extends Node

const LEVELS_UIDS: Dictionary = {
	1: "uid://fpdsorj2260",
}


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#EventsBus.level_launched.connect(_on_level_launched)
	#pass

var player
var current_level: Node
var PLAYER_UID: String = "uid://diu4m4xbplxs"


func init_level(scene: PackedScene) -> void:
	current_level = scene.instantiate()
	add_child(current_level)
	player = load(PLAYER_UID).instantiate()
	current_level.add_child(player)
	player.position = current_level.player_spawn.position
	player.set_camera_limits(current_level.get_level_bounds())
