extends RigidBody2D

signal collected


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_rigid_body_2d_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		EventsBus.collected.emit()
		self.queue_free()
