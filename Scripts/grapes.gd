extends CharacterBody2D

class_name Grapes

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hit_sound = $HitSound
@onready var grape_spawn_point = $GrapeSpawnPoint
@onready var player_detection_area = $PlayerDetectionArea
@onready var move_player_area = $MovePlayerArea

# Velocities
@export var full_vertical_jump_velocity = -180.0
@export var short_vertical_jump_velocity = -10.0
var is_full_vertical_jump_velocity = true

@export var grape_x_velocity_absolute = 100
var grape_x_velocity = -100

# Positions
@export var coin_spawn_offset: float = 20.0
var start_grape_spawn_point_position: Vector2

# Scenes
var coin_scene = preload("res://Scenes/coin.tscn")
var grape_scene = preload("res://Scenes/grape.tscn")

var death_bounce = 100.0

# Flags
var is_dead = false
var should_jump: bool = true

# Boundaries
@export var death_height = 80

var gravity = 200

enum State {
	Idle,
	Jumping,
	Throwing
}

var numStates: int = 3

var current_state: State = State.Idle

var play: bool = true

var rng = RandomNumberGenerator.new()

var player: CharacterBody2D = null

func _ready():
	start_grape_spawn_point_position = grape_spawn_point.position

func _physics_process(delta):
	if position.y > death_height:
		queue_free()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
	
	if is_dead:
		return
	
	# Animations
	if play:
		match current_state:
			State.Idle: 
				animation_player.play("idle")
			State.Jumping:
				animation_player.play("jump")
				#if down_ray_cast_2d.is_colliding():
					#collision_shape_2d.disabled = false
			State.Throwing:
				animation_player.play("throw")
	else:
		animation_player.stop()
		match current_state:
			State.Jumping: 
				if !is_on_floor():
					sprite_2d.frame = 13
				else:
					sprite_2d.frame = 0
			State.Throwing:
				sprite_2d.frame = 29
				
	if player != null:
		if player.position.x > position.x:
			sprite_2d.flip_h = true
			grape_spawn_point.position.x = -start_grape_spawn_point_position.x
			grape_x_velocity = grape_x_velocity_absolute
		else:
			sprite_2d.flip_h = false
			grape_spawn_point.position.x = start_grape_spawn_point_position.x
			grape_x_velocity = -grape_x_velocity_absolute
			
		if move_player_area.overlaps_body(player):
			player.position.x -= 16
			player.velocity.x -= 10

func loop_state():
	current_state = (current_state + 1) % numStates	

func _on_change_state_timer_timeout():
	if is_dead:
		return
	loop_state()
	play = true
	
	match current_state:
		State.Idle:
			collision_shape_2d.set_deferred("disabled", false)
		State.Throwing:
			collision_shape_2d.set_deferred("disabled", false)
		State.Jumping:
			if position.y < 0:
				velocity.y = full_vertical_jump_velocity if is_full_vertical_jump_velocity else short_vertical_jump_velocity
				is_full_vertical_jump_velocity = true if rng.randi_range(0, 5) == 1 else false
			else:
				velocity.y = full_vertical_jump_velocity
			if is_on_floor():
				collision_shape_2d.set_deferred("disabled", true)
	
func set_play_false():
	play = false

func _on_area_2d_body_entered(body):
	reset_collision()
		
func reset_collision():
	if is_dead:
		return 
		
	if velocity.y > 0:
		collision_shape_2d.set_deferred("disabled", false)

func die():
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
	
	animation_player.stop()

func spawn_grape():
	var grape = grape_scene.instantiate()
	get_parent().get_parent().add_child(grape)
	grape.position = position + grape_spawn_point.position
	grape.linear_velocity.x = grape_x_velocity

func _on_player_detection_area_body_entered(body):
	if body is Player:
		player = body

func _on_player_detection_area_body_exited(body):
	if body is Player:
		player = null
