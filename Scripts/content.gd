extends Node2D

class_name Content

@export var content_scene: PackedScene 
var content: Node2D
@export var content_amount: int = 1

func spawn_content() -> void:
	if content_scene != null:
		content = content_scene.instantiate()
		get_parent().add_child(content)
		content.position = position

func get_content() -> Node2D:
	return content

func get_content_amount() -> int:
	return content_amount

func reduce_content_amount() -> int:
	content_amount -= 1
	return content_amount

func set_content_scene(new_content_scene: PackedScene) -> void:
	content_scene = new_content_scene
	
func set_content_amount(new_content_amount: int) -> void:
	content_amount = new_content_amount
