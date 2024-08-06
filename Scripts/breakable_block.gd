extends Node2D
class_name BreakableBlock

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

@export var contentScene: PackedScene 
var content
@export var content_y_offset = -15
@export var has_content = false

func _ready():
	sprite_2d.frame = 0
	
func play_animation():
	animation_player.play("block_break")
	
	if has_content:
		create_content()
		if content is Coin:
			content.play_animation()
	
func create_content():
	content = contentScene.instantiate()
	add_child(content)
	content.position.y += content_y_offset
