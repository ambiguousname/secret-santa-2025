extends Node2D

@onready var tcp_client : TCPClient = $TCPClient;
@onready var ui : UI = $UI;
@onready var bug : Bug = $Bug;
@onready var camera : Camera2D = $Camera2D; 

func _ready() -> void:
	tcp_client.status_updated.connect(_tcp_update);
	tcp_client.connect_to_host();
	
	ui.adventure.pressed.connect(func():
		bug.jump();
		var window = get_window();
		ui.fade_ui(false, 1.0, func():
			var size = DisplayServer.screen_get_size(window.current_screen);
			window.size = Vector2i(size.x - 100, 250);
			window.position = Vector2i(50, size.y - 250);
			bug.extents = Rect2i(window.position, window.size);
			
			bug.position = Vector2(0, -250);
			camera.offset = Vector2.ZERO;
			bug.land(0.2, Vector2(0, -250), Vector2(0, 0), bug.begin_adventure);
			window.mouse_passthrough = true;
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
