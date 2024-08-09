extends StaticBody2D
class_name Block 

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var block_hit_sound = $BlockHitSound
@onready var up_shape_cast_2d = $UpShapeCast2D

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
@export var content_amount = 1

var enemyAbove 

var rng = RandomNumberGenerator.new()

func _ready():
	sprite_2d.frame = 0
	
func play_animation():
	# Kill enemies above
	if up_shape_cast_2d.is_colliding() && up_shape_cast_2d.get_collider(0) is Tomato || up_shape_cast_2d.get_collider(0) is Tomatillo:
		for n in range(up_shape_cast_2d.get_collision_count()):
			if up_shape_cast_2d.get_collider(n) is Tomato || up_shape_cast_2d.get_collider(n) is Tomatillo:
				up_shape_cast_2d.get_collider(n).die()
	
	if content_amount <= 0:
		animation_player.stop()
		animation_player.play(&"hit_without_content")
		block_hit_sound.pitch_scale = 1.0 + rng.randf_range(-3.0, 3.0) * 0.1 # Set pitch to be different every time
		block_hit_sound.play()	
		return
		
	animation_player.stop()
	animation_player.play(&"hit")
	create_content()
	if content is Coin:
		content.play_animation()
		
	content_amount -= 1	
		
func get_content_amount():
	return content_amount

func create_content():
	content = contentScene.instantiate()
	add_child(content)
	content.position.y += content_y_offset
