extends Node2D
class_name BreakableBlock

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var block_break_sound = $BlockBreakSound
@onready var despawn_timer = $DespawnTimer
@onready var collision_shape_2d = $CollisionShape2D

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
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
		create_content()
		if content is Coin:
			content.play_animation()
		
	collision_shape_2d.queue_free()
	despawn_timer.start()
	
func create_content():
	content = contentScene.instantiate()
	add_child(content)
	content.position.y += content_y_offset

func _on_despawn_timer_timeout():
	queue_free()
