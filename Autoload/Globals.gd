extends Node

const MAX_PLAYERS = 32;
const BASE_PORT = 9090;

var sync_static_obj = 0;
var sync_dynamic_obj = 0;

func spawn_static():
	sync_static_obj += 1;
	return sync_dynamic_obj;

func spawn_dynamic():
	sync_dynamic_obj += 1;
	return;
