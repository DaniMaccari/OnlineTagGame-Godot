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

#manage ticks
var timer = 0
var minTimeBetweenTicks = 1/60.0
var currentTick = 0

const BUFFER_SIZE = 1024
var inputBuffer = []
var stateBuffer = []
var default_state = {"T" :0, "P": Vector3.ZERO, "S": "idle"}
var latestServerState = default_state.duplicate()
var latestProcessedState = default_state.duplicate()

onready var spring_arm = get_node("./SpringArm")
onready var model : Spatial = get_node("./RobotArmature")
onready var anim_tree = get_node("AnimationTree")
onready var state_machine = anim_tree.get("parameters/playback")


#player INPUT variables
var is_jumping = false
var is_jumping_server = false
var move_direction := Vector3.ZERO

func _ready():
	anim_tree.active = true
	state_machine.start("idle")
	inputBuffer.resize(BUFFER_SIZE)
	stateBuffer.resize(BUFFER_SIZE)
	pass

func State():
	return state_machine.get_current_node()

func Travel(state):
	state_machine.travel(state)

func _process(delta):
	#print(str(Engine.get_frames_per_second()))

	timer += delta
	spring_arm.translation = translation

	if timer >= minTimeBetweenTicks:

		timer -= minTimeBetweenTicks
		
		#ProcessInput(minTimeBetweenTicks)
		HandleTick()
		currentTick += 1
	
func _physics_process(delta):

	if playing_game != true:
		return
	var normalized_delta = delta *60.0
	velocity.x = move_direction.x * (current_speed *normalized_delta)#delta no needed
	velocity.z = move_direction.z * (current_speed *normalized_delta) 
	velocity.y -= gravity * normalized_delta
	
	Travel(to_state)
	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	model.rotation.y = look_direction.angle()
	anim_tree.advance(delta)
	
	if is_jumping:
		velocity.y = jump_strenght *normalized_delta
		snap_vector = Vector3.ZERO
		is_jumping = false
		
	elif is_on_floor() and snap_vector == Vector3.ZERO: #just landed
		snap_vector = Vector3.DOWN
	
	elif !is_on_floor():
		to_state = "jump-up" if velocity.y > 0 else "jump-down"
	
	

	if velocity.length() > 0.2 && (velocity.x != 0 || velocity.z != 0):
		
		look_direction = Vector2(velocity.z, velocity.x).normalized()
		#last_look_direction = look_direction

		if is_on_floor():
			to_state = "walk" if !_is_running else "run"
			
	elif is_on_floor():
		to_state = "idle" #idle
	
	#var clientImput = {}
	#clientImput["T"] = currentTick
	#clientImput["D"] = move_direction
	#clientImput["R"] = look_direction
	#clientImput["S"] = State()
	#clientImput["J"] = is_jumping_server
	#is_jumping_server = false
	#clientImput["CS"] = current_speed
	
	#Server.send_client_input(clientImput) #<---------------
	

func HandleTick():
	
	var clientInput = {}
	clientInput["T"] = currentTick
	clientInput["D"] = move_direction
	clientInput["R"] = look_direction
	clientInput["S"] = State()
	clientInput["J"] = is_jumping_server
	is_jumping_server = false
	clientInput["CS"] = current_speed
	
	Server.send_client_input(clientInput) #<---------------
	pass

func _unhandled_input(event):
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("jump") && is_on_floor():
			is_jumping = true
			is_jumping_server = true
			
		if Input.is_action_just_pressed("run"):
			_is_running = !_is_running
			current_speed = speed if !_is_running else run_speed
			
		
	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	

func start_game():
	playing_game = true
	print("LETS GOO")
	$CanvasLayer/ScreenText.hide()
