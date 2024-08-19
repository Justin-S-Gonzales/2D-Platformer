extends Node2D

class_name Sunflower

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var set_state_timer = $SetStateTimer
@onready var init_attack_timer = $InitAttackTimer
@onready var attack_area_collision_shape_2d = $AttackArea/AttackAreaCollisionShape2D

enum State {
	ComingOut,
	Attacking,
	Retracting,
	Hidden
}

var numStates: int = 4

var current_state: State = State.ComingOut

var play: bool = true

var is_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():	
	set_state_timer.start()
	attack_area_collision_shape_2d.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if play:
		match current_state: 
			State.ComingOut:
				animation_player.play(&"come_out")
			State.Attacking:
				animation_player.play(&"attack")
			State.Retracting:
				animation_player.play(&"retract")
			State.Hidden:
				animation_player.stop()
				sprite_2d.frame = 6
	else:
		animation_player.stop()
		match current_state: 
			State.ComingOut:
				sprite_2d.frame = 0
			State.Retracting:
				sprite_2d.frame = 6
	
func set_play_false():
	play = false

func loop_state():
	current_state = (current_state + 1) % numStates	

func _on_set_state_timeout():
	play = true
	loop_state()
	if current_state == State.Attacking:
		init_attack_timer.start()
	else:
		set_state_timer.start()

func _on_init_attack_timer_timeout():
	loop_state()
	set_state_timer.start()
	
func disable_attack_area():
	attack_area_collision_shape_2d.disabled = true
	
func enable_attack_area():
	attack_area_collision_shape_2d.disabled = false
	
