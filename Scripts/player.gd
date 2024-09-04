extends CharacterBody2D

class_name Player

# Signals
signal coin_collected
signal fell_to_player_death
signal got_hit
signal checkpoint_hit

@onready var sprite_2d = $Sprite2D
@onready var camera_2d = $Camera2D
@onready var animation_player = $AnimationPlayer
@onready var shader_animation_player = $ShaderAnimationPlayer
@onready var attack_sprite: Sprite2D = $AttackSprite
@onready var boomerang_spawn_point_r: Marker2D = $BoomerangSpawnPointR
@onready var boomerang_spawn_point_l: Marker2D = $BoomerangSpawnPointL

# Collisions
@onready var collision_shape_2d = $CollisionShape2D
@onready var body_area_2d = $BodyArea2D
@onready var downward_area_2d = $DownwardArea2D
@onready var upward_area_2d = $UpwardArea2D
@onready var sword_air_attack_hit_box: Area2D = $SwordAirAttackHitBox
@onready var sword_right_ground_attack_hit_box: Area2D = $SwordRightGroundAttackHitBox
@onready var sword_left_ground_attack_hit_box: Area2D = $SwordLeftGroundAttackHitBox
var ground_attack_collision_shape_abs_x_offset: float = 6.0

# Health
@onready var health = $Health

# Sounds
@onready var player_hit_sound = $PlayerHitSound
@onready var jump_sound = $JumpSound
@onready var powerup_pickup_sound = $PowerupPickupSound
@onready var sword_attack_sound: AudioStreamPlayer2D = $SwordAttackSound

# Components
@onready var enemy_determiner: EnemyDeterminer = $EnemyDeterminer

var rng = RandomNumberGenerator.new()

# Speeds and velocities
@export var max_walking_speed = 80.0
@export var max_running_speed = 160.0
var current_max_speed = 0.0

@export var acceleration = 300.0
@export var deceleration = 340.0

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

# Timers
@onready var set_invulnerability_false_timer = $SetInvulnerabilityFalseTimer
@onready var replenish_boomerangs_timer: Timer = $ReplenishBoomerangsTimer
@onready var spawn_end_level_camera_timer: Timer = $SpawnEndLevelCameraTimer

# Animation
enum AnimationState {
	Idle,
	Walking,
	Running,
	Jumping,
	Attacking
}

var current_animation_state: AnimationState = AnimationState.Idle

var shader_hit_flash_color: Color = Color(1.0, 0.0, 0.0, 1.0);

var shader_powerup_flash_color: Color = Color(1, 1, 1, 0.48627451062202)

# Flags
@export var freeze_controls: bool = false
var facing_direction = 1
var is_dead = false
var is_invulnerable: bool = false
var has_powerup: int = 0
var current_attack: int = 0

# Gravity
@export var full_gravity = 2000.0
@export var jump_gravity = 800
var death_gravity = 200
var death_x_velocity = 100
var current_gravity = full_gravity

# Boundaries
@export var death_height = 80

# Scenes
var sword_beam_scene: PackedScene = preload("res://Scenes/sword_beam.tscn")
var boomerang_scene: PackedScene = preload("res://Scenes/boomerang.tscn")

# Boomerangs
var boomerang_count: int = 3
var current_boomerang: Boomerang = null

# End level
var end_level_camera: Camera2D = null

