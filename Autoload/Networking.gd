extends Node


signal player_connected(peer_id)
signal player_disconnected(peer_id)

### base setup
var network: NetworkedMultiplayerENet;

func _ready() -> void:
	setup();

func setup() -> void:
	network = NetworkedMultiplayerENet.new();
	var _err = network.create_server(Globals.BASE_PORT, Globals.MAX_PLAYERS);
	
	if _err != OK:
		print("Could not create server");
	
	get_tree().network_peer = network;
	
	var __ = network.connect("peer_connected", self, "on_client_connect");
	var ___ = network.connect("peer_disconnected", self, "on_client_disconnected");

func destroy() -> void:
	network = null;
	get_tree().network_peer = null;
	
	network.disconnect("peer_connected", self, "on_client_connect");
	network.disconnect("peer_disconnected", self, "on_client_disconnected");
	
# Events

func on_client_connect(peer_id: int):
	emit_signal("player_connected", peer_id);

func on_client_disconnected(peer_id: int):
	emit_signal("player_disconnected", peer_id);

# utility

func disconnect_player(peer_id: int): 
	network.disconnect_peer(peer_id);

# server -> client funcs

func switch_player_scene(peer_id: int, scene_id: int):
	rpc_id(peer_id, "switch_scene", scene_id);

func player_registred(peer_id: int):
	rpc_id(peer_id, "on_player_register");

func time_sync_done(peer_id: int):
	rpc_id(peer_id, "on_time_sync");

func send_world_data(peer_id: int, world_data: Dictionary):
	rpc_id(peer_id, "on_world_fetch", world_data);
# remote

remote func register_player(credentials: Dictionary):
	var peer_id = get_tree().get_rpc_sender_id();
	if !$Auth.are_credentials_valid(credentials):
		disconnect_player(peer_id);
		return;
		
	Players.register_player(peer_id, credentials);

remote func player_done_loading(credentials: Dictionary):
	Players.player_done_loading(credentials);
	pass;
