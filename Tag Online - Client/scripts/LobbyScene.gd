extends Control

signal scene_change
var selected_room = ""

func _ready():
	$ItemList.clear()
	$ItemList.add_item("Room ID", null, false)
	$ItemList.add_item("Players", null, false)
	
func _on_match_pressed():
	var selected = $ItemList.get_selected_items()
	
	if (selected.size() == 1):
		var room_index = selected[0]
		var room_id = $ItemList.get_item_text(room_index)
		Server.request_enter(room_id)
		
	else:
		print("nothing selected")
	#emit_signal("scene_change", "rooms_scene")

func enter_room():
	emit_signal("scene_change", "rooms_scene")


func _on_exit_pressed():
	emit_signal("scene_change", "login_scene")


func _on_Timer_timeout():
	Server.update_rooms()


func updated_rooms(rooms_list):
	$ItemList.clear()
	$ItemList.add_item("Room ID", null, false)
	$ItemList.add_item("Players", null, false)
	for room in rooms_list.keys():
		
		if (rooms_list[room]["game_started"] == false):
			$ItemList.add_item(room)
			
			if (room == selected_room):
				$ItemList.select($ItemList.get_item_count() - 1)
			$ItemList.add_item(str(rooms_list[room]["num_players"]) +"/9", null, false)
		else:
			$ItemList.add_item(room + " STARTED", null, false) #not clicable
			$ItemList.add_item(str(rooms_list[room]["num_players"]) +"/9", null, false)



func _on_ItemList_item_selected(index):
	selected_room = $ItemList.get_item_text(index)






