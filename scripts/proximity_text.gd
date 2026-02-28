extends Node2D
class_name ProximityText

@export var text: String = "[Placeholder]"
@export var text_size: float = 1
@export var text_node: Label = null
@export var offset_up = 0
@export var offset_left = 0
@export var area: Area2D = null

var change_speed:float = 1.5
var opacity: float = 0


#Set the opacity to visible when the local player enters
func entered(Character: Node2D) -> void:
	if Character.get_parent() != null and Character.get_parent().name == str(ClientGlobals.id):
		opacity = 1
		
	
#Set the opacity to invisible when the local player leaves
func exit(Character: Node2D) -> void:
	if Character.get_parent() != null and Character.get_parent().name == str(ClientGlobals.id):
		opacity = 0

#Slowly change the opacity towards the taret every render step
func _process(delta: float) -> void:
	text_node.modulate.a = move_toward(text_node.modulate.a, opacity, change_speed * delta)

#Apply variables and set connections
func _ready() -> void:
	text_node.modulate.a = 0
	text_node.text = text
	text_node.scale = Vector2(text_size, text_size)
	area.body_entered.connect(entered)
	area.body_exited.connect(exit)
	
