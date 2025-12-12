class_name Save extends Object

var stats : Stats = Stats.new();
const SAVE_FILE : String = "user://save.json";

func load_save():
	if FileAccess.file_exists(SAVE_FILE):
		var f = FileAccess.open(SAVE_FILE, FileAccess.READ);
		var save = JSON.parse_string(f.get_as_text());
		if save is Dictionary:
			stats.from_dict(save["bug"]);
		else:
			printerr("Could not read user settings.");
		f.close();

func write_save():
	var f = FileAccess.open(SAVE_FILE, FileAccess.WRITE);
	var d = {};
	d["bug"] = stats.to_dict();
	f.store_buffer(JSON.stringify(d).to_utf8_buffer());
