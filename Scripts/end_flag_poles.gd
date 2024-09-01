extends StaticBody2D

@onready var end_flag: Node2D = $"End Flag"

# Markers
@onready var bottom: Marker2D = $Bottom
@onready var top: Marker2D = $Top
@onready var reward_threshhold: Marker2D = $RewardThreshhold
@onready var reward_spawn_point: Marker2D = $RewardSpawnPoint

# Export vars
@export var flag_speed: float = 10.0

# Flags (literally)
var flag_direction: int = 1
var move_flag: bool = true

# Scenes
var sword_pickup_scene: PackedScene = preload("res://Scenes/sword_pickup.tscn")
var boomerang_pickup_scene: PackedScene = preload("res://Scenes/boomerang_pickup.tscn")
var coin_scene: PackedScene = preload("res://Scenes/coin.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !move_flag:
		return
	
	end_flag.position.y += flag_speed * delta * flag_direction
	
	if end_flag.position.y > bottom.position.y || end_flag.position.y < top.position.y:
		flag_direction = -flag_direction

func _on_end_flag_broken() -> void:
	move_flag = false
	if end_flag.position.y > reward_threshhold.position.y:
		spawn_coins()
	elif end_flag.position.y < reward_threshhold.position.y:
		spawn_coins()
		spawn_pickup()
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if move_flag != false && body is Player:
		var player: Player = body
		player.set_freeze_controls(true)
		spawn_coin(0)
		
func spawn_coins():
	var dist_to_bottom: float = bottom.position.y - end_flag.position.y 
	for n in range((dist_to_bottom + 8.0) / 8.0):
		spawn_coin(n * 16.0)

func spawn_coin(individual_offset: float):
	var coin: Coin = coin_scene.instantiate()
	get_parent().add_child(coin)
	coin.position = position + reward_spawn_point.position
	coin.position.x += individual_offset

func spawn_pickup():
	var pickup: RigidBody2D = null
	if rng.randi_range(0, 1) == 0:
		pickup = sword_pickup_scene.instantiate()
	else:
		pickup = boomerang_pickup_scene.instantiate()
	
	if pickup != null:
		get_parent().add_child(pickup)
		pickup.position = position + reward_spawn_point.position
		pickup.position.x -= 16.0
