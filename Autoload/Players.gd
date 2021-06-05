extends Node

signal send_world_to_player(peer_id);
signal create_player_in_world(player_name);
signal destroy_player_in_world(player_name);

const CLEAR_INTERVAL = 15;
var timer: Timer;
var players_to_register: Dictionary = {};
var active_players: Dictionary = {};
var can_finish: bool = false;
onready var thread: Thread = Thread.new();
onready var mutex: Mutex = Mutex.new();
onready var semaphore: Semaphore = Semaphore.new();
onready var player_scene = preload("res://Scenes/PlayerScene.tscn");

func _ready():
	start_thread();
	var _e = Networking.connect("player_connected", self, "on_player_connect");
	var __e = Networking.connect("player_disconnected", self, "on_player_disconnect");

# Adding player to "players_to_Register", if player will not send msg with credentails
# he will be disconnected
func player_to_register(peer_id: int):
	mutex.lock();
	
	if players_to_register.size() > 40:
		mutex.unlock();
		
		Networking.disconnect_player(peer_id);
		return;
		
	players_to_register[str(peer_id)] = true;
	mutex.unlock();
	print("Waiting for credentials: ", peer_id);

#
func register_player(peer_id: int, credentials: Dictionary):
	if !players_to_register.has(str(peer_id)):
		Networking.disconnect_player(peer_id);
		return;
		
	if active_players.has(credentials.pn):
		var player = active_players[credentials.pn] as PlayerScene;
		if player.player_state == Enums.PLAYER_STATE.NONE:
			player.reconnect(peer_id);
			return;
		else:
			Networking.disconnect_player(peer_id);
			return;
			
	var _err = mutex.lock();
	players_to_register.erase(str(peer_id));
	var __err = mutex.unlock();
	
	var player = player_scene.instance();
	player.register_player(peer_id, credentials.pn);
	active_players[credentials.pn] = player;
	add_child(player);
	
	emit_signal("create_player_in_world", player.name);
	Networking.player_registred(player.peer_id);

func disconnect_player(peer_id: int):
	if players_to_register.has(str(peer_id)):
		return;
		
	var player = find_player_by_id(peer_id);
	if player != null:
		player.disconnect_player();
	
func clock_sync_done(credentials: Dictionary):
	var player = get_node(credentials.pn) as PlayerScene;
	
	if player == null || player.player_state == Enums.PLAYER_STATE.LOADING: # TODO handle this error
		return;
		
	player.time_sync_done();
	emit_signal("send_world_to_player", player.peer_id);
	
	Networking.time_sync_done(player.peer_id);
	
# Utils

func find_player_by_id(peer_id: int):
	for player in active_players.values():
		if player.peer_id == peer_id:
			return player;
	return null;

# events
func on_player_connect(peer_id: int):
	player_to_register(peer_id);

func on_player_disconnect(peer_id: int):
	disconnect_player(peer_id);

# Thread functionality

func timer_tick():
	var _err = semaphore.post();
	pass;

func start_thread():
	var _err = thread.start(self, "player_cleaner");
	timer = Timer.new();
	timer.wait_time = CLEAR_INTERVAL;
	var _e = timer.connect("timeout", self, "timer_tick");
	add_child(timer);
	timer.start();

func player_cleaner(user_data):
	while true:
		var _err = semaphore.wait();
		mutex.lock();
		clear_players();
		mutex.unlock();
		
		if can_finish:
			break;

func clear_players():
	for i in players_to_register:
		Networking.disconnect_player(int(i));
		players_to_register.erase(i);
		print("Cleared Player with id: " + i);

func _exit_tree():
	can_finish = true;
	semaphore.post();
	thread.wait_to_finish();
	pass;
