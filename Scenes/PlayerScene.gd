extends Node
class_name PlayerScene

var player_state: int = Enums.PLAYER_STATE.NONE;
var peer_id: int = 0;

func register_player(_peer_id: int, player_name: String):
	player_state = Enums.PLAYER_STATE.TIMER_SYNC;
	peer_id = _peer_id;
	name = player_name;

func reconnect(_peer_id: int):
	peer_id = _peer_id;
	player_state = Enums.PLAYER_STATE.TIMER_SYNC;

func disconnect_player():
	player_state = Enums.PLAYER_STATE.NONE;
	peer_id = -1;

func time_sync_done():
	player_state = Enums.PLAYER_STATE.LOADING;

func player_loaded():
	player_state = Enums.PLAYER_STATE.SIMULATING;

func can_be_sync():
	return player_state == Enums.PLAYER_STATE.SIMULATING;
