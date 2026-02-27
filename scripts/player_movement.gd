extends CharacterBody2D


const SPEED = 100.0
const ACCELERATION = 50
@onready var player = $".."





func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if !ClientGlobals.id == player.owner_id: return
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
	
