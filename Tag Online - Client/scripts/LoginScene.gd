extends Control

signal scene_change

func _on_create_pressed():
	Server.create_room()
	#emit_signal("scene_change", "rooms_scene")


func enter_room():
	emit_signal("scene_change", "rooms_scene")
	
func _on_join_pressed():
	emit_signal("scene_change", "lobby_scene")
