class_name TextSettings extends Control

@onready var font_family : OptionButton = %FontFamily;
@onready var font_size : SpinBox = %FontSize;

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
	font_family.selected = fam;
	set_family(fam);
	
	font_size.value_changed.connect(func(v : float):
		var val := int(v);
		set_font_size(val);
		Settings.set_setting("font_size", val);
		Settings.save();
	);
	var f_size : int = Settings.get_setting("font_size", 16);
	set_font_size(f_size);
	font_size.value = f_size;

func set_family(family : FontFamily):
	var def = ThemeDB.get_default_theme();
	var theme = ThemeDB.get_project_theme();
	match family:
		FontFamily.QUIXEL:
			theme.default_font = quixel;
		FontFamily.NOTOSANS:
			theme.default_font = def.default_font;

func set_font_size(v : int):
	ThemeDB.get_project_theme().default_font_size = int(v);
