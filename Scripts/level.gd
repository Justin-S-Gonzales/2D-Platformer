extends Node2D

class_name Level

signal coin_collected
signal player_died

@onready var start_position = $"Start Position"
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_coin_collected():
	coin_collected.emit()

func _on_player_fell_to_player_death():
	player_died.emit()
	player.position = start_position.position

func game_over():
	var game_over_camera = Camera2D.new()
	add_child(game_over_camera)
	game_over_camera.make_current()
	game_over_camera.position = player.position
	game_over_camera.set_zoom(Vector2(4.0, 4.0))
	game_over_camera.set_limit(SIDE_LEFT, -144)
	game_over_camera.set_limit(SIDE_BOTTOM, 80)
	
	player.queue_free()	
