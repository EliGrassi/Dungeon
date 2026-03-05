extends Node
class_name PlayerSynchronizer

#The server node that handles the servers instances/physics
@export var world_controller: InstanceHandler = null
#Dictonairy of information about connected players
@export var PlayerInformation: Dictionary[int, PlayerInfo]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerGlobals.handle_player_position.connect(position_recieved)
	ServerGlobals.handle_player_change_scene.connect(scene_change_recieved)
	ServerNetworkHandler.on_client_connect.connect(register_new_player)
	world_controller.player_finished_moving.connect(scene_change_confirmed)


#Called when a client connects to the server. add them to the player information dict,
#with their ID as the key
func register_new_player(player_id:int) -> void:
	PlayerInformation[player_id] = PlayerInfo.new()
	PlayerInformation[player_id].id = player_id


#Called when a player reports their position to the server. update their stored position
#inside their dict element. also store a variable confirming that we have a
#position sent from them.
func position_recieved(sender_id: int, position_info: PlayerPosition) -> void:
	PlayerInformation[sender_id].position_updated = true
	PlayerInformation[sender_id].position = position_info.position



#Called when a player requests to change scenes. emit a signal to the instance handler
#letting it know a player wants to move, and to were, and were they're coming from
func scene_change_recieved(sender_id: int, scene_change: SceneChange) -> void:
	var info = PlayerInformation[sender_id]
	world_controller.player_request_move.emit(info, scene_change.scene, info.scene_id)
	pass


#When the server instance handler confirms a move, let all clients know about it, and tell them
#if the mover is leaving their scene, entering their scene, or the mover themself
func scene_change_confirmed(player_id: int, to: int, from: int) -> void:
	PlayerInformation[player_id].scene_id = to
	#Send a message to the person who requested a move letting them know that its confirmed
	#This is indicated by a "3" in the leaving field of the packet
	SceneChange.create(player_id, to, 3).send(ServerNetworkHandler.connected_clients[player_id])
	
	#For every player on the server, let them know what they need to about the move
	for player_key in PlayerInformation:
		var player = PlayerInformation[player_key]
		
		#If the player is in the instance the traveler just went to, tell them to spawn the traveler
		#Also, let the traveler know to spawn them as well. this is indicated by a "1" in the leaving
		#field of the scene change packet
		if player.scene_id == to:

			SceneChange.create(player_id, to, 1).send(ServerNetworkHandler.connected_clients[player.id])
			SceneChange.create(player.id, to, 1).send(ServerNetworkHandler.connected_clients[player_id])
			
		#If the player is in the scene the traveler is leaving, let them know to delete the player
		#This is indicated by a "2" in the leaving field of the scene change packet
		elif player.scene_id == from:
			SceneChange.create(player_id, to, 2).send(ServerNetworkHandler.connected_clients[player.id])


var count = 0
#The physics process emits the position of all players every 3rd run so that clients
#may know the position of their fellow peers
func _physics_process(delta: float) -> void:
	if !ServerNetworkHandler.is_server: return
	count += 1
	if count % 3 == 0:
		for player_id in PlayerInformation:
			#Only send this information if the player themselves has already told the server where they are
			if PlayerInformation[player_id].position_updated:
				var info_to_send = PlayerPosition.create(player_id, PlayerInformation[player_id].position)
				info_to_send.broadcast(ServerNetworkHandler.connection)
