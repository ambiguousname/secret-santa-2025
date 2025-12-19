class_name WeekTransition extends Control

@onready var winner : Label = $Winner;

@onready var from_week : Label = $FromWeek;
@onready var to_week : Label = $ToWeek;

@onready var onwards : Button = $Button;

func _ready() -> void:
	onwards.pressed.connect(func():
		self.visible = false;
	);

func race_name(week : int) -> String:
	match week:
		0:
			return "Beginner's Grove";
		1:
			return "Sobbing Speedway";
		2:
			return "Zorp Abyss";
		_:
			return "Unknown";

func transition_week(bug_name : String, from : int, to : int):
	self.visible = true;
	winner.text = "%s won!" % bug_name;
	from_week.text = "Week %d\n\n%s" % [from, race_name(from)];
	to_week.text = "Week %d\n\n%s" % [to, race_name(to)];
	
