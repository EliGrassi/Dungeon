extends Node2D
class_name PlayerWrapper

#ID of the player who owns this character
@export var owner_id: int
#Indicates if this is a server copy stored in the server instance handler
@export var on_server: bool = false
#Variable to check if this is run by the local caller
@export var is_authority: bool:
	get: return ClientNetworkHandler.client_connected && owner_id == ClientGlobals.id
#The actual physical CharacterBody2D of the player
@export var Character: Node = null
