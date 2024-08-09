extends CharacterBody2D

class_name Player

# Signals
signal coin_collected
signal fell_to_player_death
signal got_hit

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var camera_2d = $Camera2D

# Collisions
@onready var collision_shape_2d = $CollisionShape2D
@onready var body_area_2d = $BodyArea2D
@onready var downward_area_2d = $DownwardArea2D
@onready var down_ray_cast_2d = $DownRayCast2D

# Health
@onready var health = $Health

# Sounds
@onready var player_hit_sound = $PlayerHitSound
@onready var jump_sound = $JumpSound

var rng = RandomNumberGenerator.new()

# Speeds and velocities
@export var max_walking_speed = 80.0
@export var max_running_speed = 160.0
var current_max_speed = 0.0

@export var acceleration = 5.0
var deceleration = 10.0

var direction = 0

# Bounces and jumps
@export var jump_velocity = -350.0
@export var downward_bonk_velocity = 400.0
@export var upward_bounce_velocity = -100.0
@export var death_bounce = 100.0
@export var hit_bonk_x_velocity = 300.0
@export var hit_bonk_y_velocity = -300

# Coyote time
@export var coyoteTime = 0.05
var coyoteTimeCounter = 0
@export var jumpBufferTime = 0.18
var jumpBufferCounter = 0

# Animation
enum AnimationState {
	Idle,
	Walking,
	Running,
	Jumping
}

var current_animation_state: AnimationState = AnimationState.Idle

# Flags
var facing_direction = 1
var is_dead = false

# Gravity
@export var full_gravity = 2000.0
@export var jump_gravity = 800
var death_gravity = 200
var death_x_velocity = 100
var current_gravity = full_gravity

# Boundaries
@export var death_height = 80

func _physics_process(delta):	
	# Check for death from fall
	if position.y > death_height:
		fell_to_player_death.emit()
		return
		
	if is_dead:
		velocity.y += current_gravity * delta
		velocity.x = death_x_velocity
		move_and_slide()
		return
	
	# Get the input direction
	direction = Input.get_axis("move_left", "move_right")
	
	# Jump buffer
	if Input.is_action_just_pressed(&"jump"):
		jumpBufferCounter = jumpBufferTime
	else:
		jumpBufferCounter -= delta		
	
	if jumpBufferCounter > 0 && coyoteTimeCounter > 0:
		jump()
		
	# This is here to make it that you must re-press the jump button to jump again
	if is_on_floor(): 
		coyoteTimeCounter = coyoteTime
	else:
		coyoteTimeCounter -= delta
	
	# To apply normal gravity when jump button is not pressed
	if !Input.is_action_pressed(&"jump"):
		current_gravity = full_gravity
		
	# If we are moving downward, we need to apply normal gravity
	# This is to prevent player being able to "float" while holding the jump button
	if velocity.y > 0:
		current_gravity = full_gravity
		jump_sound.stop()
		
	# Apply gravity
	if coyoteTimeCounter <= 0:
		velocity.y += current_gravity * delta
	
	# Running and walking
	if Input.is_action_pressed(&"run"):
		current_max_speed = max_running_speed
	else:
		current_max_speed = max_walking_speed
	
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
		
	# Animation states
	if velocity.y < 0:
		current_animation_state = AnimationState.Jumping
		
	if is_on_floor():
		current_animation_state = AnimationState.Idle
	
	if !(current_animation_state == AnimationState.Jumping):
		if direction != 0:
			if Input.is_action_pressed(&"run"):
				current_animation_state = AnimationState.Running
			else:
				current_animation_state = AnimationState.Walking
		else:
			current_animation_state = AnimationState.Idle
		
	# Play animations
	match current_animation_state:
		AnimationState.Idle:
			play_idle_animation()
		AnimationState.Walking:
			animation_player.play(&"walk")
		AnimationState.Running:
			animation_player.play(&"run")
		AnimationState.Jumping:
			play_jump_animation()

	move_and_slide()

# Camera
func get_camera():
	return camera_2d

func _on_body_area_2d_area_entered(area):
	if is_dead:
		return
		
	if area is Coin:
		var coin = area as Coin
		area.play_animation()
		coin_collected.emit()
		
	if is_enemy(area.get_parent()):
		take_damage()
	
func _on_body_area_2d_body_entered(body):
	if is_dead:
		return
	
	if is_enemy(body):
		take_damage()
		
func _on_downward_area_2d_body_entered(body):
	if is_dead:
		return
		
	if is_enemy(body) && !body.is_dead:
		var tomato = body
		tomato.die()
		coin_collected.emit()
		if !Input.is_action_pressed(&"jump"):
			velocity.y = upward_bounce_velocity
		else:	
			jump()

func _on_upward_area_2d_body_entered(body):
	if is_dead:
		return 
		
	if body is Block || body is BreakableBlock:
		velocity.y = downward_bonk_velocity
		
	if body is Block:
		var block = body
		if block.get_content_amount() > 0:
			coin_collected.emit()		
		block.play_animation()		
	
	if body is BreakableBlock:
		var block = body
		block.play_animation()
		if block.has_content:
			coin_collected.emit()

func die():
	if is_dead:
		return 
	sprite_2d.flip_v = true
	is_dead = true
	collision_shape_2d.queue_free()
	velocity.y = -death_bounce
	current_gravity = death_gravity
	death_x_velocity = velocity.x

func get_health():
	health.get_health()
	return health.get_health()

func jump():
	velocity.y = jump_velocity
	current_gravity = jump_gravity
	jump_sound.pitch_scale = 1.0 + rng.randf_range(-1.0, 1.0) * 0.1 # Set pitch to be different every time
	jump_sound.play()	
	coyoteTimeCounter = 0
	jumpBufferCounter = 0
	
func play_jump_animation():
	animation_player.stop()
	sprite_2d.frame = 3

func play_idle_animation():
	animation_player.stop()
	sprite_2d.frame = 1

func is_enemy(object):
	if object is Tomato:
		return true
	elif object is Tomatillo:
		return true
	elif object is Sunflower:
		return true
	else:
		return false
		
func take_damage():
	health.reduce_by(1) # take damage
	got_hit.emit()
	player_hit_sound.play()
	if health.get_health() <= 0:
		die()
		return
	
	if direction == 0:
		velocity.x = hit_bonk_x_velocity
	else:
		velocity.x = -sign(velocity.x) * hit_bonk_x_velocity
	velocity.y = hit_bonk_y_velocity
