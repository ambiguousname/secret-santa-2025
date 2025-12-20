class_name ItemConfirm extends Control

@onready var cancel : Button = $Grid/Cancel;
@onready var choice_one : Button = $Grid/Button;
@onready var choice_two : Button = $Grid/Button2;
@onready var choice_three : Button = $Grid/Button3;
@onready var label : Label = $Grid/Label;

signal item_used(choice : int);

func _ready() -> void:
	cancel.pressed.connect(func():
		AudioEvent.play("silly_button");
		item_used.emit(-1);
	);
	
	choice_one.pressed.connect(func(): AudioEvent.play("serious_button"); item_used.emit(0));
	choice_two.pressed.connect(func(): AudioEvent.play("serious_button"); item_used.emit(1));
	choice_three.pressed.connect(func(): AudioEvent.play("serious_button"); item_used.emit(2));

func pick_item(i : Item):
	label.text = "Use %s?" % i.name;
	choice_one.text = "%s - +%d XP" % [Stats.stat_to_text(i.stat_one), i.stat_increase];
	choice_two.text = "%s - +%d XP" % [Stats.stat_to_text(i.stat_two), i.stat_increase];
	choice_three.text = "Energy - +%d" % i.energy_increase; 
