extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var area_2d = $Area2D
@onready var up_ray_cast_2d = $UpRayCast2D

# Speeds and velocities
@export var max_walking_speed = 80.0
@export var max_running_speed = 160.0
var current_max_speed = 0.0

@export var acceleration = 5.0
var deceleration = 10.0

@export var jump_velocity = -350.0
@export var downward_bonk_velocity = 400.0

# Flags
var is_jumping = false
var is_running = false
var facing_direction = 1
var can_jump = true

# Gravity
@export var gravity = 2000.0
@export var jump_gravity = 800
var current_gravity = gravity

# Signals
signal coin_collected

func _physics_process(delta):	
	# Get the input direction
	var direction = Input.get_axis("move_left", "move_right")
	
	# Handle jump.
	if Input.is_action_pressed(&"jump") and is_on_floor() && can_jump:
		velocity.y = jump_velocity
		is_jumping = true
		current_gravity = jump_gravity
		can_jump = false
	elif is_on_floor():
		is_jumping = false
	
	# This is here to make it that you must re-press the jump button to jump again
	if is_on_floor() && !Input.is_action_pressed(&"jump"):
		can_jump = true
		
	# To apply normal gravity when jump button is not pressed
	if !Input.is_action_pressed(&"jump"):
		current_gravity = gravity
		
	# If we are moving downward, we need to apply normal gravity
	# This is to prevent player being able to "float" while holding the jump button
	if velocity.y > 0:
		current_gravity = gravity
	
	# Apply gravity
	velocity.y += current_gravity * delta
	
	# Running and walking
	if Input.is_action_pressed(&"run"):
		current_max_speed = max_running_speed
		is_running = true
	else:
		current_max_speed = max_walking_speed
		is_running = false
	
	# Apply movement	
	if direction != 0:
		if abs(velocity.x) > current_max_speed:
			velocity.x -= sign(velocity.x) * deceleration
		else:
			velocity.x += direction * acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

	# Flip sprite	
	if direction != 0:
		facing_direction = direction
	
	sprite_2d.flip_h = facing_direction < 0
		
	# Play animations
	if is_jumping: # Jumping
		animation_player.stop()
		sprite_2d.frame = 3
	elif direction == 0: # Idle
		animation_player.stop()
		sprite_2d.frame = 1
	else: # Running or walking
		if is_running:
			animation_player.play(&"run")
		else:
			animation_player.play(&"walk")
	
	# Raycasts
	if up_ray_cast_2d.is_colliding():
		if up_ray_cast_2d.get_collider() is Block:
			var block = up_ray_cast_2d.get_collider()
			if block.get_content_amount() > 0:
				coin_collected.emit()		
			block.play_animation()		
			velocity.y += downward_bonk_velocity

	move_and_slide()

func _on_area_2d_area_entered(area):
	if area is Coin:
		var coin = area as Coin
		area.play_animation()
		coin_collected.emit()
