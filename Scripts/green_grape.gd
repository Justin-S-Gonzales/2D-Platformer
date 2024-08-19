extends RigidBody2D

class_name GreenGrape

@onready var hit_sound = $HitSound
@onready var collision_shape_2d = $CollisionShape2D

# Boundaries
@export var death_height = 80

var is_dead = false

func _process(delta: float) -> void:
	if position.y > death_height:
		queue_free()

func die():
	hit_sound.play()
	collision_shape_2d.set_deferred("disabled", true)
	linear_velocity.x = 0
	gravity_scale = 0.4

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
