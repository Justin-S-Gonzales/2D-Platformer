extends Node2D

signal broken

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		
		player.set_freeze_controls(true)
		player.start_spawn_end_level_camera_timer()
		
		broken.emit()
		animation_player.play(&"rip")
