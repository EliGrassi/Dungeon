extends Node2D

@export var player: PackedScene


func _ready() -> void:
	NetworkHandler.on_client_connect.connect(spawn_player)
	
	#Call an alternate script for spawning things locally that does not run if the
	#client is also the server
	ClientGlobals.handle_local_id_assignment.connect(server_spawner)
	
	ClientGlobals.handle_foreign_id_assignment.connect(spawn_player)


#Does not perform client spawning if already covered by the client being the server
func server_spawner(id: int) -> void:
	if NetworkHandler.is_server: return
	spawn_player(id)

func spawn_player(id: int) -> void:

	var new_player: Node = player.instantiate()
	new_player.owner_id = id
	new_player.name = str(id)
	call_deferred("add_child", new_player)
