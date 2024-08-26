extends CharacterBody2D

class_name Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var is_dead: bool = false
var death_bounce = 100.0

# Boundaries
@export var death_height = 80

# Coin
@export var coin_spawn_offset = 20.0
var coin_scene = preload("res://Scenes/coin.tscn")

func _physics_process(delta: float) -> void:
	if position.y > death_height:
		queue_free()

func die() -> void:
	if is_dead:
		return
		
	hit_sound.play()
	sprite_2d.flip_v = true
	is_dead = true
	collision_shape_2d.queue_free()
	velocity.y -= death_bounce
	
	# Spawn a coin
	var coin = coin_scene.instantiate()
	get_parent().get_parent().add_child(coin)
	coin.position = Vector2(position.x, position.y - coin_spawn_offset)
	coin.play_animation()
