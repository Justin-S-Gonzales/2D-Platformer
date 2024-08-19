extends Node2D 
class_name BreakableBlock

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var block_break_sound = $BlockBreakSound
@onready var despawn_timer = $DespawnTimer
@onready var collision_shape_2d = $CollisionShape2D
@onready var up_shape_cast_2d = $UpShapeCast2D

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
@export var has_content = false

var block_break_scale = Vector2(2.0, 2.0)

var rng = RandomNumberGenerator.new()

var enemyAbove = null

func _ready():
	sprite_2d.frame = 0
	has_content = rng.randi_range(0, 1)
	
func play_animation():
	# Play animation and emit particles
	sprite_2d.scale = block_break_scale
	animation_player.play("block_break")
	gpu_particles_2d.emitting = true
	
	if enemyAbove != null:
		enemyAbove.die()
	
	# Play sound
	block_break_sound.pitch_scale += rng.randf_range(-5.0, 5.0) * 0.1 # Set pitch to be different every time
	block_break_sound.play()
	
	if has_content:
		create_content()
		if content is Coin:
			content.play_animation()
			
	# Kill enemies above
	if up_shape_cast_2d.is_colliding() && is_enemy(up_shape_cast_2d.get_collider(0)):
		for n in range(up_shape_cast_2d.get_collision_count()):
			if is_enemy(up_shape_cast_2d.get_collider(n)):
				up_shape_cast_2d.get_collider(n).die()
		
	collision_shape_2d.queue_free()
	despawn_timer.start()
	
func create_content():
	content = contentScene.instantiate()
	add_child(content)
	content.position.y += content_y_offset

func _on_despawn_timer_timeout():
	queue_free()

func _on_up_area_2d_body_entered(body):
	if body is Tomato || body is Tomatillo:
		var enemyAbove = body

func _on_up_area_2d_body_exited(body):
	enemyAbove = null 

func is_enemy(entity: Node2D):
	if entity is Tomato:
		return true
	if entity is Tomatillo:
		return true
	if entity is Grapes:
		return true
	if entity is GreenGrapes:
		return true
	else:
		return false
