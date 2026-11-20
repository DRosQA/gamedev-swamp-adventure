class_name MainMenuComponent
extends Control

signal game_started

@export_group("Credits")
@export_file var dev_credits
@export_file var audio_credits
@export_file var sprite_credits
@export_file var art_credits
@export_file var ui_credits

var game_name: String = ProjectSettings.get_setting("application/config/name")

@onready var credits: Node = %CreditsOverlay


func _ready() -> void:
	AudioManager.play_music(AudioManager.menu_music_uid)
	%TitleLabel.text = game_name
	%Dev.display_file(dev_credits)
	%Audio.display_file(audio_credits)
	%Art.display_file(art_credits)
	%Sprites.display_file(sprite_credits)
	%UI.display_file(ui_credits)
	credits.visible = false
	Animate.fade_from_down(%Menu, 2.0)
	Animate.fade_from_up(%TitlePanel, 2.0)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


## load Credits Scene
func _on_credits_button_pressed() -> void:
	AudioManager.ui_button_clicked()
	credits.visible = true


## start new game
func _on_start_button_pressed() -> void:
	AudioManager.ui_button_clicked()
	game_started.emit()


func _on_back_button_pressed() -> void:
	AudioManager.ui_button_clicked()
	credits.visible = false


#
func _on_hide_main_menu() -> void:
	self.queue_free()


func _on_meta_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at runtime.
	OS.shell_open(str(meta))
