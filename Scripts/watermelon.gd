extends CharacterBody2D

@onready var left_ray_cast = $LeftRayCast
@onready var right_ray_cast = $RightRayCast
@onready var animation_player = $AnimationPlayer
@onready var up_ray_cast = $UpRayCast

@export var speed: float = 100.0
@export var push_force = 1.0

var gravity: float = 200.0
var direction: int = 1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if left_ray_cast.is_colliding():
		direction = 1
		animation_player.speed_scale = 1
		animation_player.advance(0.4)
	elif right_ray_cast.is_colliding():
		direction = -1
		animation_player.speed_scale = -1
		animation_player.advance(0.4)
		
	velocity.x = direction * speed
	
	move_and_slide()
	
	if up_ray_cast.is_colliding() && up_ray_cast.get_collider() is Sunflower:
		var sunflower: Sunflower = up_ray_cast.get_collider()
		sunflower.position = position + up_ray_cast.target_position
