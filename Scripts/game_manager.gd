extends Node

@onready var hud = $HUD
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var start_next_level_timer: Timer = $StartNextLevelTimer

var test_level_scene: PackedScene = preload("res://Scenes/level.tscn")
var level1_scene: PackedScene = preload("res://Scenes/level1.tscn")
var current_level: Level = null
var current_level_index: int = 0

var coins: int = 0
var one_up_coins_count: int = 100
@export var lives: int = 3

func _ready():
	hud.set_lives(lives)
	
	setup_level(test_level_scene)
	
	hud.set_health(current_level.get_player_health())

func _process(delta):
	audio_stream_player_2d.position = current_level.get_player_position()

func _on_level_coin_collected():
	coins += 1
	if coins >= one_up_coins_count:
		lives += 1
		coins = 0
		hud.set_lives(lives)
	hud.set_coins(coins)

func _on_level_player_died():
	lives -= 1
	if lives < 0:
		hud.show_game_over()
		current_level.game_over()
		current_level.respawn_player = false
		current_level.is_game_over = true
	else:
		hud.set_lives(lives)

func update_hud():
	hud.set_health(current_level.get_player_health())

func load_next_level():
	current_level_index += 1
	start_next_level_timer.start()
		
func setup_level(level_scene: PackedScene):
	if current_level != null:
		current_level.queue_free()
	
	current_level = level_scene.instantiate()
	if current_level == null:
		print(&"error loading level")
		return 
		
	add_child(current_level)
	setup_level_connections()
	
	current_level.set_player_freeze_controls(false)
	
	audio_stream_player_2d.seek(0.0)

func setup_level_connections():
	current_level.coin_collected.connect(_on_level_coin_collected)
	current_level.player_died.connect(_on_level_player_died)
	current_level.player_got_hit.connect(update_hud)
	current_level.player_respawned.connect(update_hud)
	current_level.level_end_reached.connect(load_next_level)

func _on_start_next_level_timer_timeout() -> void:
	if current_level_index == 1:
		setup_level(level1_scene)
