extends Node

enum PLAYER_STATE {
	NONE, # JUST CONNECTED
	TIMER_SYNC, # SYNCING TIMER
	LOADING, # SYNCING WORLD STATE
	SIMULATING, # PLAYING THE GAME
	DISCONNECTED,
}

enum PLAYER_SCENES {
	NONE,
	WORLD,
	LOBBY,
}

enum DYNAMIC_OBJECTS {
	PLAYER
}
