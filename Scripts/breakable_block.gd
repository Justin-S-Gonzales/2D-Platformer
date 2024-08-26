extends Node2D 
class_name BreakableBlock

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var block_break_sound = $BlockBreakSound
@onready var despawn_timer = $DespawnTimer
@onready var collision_shape_2d = $CollisionShape2D
@onready var up_area: Area2D = $UpArea

# Components
@onready var enemy_determiner: EnemyDeterminer = $EnemyDeterminer
@onready var content: Content = $Content

@export var has_content = false

var block_break_scale = Vector2(2.0, 2.0)

var rng = RandomNumberGenerator.new()

func _ready():
	sprite_2d.frame = 0
	has_content = rng.randi_range(0, 1)
	
func play_animation():
	# Play animation and emit particles
	sprite_2d.scale = block_break_scale
	animation_player.play("block_break")
	gpu_particles_2d.emitting = true
	
	# Play sound
	block_break_sound.pitch_scale += rng.randf_range(-5.0, 5.0) * 0.1 # Set pitch to be different every time
	block_break_sound.play()
	
	if has_content:
		content.spawn_content()
		if content.get_content() is Coin:
			content.get_content().play_animation()
			
	# Kill enemies above
	if up_area.has_overlapping_bodies():
		for body in up_area.get_overlapping_bodies():
			if enemy_determiner.is_enemy(body):
				body.die()
		
	collision_shape_2d.queue_free()
	despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
