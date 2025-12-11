class_name Stats extends Object
class Stat:
	var level : int = 0;
	var xp : float = 0;
	func from_dict(d : Dictionary):
		self.level = d["level"];
		self.xp = d["xp"];
	func to_dict() -> Dictionary:
		return {
			level: self.level,
			xp: self.xp
		};

var energy : float = 100.0;
var running : Stat = Stat.new();
var climbing : Stat = Stat.new();
var jumping : Stat = Stat.new();
var skateboarding : Stat = Stat.new();

const BUG_FILE : String = "user://bug.json";
static func load_st() -> Stats:
	if FileAccess.file_exists(BUG_FILE):
		var f = FileAccess.open(BUG_FILE, FileAccess.READ);
		var bug_save = JSON.parse_string(f.get_as_text());
		var this = Stats.new();
		if bug_save is Dictionary:
			this.running.from_dict(bug_save["running"]);
			this.climbing.from_dict(bug_save["climbing"]);
			this.jumping.from_dict(bug_save["jumping"]);
			this.skateboarding.from_dict(bug_save["skateboarding"]);
		else:
			printerr("Could not read user settings.");
		f.close();
		return this;
	else:
		return Stats.new();
func save():
	var out = {};
	out["running"] = self.running.to_dict();
	out["climbing"] = self.climbing.to_dict();
	out["jumping"] = self.jumping.to_dict();
	out["skateboarding"] = self.skateboarding.to_dict();
