extends Node2D
class_name Spawner

var server_instances: Dictionary[int, SubViewport] = {}

@export var player: PackedScene
@export var default_map: PackedScene
@export var current_map: Node

#Stuff for the server

@export var active_viewport_container: SubViewportContainer
@export var active_viewport: SubViewport
@export var instance_root: Node



func _ready() -> void:
	
	current_map = default_map.instantiate()
	
	if ServerNetworkHandler.is_server:
		active_viewport_container = SubViewportContainer.new()
		active_viewport_container.stretch = true
		active_viewport = SubViewport.new()

		active_viewport.disable_3d = true
		active_viewport_container.add_child(active_viewport)
		
		instance_root.add_child(active_viewport_container)
		active_viewport.add_child(current_map)
	
	ClientGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientGlobals.handle_foreign_id_assignment.connect(spawn_player)

func spawn_player(id: int) -> void:
	
	var new_player: Node = player.instantiate()
	if id != ClientGlobals.id:
		new_player.global_position += Vector2(999,999)
	new_player.owner_id = id
	new_player.name = str(id)
	new_player.global_position = Vector2(600, 300)
	current_map.add_child(new_player)
