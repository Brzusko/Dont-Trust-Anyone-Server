extends Node
class_name Players

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

# Adding player to "players_to_Register", if player will not send msg with credentails
# he will be disconnected
func player_to_register(peer_id: int):
	mutex.lock();
	if players_to_register.size() > 40:
		mutex.unlock();
		return false;
	players_to_register[str(peer_id)] = true;
	mutex.unlock();
	return true;

#
func register_player(peer_id: int, player_name: String):
	if !players_to_register.has(str(peer_id)):
		return false;
		
	if active_players.has(player_name):
		var player = active_players[player_name] as PlayerScene;
		if player.player_state == Enums.PLAYER_STATE.NONE:
			player.register_player(peer_id);
			return true;
		else:
			return false;
			
	mutex.lock();
	players_to_register.erase(str(peer_id));
	mutex.unlock();
	
	var player = player_scene.instance();
	player.register_player(peer_id, player_name);
	active_players[player_name] = player;
	add_child(player);
	return true;

func clock_sync_done(credentials: Dictionary):
	var player = get_node(credentials.pn);
	if player == null: # TODO handle this error
		return;
	player.time_sync();
	
# Thread functionality

func timer_tick():
	semaphore.post();
	pass;

func start_thread():
	thread.start(self, "player_cleaner");
	timer = Timer.new();
	timer.wait_time = CLEAR_INTERVAL;
	timer.connect("timeout", self, "timer_tick");
	add_child(timer);
	timer.start();

func player_cleaner(user_data):
	while true:
		semaphore.wait();
		mutex.lock();
		clear_players();
		mutex.unlock();
		
		if can_finish:
			break;

func clear_players():
	for i in players_to_register:
		players_to_register.erase(i);
		print("Cleared Player with id: " + i);

func _exit_tree():
	can_finish = true;
	semaphore.post();
	thread.wait_to_finish();
	pass;
