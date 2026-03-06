class_name PacketBase

enum  PACKET_TYPE{
	ID_SET = 0,
	PLAYER_POSITION = 1,
	PLAYER_ANIMATION = 2,
	SCENE_CHANGE = 3
}

#The type of packet
var packet_type = PACKET_TYPE
#If the packet is TCP or UDP
var flag: int


func encode() -> PackedByteArray:
	var data: PackedByteArray
	data.resize(1)
	data.encode_u8(0, packet_type)
	return data
	
func decode(data: PackedByteArray) -> void:
	packet_type = data.decode_u8(0) as PACKET_TYPE
	

func send(target: ENetPacketPeer) -> void:
	target.send(0, encode(), flag)

func broadcast(server: ENetConnection) -> void:
	server.broadcast(0, encode(), flag)
