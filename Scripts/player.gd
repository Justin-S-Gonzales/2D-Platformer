extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export var speed = 300.0
@export var jump_velocity = -400.0

var can_move = true
var is_jumping = false
var facing_direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if can_move == false:
		velocity.x = 0
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_pressed(&"jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Get the input direction
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		facing_direction = direction
	
	# Flip sprite
	sprite_2d.flip_h = facing_direction < 0
		
	# Play animations
	if is_jumping:
		animation_player.stop()
		sprite_2d.frame = 3
	else:
		if direction == 0:
			animation_player.stop()
			sprite_2d.frame = 1
		else:
			animation_player.play(&"run")
			
	# Apply movement
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
