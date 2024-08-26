extends Node

class_name EnemyDeterminer

func is_enemy(object: Node) -> bool:
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
