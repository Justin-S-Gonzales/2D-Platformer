extends StaticBody2D

@onready var end_flag: Node2D = $"End Flag"
@onready var bottom: Marker2D = $Bottom
@onready var top: Marker2D = $Top

var flag_direction: int = 1
@export var flag_speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	end_flag.position.y += flag_speed * delta * flag_direction
	
	if end_flag.position.y > bottom.position.y || end_flag.position.y < top.position.y:
		flag_direction = -flag_direction

func _on_end_flag_broken() -> void:
	print("end of level")
