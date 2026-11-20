extends Node
## must be in autoloads/globals, obviously

@warning_ignore_start("unused_signal")
signal button_clicked
signal level_launched(level_to_launch: int)
signal level_loaded
signal item_collected
signal player_died
@warning_ignore_restore("unused_signal")
