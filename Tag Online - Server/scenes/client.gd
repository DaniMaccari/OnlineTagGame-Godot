extends Node

onready var rooms = get_parent().get_parent().get_node("rooms")
var client_info = {
	"name": null,
	"room_id": null,
	"hunter": false,
	"points": 0,
	"ready": false
}

func terminate():
	var room = rooms.get_node_or_null(str(client_info["room_id"]))
	if room != null:
		room.exit_client(self.name)
