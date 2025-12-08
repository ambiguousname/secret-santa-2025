extends Node

var _store : Dictionary = {};

const SETTINGS_FILE : String = "user://settings.json";

func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var f = FileAccess.open(SETTINGS_FILE, FileAccess.READ);
		var settings = JSON.parse_string(f.get_as_text());
		if settings is Dictionary:
			_store = settings;
		else:
			printerr("Could not read user settings.");
		f.close();

func get_setting(setting_name : String, default : Variant) -> Variant:
	if setting_name in _store:
		return _store[setting_name];
	else:
		return default;

func set_setting(setting_name: String, value : Variant):
	_store[setting_name] = value;

func save():
	var f = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE);
	var json_string = JSON.stringify(_store);
	if !f.store_string(json_string):
		printerr("Could not save user settings.");
	f.close();
