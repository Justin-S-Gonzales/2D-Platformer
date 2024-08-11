extends RigidBody2D

class_name Grape

@onready var hit_sound = $HitSound
@onready var collision_shape_2d = $CollisionShape2D

var is_dead = false

func die():
	hit_sound.play()
	collision_shape_2d.set_deferred("disabled", true)
	linear_velocity.x = 0
