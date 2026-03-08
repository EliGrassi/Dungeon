extends Node

signal start_scene_change(id: int, target_scene: int)
signal server_confirmed_signal(id: int, target_scene: int, leaving: int)

signal map_loaded_signal()
signal player_moved_signal()

signal finished()

var server_confirmed = false
var map_loaded = false
var player_moved = false


func _ready() -> void:
	ClientGlobals.handle_peer_scene_change.connect(confirm_server)
	
	start_scene_change.connect(change_scene)
	map_loaded_signal.connect(confirm_map_loaded)
	player_moved_signal.connect(confirm_player_moved)
	
func change_scene(id_target: int, target_scene_target: int) -> void:
	SceneChange.create(id_target, target_scene_target, 4).send(ClientNetworkHandler.connected_server)
	
func confirm_server(scene_change_to_check: SceneChange) -> void:
	server_confirmed_signal.emit(scene_change_to_check.id, scene_change_to_check.scene,scene_change_to_check.leaving)

func confirm_map_loaded() -> void:
	map_loaded = true
	
func confirm_player_moved() -> void:
	player_moved = true
	
func finalize_change() -> void:
	server_confirmed = false
	map_loaded = false
	player_moved = false
	finished.emit()
	
	
func _physics_process(_delta: float) -> void:
	if server_confirmed and map_loaded and player_moved:
		finalize_change()
