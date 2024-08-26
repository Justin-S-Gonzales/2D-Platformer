extends RigidBody2D

class_name SwordBeam

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enemy_determiner: EnemyDeterminer = $EnemyDeterminer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if area_2d.has_overlapping_bodies():
		for body in area_2d.get_overlapping_bodies():
			if enemy_determiner.is_enemy(body):
				body.die()
				queue_free()

func flip_sprite():
	sprite_2d.flip_h = true
	
func reverse_velocity():
	linear_velocity.x = -linear_velocity.x

func _on_despawn_timer_timeout() -> void:
	queue_free()
