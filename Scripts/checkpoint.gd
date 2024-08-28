extends RigidBody2D

class_name Checkpoint

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func die():
	collision_shape_2d.set_deferred("disabled", true)
	linear_velocity = Vector2(80.0, -100.0)
	audio_stream_player_2d.play()
