extends Area2D

class_name Coin

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

# signal got_coin

func _ready():
	sprite_2d.frame = 0

func _on_body_entered(body):
# 	got_coin.emit()
	animation_player.play("pickup")

func play_animation():
	animation_player.play("pickup")
