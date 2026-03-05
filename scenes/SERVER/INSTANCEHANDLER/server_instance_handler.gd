extends Node
class_name InstanceHandler

#Node for the player to put into instances
@export var player_node: PackedScene = null
#Node for the instance containers used to hold maps/entities on the server
@export var instance_container: PackedScene


#signal confirming an instance has finished loading
signal instance_loaded(instance_id: int)
#Signal that can be called to try and move a player
signal player_request_move(player_info: PlayerInfo, to_id: int, from_id: int)
#Signal confirming that the player has been moved
signal player_finished_moving(player_id: int, to_id: int, from_id: int)

#Dict of instances on the server
var containers: Dictionary[int, ServerInstanceContainer] = {}



func _ready() -> void:
	player_request_move.connect(player_moving_to_instance_request)





#When we get a signal to move a player, confirm if the target instance exists
#If it does not, create it, and then call the player joined instance function regardless

#PLAYER_INFO: Information about the player sending a move request
#TO_ID: The id of the scene the player wants to move to
#FROM_ID: The id of the scene the player is coming from
func player_moving_to_instance_request(player_info: PlayerInfo, to_id:int, from_id:int) -> void:
	#Check if the server already has the wanted location running in an instance
	if !containers.has(to_id):
		#If it does not, create the new instance and add it to our dict
		var new_instance = instance_container.instantiate()
		new_instance.master = self
		new_instance.id = to_id
		containers[to_id] = new_instance
		call_deferred("add_child", new_instance)
	#Now that we know the instance exists, finish moving the player to it
	#I should add some way to wait for it to be done getting loaded
	player_joined_instance(player_info, to_id, from_id)
	
#Called after the wanted instance of a move is confirmed to exist	
#Re parent the player to the new instance containers player holder, then emit
#A signal confirming that the player has been moved.

#PLAYER_INFO: Information about the player sending a move request
#TO_ID: The id of the scene the player wants to move to
#FROM_ID: The id of the scene the player is coming from
func player_joined_instance(player_info: PlayerInfo, to_id:int, from_id:int) -> void:
	var player_id = player_info.id
	#If the player is already in an area (-1 is used for not being anywhere) and the server
	#has the area registered (Should be guarenteed, but may as well check)
	if from_id != -1 and containers.has(from_id):
		#Get the instance the player is leaving, get the player inside it, and reparent the player
		#to the new area they're entering
		var container = containers[from_id]
		var player_in_container = container.players_container.get_node(str(player_id))
		player_in_container.reparent(containers[to_id].players_container)
	
	#Otherwise, this player does not exist on the server yet. create the player
	#object, set its information right, and put it in its destination
	else:
		var new_player: PlayerWrapper = player_node.instantiate()
		new_player.name = str(player_id)
		new_player.on_server = true
		new_player.owner_id = player_id
		containers[to_id].players_container.call_deferred("add_child", new_player)
		
	#Emit a signal to confirm the player has finished moving. this can be read
	#by other scripts to manage moved player conditions
	player_finished_moving.emit(player_id, to_id, from_id)
	
	
