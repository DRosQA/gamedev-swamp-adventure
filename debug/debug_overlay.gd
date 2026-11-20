extends Control

const VERSION_SETTING: String = "application/config/version"

var show_debug = false

@onready var fps_label: Label = %FpsValue
@onready var version_label: Label = %VersionInfo
@onready var input_label: Label = %InputValue


func _ready() -> void:
	_add_version_to_info_label()
	self.visible = show_debug


func _process(_delta: float) -> void:
	_toggle_debug()
	# don't update invisible debug overlay
	if self.visible:
		_set_fps_label()
		_reset_input_label()


# add to built-in _input method to catch inputs
func _input(event) -> void:
	if self.visible:
		input_label.set_text(str(event.as_text()))


func _add_version_to_info_label() -> void:
	var version_str: String = ProjectSettings.get_setting(VERSION_SETTING)
	version_label.text += version_str


func _set_fps_label() -> void:
	fps_label.set_text(str(Engine.get_frames_per_second()))


# reset label when nothing is pressed
func _reset_input_label() -> void:
	if not Input.is_anything_pressed():
		input_label.set_text("")


func _toggle_debug():
	if Input.is_action_just_pressed("debug_toggle"):
		self.visible = not self.visible
