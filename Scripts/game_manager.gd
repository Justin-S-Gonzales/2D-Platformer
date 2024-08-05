extends Node

@onready var hud = $HUD
@onready var level_1 = $Level1

var coins = 0
var one_up_coins_count = 100
@export var lives = 3

func _ready():
	hud.set_lives(lives)

func _on_level_coin_collected():
	coins += 1
	if coins >= one_up_coins_count:
		lives += 1
		coins = 0
		hud.set_lives(lives)
	hud.set_coins(coins)

func _on_level_1_player_died():
	lives -= 1
	if lives < 0:
		hud.show_game_over()
		level_1.game_over()
	else:
		hud.set_lives(lives)
