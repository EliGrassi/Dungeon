class_name SceneChange extends PacketBase


var id: int
var leaving: int
var scene: int

static func create(id: int, scene_id: int, scene_leaving:int) -> SceneChange:
	var info: SceneChange = SceneChange.new()
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.packet_type = PACKET_TYPE.SCENE_CHANGE
	info.id = id
	info.scene = scene_id
	info.leaving = scene_leaving
	return info


static func create_from_data(data: PackedByteArray) -> SceneChange:
	var info = SceneChange.new()
	info.decode(data)
	return info
	
func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	#one byte for packet type, one byte for sender id, 1 bytes
	#for the scene id
	data.resize(4)
	data.encode_u8(1, id)
	data.encode_float(2, scene)
	data.encode_float(3, leaving)
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	scene = data.decode_u8(2)
	leaving = data.decode_u8(3)
