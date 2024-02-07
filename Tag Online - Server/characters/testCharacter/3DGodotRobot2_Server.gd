extends KinematicBody

export var speed := 7.0
export var run_speed := 11.0
var current_speed := speed
export var jump_strenght := 22.0
export var gravity := 1.0
var _is_running = false
var playing_game = true

var velocity = Vector3.ZERO
var snap_vector := Vector3.DOWN
var to_state = "idle"
var look_direction := Vector2(90, 90)
var last_look_direction := look_direction



#onready var model : Spatial = get_node("./RobotArmature")
onready var anim_tree = get_node("AnimationTree")
onready var state_machine = anim_tree.get("parameters/playback")


#player INPUT variables
var is_jumping = false
var is_jumping_server = false
var move_direction := Vector3.ZERO


#- manage ticks -
var timer = 0
var minTimeBetweenTicks = 1/60.0
var currentTick = 0
var inputQueue = []
var ServerTick = 0
var stateBuffer = []
const BUFFER_SIZE = 1024
var maxTick = 0

func _ready():
	stateBuffer.resize(BUFFER_SIZE)
	#anim_tree.active = true
	#state_machine.start("idle")


func State():
	return state_machine.get_current_node()

func Travel(state):
	state_machine.travel(state)

func _process(delta):
	timer += delta
	
	if timer >= minTimeBetweenTicks:
		#print("MINTIMEBETWEENTICKKKSSS")
		timer -= minTimeBetweenTicks
		HandleTick()
		currentTick += 1
	
func ProcessInput(client_input):
	
	if playing_game != true:
		return
		
	#erase later
	if client_input == null:
		return

	velocity.x = client_input["D"].x * (client_input["CS"] *minTimeBetweenTicks) *60
	velocity.z = client_input["D"].z * (client_input["CS"] *minTimeBetweenTicks) *60
	velocity.y -= gravity * minTimeBetweenTicks
	
	move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
	
	if client_input["J"]:
		velocity.y = jump_strenght
		snap_vector = Vector3.ZERO
		
	elif is_on_floor() and snap_vector == Vector3.ZERO: #just landed
		snap_vector = Vector3.DOWN
	
	elif !is_on_floor():
		to_state = "jump-up" if velocity.y > 0 else "jump-down"
	
	Travel(client_input["S"])
	anim_tree.advance(minTimeBetweenTicks)
	

	#if velocity.length() > 0.2 && (velocity.x != 0 || velocity.z != 0):
		
	#	if is_on_floor():
	#		to_state = "walk" if !_is_running else "run"
			
	#elif is_on_floor():
	#	to_state = "idle" #idle
	
	#model.rotation.y = client_input["R"]
	
	
	return {"T": client_input["T"], "P": transform.origin, "S": client_input["S"], "R": client_input["R"]}
	

func HandleTick():
	var bufferIndex = -1
	
	while inputQueue.size() > 0:
		var input = inputQueue.pop_front()
		ServerTick = input["T"]
		var statePayload = ProcessInput(input)
		bufferIndex = input["T"] % BUFFER_SIZE
		stateBuffer[bufferIndex] = statePayload
		print("Actual Buffer Index - " + str(bufferIndex))
		
	if bufferIndex != -1:
		get_parent().get_parent().SendPlayerState(self.name, stateBuffer[bufferIndex])

func OnClientInput(input):
	if inputQueue.size() > 0:
		if input["T"] > inputQueue[inputQueue.size() - 1]["T"]:
			inputQueue.append(input)
		else:
			print("packet delay")
	else:
		inputQueue.append(input)



