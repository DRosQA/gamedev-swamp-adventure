extends Node

signal progress_changed(new_progress)
signal loading_finished
signal loading_screen_readied

var loaded_level: PackedScene
var scene_path: String
var progress: Array = []

@onready var transition: PackedScene = preload("uid://0m4k4dhua4w7")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var loading_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match loading_status:
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Loading failed")
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_level = ResourceLoader.load_threaded_get(scene_path)
			loading_finished.emit()
			set_process(false)


func ready_loading_screen() -> void:
	var loading_screen = transition.instantiate()
	add_child(loading_screen)
	progress_changed.connect(loading_screen._on_progress_changed)
	loading_finished.connect(loading_screen._on_load_finished)

	await loading_screen.transition_ready
	loading_screen_readied.emit()


func start_loading(path: String) -> void:
	scene_path = path
	var state = ResourceLoader.load_threaded_request(scene_path)
	if state == OK:
		set_process(true)
