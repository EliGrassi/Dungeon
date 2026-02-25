extends Camera2D


@onready var parent: Node = $"../.."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if str(ClientGlobals.id) == parent.name:
		make_current()
	pass # Replace with function body.
