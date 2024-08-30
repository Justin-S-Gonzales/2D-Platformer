extends StaticBody2D

class_name Pipe

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_end_point: Marker2D = $EnemyEndPoint
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

@export var spawn_scene: PackedScene = null
var spawn: Node2D = null

var is_traveling_up: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if spawn != null && is_traveling_up && path_follow_2d.progress_ratio < 1:
		path_follow_2d.progress_ratio += 1 * delta
	if path_follow_2d.progress_ratio >= 1:
		path_follow_2d.progress_ratio = 0
		is_traveling_up = false
		path_follow_2d.remove_child(spawn)
		get_parent().add_child(spawn)
		spawn.position = position + enemy_end_point.position
		spawn.set_process(true)
		spawn.set_physics_process(true)
		
		if spawn is Watermelon:
			var watermelon: Watermelon = spawn
			
			watermelon.scale = Vector2(1.0, 1.0)
			watermelon.direction = -1
			watermelon.position.y -= 8

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	spawn_timer.start()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn_timer.stop()

func _on_spawn_timer_timeout() -> void:
	if !is_traveling_up:
		spawn = spawn_scene.instantiate()
		path_follow_2d.add_child(spawn)
		is_traveling_up = true
		spawn.set_process(false)
		spawn.set_physics_process(false)
		
		if spawn is Watermelon:
			var watermelon: Watermelon = spawn
			
			watermelon.scale = Vector2(0.6, 0.6)
			(watermelon.get_node("AnimationPlayer") as AnimationPlayer).speed_scale = -1
			
	# current_content_position = content.position
