extends Node
class_name client_scene_changer

@export var area: Area2D
@export var target_scene: int
@export var destination: Vector2 = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(change_scene)
	#The player is on layer 2, so the area
	#needs to check on layer 2 with its mask
	area.collision_mask = 2
	pass # Replace with function body.


#Triggers when we enter the area assigned to this scene changer
func change_scene(body: Node2D) -> void:
	var id: int = ClientGlobals.id
	#if the thing entering is the local player, send a scene change packet to the target
	if body.get_parent() != null and body.get_parent().name == str(ClientGlobals.id):
		if body.get_parent().on_server: return
		#use 4 to mean nothing for the leaving value. only client uses this value
		body.global_position = destination
		SceneChangeHandler.start_scene_change.emit(id, target_scene)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
