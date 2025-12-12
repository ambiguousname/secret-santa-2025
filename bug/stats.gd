class_name Stats extends Object
class Stat:
	var level : int = 0;
	var xp : float = 0;
	func from_dict(d : Dictionary):
		self.level = d["level"];
		self.xp = d["xp"];
	func to_dict() -> Dictionary:
		return {
			"level": self.level,
			"xp": self.xp
		};

var energy : float = 100.0;
var running : Stat = Stat.new();
var climbing : Stat = Stat.new();
var jumping : Stat = Stat.new();
var skateboarding : Stat = Stat.new();

var name : String = "";

func from_dict(dict : Dictionary):
	self.running.from_dict(dict["running"]);
	self.climbing.from_dict(dict["climbing"]);
	self.jumping.from_dict(dict["jumping"]);
	self.skateboarding.from_dict(dict["skateboarding"]);
	self.name = dict["name"];

func to_dict() -> Dictionary:
	var out = {};
	out["running"] = self.running.to_dict();
	out["climbing"] = self.climbing.to_dict();
	out["jumping"] = self.jumping.to_dict();
	out["skateboarding"] = self.skateboarding.to_dict();
	out["name"] = self.name;
	return out;
