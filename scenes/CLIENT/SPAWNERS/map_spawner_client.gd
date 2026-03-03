extends Node
class_name ClientMapSpawner


var loaded = false
@export var wanted_map_uid: String = "null"
@export var wanted_map: PackedScene = null
@export var current_map: Map = null

func _ready() -> void:
	ClientGlobals.handle_local_id_assignment.connect(enter_first_area)
	ClientGlobals.handle_peer_scene_change.connect(get_scene_change_confirm)
	
func get_scene_change_confirm(scene_change: SceneChange) -> void:
	print("CLIENT: Signal Recieved to enter new area from server")
	if !scene_change.id == ClientGlobals.id: return
	scene_changed(scene_change.scene)
	
func enter_first_area(player_id: int) -> void:
	#Tell the server were entering the first scene, scene 0
	print("CLIENT: Sending signal to enter first area")
	SceneChange.create(player_id, 0, 2).send(ClientNetworkHandler.connected_server)

func scene_changed(scene_id: int) -> void:
	var new_uid = MapGlobalsLookup.id_to_map[scene_id]
	load_new_map(new_uid)
	
func load_new_map(uid: String) -> void:
	wanted_map_uid = uid
	ResourceLoader.load_threaded_request(wanted_map_uid)
	if current_map != null:
		current_map.queue_free()
	loaded = false

func _physics_process(delta: float) -> void:
	if loaded == false:
		if ResourceLoader.load_threaded_get_status(wanted_map_uid) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			wanted_map = ResourceLoader.load_threaded_get(wanted_map_uid)
			current_map = wanted_map.instantiate()
			call_deferred("add_child", current_map)
			loaded = true
