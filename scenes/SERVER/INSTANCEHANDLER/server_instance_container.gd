
#Container that holds a map/the things in it on the server

extends SubViewport
class_name ServerInstanceContainer

#The handler that spawns and destroys these containers
@export var master: InstanceHandler = null


@export var wanted_map: PackedScene = null
@export var current_map: Map = null
@export var id: int = -1
var map_uid: String
@export var initialized: bool = false

#Container for entities inside this instance
@export var entities_container: Node
#Container for players inside this instance
@export var players_container: Node
#List of players inside this instance by ids (not used at the moment)
var current_player_ids: Array[int] = []


func _ready() -> void:
	#On creation, look up the map we want based on id, and queue it to be loaded.
	#Also, make sure the instance container has its own world2D
	map_uid = MapGlobalsLookup.id_to_map[id]
	world_2d = World2D.new()
	ResourceLoader.load_threaded_request(map_uid)


func _physics_process(delta: float) -> void:
	#If we arent done being created, listen for if our wanted map
	#is done being loaded in, create it, add it to our container, and emit
	#our ID as a signal indicating that were done loading.
	if initialized == false:
		if ResourceLoader.load_threaded_get_status(map_uid) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			wanted_map = ResourceLoader.load_threaded_get(map_uid)
			current_map = wanted_map.instantiate()
			call_deferred("add_child", current_map)
			initialized = true
			master.instance_loaded.emit(id)
		
