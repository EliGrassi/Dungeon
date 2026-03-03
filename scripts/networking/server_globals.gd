extends Node


signal handle_player_position(client_id: int, player_position: PlayerPosition)
signal handle_player_animation(client_id: int, player_animation: PlayerAnimation)
signal handle_player_change_scene(client_id: int, scene_change: SceneChange)


var client_ids: Array[int]


func _ready() -> void:
	ServerNetworkHandler.on_client_connect.connect(on_client_connected)
	ServerNetworkHandler.on_client_disconnect.connect(on_client_disconnected)
	ServerNetworkHandler.on_server_get_packet.connect(handle_incoming_packet)
	

func on_client_connected(client_id: int) -> void:
	client_ids.append(client_id)
	IDSet.create(client_id, client_ids).broadcast(ServerNetworkHandler.connection)
	
func on_client_disconnected(client_id: int) -> void:
	client_ids.erase(client_id)
	#MAKE THING TO TELL SERVER CLIENT DIED
	
func handle_incoming_packet(client_id: int, packet: PackedByteArray) -> void:
	var packet_type: int = packet.decode_u8(0)
	match packet_type:
		PacketBase.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(client_id, PlayerPosition.create_from_data(packet))
			pass
		PacketBase.PACKET_TYPE.PLAYER_ANIMATION:
			handle_player_animation.emit(client_id, PlayerAnimation.create_from_data(packet))
		PacketBase.PACKET_TYPE.SCENE_CHANGE:
			print("Routing scene change packet. . .")
			handle_player_change_scene.emit(client_id, SceneChange.create_from_data(packet))
	pass
