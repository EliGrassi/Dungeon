extends Node
class_name ClientMapSpawner


var loaded = false
#UID of the map we want to spawn
@export var wanted_map_uid: String = "null"
#Packed scene of the map, gotten from loading UID
@export var wanted_map: PackedScene = null
#The map itself
@export var current_map: Map = null

func _ready() -> void:
	ClientGlobals.handle_local_id_assignment.connect(enter_first_area)
	ClientGlobals.handle_peer_scene_change.connect(get_scene_change_confirm)
	
	
#When the server confirms we've changed scenes, and we know the message is about
#us and not a peer, call the scene change function
func get_scene_change_confirm(scene_change: SceneChange) -> void:

	if !scene_change.id == ClientGlobals.id: return
	scene_changed(scene_change.scene)
	
	
#When we load into the game for the first time as confirmed by the server, send a message
#telling it to send us to the first area we want.
func enter_first_area(player_id: int) -> void:
	SceneChange.create(player_id, 0, 2).send(ClientNetworkHandler.connected_server)


#Collect the UID we want based on the scene_id confirmed to be ours by the server
#Call the function to load this map UID
func scene_changed(scene_id: int) -> void:
	var new_uid = MapGlobalsLookup.id_to_map[scene_id]
	load_new_map(new_uid)
	
#After we've gotten confirmation from the server and the map UID we want from it, queue it to be loaded
#If we already have a map loaded, free it from memory, and set our state to not have a map
func load_new_map(uid: String) -> void:
	wanted_map_uid = uid
	ResourceLoader.load_threaded_request(wanted_map_uid)
	if current_map != null:
		current_map.queue_free()
	loaded = false



#If we dont have a loaded map, wait for one to be finished loading, and then spawn it in
#update our state to confirm that we have a map loaded.
func _physics_process(_delta: float) -> void:
	if loaded == false:
		if ResourceLoader.load_threaded_get_status(wanted_map_uid) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			wanted_map = ResourceLoader.load_threaded_get(wanted_map_uid)
			current_map = wanted_map.instantiate()
			call_deferred("add_child", current_map)
			loaded = true
