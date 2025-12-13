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
func set_day(day : int, advance: bool):
	day_label.text = "RACE IN\n%d DAYS" % day;

func start_race_day():
	day_label.text = "RACE TODAY";
	adventure.visible = false;
	race.visible = true;

@onready var energy : ProgressBar = %Energy;
func set_energy(e : float):
	energy.value = e;

func win():
	adventure.visible = false;
	race.visible = false;
	# TODO: Expand, retirement?

@onready var running : Radial = %Running/Stat;
@onready var skateboarding : Radial = %Skateboarding/Stat;
@onready var climbing : Radial = %Climbing/Stat;
@onready var jumping : Radial = %Jumping/Stat;
func set_stats(s : Stats):
	running.amount = s.running.xp/s.running.to_level_up;
	running.get_node("Label").text = str(s.running.level);
	
	skateboarding.amount = s.skateboarding.xp/s.skateboarding.to_level_up;
	skateboarding.get_node("Label").text = str(s.skateboarding.level);
	
	climbing.amount = s.climbing.xp/s.climbing.to_level_up;
	climbing.get_node("Label").text = str(s.climbing.level);
	
	jumping.amount = s.jumping.xp/s.jumping.to_level_up;
	jumping.get_node("Label").text = str(s.jumping.level);
