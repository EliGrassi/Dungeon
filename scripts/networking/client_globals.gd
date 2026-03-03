extends Node

signal handle_local_id_assignment(id: int)
signal handle_foreign_id_assignment(id: int)
signal handle_player_position(player_position: PlayerPosition)
signal handle_peer_animation_state(player_animation: PlayerAnimation)
signal handle_peer_scene_change(scene_change: SceneChange)

var id: int = -1
var remote_ids: Array[int]

func _ready() -> void:
	ClientNetworkHandler.on_client_get_packet.connect(on_client_packet)

func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		PacketBase.PACKET_TYPE.ID_SET:
			handle_ids(IDSet.create_from_data(data))
		PacketBase.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		PacketBase.PACKET_TYPE.PLAYER_ANIMATION:
			handle_peer_animation_state.emit(PlayerAnimation.create_from_data(data))
		PacketBase.PACKET_TYPE.SCENE_CHANGE:
			handle_peer_scene_change.emit(SceneChange.create_from_data(data))
			pass


func handle_ids(data: IDSet) -> void:
	if id == -1:
		id = data.id
		handle_local_id_assignment.emit(id)
		
		for remote_id in data.remote_ids:
			if remote_id == id: continue
			if not remote_id in remote_ids:
				remote_ids.append(remote_id)
			handle_foreign_id_assignment.emit(remote_id)
	else:
		remote_ids.append(data.id)
		handle_foreign_id_assignment.emit(data.id)
