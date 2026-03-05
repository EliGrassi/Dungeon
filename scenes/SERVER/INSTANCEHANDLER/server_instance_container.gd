extends SubViewport
class_name ServerInstanceContainer


@export var master: InstanceHandler = null


@export var wanted_map: PackedScene = null
@export var current_map: Map = null
@export var id: int = -1
var map_uid: String
@export var initialized: bool = false
@export var entities_container: Node
@export var players_container: Node
var current_player_ids: Array[int] = []


func _ready() -> void:
	map_uid = MapGlobalsLookup.id_to_map[id]
	world_2d = World2D.new()
	ResourceLoader.load_threaded_request(map_uid)


func _physics_process(delta: float) -> void:
	if initialized == false:
		if ResourceLoader.load_threaded_get_status(map_uid) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			wanted_map = ResourceLoader.load_threaded_get(map_uid)
			current_map = wanted_map.instantiate()
			call_deferred("add_child", current_map)
			initialized = true
			master.instance_loaded.emit(id)
		
