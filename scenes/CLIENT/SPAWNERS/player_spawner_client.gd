extends Node
class_name ClientPlayerSpawner


#The scene that is the player
@export var player: PackedScene
#A list of player objects spawned on our client
@export var player_list: Dictionary[int, PlayerWrapper]

func _ready() -> void:
	
	ClientGlobals.handle_local_id_assignment.connect(spawn_player)
	ClientGlobals.handle_peer_scene_change.connect(player_instance_changed)


#Function for spawning a player. can be used for peers or ourselves.
#is called automatically on our own ID when the server confirms we have connected to it

#ID: the player to be created
func spawn_player(id: int) -> void:
	var new_player: Node = player.instantiate()
	new_player.owner_id = id
	new_player.name = str(id)
	player_list[id] = new_player
	new_player.global_position = Vector2(600, 300)
	call_deferred("add_child", new_player)
	

#Function for deleting a player given its id

#ID: the player to be deleted
func delete_player(id: int) -> void:
	player_list[id].queue_free()
	player_list.erase(id)


#Called when the server informs us a player has changed scenes

#SCENE_CHANGE: the scene change packet recieved from the server
func player_instance_changed(scene_change: SceneChange) -> void:


	var id = scene_change.id
	
	#This signal is sent to confirm we've changed to a new area, leaving=3 means delete all old players
	#since we will shortly after load new ones
	if id == ClientGlobals.id and scene_change.leaving == 3: 
		for player_key in player_list:
			print(player_key)
			if player_key != ClientGlobals.id:
				delete_player(player_key)
		return
		
	#If we are the player moving and this is not the new join signal, dont do anything
	if id == ClientGlobals.id and scene_change.leaving != 3: return 

	#if a player is joining the scene, spawn them in
	if scene_change.leaving == 1:
		spawn_player(id)
		
	#if a player is leaving our scene, delete them
	elif scene_change.leaving == 2:
		delete_player(id)
		
		
	
