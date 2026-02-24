extends Node


signal handle_player_position(client_id: int, player_position: PlayerPosition)


var client_ids: Array[int]


func _ready() -> void:
	NetworkHandler.on_client_connect.connect(on_client_connected)
	NetworkHandler.on_client_disconnect.connect(on_client_disconnected)
	NetworkHandler.on_server_get_packet.connect(handle_incoming_packet)
	

func on_client_connected(client_id: int) -> void:
	client_ids.append(client_id)
	IDSet.create(client_id, client_ids).broadcast(NetworkHandler.connection)
	
func on_client_disconnected(client_id: int) -> void:
	client_ids.erase(client_id)
	#MAKE THING TO TELL SERVER CLIENT DIED
	
func handle_incoming_packet(client_id: int, packet: PackedByteArray) -> void:
	var packet_type: int = packet.decode_u8(0)
	match packet_type:
		PacketBase.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(client_id, PlayerPosition.create_from_data(packet))
			pass
	pass
