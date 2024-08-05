extends Node

@onready var hud = $HUD

var coins = 0
var one_up_coins_count = 100
var lives = 3

func _ready():
	hud.set_lives(lives)

func _on_level_coin_collected():
	coins += 1
	if coins >= one_up_coins_count:
		lives += 1
		coins = 0
		hud.set_lives(lives)
	hud.set_coins(coins)
