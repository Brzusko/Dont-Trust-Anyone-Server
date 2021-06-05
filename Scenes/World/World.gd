extends Node2D

# TODO Asset creation in multithread context

onready var player = $Players;
onready var player_scene = preload("res://Scenes/Sync/Dynamic/Player.tscn");

var created_players = {};

var world_objects: Dictionary = {
	"p": [],
};

func _ready():
	var _e = Players.connect("send_world_to_player", self, "serialize_world");
	var __e = Players.connect("create_player_in_world", self, "create_player");
	var ___e = Players.connect("destroy_player_in_world", self, "destroy_player");

# Events
func create_player(player_name):
	if created_players.has(player_name):
		return;
	var new_player = player_scene.instance();
	new_player.name = player_name;
	created_players[player_name] = true;
	world_objects.p.append(new_player.serialize());
	$Players.call_deferred("add_child", new_player);	

func destroy_player(player_name):
	pass;

func serialize_world(peer_id):
	print("Player wants world")
	var world_data = {
		"t": OS.get_system_time_msecs(),
		"p": world_objects.p.duplicate()
	}
	Networking.send_world_data(peer_id, world_data);
