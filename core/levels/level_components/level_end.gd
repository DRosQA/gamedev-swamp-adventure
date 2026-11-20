extends Node2D


#func _on_area_entered(body: CharacterBody2D)-> void:
	#if body is_in_group("Player"):
		#pass
