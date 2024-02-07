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

onready var model : Spatial = get_node("./RobotArmature")
onready var anim_tree = get_node("AnimationTree")
onready var state_machine = anim_tree.get("parameters/playback")


#
#func _ready():
#	anim_tree.active = true
#	state_machine.start("idle")
#	pass

func State():
	return state_machine.get_current_node()

func Travel(state):
	state_machine.travel(state)

func _process(delta):
	#print(str(Engine.get_frames_per_second()))

	timer += delta

	if timer >= minTimeBetweenTicks:
		timer -= minTimeBetweenTicks
		HandleTick()
		currentTick += 1

func HandleTick():
	anim_tree.advance(minTimeBetweenTicks)
	
	
	
