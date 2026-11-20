extends Node2D

var can_appear: bool = false


func _ready():
	self.visible = false


func _process(delta):
	if can_appear:
		if Input.is_action_just_pressed("croak"):
			self.visible = true


func _on_detection_area_entered(body):
	if body.is_in_group("Players"):
		can_appear = true


func _on_detection_area_exited(body):
	if body.is_in_group("Players"):
		can_appear = false
