class_name UI extends Control

@onready var adventure : Button = %Adventure;
@onready var race : Button = %Race;
@onready var submit_name : Button = %Submit;
@onready var items_button : Button = %ItemsButton;
@onready var items : ItemManager = %Items;
@onready var settings_button : Button = $FullInfo/SettingsButton;
@onready var settings_menu : SettingsMenu = $SettingsMenu;
@onready var item_notif : Control = items_button.get_node("NotifDot");
@onready var settings_notif : Circle = settings_button.get_node("NotifDot");

@onready var full_info : Control = $FullInfo;


func update_tcp_status(text : String, color : Color):
	settings_menu.install.error_text.text = text;
	if settings_menu.is_visible_in_tree():
		return;
	settings_notif.color = color;
	settings_notif.visible = true;

signal retire();

func _ready() -> void:
	bug_name.text_submitted.connect(end_setup, CONNECT_ONE_SHOT);
	submit_name.pressed.connect(func():
		AudioEvent.play("silly_button");
		end_setup(bug_name.text);
	);
	
	items_button.pressed.connect(func():
		AudioEvent.play("silly_button");
		items.visible = true;
		full_info.visible = false;
		item_notif.visible = false;
	);
	items.close.pressed.connect(func():
		AudioEvent.play("serious_button");
		items.visible = false;
		full_info.visible = true;
	);
	items.item_added.connect(func():
		item_notif.visible = true;
	);
	settings_button.pressed.connect(func():
		AudioEvent.play("serious_button");
		settings_menu.visible = true;
		full_info.visible = false;
		settings_notif.visible = false;
	);
	settings_menu.close.pressed.connect(func():
		AudioEvent.play("serious_button");
		full_info.visible = true;
		settings_menu.visible = false;
	);
	$WinScreen/VBoxContainer/Button.pressed.connect(func():
		AudioEvent.play("serious_button");
		retire.emit();
	);

@onready var bug_name : LineEdit = $"Bug Name";

signal setup_ended(b_name : String);

func setup_bug_dead(bug_name : String):
	setup_bug();
	$SetupText.text = "%s lost! You must start again." % bug_name;

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
	adventure.visible = false;
	$SetupText.text = "Start your journey, name your bug!";

func end_setup(n : String):
	$SetupText.visible = false;
	bug_name.editable = false;
	
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
@onready var day_progress : ProgressBar = $FullInfo/Day/ProgressBar;
@onready var week_transition : WeekTransition = $WeekTransition;
func set_day(day : int, day_percent : float, advance: bool):
	day_label.text = "RACE IN\n%d DAYS" % day;
	set_day_progress(day_percent);

func set_week(b_name : String, color : Color, old_week : int, new_week : int):
	week_transition.transition_week(b_name, color, old_week, new_week);

func set_day_progress(day_percent : float):
	day_progress.value = day_percent;

func start_race_day():
	day_label.text = "RACE TODAY";
	adventure.visible = false;
	race.visible = true;

func end_race_day(winner : bool):
	adventure.visible = true;
	race.visible = false;
	if !winner:
		full_info.visible = false;
		adventure.visible = false;

@onready var energy : ProgressBar = %Energy;
func set_energy(e : float):
	energy.value = e;

func win(b_name : String):
	adventure.visible = false;
	race.visible = false;
	full_info.visible = false;
	$WinScreen/VBoxContainer/Label.text = "%s is a champion!" % b_name;
	$WinScreen.visible = true;

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
