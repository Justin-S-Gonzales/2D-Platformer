extends Node2D

@export var _health: int = 1

func get_health() -> int:
	return _health
	
func reduce_by(amount: int) -> int: 
	_health -= amount
	return _health

func add(amount: int) -> int:
	_health += amount
	return _health
