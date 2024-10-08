class_name Tomato extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var left_ray_cast_2d = $LeftRayCast2D
@onready var right_ray_cast_2d = $RightRayCast2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hit_sound = $HitSound
@onready var content: Content = $Content

# Velocities and speeds
@export var speed = 60.0
@export var gravity = 200.0
@export var static_body_bounce = 300.0
var death_bounce = 100.0
var direction = -1

# Boundaries
@export var death_height = 80

# Flags
var is_dead = false

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
				velocity.x = -sign(velocity.x) * static_body_bounce
				sprite_2d.flip_h = !sprite_2d.flip_h

	move_and_slide()

func die():
	if is_dead:
		return
		
	hit_sound.play()
	sprite_2d.flip_v = true
	is_dead = true
	collision_shape_2d.queue_free()
	velocity.y -= death_bounce
	
	# Spawn a coin
	content.spawn_content()
	content.get_content().play_animation()
