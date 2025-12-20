class_name WeekTransition extends Control

@onready var winner : Label = $Winner;

@onready var from_week : Label = $FromWeek;
@onready var to_week : Label = $ToWeek;

@onready var onwards : Button = $Button;

func _ready() -> void:
	onwards.pressed.connect(func():
		AudioEvent.play("silly_button");
		bug.play(&"walk");
		bug.speed_scale = 2.0;
		var tween = create_tween();
		tween.tween_property(bug, "position", Vector2(to_week.position.x, bug.position.y), 0.5);
		tween.parallel();
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5);
		tween.tween_callback(func():
			self.visible = false;
		);
	);

func race_name(week : int) -> String:
	match week:
		0:
			return "Beginner's Grove";
		1:
			return "Cliffs of Despair";
		2:
			return "Zorp Abyss";
		_:
			return "Unknown";

@onready var bug : AnimatedSprite2D = $Bug;
func transition_week(bug_name : String, bug_color : Color, from : int, to : int):
	bug.speed_scale = 1.0;
	bug.play(&"idle");
	bug.material.set_shader_parameter("body_tint", bug_color);
	self.modulate = Color(1, 1, 1, 1);
	self.visible = true;
	winner.text = "%s won!" % bug_name;
	from_week.text = "Week %d\n\n%s" % [from, race_name(from)];
	to_week.text = "Week %d\n\n%s" % [to, race_name(to)];
	
