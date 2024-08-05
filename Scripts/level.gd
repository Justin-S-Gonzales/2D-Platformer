extends Node2D

class_name Level

signal coin_collected
signal player_died

@onready var start_position = $"Start Position"
@onready var player = $Player
@onready var respawn_timer = $RespawnTimer

var game_over_camera

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
	game_over()
	respawn_timer.start()

func game_over():
	game_over_camera = player.get_camera().duplicate()
	add_child(game_over_camera)
	game_over_camera.position = player.position
	
	player.queue_free()		
	
	game_over_camera.make_current()
	
func reset_player_position():
	game_over_camera.queue_free()
	player.position = start_position.position	

func _on_respawn_timer_timeout():
	player = load("res://Scenes/player.tscn").instantiate()
	add_child(player)
	reset_player_position()
	connect_player_signals()
	
func connect_player_signals():
	player.coin_collected.connect(_on_player_coin_collected)
	player.fell_to_player_death.connect(_on_player_fell_to_player_death)
