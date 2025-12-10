extends Node2D

@onready var tcp_client : TCPClient = $TCPClient;
@onready var ui : UI = $UI;
@onready var bug = $Bug;

func _ready() -> void:
	tcp_client.status_updated.connect(_tcp_update);
	tcp_client.connect_to_host();
	
	ui.adventure.pressed.connect(func():
		ui.fade_ui(false, 1.0);
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true);
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true);
		
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
