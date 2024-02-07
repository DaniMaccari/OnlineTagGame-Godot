extends Node

var temp_list
var network = NetworkedMultiplayerENet.new()
var r_id = 0


var ip_address = "127.0.0.1" #local IP
#var ip_address = "194.163.168.245" #myServer IP
var port = 1909
onready var scene_handler = get_node("/root/scene_handler")
var client_clock = OS.get_system_time_msecs()
var latency = 0
var decimal_collector = 0.0

func _ready():
	start_client()

func _physics_process(delta):
	client_clock += int(delta*1000)
	decimal_collector += (delta*1000) - int(delta*1000)
	
	if( decimal_collector >= 1):
		client_clock += 1
		decimal_collector -= 1
	
func start_client():
	network.create_client(ip_address, port)
	get_tree().network_peer = network

	get_tree().connect("connected_to_server", self, "_connection_success")
	get_tree().connect("connection_failed", self, "_connection_failed")

func _connection_success():
	print("connected succesfully")
	rpc_id(1, "GetServerTime", OS.get_system_time_msecs())
	
	var timer_resync = Timer.new()
	timer_resync.wait_time = 3
	timer_resync.autostart = true
	timer_resync.connect("timeout", self, "resync")
	get_parent().get_node("scene_handler").add_child(timer_resync)

remote func ReturnServerTime(server_time, old_client_time):
	latency = (OS.get_system_time_msecs() - old_client_time)/2
	client_clock = server_time + latency
	
func resync():
	rpc_id(1, "GetServerTime", OS.get_system_time_msecs())

func _connection_failed():
	print("connection failed")

func create_room():
	rpc_id(1, "create_room")

remote func enter_room(room_id):
	if( get_tree().get_rpc_sender_id() != 1): #no es el servidor
		return
	
	r_id = int(room_id)
	var res = scene_handler.get_node_or_null("LoginScene") #uuuu suspicious before LoginScene
	
	if(res != null):
		res.enter_room()
	else:
		res = scene_handler.get_node_or_null("Lobby")
		if (res != null):
			res.enter_room()
		else:
			print("scene is null")

func add_client():
	rpc_id(1, "add_client", r_id)
	
func update_clients():
	rpc_id(1, "update_clients", r_id)

remote func updated_clients(client_list):
	print("we r so back")
	if( get_tree().get_rpc_sender_id() != 1): #no es el servidor
		return
	
	var res = scene_handler.get_node_or_null("RoomsScene") #RoomsScene
	if(res != null):
		res.update_clients(client_list)
	
func exit_room():
	rpc_id(1, "exit_room", r_id)
	
func update_rooms():
	rpc_id(1, "update_rooms")
	
remote func updated_rooms(rooms_list):
	if(get_tree().get_rpc_sender_id() != 1):
		return
	
	var res = scene_handler.get_node_or_null("Lobby")
	if (res != null):
		res.updated_rooms(rooms_list)

func request_enter(room_id):
	rpc_id(1, "request_enter", room_id)

func send_start_signal():
	rpc_id(1, "send_start_signal", r_id)

remote func load_stage(client_list):
	if get_tree().get_rpc_sender_id() != 1:
		return
		
	var res = scene_handler.get_node_or_null("RoomsScene") #RoomsScene
	if res != null:
		temp_list = client_list
		res.load_stage()

func send_ready_signal():
	rpc_id(1, "send_ready_signal", r_id)

remote func all_ready():
	var res = scene_handler.get_node_or_null("GameScene") #GameScene

	if res != null:
		res.get_node("3DGodotRobot").start_game()
		res.set_process(true)

func send_client_input(client_input):
	if network.get_connection_status() == 2:
		print("send_client-input - Im Connected")
		rpc_unreliable_id(1, "client_input_update", client_input, r_id)

#
#remote func update_other_players(c_id, c_position):
#	if(get_tree().get_rpc_sender_id() != 1):
#		return
#	var res = scene_handler.get_node_or_null("GameScene")
#	if (res != null) and (BORRAR):
#		res.update_players(c_id, c_position)

remote func update_world_state(world_state):
	if get_tree().get_rpc_sender_id() != 1:
		return
	var res = scene_handler.get_node_or_null("GameScene")
	if res!=null:
		res.update_world_state(world_state)



