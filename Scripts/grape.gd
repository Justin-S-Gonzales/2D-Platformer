extends RigidBody2D

class_name Grape

@onready var hit_sound = $HitSound

var is_dead = false

func die():
	hit_sound.play()
