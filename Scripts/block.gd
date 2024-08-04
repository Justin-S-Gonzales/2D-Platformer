extends StaticBody2D
class_name Block 

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
@export var content_amount = 1

func _ready():
	# content = Coin.new() as Coin
	sprite_2d.frame = 0
	
func play_animation():
	if content_amount <= 0:
		animation_player.play(&"hit_without_content")
		return
		
	animation_player.play(&"hit")
	create_content()
	if content is Coin:
		content.set_visible(true)
		content.play_animation()
		
	content_amount -= 1	
		
		
func get_content_amount():
	return content_amount

func create_content():
	content = contentScene.instantiate()
	add_child(content)
	content.set_visible(false)
	content.position.y += content_y_offset
