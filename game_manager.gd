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
			2:
				return 7;
			_:
				return -1;

func _ready() -> void:
	save.adv_info.generate_item = generate_item;
	
	ui.setup_ended.connect(func(n : String):
		save.adv_info.select_nature();
		save.stats.name = n;
		save.write_save();
	);
	
	save.load_save();
	ui.set_energy(save.stats.energy);
	if race_day > 0 && save.adv_info.day != race_day && save.stats.energy == 0 && !save.adv_info.can_regain_energy():
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
		
		if race_day > 0 && save.adv_info.day != race_day && save.stats.energy == 0 && !save.adv_info.can_regain_energy():
			new_day(save.adv_info.day + 1);
		
		if save.stats.energy > 0:
			ui.adventure.disabled = false;
	);
	
	check_win();
	
	if save.stats.energy == 0:
		ui.adventure.disabled = true;
	
	save.adv_info.mark_dirty.connect(func():
		var end_adventure = false;
		var new_day_call = false;
		if save.stats.energy <= 0:
			save.stats.energy = 0;
			end_adventure = true;
			if !save.adv_info.can_regain_energy():
				new_day_call = true;
		if save.adv_info.day_progress_time <= 0:
			end_adventure = true;
			new_day_call = true;
		
		if new_day_call: 
			new_day(save.adv_info.day + 1);
			save.adv_info.day_progress_time = 100;
		
		if end_adventure:
			bug.end_adventure();
		save.write_save();
	);
	
	if !FileAccess.file_exists(save.SAVE_FILE) || save.stats.name == "":
		ui.setup_bug();
	else:
		ui.bug_name.text = save.stats.name;
	
	tcp_client.status_updated.connect(_tcp_update);
	tcp_client.should_connect = ui.settings_menu.install.connectable;
	if tcp_client.should_connect:
		tcp_client.connect_to_host();
	else:
		_tcp_update(TCPClient.Status.DISCONNECTED);
	ui.settings_menu.install.connectable_changed.connect(func(b : bool):
		tcp_client.should_connect = b; 
		if b:
			tcp_client.connect_to_host();
		else:
			tcp_client.disconnect_from_host();
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
			var pos = DisplayServer.screen_get_position(window.current_screen);
			window.size = Vector2i(size.x - 100, 250);
			_stats_window_pos = window.position;
			window.position = Vector2i(pos.x + 50, size.y - 250);
			
			bug.position = Vector2(0, -250);
			camera.offset = Vector2.ZERO;
			bug.energy = save.stats.energy;
			bug.land(0.2, Vector2(0, 250), Vector2(0, 0), 0.5, func():
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
		ui.set_day_progress(save.adv_info.day_progress_time);
		
		bug.jump(func():
			var window = get_window();
			window.mouse_passthrough_polygon = [];
			window.set_flag(Window.FLAG_BORDERLESS, false);
			window.size = Vector2i(500, 500);
			camera.offset = Vector2i(250, 250);
			window.position = _stats_window_pos;
			
			ui.fade_ui(true, 1.0, func():
				bug.land(0.1, Vector2(250, -250), Vector2(250, 250), 1.0, Callable());
				if save.stats.energy > 0:
					ui.adventure.disabled = false;
			);
			ui.set_energy(save.stats.energy);
			window.set_flag(Window.FLAG_ALWAYS_ON_TOP, false);
			# window.mouse_passthrough = false;
		);
	);
	
	ui.race.pressed.connect(start_race);
	
	ui.retire.connect(func():
		# TODO: Save retired bugs to file.
		ui.get_node("WinScreen").visible = false;
		reset_to_setup();
		ui.setup_bug();
	);
	
	save.stats.energy_updated.connect(func():
		bug.energy = save.stats.energy;
	);
	save.stats.energy_updated.emit();

func _tcp_update(status : TCPClient.Status):
	var text : String = "";
	var color : Color = Color.WHITE;
	match status:
		TCPClient.Status.UNACKNOWLEDGED:
			text = "[color=yellow]Waiting for server...\nLaunch Hollow Knight![/color]";
			color = Color.YELLOW;
		TCPClient.Status.AWAITING_ACKNOWLEDGEMENT:
			text = "[color=green]Making handshake...[/color]";
			color = Color.GREEN;
		TCPClient.Status.CONNECTED:
			text = "[color=green]Connected![/color]";
			color = Color.GREEN;
			if !ui.adventure.disabled && !bug._adventuring:
				ui.adventure.pressed.emit();
		TCPClient.Status.DISCONNECTED:
			if bug._adventuring && tcp_client.has_connection:
				bug.end_adventure();
			text = "Disconnected.";
			if tcp_client.timer.time_left > 0:
				text += "\nRetrying in %d seconds..." % int(tcp_client.timer.time_left);
		_:
			color = Color.RED;
			text = "[color=red]Undefined state.[/color]";
	ui.update_tcp_status(text, color);

func new_day(day_progress : int):
	save.adv_info.day = day_progress;
	save.adv_info.day_progress_time = 100;
	save.stats.energy += 20;
	save.write_save();
	
	set_day(day_progress, true);
	
	ui.set_energy(save.stats.energy);

func set_day(day_progress : int, advance: bool = false):
	if race_day > 0 && day_progress >= race_day:
		ui.start_race_day();
		return;
	ui.set_day(race_day - day_progress, save.adv_info.day_progress_time, advance);

func start_race():
	var race_scene : PackedScene = null;
	match save.adv_info.week:
		0:
			race_scene = preload("uid://cwb4fbjlm6jac");
		1:
			race_scene = preload("uid://cfadllsrcwd4j");
		2:
			race_scene = preload("uid://cm07uogntc5rs");
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
		var pos = DisplayServer.screen_get_position(window.current_screen);
		
		var tween = create_tween();
		tween.tween_property(window, "position", Vector2i(size.x/4 + pos.x, window.position.y), 0.5);
		#tween.parallel();
		tween.tween_property(window, "size", Vector2i(size.x/2, 500), 0.5);
	);
	

