extends Node2D

class_name MainMenu
@onready var foreground_tile_map_1: Node2D = $ForegroundTileMap1
@onready var foreground_tile_map_2: Node2D = $ForegroundTileMap2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var player: Player = $Player

var tilemap_shift_dist: float = 2048.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	audio_stream_player_2d.position = player.position

func _on_move_other_tilemap_area_1_body_entered(body: Node2D) -> void:
	if body is Player:
		foreground_tile_map_2.position.x = foreground_tile_map_1.position.x + tilemap_shift_dist

func _on_move_other_tilemap_area_2_body_entered(body: Node2D) -> void:
	if body is Player:
		foreground_tile_map_1.position.x = foreground_tile_map_2.position.x + tilemap_shift_dist
