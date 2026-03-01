extends Node2D
class_name PlayerWrapper

@export var owner_id: int
@export var is_authority: bool:
	get: return ClientNetworkHandler.client_connected && owner_id == ClientGlobals.id
@export var Character: Node = null
