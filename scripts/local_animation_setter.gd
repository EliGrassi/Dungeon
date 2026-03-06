extends Node

@export var TargetAnimationController: AnimationController
@export var TargetCharacterBody: CharacterBody2D
@export var Health: Node = null

var current_action
var current_direction



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if TargetCharacterBody.get_parent().name != str(ClientGlobals.id): return
	
	
	var wanted_action = TargetAnimationController.ACTION.IDLE
	var wanted_direction = null
	
	#negative, positive
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	
	if directionX < 0:
		wanted_direction = TargetAnimationController.DIRECTION.LEFT
	elif directionX > 0:
		wanted_direction = TargetAnimationController.DIRECTION.RIGHT
		
	#Check Y second because we want up/down to overwrite left/right
	
	if directionY < 0:
		wanted_direction = TargetAnimationController.DIRECTION.UP
	elif directionY > 0:
		wanted_direction = TargetAnimationController.DIRECTION.DOWN
		
	var velocity = TargetCharacterBody.velocity
	
	if velocity.length() > 0:
		wanted_action = TargetAnimationController.ACTION.MOVING
		
	#We want velocity to overwrite inputs in order to resolve people holding down
	#several buttons looking wrong
	
	if velocity.x < 0:
		wanted_direction = TargetAnimationController.DIRECTION.LEFT
	elif velocity.x > 0:
		wanted_direction = TargetAnimationController.DIRECTION.RIGHT
		
	if velocity.y > 0:
		wanted_direction = TargetAnimationController.DIRECTION.DOWN
	elif velocity.y < 0:
		wanted_direction = TargetAnimationController.DIRECTION.UP
	
	var updated = false
	
	if wanted_action != current_action:
		updated = true
		current_action = wanted_action
		TargetAnimationController.change_action(wanted_action)
	if wanted_direction != current_direction and wanted_direction != null:
		current_direction = wanted_direction
		TargetAnimationController.change_direction(wanted_direction)
		updated = true
	if updated:
		state_changed()
	
	
	

#NETWORKING CODE:

func state_changed() -> void:
	PlayerAnimation.create(ClientGlobals.id, TargetAnimationController.EntityAction, TargetAnimationController.EntityDirection).send(ClientNetworkHandler.connected_server)


func client_animation_get(animation_packet: PlayerAnimation) -> void:
	if animation_packet.id == ClientGlobals.id: return
	if str(animation_packet.id) != get_parent().get_parent().name: return
	TargetAnimationController.change_action(animation_packet.animation_action)
	TargetAnimationController.change_direction(animation_packet.animation_direction)

func server_animation_get(_client_id: int, animation_packet: PlayerAnimation) -> void:
	animation_packet.broadcast(ServerNetworkHandler.connection)
	pass
	

func _ready() -> void:
	current_action = TargetAnimationController.EntityAction
	current_direction = TargetAnimationController.EntityDirection
	ClientGlobals.handle_peer_animation_state.connect(client_animation_get)
	ServerGlobals.handle_player_animation.connect(server_animation_get)
	pass # Replace with function body.
