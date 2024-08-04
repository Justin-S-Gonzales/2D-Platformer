extends TileMap

@onready var player = %Player

signal coin_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cellAtPlayerPosition = get_cell_tile_data(0, local_to_map(player.position))
	if cellAtPlayerPosition is Coin:
		cellAtPlayerPosition.play_animation()
