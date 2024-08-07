extends StaticBody2D
class_name Block 

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var block_hit_sound = $BlockHitSound

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
@export var content_amount = 1

var rng = RandomNumberGenerator.new()

func _ready():
	sprite_2d.frame = 0
	
func play_animation():
	if content_amount <= 0:
		animation_player.play(&"hit_without_content")
		block_hit_sound.pitch_scale = 1.0 + rng.randf_range(-3.0, 3.0) * 0.1 # Set pitch to be different every time
		block_hit_sound.play()	
		return
		
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
