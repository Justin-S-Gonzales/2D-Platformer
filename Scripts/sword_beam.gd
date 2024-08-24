extends RigidBody2D

class_name SwordBeam

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if area_2d.has_overlapping_bodies():
		for body in area_2d.get_overlapping_bodies():
			if is_enemy(body):
				body.die()
				queue_free()

func is_enemy(object):
	if object is Tomato:
		return true
	elif object is Tomatillo:
		return true
	elif object is Sunflower:
		return true
	elif object is Grapes:
		return true
	elif object is Grape:
		return true
	elif object is GreenGrapes:
		return true
	elif object is GreenGrape:
		return true
	else:
		return false

func flip_sprite():
	sprite_2d.flip_h = true
	
func reverse_velocity():
	linear_velocity.x = -linear_velocity.x

func _on_despawn_timer_timeout() -> void:
	queue_free()
