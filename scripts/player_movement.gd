extends CharacterBody2D


const SPEED = 300.0
@onready var player = $".."


func _enter_tree() -> void:
	ServerGlobals.handle_player_position.connect(server_handle_position)
	ClientGlobals.handle_player_position.connect(client_handle_position)

func _physics_process(delta: float) -> void:

	if !player.is_authority: return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
	PlayerPosition.create(player.owner_id, global_position).send(NetworkHandler.connected_server)

func server_handle_position(client_id: int, player_position: PlayerPosition) -> void:
	if player.owner_id != client_id: return
	
	global_position = player_position.position
	PlayerPosition.create(player.owner_id, global_position).broadcast(NetworkHandler.connection)
	
func client_handle_position(player_position: PlayerPosition) -> void:
	if player.is_authority || player_position.id != player.owner_id: return
	global_position = player_position.position
