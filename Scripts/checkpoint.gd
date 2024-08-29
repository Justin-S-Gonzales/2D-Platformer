extends RigidBody2D

class_name Checkpoint

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D
@onready var area_collision_shape: CollisionShape2D = $Area2D/AreaCollisionShape

func die():
	collision_shape_2d.set_deferred("disabled", true)
	linear_velocity = Vector2(80.0, -100.0)
	audio_stream_player_2d.play()
	area_collision_shape.set_deferred("disabled", true)
