extends Node

var loader
var time_max = 100
var wait_frame = 0

var current_scene
func _ready():
	current_scene = load("res://scenes/LoginScene.tscn").instance()
	add_child(current_scene)
	current_scene.connect("scene_change", self, "handle_scene_change")

func handle_scene_change(scene_name):

	match scene_name:
		"login_scene":
			loader = ResourceLoader.load_interactive("res://scenes/LoginScene.tscn")
			
		"rooms_scene":
			loader = ResourceLoader.load_interactive("res://scenes/RoomsScene.tscn")
			
		"lobby_scene":
			loader = ResourceLoader.load_interactive("res://scenes/LobbyScene.tscn")
			
		"game_scene": #change to new game Scene later
			loader = ResourceLoader.load_interactive("res://scenes/GameScene.tscn")
			
	if loader == null:
		print("scene not found")
		return
	
	$progressBar.value = 0
	$progressBar.visible = true
	set_process(true)
	wait_frame = 1

	current_scene.queue_free()


func _process(_delta):
	if loader == null:
		set_process(false)
		return

	if wait_frame > 0:
		wait_frame -= 1
		return

	var t = OS.get_ticks_msec()

	while OS.get_ticks_msec() < t + time_max: #if toomuch time pass break
		var error = loader.poll()

		if error == ERR_FILE_EOF:
			var next_scene = loader.get_resource()
			loader = null
			set_new_scene(next_scene)
			break

		elif error == OK:
			update_progress()
		
		else:
			print(error)
			loader = null
			break

func set_new_scene(next_scene):
	$progressBar.visible = false
	current_scene = next_scene.instance()
	current_scene.connect("scene_change", self, "handle_scene_change")
	add_child(current_scene)

func update_progress():
	var progress = ( float(loader.get_stage()) / loader.get_stage_count()) * 100
	$progressBar.value = progress
