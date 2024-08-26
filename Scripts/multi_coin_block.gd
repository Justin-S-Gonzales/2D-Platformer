extends Node2D

class_name MultiCoinBlock

@onready var block = $Block
var rng = RandomNumberGenerator.new()

func _ready():
	block.content.set_content_amount(rng.randf_range(0, 10.0))
