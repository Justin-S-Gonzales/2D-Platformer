extends RigidBody2D

class_name SwordPickup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	if position.y > 80.0:
		queue_free()
