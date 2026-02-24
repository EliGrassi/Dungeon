extends Node


#SERVER SIGNALS

#fires when a client connects to server
signal on_client_connect(client_id: int)
#fires when a client disconnects from server
signal on_client_disconnect(client_id: int)
#fires when the server recieves a packet
signal on_server_get_packet(client_id: int, data: PackedByteArray)


#SERVER VARS
var connected_client_ids: Array = range(255, -1, -1)
var connected_clients: Dictionary[int, ENetPacketPeer]
var max_clients: int = 4



#GENERAL VARS

var connection: ENetConnection
var is_server: bool = false


#PROCESS LOOP FOR RECIEVING PACKETS

func _process(delta: float) -> void:
	if connection == null: return
	
	handle_packets()

func handle_packets() -> void:
	var packet_event: Array = connection.service()
	var event_type: ENetConnection.EventType = packet_event[0]
	
	while event_type != ENetConnection.EVENT_NONE:
		var client = packet_event[1]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("SERVER: PACKAGE ERROR - unkown error")
				pass
			ENetConnection.EVENT_CONNECT:
				if is_server:
					client_connected(client)
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					client_disconnected(client)
				pass
			ENetConnection.EVENT_RECEIVE:
				on_server_get_packet.emit(client.get_meta("id"), client.get_packet())
		packet_event = connection.service()
		event_type = packet_event[0]


#FUNCTIONS FOR HANDLING CONNECTIONS

func client_connected(client: ENetPacketPeer) -> void:
	var client_id: int = connected_client_ids.pop_back()
	client.set_meta("id", client_id)
	connected_clients[client_id] = client
	print("SERVER: client connected")
	on_client_connect.emit(client_id)


#FUNCTIONS FOR HANDLING DISCONNECTIONS

func client_disconnected(client: ENetPacketPeer) -> void:
	var client_id: int = client.get_meta("id")
	connected_client_ids.push_back(client_id)
	connected_clients.erase(client_id)
	print("SERVER: client", client_id, "disconnected")
	on_client_disconnect.emit(client_id)



#FUNCTIONS FOR STARTING A SERVER/CLIENT

func start_server(ip_address: String = "127.0.0.1", port: int = 25555) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host_bound(ip_address, port, max_clients)
	if error:
		print("SERVER: Failed to start server: ", error_string(error))
		connection = null
		return
	print("SERVER: server started")
	is_server = true
	
	
	
	
	
	
	
	
	
	
	
