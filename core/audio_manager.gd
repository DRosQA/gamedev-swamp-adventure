extends Node

@export var menu_music_uid: String = "uid://c1tmq0djx5mlx"
@export var level_music_uid: String = "uid://kyvwrn2x11j8"
@export var level_ambiance_uid: String = "uid://c3dbj3efq13ij"
@export var ui_button_click_uid: String = "uid://chgfl7rl3xflg"

## must be in autoloads/globals, obviously
## heavily based on audio manager singleton by Mark Arneman / bearlikelion
## https://gist.github.com/bearlikelion/48a2e8e6fd1cd3d55d1ceaabe4fba1f2

var num_players: int = 8
var initial_bus: String = "SFX"
var available = []  # The available players.
var queue = []  # The queue of sounds to play.
var music: AudioStreamPlayer = AudioStreamPlayer.new() # player for BGM


func _ready():
	add_child(music) # add the music player
# Create the pool of AudioStreamPlayer nodes.
	for i: int in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = initial_bus


func _process(_delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		var soundToPlay: Array = queue.pop_front()
		available[0].stream = load(soundToPlay[0])
		available[0].bus = soundToPlay[1]
		available[0].play()
		available.pop_front()


func _on_stream_finished(player: AudioStreamPlayer) -> void:
	# When finished playing a stream, make the player available again
	available.append(player)


func play_sound(sound_file_UID: String, bus_name: String = "SFX") -> void:
	queue.append([sound_file_UID, bus_name])


func play_music(soundUid: String) -> void:
	music.bus = "Music"
	music.stream = load(soundUid)
	music.play()


func ui_button_clicked()-> void:
	play_sound(ui_button_click_uid)
