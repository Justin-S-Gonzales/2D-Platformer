extends CharacterBody2D

class_name Watermelon

@onready var left_ray_cast = $LeftRayCast
@onready var right_ray_cast = $RightRayCast
@onready var animation_player = $AnimationPlayer
@onready var up_ray_cast = $UpRayCast

@export var speed: float = 100.0
@export var push_force = 1.0

@export var grapes_vertical_offset: float = 32.5

var gravity: float = 200.0
var direction: int = 1

var grapes: Node2D = null

func _ready() -> void:
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if left_ray_cast.is_colliding() && !(left_ray_cast.get_collider() is Player):
		direction = 1
		animation_player.speed_scale = 1
		animation_player.advance(0.4)
	elif right_ray_cast.is_colliding() && !(right_ray_cast.get_collider() is Player):
		direction = -1
		animation_player.speed_scale = -1
		animation_player.advance(0.4)
		
	velocity.x = direction * speed
	
	move_and_slide()
	
	if up_ray_cast.is_colliding() && up_ray_cast.get_collider() is Sunflower:
		var sunflower: Sunflower = up_ray_cast.get_collider()
		sunflower.position = position + up_ray_cast.target_position
		
	if up_ray_cast.is_colliding() && up_ray_cast.get_collider() is Grapes || up_ray_cast.get_collider() is GreenGrapes:
		grapes = up_ray_cast.get_collider()
		grapes.grape_x_velocity_absolute = 150
		
	if grapes != null && !grapes.is_dead: 
		grapes.position.x = position.x
		if grapes.position.y > position.y - grapes_vertical_offset:
			grapes.position.y = position.y - grapes_vertical_offset
			if grapes.velocity.y > 0:
				grapes.velocity.y = 0
		
	if left_ray_cast.is_colliding() && left_ray_cast.get_collider() is Player:
		var player: Player = left_ray_cast.get_collider()
		bonk_player(player)
		
	if right_ray_cast.is_colliding() && right_ray_cast.get_collider() is Player:
		var player: Player = right_ray_cast.get_collider()
		bonk_player(player)

func die():
	return # todo
	
func bonk_player(player: Player):
	player.take_damage()
	player.position.y -= 16.0
	player.velocity.y -= 10.0
