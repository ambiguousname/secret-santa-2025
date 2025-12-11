class_name UI extends Control

@onready var tcp_status : Label = $TCPStatus;

func update_tcp_status(text : String):
	tcp_status.text = text;

@onready var adventure : Button = $Buttons/Adventure;
@onready var race : Button = $Buttons/Race;

func fade_ui(vis : bool, duration : float, callback: Callable):
	var tween = create_tween();
	var from = 1.0;
	var to = 0.0;
	
	if vis:
		from = 0.0;
		to = 1.0;
	
	tween.tween_property(self, "modulate", Color(1, 1, 1, to), duration).from(Color(1, 1, 1, from));
	tween.finished.connect(func():
		self.visible = vis;
		callback.call();
	);