func finish_race(winner : bool):
	ui.end_race_day(winner);
	var bug_name = String(save.stats.name);
	if winner:
		ui.set_week(bug_name, save.adv_info.week, save.adv_info.week + 1);
		save.adv_info.week += 1;
		save.adv_info.day = 0;
		# Day is advanced by end_race_day above.
		set_day(save.adv_info.day, false);
		
		check_win();
	else:
		reset_to_setup();
	
	var window = get_window();
	
	var tween = create_tween();
	tween.tween_property(window, "size", Vector2i(500, 500), 0.5);
	tween.tween_property(window, "position", _stats_window_pos, 0.5);
	#tween.parallel();
	tween.tween_callback(func():
		camera.enabled = true;
		ui.fade_ui(true, 1.0, func():
			if !winner:
				bug.animation.play(&"die");
				bug.animation.animation_finished.connect(func(_a : String):
					bug.visible = false;
					bug.animation.play(&"RESET");
					bug.position = Vector2(250, -250);
					bug.animation.animation_finished.connect(func(_b : String):
						bug.position = Vector2(250, -250);
						bug.visible = true;
						bug.land(0.5, Vector2(250, -250), Vector2(250, 250), 1.0, ui.setup_bug_dead.bind(bug_name));
					, CONNECT_ONE_SHOT);
				, CONNECT_ONE_SHOT);
			else:
				bug.visible = true;
				bug.land(0.0, Vector2(250, -250), Vector2(250, 250), 1.0, Callable());
		);
	);
	
	save.write_save();

func check_win():
	# TODO: Expand.
	if save.adv_info.week >= 3:
		ui.win(save.stats.name);

func generate_item() -> Item:
	var i = self.items[randi() % self.items.size()];
	ui.items.add_item(i, true);
	return i;

func reset_to_setup():
	save.clear();
	
	ui.set_energy(100);
	ui.set_day(race_day - 0, 100, false);
	ui.set_stats(save.stats);
	ui.items.clear();
