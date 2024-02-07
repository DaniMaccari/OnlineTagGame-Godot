extends Node

var room = preload("res://scenes/room.tscn")
var client = preload("res://scenes/client.tscn")
var network = NetworkedMultiplayerENet.new()
var rng = RandomNumberGenerator.new()

var max_players = 100 
var max_lobby_players = 10
var port = 1909

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_players)
	get_tree().network_peer = network
	print("server is UP")

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")


func _player_connected(player_id):
	print((str(player_id)) + " joined")
	var new_client = client.instance()
	new_client.name =  str(player_id) #"guest_" + str(player_id)
	$clients.add_child(new_client)

func _player_disconnected(player_id):
	print((str(player_id) + " disconnected"))
	$clients.get_node(str(player_id)).terminate()

remote func GetServerTime(client_time):
	var client_id = get_tree().get_rpc_sender_id()
	rpc_id(client_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)

remote func create_room():
	print("creating a room...")
	var client_id = get_tree().get_rpc_sender_id()
	var new_room = room.instance()
	rng.randomize()
	var room_id = rng.randi_range(10000,99999)
	new_room.name = str(room_id)
	$rooms.add_child(new_room)
	print("room created")
	if client_id in get_tree().get_network_connected_peers():
		rpc_id(client_id, "enter_room", room_id)
	else:
		$rooms.get_node(str(room_id)).queue_free()

remote func add_client(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	
	if r != null:
		r.add_client(client_id)
	
	else:
		print("room doesnt exist")
		
remote func update_clients(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	
	if r != null:
		if client_id in get_tree().get_network_connected_peers():
			rpc_id(client_id, "updated_clients", r.client_list)

remote func exit_room(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	
	if r !=null:
		r.exit_client(client_id)

remote func update_rooms():
	var client_id = get_tree().get_rpc_sender_id()
	rpc_id(client_id, "updated_rooms", $rooms.rooms_list)
	

remote func request_enter(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(room_id)
	
	if r !=null:
		if r.game_started == false and r.num_players < max_lobby_players:
			if client_id in get_tree().get_network_connected_peers():
				rpc_id(client_id, "enter_room", room_id)
		else:
			print("room full or started")
	else:
		print("room doesnt exist")

remote func send_start_signal(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	if r != null:
		
		var keys = r.client_list.keys()
		if keys[0] == str(client_id):
			
			r.load_stage()
			for c in keys:
				rpc_id(int(c), "load_stage", r.client_list)

remote func send_ready_signal(room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	if r !=null:
		print("received")
		r.make_ready(client_id)

#HERE SHOULD BE AN ERROR
##--------------------------------------
func all_ready(client_keys):
	for c in client_keys:
		rpc_id(int(c), "all_ready")
##--------------------------------------
remote func client_input_update(client_input, room_id):
	var client_id = get_tree().get_rpc_sender_id()
	var r = $rooms.get_node_or_null(str(room_id))
	if r !=null:
		r.get_node("clients/"+str(client_id)).OnClientInput(client_input)
	
func send_world_state(world_state, client_id, room_id):
	if client_id in get_tree().get_network_connected_peers():
		rpc_unreliable_id(client_id, "update_world_state", world_state)

func send_all_data():
	pass





