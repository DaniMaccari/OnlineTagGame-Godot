extends Viewport

var stage_scene = preload("res://stages/testStage/tetsMovement_Server.tscn")#elegir escena
var character_scene = preload("res://characters/testCharacter/3DGodotRobot2_Server.tscn")

var client_list = {}
var client_info = {
	"name": null,
	"room_id": null,
	"hunter": false,
	"points": 0,
	"ready": false
}

var max_players = 9
var num_players = 0
var game_started = false

var currentTick = 0
var minTimeBetweenTicks = 1/20
const SERVER_TICK_RATE = 20
var world_state = {}
var worldstate_buffer = {}
var timer = 0.0

func _ready():
	set_process(false)
	get_parent().add_room(self.name)
	

func SendPlayerState(id, state):
	worldstate_buffer[id] = state

func _process(delta):
	timer += delta
	
	while timer >= minTimeBetweenTicks:
		timer -= minTimeBetweenTicks
		HandleTick()

func HandleTick():
	if client_list.size() != 0:
		world_state["T"] = OS.get_system_time_msecs()
		for c in $clients.get_children():
			if worldstate_buffer[c.name] != null:
				world_state[c.name] = worldstate_buffer[c.name]
		for id in $clients.get_children():
			get_parent().get_parent().send_world_state(world_state, int(id.name), self.name)
		
func add_client(c_id):
	if client_list.size() >= max_players:
		print("Room Full")
		return
	var new_client = client_info.duplicate()
	var c = get_parent().get_parent().get_node("clients").get_node(str(c_id))
	new_client["name"] = c.client_info["name"]
	new_client["room_id"] = self.name
	new_client["hunter"] = false
	new_client["points"] = 0
	c.client_info = new_client
	client_list[str(c_id)] = new_client
	update_count()

func exit_client(c_id):
	client_list.erase(str(c_id))
	update_count()
	if --num_players == 0:
		get_parent().delete_room(self.name)
		self.queue_free()

func update_count():
	var aux_players = 0
	for c in client_list.keys():
		aux_players += 1
	num_players = aux_players
	get_parent().update_room(self.name, {"num_players": num_players, "game_started": game_started})


func _on_Timer_timeout():
	if num_players == 0:
		get_parent().delete_room(self.name)
		self.queue_free()

func load_stage():
	
	if get_node_or_null("stage1") != null: #testMovement
		return
	
	game_started = true
	get_parent().update_room(self.name, {"num_players": num_players, "game_started": game_started})
	
	var stage = stage_scene.instance()
	stage.name = "stage1"
	add_child(stage)
	
	var pos_prey = 0
	for c in client_list.keys():
		#change this later to spawn hunter in the middle and preys in a circle
		var pos
		if false: #client_list[c]["hunter"] == true:
			pos = Vector3(0, 0.6, 0)
		else:
			pos = Vector3(-4 + pos_prey, 0.6, -2)
			pos_prey += 2
		var new_client = character_scene.instance()
		new_client.name = c
		new_client.transform.origin = pos
		$clients.add_child(new_client)
		
	$TimerClientsReady.start()
	
func make_ready(client_id):
	client_list[str(client_id)]["ready"] = true
	print("OK, READY")

func _on_TimerClientsReady_timeout(): #ver si todos están listos, sino esperar
	
	var stillWaiting = false
	for c in client_list.keys():
		if client_list[c]["ready"] == false:
			stillWaiting = true
			
			break
		else:
			
			pass
	print("trying")
	
	if !stillWaiting:
		
		get_parent().get_parent().all_ready(client_list.keys())
		set_process(true)
		print()
		print("-----on_timerclients - process TRUE -----")
		print()
		$TimerClientsReady.queue_free()
		





