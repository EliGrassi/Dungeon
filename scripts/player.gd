extends Node2D

@export var owner_id: int
@export var is_authority: bool:
	get: return ClientNetworkHandler.client_connected && owner_id == ClientGlobals.id
