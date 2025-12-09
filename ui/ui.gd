class_name UI extends Control

@onready var tcp_status : Label = $TCPStatus;

func update_tcp_status(text : String):
	tcp_status.text = text;

@onready var adventure : Button = $Buttons/Adventure;
func _ready() -> void:
	adventure.pressed.connect(func(): 
		set_ui_display(false);
	);

func set_ui_display(vis : bool):
	self.visible = vis;
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, !vis);
