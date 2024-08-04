extends Node

@onready var hud = $HUD

func _on_level_coin_collected():
	hud.add_point()
