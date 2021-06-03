extends Node

# remote func
export var Players_path: NodePath;
onready var players = get_node(Players_path) as Players;

remote func get_letanecy(client_time):
	var peer_id = get_tree().get_rpc_sender_id();
	rpc_id(peer_id, "recive_time", OS.get_system_time_msecs(), client_time);

remote func clock_synced(credentials: Dictionary):
	players.clock_sync_done(credentials);

func _physics_process(delta):
	print(OS.get_system_time_msecs());
