extends Node2D

@export var player: PackedScene


func _ready() -> void:
	NetworkHandler.on_client_connect.connect(spawn_player)
	ClientGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientGlobals.handle_foreign_id_assignment.connect(spawn_player)


func spawn_player(id: int) -> void:
	var new_player: Node = player.instantiate()
	new_player.owner_id = id
	new_player.name = str(id)
	call_deferred("add_child", new_player)
