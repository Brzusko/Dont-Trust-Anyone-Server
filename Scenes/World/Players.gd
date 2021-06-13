extends YSort

export(PackedScene) var player_scene;

var entities = {};

func create_player(player_name: String):
	if entities.has(player_name):
		return;
	var new_player = player_scene.instance();
	new_player.setup(player_name);
	entities[player_name] = new_player;
	add_child(new_player);

func clear_input(player_name: String):
	if !entities.has(player_name):
		return;
	var player_obj = entities[player_name];
	player_obj.clear_input();

func process_input(delta):
	for player in get_children():
		player.process_input(delta);

func serialize_entities():
	var entities_array = {};
	for ent in entities:
		entities_array[ent] = entities[ent].serialize();
	return entities_array;
