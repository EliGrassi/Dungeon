extends AnimatedSprite2D
class_name AnimationController



@export var EntityDirection: DIRECTION = DIRECTION.UP
@export var EntityAction: ACTION = ACTION.IDLE
@export var AnimatedSprite: AnimatedSprite2D = self

enum DIRECTION{
	UP,
	DOWN,
	LEFT,
	RIGHT
}

enum ACTION{
	IDLE,
	MOVING,
	HURT
}

func change_direction(direction: DIRECTION) -> void:
	EntityDirection = direction
	select_animation()
func change_action(action: ACTION) -> void:
	EntityAction = action
	select_animation()

#Selects animation of sprite2D based on state
func select_animation() -> void:
	AnimatedSprite.flip_h = false
	match EntityDirection:
		DIRECTION.UP:
			match EntityAction:
				ACTION.IDLE:
					AnimatedSprite.play("IDLE_UP")
				ACTION.MOVING:
					AnimatedSprite.play("MOVE_UP")
				ACTION.HURT:
					AnimatedSprite.play("HURT_UP")
				
		DIRECTION.DOWN:
			match EntityAction:
				ACTION.IDLE:
					AnimatedSprite.play("IDLE_DOWN")
				ACTION.MOVING:
					AnimatedSprite.play("MOVE_DOWN")
				ACTION.HURT:
					AnimatedSprite.play("HURT_DOWN")
		DIRECTION.LEFT:
			AnimatedSprite.flip_h = true
			match EntityAction:
				ACTION.IDLE:
					AnimatedSprite.play("IDLE_RIGHT")
				ACTION.MOVING:
					AnimatedSprite.play("MOVE_RIGHT")
				ACTION.HURT:
					AnimatedSprite.play("HURT_RIGHT")
		DIRECTION.RIGHT:
			match EntityAction:
				ACTION.IDLE:
					AnimatedSprite.play("IDLE_RIGHT")
				ACTION.MOVING:
					AnimatedSprite.play("MOVE_RIGHT")
				ACTION.HURT:
					AnimatedSprite.play("HURT_RIGHT")



#CODE FOR NETWORKING
func state_changed() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
