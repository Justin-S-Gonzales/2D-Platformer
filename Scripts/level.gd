extends Node2D

class_name Level

signal coin_collected
signal player_died
signal player_got_hit
signal player_respawned

@onready var start_position = $"Start Position"
@onready var player = $Player
@onready var respawn_timer = $RespawnTimer

@export var cloud_movement_speed = 5.0

var respawn_player = true
var is_game_over = false

var game_over_camera

# Called when the node enters the scene tree for the first time.
func _ready():
	player.position = start_position.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# clouds.motion_offset.x -= cloud_movement_speed * delta

func _on_player_coin_collected():
	coin_collected.emit()

func _on_player_fell_to_player_death():
	player_died.emit()
	game_over()
	if respawn_player:
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
	player_respawned.emit()
	
func connect_player_signals():
	player.coin_collected.connect(_on_player_coin_collected)
	player.fell_to_player_death.connect(_on_player_fell_to_player_death)
	player.got_hit.connect(_on_player_got_hit)
	player.checkpoint_hit.connect(_on_player_checkpoint_hit)

func get_player_health():
	return player.get_health()

func _on_player_got_hit():
	player_got_hit.emit()
	
func get_player_position():
	if respawn_timer.is_stopped() && is_game_over == false:
		return player.position
	else:
		return game_over_camera.position

func _on_player_checkpoint_hit() -> void:
	start_position.position = player.position
