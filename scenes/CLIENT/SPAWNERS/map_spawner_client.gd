extends Node
class_name ClientMapSpawner

var loaded = false
@export var wanted_map_uid: String = "null"
@export var wanted_map: PackedScene = null
@export var current_map: Map = null


func load_new_map(uid: String) -> void:
	wanted_map_uid = uid
	ResourceLoader.load_threaded_request(wanted_map_uid)
	current_map.queue_free()
	loaded = false

func _physics_process(delta: float) -> void:
	if loaded == false:
		if ResourceLoader.load_threaded_get_status(wanted_map_uid) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			wanted_map = ResourceLoader.load_threaded_get(wanted_map_uid)
			current_map = wanted_map.instantiate()
			call_deferred("add_child", current_map)
			loaded = true
