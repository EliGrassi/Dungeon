#Information held about players by the server


extends Node
class_name PlayerInfo

@export var position_updated: bool = false
@export var id: int = -1
@export var position: Vector2 = Vector2(0,0)
@export var scene_id: int = -1
@export var attacking: bool = false
