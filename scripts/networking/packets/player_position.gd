class_name PlayerPosition extends PacketBase


var id: int
var position: Vector2

static func create(player_id: int, position_of_player: Vector2) -> PlayerPosition:
	var info: PlayerPosition = PlayerPosition.new()
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.packet_type = PACKET_TYPE.PLAYER_POSITION
	info.id = player_id
	info.position = position_of_player
	return info


static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var info = PlayerPosition.new()
	info.decode(data)
	return info
	
func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	#one byte for packet type, one byte for sender id, 8 bytes
	#for the 2 floats of a vec2
	data.resize(10)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector2(data.decode_float(2), data.decode_float(6))