func _ready():
	material.set_shader_parameter("flash_value", 0)
	# has_powerup = 1

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
	
	if freeze_controls:
		Input.action_release(&"move_left")
		Input.action_release(&"run")
		Input.action_release(&"jump")
		Input.action_release(&"attack")
		Input.action_press(&"move_right")
	
	# Get the input direction
	direction = Input.get_axis("move_left", "move_right")
	
	# Jump buffer
	if !freeze_controls && Input.is_action_just_pressed(&"jump"):
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
	if direction != 0 && !(current_attack == 1 || current_attack == 3) && abs(velocity.x) < current_max_speed:
		velocity.x += direction * acceleration * delta
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	# Flip sprite	
	if direction != 0:
		facing_direction = direction
	
	sprite_2d.flip_h = facing_direction < 0
	attack_sprite.flip_h  = facing_direction < 0
	
	# Powerup moves
	if !freeze_controls && has_powerup == 1 && (Input.is_action_just_pressed(&"attack") || current_animation_state == AnimationState.Attacking):
			current_animation_state = AnimationState.Attacking
			
			if Input.is_action_just_pressed(&"attack") && is_on_floor():
				animation_player.play(&"ground_sword_attack")
				current_attack = 1
			elif Input.is_action_just_pressed(&"attack") && !is_on_floor():
				animation_player.play(&"sword_air_attack")
				current_attack = 2
	elif !freeze_controls && has_powerup == 2 && (Input.is_action_just_pressed(&"attack") || current_animation_state == AnimationState.Attacking):
		if boomerang_count > 0:
			current_animation_state = AnimationState.Attacking
			current_attack = 3
			animation_player.play(&"boomerang_throw")
	else:
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
	
	# Boomerang return held move
	if current_animation_state != AnimationState.Attacking && has_powerup == 2 && Input.is_action_pressed(&"attack") && current_boomerang != null:
		current_boomerang.set_should_return(false)
	elif current_boomerang != null:
		current_boomerang.set_should_return(true)
	
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
			
	# Sword attack
	if current_animation_state == AnimationState.Attacking:
		if current_attack == 1:
			if facing_direction == 1 && sword_right_ground_attack_hit_box.has_overlapping_bodies():
				slash_enemies_in_hitbox(sword_right_ground_attack_hit_box)
			if facing_direction == -1 && sword_left_ground_attack_hit_box.has_overlapping_bodies():
				slash_enemies_in_hitbox(sword_left_ground_attack_hit_box)
				
		if current_attack == 2 && sword_air_attack_hit_box.has_overlapping_bodies():
			slash_enemies_in_hitbox(sword_air_attack_hit_box)

	move_and_slide()

func slash_enemies_in_hitbox(hitbox: Area2D):
	for body in hitbox.get_overlapping_bodies():
		if enemy_determiner.is_enemy(body) && !body.is_dead:
			kill_enemy(body)

# Camera
func get_camera():
	return camera_2d

func _on_body_area_2d_area_entered(area):
	if is_dead:
		return
		
	if area is Coin:
		area.play_animation()
		coin_collected.emit()
	
	if enemy_determiner.is_enemy(area.get_parent()) && (area.get_parent() is Sunflower):
		take_damage()
		
	if area.get_parent() is Checkpoint:
		print("Checkpoint!")
		area.get_parent().die()
		checkpoint_hit.emit()
	
func _on_body_area_2d_body_entered(body):
	if is_dead:
		return
	
	if enemy_determiner.is_enemy(body) && !(body is Sunflower):
		if body.is_dead:
			return
			
		take_damage()
		
		if body is Grape:
			body.collision_shape_2d.set_deferred("disabled", true)
	
	# Powerups
	if body is SwordPickup || body is BoomerangPickup:
		powerup_pickup_sound.play()
		body.queue_free()
		
		# Play flashing animation for picking up a powerup
		material.set_shader_parameter(&"flash_color", shader_powerup_flash_color)		
		shader_animation_player.stop()
		shader_animation_player.play(&"hit_flash")
		set_invulnerability_false_timer.start()
		
		if body is SwordPickup:
			has_powerup = 1
		elif body is BoomerangPickup:
			has_powerup = 2
		
		health.set_health(2)
		
		got_hit.emit()
		
		
func _on_downward_area_2d_body_entered(body):
	if is_dead:
		return
		
	if enemy_determiner.is_enemy(body) && !body.is_dead:
		bounce_off_enemy(body)
	
	if body is Boomerang:
		bounce_off_enemy(body)

func _on_downward_area_2d_area_entered(area):
	if is_dead:
		return
		
	if enemy_determiner.is_enemy(area.get_parent()) && !area.get_parent().is_dead && !(area is GrapesGroundDetector || area is PlayerDetectionArea):
		bounce_off_enemy(area.get_parent())
			
