extends Node

@export var player: Node
@export var character: CharacterBody2D
var count: int = 0

var target_position: Vector2 = Vector2(0,0)
var position_recieved: bool = false

func _enter_tree() -> void:
	ClientGlobals.handle_player_position.connect(client_handle_position)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func client_handle_position(player_position: PlayerPosition) -> void:
	if player.is_authority || player_position.id != player.owner_id: return
	if position_recieved == false:
		character.global_position = player_position.position
		position_recieved = true
	target_position = player_position.position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	count += 1
	if !(player.owner_id == ClientGlobals.id): 
		if position_recieved:
			character.global_position.y = move_toward(character.global_position.y, target_position.y, character.SPEED * delta)
			character.global_position.x = move_toward(character.global_position.x, target_position.x, character.SPEED * delta)
		return
	if count % 3 == 0:
		PlayerPosition.create(player.owner_id, character.global_position).send(ClientNetworkHandler.connected_server)
