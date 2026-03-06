class_name PlayerAnimation extends PacketBase


var id: int
var animation_action: int
var animation_direction: int

static func create(player_id: int, player_animation_action: int, player_animation_direction: int) -> PlayerAnimation:
	var info: PlayerAnimation = PlayerAnimation.new()
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.packet_type = PACKET_TYPE.PLAYER_ANIMATION
	info.id = player_id
	info.animation_action = player_animation_action
	info.animation_direction = player_animation_direction
	return info


static func create_from_data(data: PackedByteArray) -> PlayerAnimation:
	var info = PlayerAnimation.new()
	info.decode(data)
	return info
	
func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	#one byte for packet type, one byte for sender id, 1 byte for flags
	data.resize(4)
	data.encode_u8(1, id)
	data.encode_u8(2, animation_action)
	data.encode_u8(3, animation_direction)
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	animation_action = data.decode_u8(2)
	animation_direction = data.decode_u8(3)
