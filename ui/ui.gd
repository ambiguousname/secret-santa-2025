class_name UI extends Control

@onready var tcp_status : Label = $TCPStatus;

func update_tcp_status(text : String):
	tcp_status.text = text;

@onready var adventure : Button = %Adventure;
@onready var race : Button = %Race;
@onready var submit_name : Button = %Submit;

@onready var full_info : Control = $FullInfo;

@onready var bug_name : LineEdit = $"Bug Name";

signal setup_ended(b_name : String);

func setup_bug():
	const NAMES : Array[String] = ["Mozzarella", "Quibble", "Cloof", "Blast", "Cloak", "Palt",
	"Grub", "Emboss", "Phobos", "Bud", "Trinity", "Gouda", "Margherita", "Wensleydale", "Young", "Old"];
	const SURNAMES : Array[String] = ["Sera", "Squeem", "Chew", "Gready", "Yon",
	"Undefeated", "Pizza", "Fizzle", "Chosen", "Untold", "Buggy", "Goat", "Blue", "Grognard"];
	if randi() % 100 >= 80:
		bug_name.text = NAMES[randi() % NAMES.size()];
	else:
		bug_name.text = "%s %s" % [NAMES[randi() % NAMES.size()], SURNAMES[randi() % SURNAMES.size()]];
	bug_name.editable = true;
	
	full_info.visible = false;
	submit_name.visible = true;
	bug_name.text_submitted.connect(end_setup, CONNECT_ONE_SHOT);
	submit_name.pressed.connect(func():
		end_setup(bug_name.text);
	);
	adventure.visible = false;

func end_setup(n : String):
	bug_name.editable = false;
	
	bug_name.text_submitted.disconnect(end_setup);
	full_info.visible = true;
	adventure.visible = true;
	submit_name.visible = false;
	
	var tween = create_tween();
	tween.tween_property(adventure, "modulate", Color(1, 1, 1, 1), 0.5).from(Color(1, 1, 1, 0));
	tween.parallel();
	tween.tween_property(full_info, "modulate", Color(1, 1, 1, 1), 0.5).from(Color(1, 1, 1, 0));
	setup_ended.emit(n);

func fade_ui(vis : bool, duration : float, callback: Callable):
	var tween = create_tween();
	var from = 1.0;
	var to = 0.0;
	
	if vis:
		from = 0.0;
		to = 1.0;
		self.visible = vis;
	
	tween.tween_property(self, "modulate", Color(1, 1, 1, to), duration).from(Color(1, 1, 1, from));
	tween.finished.connect(func():
		self.visible = vis;
		if !callback.is_null():
			callback.call();
	);

@onready var day_label : Label = $FullInfo/Day/Label;
func advance_day(day : int):
	set_day(day);

func set_day(day : int):
	day_label.text = "RACE IN\n%d DAYS" % day;

@onready var energy : ProgressBar = %Energy;
func set_energy(e : float):
	energy.value = e;
