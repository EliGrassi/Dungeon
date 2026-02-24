extends Node2D

@export var owner_id: int
@export var is_authority: bool:
	get: return !NetworkHandler.is_server && owner_id == ClientGlobals.id
