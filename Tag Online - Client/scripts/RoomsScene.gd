extends Control

signal scene_change

var clients_list = {}


func _ready():
	Server.add_client()
	$Label.text = "ROOM ID " + str(Server.r_id)
	
	$ItemList.clear()
	$ItemList.add_item("Player ID", null, false)
	$ItemList.add_item("Puntuation", null, false)

func _on_match_pressed():
	Server.send_start_signal()
	#emit_signal("scene_change", "game_scene")

func load_stage():
	emit_signal("scene_change", "game_scene")

func _on_exit_pressed():
	Server.exit_room()
	emit_signal("scene_change", "login_scene")

func update_clients(c_list):
	$ItemList.clear()
	clients_list = c_list
	
	$ItemList.add_item("Player ID", null, false)
	$ItemList.add_item("Puntuation", null, false)
	for c in clients_list.keys():
		#$ItemList.add_item(str(c), null, false)
		
		if( c == str(get_tree().get_network_unique_id())):
			$ItemList.add_item(str(c) + " (í ¾í´™YOU)", null, false)
			
			if ($ItemList.get_item_count()-1 == 2): #only host can start game
				$match.disabled = false
			$ItemList.add_item(str(clients_list[c]["points"]) + "pts", null, false)
		else:
			$ItemList.add_item(str(c), null, false)
			$ItemList.add_item(str(clients_list[c]["points"]) + "pts", null, false)
	
func _on_Timer_timeout():
	Server.update_clients()

