extends Node2D

# TODO Asset creation in multithread context

onready var player = $Players;
onready var player_scene = preload("res://Scenes/Sync/Dynamic/Player.tscn");

var current_frame_world_state = {};

func _ready():
	var _e = Players.connect("send_world_to_player", self, "serialize_world");
	var __e = Players.connect("create_player_in_world", self, "create_player");
	var ___e = Players.connect("destroy_player_in_world", self, "destroy_player");

# Events
func create_player(player_name):
	$Players.create_player(player_name);

func destroy_player(player_name):
	$Players.clear_input(player_name);
	pass;

func serialize_world(peer_id, player_name):
	Networking.send_world_data(peer_id, current_frame_world_state.duplicate(true));

remote func verify_world(player_world_data: Dictionary):
	var peer_id = get_tree().get_rpc_sender_id();
	var player_world_entities_count = 0;
	var current_world_enitties_count = 0;

	for world_entities in current_frame_world_state.keys():
		if world_entities == "t":
			continue;
		current_world_enitties_count += current_frame_world_state[world_entities].size();

	for player_entities in player_world_data.values():
		player_world_entities_count += player_entities.size();
	
	var result = player_world_entities_count == current_world_enitties_count;
	var world_data = {};
	if !result:
		world_data = current_frame_world_state.duplicate(true);
		
	rpc_id(peer_id, "verify_result", result, world_data);

#remote func test():
#	var peer_id = get_tree().get_rpc_sender_id();
#	create_player("test");
#	rpc_id(peer_id, "verify_result", false, current_frame_world_state.duplicate(true));

func _physics_process(delta):
	$Players.process_input(delta);
	
	var world_state = {
		"t": OS.get_system_time_msecs(),
		"p": $Players.serialize_entities()
	}
	current_frame_world_state = world_state;
	
	for player in Players.active_players.values():
		if !player.can_be_sync():
			continue;
		rpc_unreliable_id(player.peer_id, "recive_world_state", current_frame_world_state);