func bounce_off_enemy(enemy):
		if enemy is Sunflower:
			return
	
		kill_enemy(enemy)
			
		if !Input.is_action_pressed(&"jump"):
			velocity.y = upward_bounce_velocity
		else:	
			jump()
			
func kill_enemy(enemy):
	enemy.die()
		
	if !(enemy is Grape || enemy is GreenGrape):
		coin_collected.emit()

func _on_upward_area_2d_body_entered(body):
	if is_dead:
		return 
		
	if body is Block || body is BreakableBlock:
		velocity.y = downward_bonk_velocity
		
	if body is Block:
		var block = body
		var content_amt: int = block.get_content_amount()
		block.play_animation()		
		if content_amt > 0 && block.content.get_content() is Coin:
			coin_collected.emit()		
	
	if body is BreakableBlock:
		var block = body
		block.play_animation()
		if block.has_content:
			coin_collected.emit()

func die():
	if is_dead:
		return 
	sprite_2d.flip_v = true
	attack_sprite.flip_v = true
	is_dead = true
	collision_shape_2d.queue_free()
	velocity.y = -death_bounce
	current_gravity = death_gravity
	death_x_velocity = velocity.x
	
	# Remove powerup
	has_powerup = 0

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

func take_damage():
	player_hit_sound.play()

	if health.get_health() - 1 > 0:
		# Haha bonk
		if direction == 0:
			velocity.x = -hit_bonk_x_velocity
		else:
			velocity.x = -sign(velocity.x) * hit_bonk_x_velocity
		velocity.y = hit_bonk_y_velocity
	
	# Don't take damage if we are invulnerable
	if is_invulnerable:
		return
		
	# Take damage
	health.reduce_by(1) 
	got_hit.emit()
	
	# Die
	if health.get_health() <= 0:
		die()
		is_invulnerable = true
		return
	
	# Set invulnerability
	is_invulnerable = true
	set_invulnerability_false_timer.start()

	# Play flash animation
	material.set_shader_parameter("flash_color", shader_hit_flash_color)	
	shader_animation_player.play("hit_flash")
	
	# Reset back to normal sprite if attack animation was interupted
	attack_sprite.hide()
	sprite_2d.show()

func _on_set_invulnerability_false_timer_timeout():
	is_invulnerable = false
	
	# Stop flash animation
	shader_animation_player.stop()
	material.set_shader_parameter("flash_value", 0)	

func reset_animation_state():
	current_animation_state = AnimationState.Idle
	current_attack = 0

func set_sword_sound_to_random_pitch():
	sword_attack_sound.pitch_scale = 1.0 + rng.randf_range(-2.0, 2.0) * 0.1 # Set pitch to be different every time
	
func spawn_sword_beam():
	if current_attack != 0 && health.get_health() != 2:
		return
	
	var sword_beam: SwordBeam = sword_beam_scene.instantiate()
	get_parent().add_child(sword_beam)
	sword_beam.position = position
	
	# flipping
	if facing_direction == -1:
		sword_beam.flip_sprite()
		sword_beam.reverse_velocity()

func spawn_boomerang():
	var boomerang: Boomerang = boomerang_scene.instantiate()
	get_parent().add_child(boomerang)
	
	if current_boomerang != null:
		current_boomerang.set_should_return(true)
		
	current_boomerang = boomerang
	
	if facing_direction == -1:
		boomerang.reverse_velocity()
		boomerang.position = position + boomerang_spawn_point_l.position
	else:
		boomerang.position = position + boomerang_spawn_point_r.position
		
	boomerang_count -= 1
	
	if replenish_boomerangs_timer.is_stopped():
		replenish_boomerangs_timer.start()

func _on_replenish_boomerangs_timer_timeout() -> void:
	boomerang_count = 3

func set_freeze_controls(freeze_contr: bool):
	freeze_controls = freeze_contr
	
	if freeze_contr == false:
		Input.action_release(&"move_right")
	
func start_spawn_end_level_camera_timer():
	spawn_end_level_camera_timer.start()

func _on_spawn_end_level_camera_timer_timeout() -> void:
	end_level_camera = camera_2d.duplicate()
	get_parent().add_child(end_level_camera)
	end_level_camera.position = position
	end_level_camera.make_current()
