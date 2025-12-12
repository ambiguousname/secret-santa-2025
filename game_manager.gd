extends Node2D

@onready var tcp_client : TCPClient = $TCPClient;
@onready var ui : UI = $UI;
@onready var bug : Bug = $Bug;
@onready var camera : Camera2D = $Camera2D; 

var _stats_window_pos : Vector2i = Vector2i.ZERO;
var save : Save = Save.new();

func _ready() -> void:
	ui.setup_ended.connect(func(n : String):
		save.stats.name = n;
		save.write_save();
	);
	
	save.load_save();
	ui.set_energy(save.stats.energy);
	ui.set_day(7 - save.adv_info.day);
	
	save.adv_info.mark_dirty.connect(func():
		var end_adventure = false;
		if save.stats.energy <= 0:
			save.stats.energy = 0;
			end_adventure = true;
		if save.adv_info.day_progress_time <= 0:
			save.adv_info.day += 1;
			end_adventure = true;
			ui.advance_day(7 - save.adv_info.day);
			# Reset progress for the next time:
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
	tcp_client.connect_to_host();
	
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
		
		# TODO: Flashy effect to hide the bug, set the window to the width of the bottom of the screen,
		# Then flashy effect for the bug to re-appear.
		#var size :  Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen());
		#var tween = create_tween();
		#tween.tween_method(DisplayServer.window_set_position, DisplayServer.window_get_position(), Vector2i(0, size.y - 500), 1.0);
		#tween.tween_method(DisplayServer.window_set_size, Vector2i(500, 500), Vector2i(size.x - 100, 250), 1.0);
		#tween.parallel();
		#tween.tween_method(DisplayServer.window_set_position, Vector2i(0, size.y - 500), Vector2i(50, size.y - 250), 1.0);
		#tween.finished.connect(bug.begin_adventure);
	);
	bug.adventure_ended.connect(func():
		# Write any outstanding data:
		save.write_save();
		
		bug.jump(func():
			var window = get_window();
			window.size = Vector2i(500, 500);
			camera.offset = Vector2i(250, 250);
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

func _tcp_update(status : TCPClient.Status):
	var text : String = "";
	match status:
		TCPClient.Status.UNACKNOWLEDGED:
			text = "Waiting for server...";
		TCPClient.Status.AWAITING_ACKNOWLEDGEMENT:
			text = "Making handshake...";
		TCPClient.Status.CONNECTED:
			text = "Connected!";
		TCPClient.Status.DISCONNECTED:
			text = "Disconnected.";
		_:
			text = "Undefined state.";
	ui.update_tcp_status(text);
