extends Node

@export var player: PlayerWrapper
@export var character: CharacterBody2D
var count: int = 0

var target_position: Vector2 = Vector2(0,0)
var position_recieved: bool = false

func _ready() -> void:
	ClientGlobals.handle_player_position.connect(client_handle_position)



#Function for handling packet telling you this players position
func client_handle_position(player_position: PlayerPosition) -> void:
	#If this player is yours (and not the server copy), or if this player isnt the one the packet
	#Is referring to, return.
	if (player.is_authority and not player.on_server) || player_position.id != player.owner_id: return
	
	#If we've yet to get positional information about this player, set its location
	#immediatly instead of having it tween to a new location
	if position_recieved == false:
		character.global_position = player_position.position
		position_recieved = true
	target_position = player_position.position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	count += 1
	#If this is not the local player or this player is the servers copy
	#simply update its registered position and then return
	if !(player.owner_id == ClientGlobals.id) || player.on_server: 
		if position_recieved:
			character.global_position.y = move_toward(character.global_position.y, target_position.y, character.SPEED * delta)
			character.global_position.x = move_toward(character.global_position.x, target_position.x, character.SPEED * delta)
		return
	#If this is the local player, emit its position to the server
	if count % 3 == 0:
		PlayerPosition.create(player.owner_id, character.global_position).send(ClientNetworkHandler.connected_server)
