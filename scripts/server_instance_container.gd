extends SubViewport
class_name ServerInstanceContainer


@export var master: InstanceHandler = null


@export var wanted_map: PackedScene = null
@export var current_map: Map = null
@export var id: int = -1
@export var initialized: bool = false

@export var entities_container: Node = null
@export var players_container: Node = null
var current_player_ids: Array[int] = []


func _ready() -> void:
	if wanted_map != null:
		current_map = wanted_map.instantiate()
		call_deferred("add_child", current_map)
	initialized = true
	master.instance_loaded.emit(id)
