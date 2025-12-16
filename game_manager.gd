extends Node2D

@export var items : Array[Item] = [];

@onready var tcp_client : TCPClient = $TCPClient;
@onready var ui : UI = $UI;
@onready var bug : Bug = $Bug;
@onready var camera : Camera2D = $Camera2D; 

var _stats_window_pos : Vector2i = Vector2i.ZERO;
var save : Save = Save.new();

var race_day : int:
	get():
		match save.adv_info.week:
			0:
				return 1;
			1:
				return 3;
			_:
				printerr("Invalid week.");
				return 0;

func _ready() -> void:
	save.adv_info.generate_item = generate_item;
	
	ui.setup_ended.connect(func(n : String):
		save.stats.name = n;
		save.write_save();
	);
	
	save.load_save();
	ui.set_energy(save.stats.energy);
	if save.adv_info.day != race_day && save.stats.energy == 0 && !save.adv_info.can_regain_energy():
		new_day(save.adv_info.day + 1);
	else:
		set_day(save.adv_info.day);
	ui.set_stats(save.stats);
	
	for i in save.adv_info.items:
		ui.items.add_item(i);
	ui.items.use_item.connect(func(i : Item, c : int):
		match c:
			0:
				save.stats.increase_stat(i.stat_one, i.stat_increase);
				ui.set_stats(save.stats);
			1:
				save.stats.increase_stat(i.stat_two, i.stat_increase);
				ui.set_stats(save.stats);
			2:
				save.stats.energy = min(save.stats.energy + i.energy_increase, 100);
				ui.set_energy(save.stats.energy);
		save.adv_info.items.remove_at(save.adv_info.items.find(i));
		save.write_save();
	);
	
	check_win();
	
	save.adv_info.mark_dirty.connect(func():
		var end_adventure = false;
		if save.stats.energy <= 0:
			save.stats.energy = 0;
			end_adventure = true;
		if save.adv_info.day_progress_time <= 0:
			end_adventure = true;
			new_day(save.adv_info.day + 1);
			# Reset progress for the next time:
			save.adv_info.day_progress_time = 100;
		
		if save.stats.energy == 0 && !save.adv_info.can_regain_energy():
			new_day(save.adv_info.day + 1);
			save.adv_info.day_progress_time = 100;
		
		if end_adventure:
			bug.end_adventure();
		save.write_save();
	);
	
	if !FileAccess.file_exists(save.SAVE_FILE):
		ui.setup_bug();
	else:
		ui.bug_name.text = save.stats.name;
	
	tcp_client.status_updated.connect(_tcp_update);
	tcp_client.should_connect = ui.settings_menu.install.connectable;
	if tcp_client.should_connect:
		tcp_client.connect_to_host();
	ui.settings_menu.install.connectable_changed.connect(func(b : bool):
		tcp_client.should_connect = b; 
		if b:
			tcp_client.connect_to_host();
	);
	tcp_client.game_state_update.connect(func(d : Dictionary): 
		if !("events" in d) || !bug._adventuring:
			return;
		for event in d["events"]:
			if "name" in event:
				match event["name"]:
					"heroState":
						if event["value"] == "running":
							save.stats.running.increase(event["duration"]);
							save.write_save();
					"wallSlide", "wallTouch":
						save.stats.climbing.increase(event["duration"]);
						save.write_save();
					"jump":
						save.stats.jumping.increase(event["duration"]);
						save.write_save();
					"bounce", "attack":
						save.stats.skateboarding.increase(event["duration"]);
						save.write_save();
					"damage":
						if randi() % 100 > 10 * d["hp"]:
							generate_item();
					"death":
						if randi() % 100 > 50:
							generate_item();
	);
	
	ui.adventure.pressed.connect(func():
		ui.adventure.disabled = true;
		bug.jump();
		var window = get_window();
		ui.fade_ui(false, 1.0, func():
			var size = DisplayServer.screen_get_size(window.current_screen);
			window.size = Vector2i(size.x - 100, 250);
			_stats_window_pos = window.position;
			window.position = Vector2i(50, size.y - 250);
			
			bug.position = Vector2(0, -250);
			camera.offset = Vector2.ZERO;
			bug.land(0.2, Vector2(0, 250), Vector2(0, 0), func():
				bug.begin_adventure(Rect2i(window.position, window.size), save.adv_info);
			);
			# window.mouse_passthrough = true;
		);
		
		window.set_flag(Window.FLAG_ALWAYS_ON_TOP, true);
		window.set_flag(Window.FLAG_BORDERLESS, true);
	);
	bug.adventure_ended.connect(func():
		# Write any outstanding data:
		save.write_save();
		
		ui.set_stats(save.stats);
		
		bug.jump(func():
			var window = get_window();
			window.mouse_passthrough_polygon = [];
			window.size = Vector2i(500, 500);
			# Stupid hack:
			camera.offset = Vector2i(250, 230);
			window.position = _stats_window_pos;
			
			ui.fade_ui(true, 1.0, func():
				bug.land(0.1, Vector2(250, -250), Vector2(250, 250), Callable());
				if save.stats.energy > 0:
					ui.adventure.disabled = false;
			);
			ui.set_energy(save.stats.energy);
			window.set_flag(Window.FLAG_ALWAYS_ON_TOP, false);
			window.set_flag(Window.FLAG_BORDERLESS, false);
			# window.mouse_passthrough = false;
		);
	);
	
	ui.race.pressed.connect(start_race);

