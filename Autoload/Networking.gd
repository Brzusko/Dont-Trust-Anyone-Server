extends Node

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
	if $Players.player_to_register(peer_id):
		print("Player waiting for register: " + str(peer_id));
	else:
		network.disconnect_peer(peer_id, false);

func on_client_disconnected(peer_id: int):
	print("Player disconnected: " + str(peer_id));

# utility
func disconnect_player(peer_id: int): 
	network.disconnect_peer(peer_id);
	
# remote methods

# ATM 
#
# var credentials: {
#	"pn": "Zdzisiek"
# }

remote func register_player(credentials: Dictionary):
	var peer_id = get_tree().get_rpc_sender_id();
	if !$Players.register_player(peer_id, credentials.pn):
		network.disconnect_peer(peer_id);
		return;
	rpc_id(peer_id, "on_player_register");

