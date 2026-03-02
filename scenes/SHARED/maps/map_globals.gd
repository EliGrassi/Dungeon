extends Node
class_name MapGlobals

@export var id_to_map: Dictionary[int, String] = {}


func _ready() -> void:
	#Spawn Map
	id_to_map[1] = "uid://cberqe5705613"
