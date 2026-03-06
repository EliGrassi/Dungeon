extends Node



#CLIENT SIGNALS
signal on_connect_to_server()
signal on_disconnect_to_server()
signal on_client_get_packet(data: PackedByteArray)


#CLIENT VARS
var connected_server: ENetPacketPeer


#GENERAL VARS
@export var client_connected: bool = false
var connection: ENetConnection


#PROCESS LOOP FOR RECIEVING PACKETS

func _process(_delta: float) -> void:
	if connection == null: return
	handle_packets()

func handle_packets() -> void:
	var packet_event: Array = connection.service()
	var event_type: ENetConnection.EventType = packet_event[0]
	
	while event_type != ENetConnection.EVENT_NONE:
		var client = packet_event[1]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("CLIENT: PACKAGE ERROR - unkown error")
				pass
			ENetConnection.EVENT_CONNECT:
				connected_to_server()
			ENetConnection.EVENT_DISCONNECT:
				disconnected_to_server()
				return
			ENetConnection.EVENT_RECEIVE:
				on_client_get_packet.emit(client.get_packet())
		packet_event = connection.service()
		event_type = packet_event[0]


#FUNCTIONS FOR HANDLING CONNECTIONS

func connected_to_server() -> void:
	print("CLIENT: connected to server")
	on_connect_to_server.emit()


#FUNCTIONS FOR HANDLING DISCONNECTIONS


func disconnected_to_server() -> void:
	print("CLIENT: disconnected to server")
	on_disconnect_to_server.emit()
	connection = null
	
func disconnect_client() -> void:
	connected_server.peer_dissconnect()
	print("CLIENT: client disconnected")
	client_connected = false
#FUNCTIONS FOR STARTING A SERVER/CLIENT


	
func start_client(ip_address: String = "127.0.0.1", port: int = 25555) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host(1)
	if error:
		print("CLIENT: Failed to start client: ", error_string(error))
		connection = null
		return
	print("CLIENT: client started")
	connected_server = connection.connect_to_host(ip_address, port)
	client_connected = true
	
	
	
	
	
	
	
	
	
