extends CharacterBody2D


const SPEED = 100.0
const ACCELERATION = 50
@onready var player = $".."

var count: int = 0

var target_position: Vector2 = Vector2(0,0)
var position_recieved: bool = false

func _enter_tree() -> void:
	ServerGlobals.handle_player_position.connect(server_handle_position)
	ClientGlobals.handle_player_position.connect(client_handle_position)

func _physics_process(delta: float) -> void:
	count += 1
	if !(player.owner_id == ClientGlobals.id): 
		if position_recieved:
			global_position.y = move_toward(global_position.y, target_position.y, SPEED * delta)
			global_position.x = move_toward(global_position.x, target_position.x, SPEED * delta)
		return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	if directionX:
		velocity.x = move_toward(velocity.x, directionX*SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if directionY:
		velocity.y = move_toward(velocity.y, directionY*SPEED, ACCELERATION)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	if count % 3 == 0:
		PlayerPosition.create(player.owner_id, global_position).send(ClientNetworkHandler.connected_server)

func server_handle_position(client_id: int, player_position: PlayerPosition) -> void:
	if player.owner_id != client_id: return
	PlayerPosition.create(player.owner_id, player_position.position).broadcast(ServerNetworkHandler.connection)
	
func client_handle_position(player_position: PlayerPosition) -> void:
	if player.is_authority || player_position.id != player.owner_id: return
	
	position_recieved = true
	target_position = player_position.position
