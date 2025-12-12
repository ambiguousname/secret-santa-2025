class_name Save extends Object

var stats : Stats = Stats.new();
var adv_info : AdventureInfo = AdventureInfo.new(stats);
const SAVE_FILE : String = "user://save.json";

func load_save():
	if FileAccess.file_exists(SAVE_FILE):
		var f = FileAccess.open(SAVE_FILE, FileAccess.READ);
		var save = JSON.parse_string(f.get_as_text());
		if save is Dictionary:
			if "bug" in save:
				stats.from_dict(save["bug"]);
			if "adventure" in save:
				adv_info.from_dict(save["adventure"]);
		else:
			printerr("Could not read user settings.");
		f.close();

func write_save():
	var f = FileAccess.open(SAVE_FILE, FileAccess.WRITE);
	var d = {};
	d["bug"] = stats.to_dict();
	d["adventure"] = adv_info.to_dict();
	f.store_buffer(JSON.stringify(d).to_utf8_buffer());
