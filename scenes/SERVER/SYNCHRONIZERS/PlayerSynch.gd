extends Node
class_name PlayerSynchronizer

@export var world_controller: InstanceHandler = null
@export var PlayerInformation: Dictionary[int, PlayerInfo]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerGlobals.handle_player_position.connect(position_recieved)
	ServerGlobals.handle_player_change_scene.connect(scene_change_recieved)
	ServerNetworkHandler.on_client_connect.connect(register_new_player)
	world_controller.player_finished_moving.connect(scene_change_confirmed)
	pass # Replace with function body.

func register_new_player(player_id:int) -> void:
	PlayerInformation[player_id] = PlayerInfo.new()
	PlayerInformation[player_id].id = player_id


func position_recieved(sender_id: int, position_info: PlayerPosition) -> void:
	PlayerInformation[sender_id].position_updated = true
	PlayerInformation[sender_id].position = position_info.position



func scene_change_recieved(sender_id: int, scene_change: SceneChange) -> void:

	#info, to, from
	var info = PlayerInformation[sender_id]
	world_controller.player_request_move.emit(info, scene_change.scene, info.scene_id)
	pass


func scene_change_confirmed(player_id: int, to: int, from: int) -> void:
	PlayerInformation[player_id].scene_id = to
	SceneChange.create(player_id, to, 3).send(ServerNetworkHandler.connected_clients[player_id])
	for player_key in PlayerInformation:
		var player = PlayerInformation[player_key]
		if player.scene_id == to:
			#If this player is in the new scene we traveled to, tell them about the joiner
			SceneChange.create(player_id, to, 1).send(ServerNetworkHandler.connected_clients[player.id])
			SceneChange.create(player.id, to, 1).send(ServerNetworkHandler.connected_clients[player_id])
		elif player.scene_id == from:
			SceneChange.create(player_id, to, 2).send(ServerNetworkHandler.connected_clients[player.id])


# Called every frame. 'delta' is the elapsed time since the previous frame.
var count = 0
func _physics_process(delta: float) -> void:
	if !ServerNetworkHandler.is_server: return
	count += 1
	if count % 3 == 0:
		for player_id in PlayerInformation:
			if PlayerInformation[player_id].position_updated:
				var info_to_send = PlayerPosition.create(player_id, PlayerInformation[player_id].position)
				info_to_send.broadcast(ServerNetworkHandler.connection)
