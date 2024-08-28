extends StaticBody2D
class_name Block 

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var block_hit_sound = $BlockHitSound
@onready var powerup_spawn_sound = $PowerupSpawnSound
@onready var enemy_determiner: EnemyDeterminer = $EnemyDeterminer
@onready var up_area: Area2D = $UpArea
@onready var content: Content = $Content

@export var content_scene: PackedScene = null
@export var powerup_bonk: Vector2 = Vector2(0.0, -200.0)

var rng = RandomNumberGenerator.new()

func _ready():
	sprite_2d.frame = 0
	content.set_content_scene(content_scene)
	
func play_animation():
	# Kill enemies above
	if up_area.has_overlapping_bodies():
		for body in up_area.get_overlapping_bodies():
			if enemy_determiner.is_enemy(body):
				body.die()
			if body is SwordPickup || body is BoomerangPickup:
				(body as RigidBody2D).apply_impulse(powerup_bonk)
	
	if content.get_content_amount() <= 0:
		animation_player.stop()
		animation_player.play(&"hit_without_content")
		block_hit_sound.pitch_scale = 1.0 + rng.randf_range(-3.0, 3.0) * 0.1 # Set pitch to be different every time
		block_hit_sound.play()	
		return
		
	animation_player.stop()
	animation_player.play(&"hit")
	content.spawn_content()
	
	if content.get_content() is Coin:
		content.get_content().play_animation()
		
	if content.get_content() is SwordPickup || content.get_content() is BoomerangPickup:
		powerup_spawn_sound.play()
		
	content.reduce_content_amount()	
		
func get_content_amount():
	return content.get_content_amount()
