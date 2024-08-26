extends RigidBody2D

class_name Boomerang

@onready var area_2d: Area2D = $Area2D
@onready var enemy_determiner: EnemyDeterminer = $EnemyDeterminer
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_dead: bool = false

var death_bounce: float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	
	if area_2d.has_overlapping_bodies():
		for body in area_2d.get_overlapping_bodies():
			if enemy_determiner.is_enemy(body):
				body.die()
	
	linear_velocity.x -= 100.0 * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func die():
	if is_dead:
		return
		
	is_dead = true
	
	hit_sound.play()
	collision_shape_2d.queue_free()
	linear_velocity.y -= death_bounce
	linear_velocity.x = 0
	gravity_scale = 0.4
	
