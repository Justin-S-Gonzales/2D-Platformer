extends CharacterBody2D

class_name Tomato

@onready var left_ray_cast_2d = $LeftRayCast2D
@onready var right_ray_cast_2d = $RightRayCast2D
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

# Velocities and speeds
@export var speed = 100.0
@export var gravity = 200.0
@export var static_body_bounce = 80.0
var death_bounce = 100.0
var direction = -1

# Boundaries
@export var death_height = 80

# Flags
var is_dead = false

# Coin
@export var coin_spawn_offset = 20.0
var coin_scene = preload("res://Scenes/coin.tscn")

func _physics_process(delta):
	if position.y > death_height:
		queue_free()
	
	# Add the gravity
	velocity.y += gravity * delta

	velocity.x = direction * speed
	
	if !is_dead:
		if left_ray_cast_2d.is_colliding() || right_ray_cast_2d.is_colliding():
			if !(left_ray_cast_2d.get_collider() is Player) || !(right_ray_cast_2d.get_collider() is Player):
				direction = -direction
				velocity.x -= sign(velocity.x) * static_body_bounce
				sprite_2d.flip_h = !sprite_2d.flip_h

	move_and_slide()

func die():
	sprite_2d.flip_v = true
	is_dead = true
	collision_shape_2d.disabled = true
	velocity.y -= death_bounce
	# spawn a coin
	var coin = coin_scene.instantiate()
	get_parent().get_parent().add_child(coin)
	coin.position = Vector2(position.x, position.y - coin_spawn_offset)
	coin.play_animation()
