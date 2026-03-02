extends Node2D
class_name ClientPlayerSpawner


@export var player: PackedScene
@export var player_list: Dictionary[int, PlayerWrapper]

func _ready() -> void:
	
	ClientGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientGlobals.handle_foreign_id_assignment.connect(spawn_player)

func spawn_player(id: int) -> void:
	
	var new_player: Node = player.instantiate()
	if id != ClientGlobals.id:
		new_player.global_position += Vector2(999,999)
	new_player.owner_id = id
	new_player.name = str(id)
	player_list[id] = new_player
	new_player.global_position = Vector2(600, 300)
	call_deferred("add_child", new_player)

func delete_player(id: int) -> void:
	player_list[id].queue_free()
	player_list.erase(id)
