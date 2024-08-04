extends Area2D

class_name Coin

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

func _ready():
	sprite_2d.frame = 0

func play_animation():
	animation_player.play("pickup")
