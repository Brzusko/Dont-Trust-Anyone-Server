extends YSort

export(PackedScene) var player_scene;

var entities = {};

func create_player(player_name):
	if entities.has(player_name):
		return;
	var new_player = player_scene.instance();
	new_player.setup(player_name);
	entities[player_name] = new_player;
	add_child(new_player);

func process_input(delta):
	for player in get_children():
		player.process_input(delta);

func serialize_entities():
	var entities_array = {};
	for ent in entities:
		entities_array[ent] = entities[ent].serialize();
	return entities_array;
