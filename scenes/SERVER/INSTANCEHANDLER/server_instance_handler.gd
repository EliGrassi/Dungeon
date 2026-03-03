extends Node
class_name InstanceHandler

#Node for the player to put into instances
@export var player_node: PackedScene = null



#signal confirming an instance has finished loading
signal instance_loaded(instance_id: int)
#Signal that can be called to try and move a player
signal player_request_move(player_info: PlayerInfo, to_id: int, from_id: int)
#Signal confirming that the player has been moved
signal player_finished_moving(player_id: int, to_id: int, from_id: int)
#Signal for updating player position in a instance
signal update_player(player_info: PlayerInfo)

var containers: Dictionary[int, ServerInstanceContainer] = {}



func _ready() -> void:
	player_request_move.connect(player_moving_to_instance_request)





#When we get a signal to move a player, confirm if the target instance exists
#If it does not, create it, and then call the player joined instance function regardless

func player_moving_to_instance_request(player_info: PlayerInfo, to_id:int, from_id:int) -> void:
	if !containers.has(to_id):
		var new_instance = ServerInstanceContainer.new()
		new_instance.master = self
		new_instance.id = to_id
		containers[to_id] = new_instance
		call_deferred("add_child", new_instance)
	player_joined_instance(player_info, to_id, from_id)
	
	
#Re parent the player to the new instance containers player holder, then emit
#A signal confirming that the player has been moved.
	
func player_joined_instance(player_info: PlayerInfo, to_id:int, from_id:int) -> void:
	var player_id = player_info.id
	if from_id != -1 and containers.has(from_id):
		var container := containers[from_id]
		var player_in_container = container.players_container.get_node(str(player_id))
		player_in_container.reparent(containers[to_id].players_container)
	else:
		var new_player: PlayerWrapper = player_node.instantiate()
		new_player.on_server = true
		new_player.owner_id = player_id
		containers[to_id].call_deferred("add_child", new_player)
	player_finished_moving.emit(player_id, to_id, from_id)
	
	
# move player inside its instance
func update_player_func(player_info: PlayerInfo):
	var container = containers[player_info.instance_id]
	var player: PlayerWrapper = container.players_container.get_node(str(player_info.id))
	#player.Character.global_position = Vector2(player_info.position)