func _tcp_update(status : TCPClient.Status):
	var text : String = "";
	match status:
		TCPClient.Status.UNACKNOWLEDGED:
			text = "Waiting for server...";
		TCPClient.Status.AWAITING_ACKNOWLEDGEMENT:
			text = "Making handshake...";
		TCPClient.Status.CONNECTED:
			text = "Connected!";
			if !ui.adventure.disabled && !bug._adventuring:
				ui.adventure.pressed.emit();
		TCPClient.Status.DISCONNECTED:
			if bug._adventuring && tcp_client.has_connection:
				bug.end_adventure();
			text = "Disconnected.";
		_:
			text = "Undefined state.";
	ui.update_tcp_status(text);

func new_day(day_progress : int):
	save.adv_info.day = day_progress;
	save.write_save();
	
	set_day(day_progress, true);
	
	if day_progress >= race_day:
		return;
	save.stats.energy += 20;
	ui.set_energy(save.stats.energy);

func set_day(day_progress : int, advance: bool = false):
	if day_progress >= race_day:
		ui.start_race_day();
		return;
	ui.set_day(race_day - day_progress, advance);

func start_race():
	var race_scene : PackedScene = null;
	match save.adv_info.week:
		0:
			race_scene = preload("uid://cwb4fbjlm6jac");
	if race_scene == null:
		printerr("Could not get race for week %d" % save.adv_info.week);
		return;
	
	bug.jump(func():
		bug.visible = false;
		ui.fade_ui(false, 1.2, func(): 
			ui.visible = false;
			camera.enabled = false;
			var race : Course = race_scene.instantiate();
			race.race_end.connect(func(won : bool):
				# TODO: Show win, set ui to hide "Start Race" button.
				var end_t = race.create_tween();
				end_t.tween_property(race, "modulate", Color(1, 1, 1, 0), 0.5);
				end_t.tween_callback(func():
					race.queue_free();
					finish_race(won);
				);
			);
			
			race.modulate = Color(0, 0, 0, 0);
			var t = race.create_tween();
			t.tween_property(race, "modulate", Color(1, 1, 1, 1), 0.5).from(Color(1, 1, 1, 0));
			t.tween_callback(func():
				race.start_race(save.stats);
			);
			add_child(race);
		);
		var window = get_window();
		_stats_window_pos = window.position;
		
		var size = DisplayServer.screen_get_size(window.current_screen);
		var tween = create_tween();
		tween.tween_property(window, "position", Vector2i(size.x/4, window.position.y), 0.5);
		#tween.parallel();
		tween.tween_property(window, "size", Vector2i(size.x/2, 500), 0.5);
	);
	

func finish_race(winner : bool):
	ui.end_race_day(winner);
	
	save.adv_info.week += 1;
	save.adv_info.day = 0;
	# Day is advanced by end_race_day above.
	ui.set_day(save.adv_info.day, false);
	
	check_win();
	
	var window = get_window();
	
	var tween = create_tween();
	tween.tween_property(window, "size", Vector2i(500, 500), 0.5);
	tween.tween_property(window, "position", _stats_window_pos, 0.5);
	#tween.parallel();
	tween.tween_callback(func():
		camera.enabled = true;
		ui.fade_ui(true, 1.0, func():
			bug.visible = true;
			bug.land(0.0, Vector2(250, -250), Vector2(250, 250), Callable());
		);
	);
	
	save.write_save();

func check_win():
	# TODO: Expand.
	if save.adv_info.week == 2:
		ui.win();

func generate_item() -> Item:
	return self.items[randi() % self.items.size()];
