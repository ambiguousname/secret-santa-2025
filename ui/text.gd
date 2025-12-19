class_name TextSettings extends Control

@onready var font_family : OptionButton = %FontFamily;

var quixel : FontFile = preload("uid://coucdedhg8x0e");

enum FontFamily {
	QUIXEL = 0,
	NOTOSANS = 1,
};

func _ready() -> void:
	font_family.item_selected.connect(func(i : int):
		var family : FontFamily = i;
		set_family(family);
		Settings.set_setting("font_family", family);
		Settings.save();
	);
	var fam : FontFamily = Settings.get_setting("font_family", FontFamily.QUIXEL);
	set_family(fam);

func set_family(family : FontFamily):
	var def = ThemeDB.get_default_theme();
	var theme = ThemeDB.get_project_theme();
	match family:
		FontFamily.QUIXEL:
			theme.default_font = quixel;
		FontFamily.NOTOSANS:
			theme.default_font = def.default_font;
