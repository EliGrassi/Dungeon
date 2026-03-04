extends Node
class_name ClientPlayerSpawner


@export var player: PackedScene
@export var player_list: Dictionary[int, PlayerWrapper]

func _ready() -> void:
	
	ClientGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientGlobals.handle_peer_scene_change.connect(player_instance_changed)

func spawn_player(id: int) -> void:
	var new_player: Node = player.instantiate()
	new_player.owner_id = id
	new_player.name = str(id)
	player_list[id] = new_player
	new_player.global_position = Vector2(600, 300)
	call_deferred("add_child", new_player)
	

func delete_player(id: int) -> void:
	player_list[id].queue_free()
	player_list.erase(id)

func player_instance_changed(scene_change: SceneChange) -> void:

	var id = scene_change.id
	if id == ClientGlobals.id: return

	if scene_change.leaving == 1:
		spawn_player(id)
	elif scene_change.leaving == -1:
		delete_player(id)
		
		
	
