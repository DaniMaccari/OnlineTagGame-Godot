extends Spatial

var character_scene = preload("res://scenes/3DGodotRobot2_duplicate.tscn")
signal scene_change

var client_list
var all_ready_start

func _ready():
	client_list = Server.temp_list
	spawn_clients()
	
func spawn_clients():
	var pos_prey = 0
	for client in client_list.keys():
		#change this later to spawn hunter in the middle and preys in a circle
		var pos
		if false: #client_list[client]["hunter"] == true:
			pos = Vector3(0, 0.6, 0)
		else:
			pos = Vector3(-4 + pos_prey, 0.6, -2)# + pos_prey)
			pos_prey += 2
			
		if client == str(get_tree().get_network_unique_id()):
			$"3DGodotRobot".transform.origin = pos
		
		else:
			var new_client = character_scene.instance()
			new_client.name = client
			new_client.transform.origin = pos
			add_child(new_client)
	
	print("estamos ready")
	Server.send_ready_signal()

func update_world_state(world_state):
	for c in world_state.keys():
		
		if c == "T":
			continue
		elif c == str(get_tree().get_network_unique_id()):
			continue
		else:
			#print (get_node(c) != null )
			
			get_node(c).transform.origin = world_state[c]["P"]
			#get_node(c).rotation.y = world_state[c]["R"]
			#get_node(c).Travel(world_state[c]["S"])

	pass

#func update_players(c_id, c_position):
#
#	if c_id != str(get_tree().get_network_unique_id()):
#		get_node(c_id).transform.origin = c_position


