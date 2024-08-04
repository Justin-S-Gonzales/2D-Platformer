extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export var max_walking_speed = 80.0
@export var max_running_speed = 160.0

@export var acceleration = 5.0
var deceleration = 10.0

var current_max_speed = 0.0

@export var jump_velocity = -350.0

var is_jumping = false
var is_running = false
var facing_direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 2000.0
@export var jump_gravity = 800

var current_gravity = gravity

func _physics_process(delta):	
	# Get the input direction
	var direction = Input.get_axis("move_left", "move_right")
	
	# Handle jump.
	if Input.is_action_pressed(&"jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
		current_gravity = jump_gravity
	elif is_on_floor():
		is_jumping = false
		
	if !Input.is_action_pressed(&"jump"):
		current_gravity = gravity
		
	if velocity.y > 0:
		current_gravity = gravity
	
	velocity.y += current_gravity * delta
	
	# Running and walking
	if Input.is_action_pressed(&"run"):
		current_max_speed = max_running_speed
		# current_deceleration = running_deceleration
		# current_acceleration = running_acceleration
		is_running = true
	else:
		current_max_speed = max_walking_speed
		# current_deceleration = walking_deceleration		
		# current_acceleration = walking_acceleration
		is_running = false
	
	# Apply movement	
	if direction:
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
	if is_jumping:
		animation_player.stop()
		sprite_2d.frame = 3
	else:
		# idle
		if direction == 0:
			animation_player.stop()
			if !animation_player.is_playing():
				sprite_2d.frame = 1
		else: # running or walking
			if is_running:
				animation_player.play(&"run")
			else:
				animation_player.play(&"walk")
			

	move_and_slide()
