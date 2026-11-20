class_name GameManager extends Node

enum SceneType {
	MENU,
	LEVEL,
}

const MAIN_MENU_UID = "uid://dqbue8swtynn7"

var main_menu: Node
var scene_to_load: String

@onready var UI = %UILayer
@onready var LEVEL_MANAGER = %LevelManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_main_menu()


func load_main_menu() -> void:
	scene_to_load = MAIN_MENU_UID
	main_menu = (await _manage_loading_scene()).instantiate()
	UI.add_child(main_menu)
	main_menu.game_started.connect(_on_game_started)


func _manage_loading_scene() -> PackedScene:
	SceneLoader.ready_loading_screen()
	await SceneLoader.loading_screen_readied
	SceneLoader.start_loading(scene_to_load)
	await SceneLoader.loading_finished
	return SceneLoader.loaded_level


func load_level(level_to_load: int) -> void:
	scene_to_load = %LevelManager.LEVELS_UIDS[level_to_load]
	%LevelManager.init_level(await _manage_loading_scene())
	main_menu.queue_free()


func _on_game_started()-> void:
	load_level(1)
