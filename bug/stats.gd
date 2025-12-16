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
	var to_level_up : float:
		get():
			return exp(self.level);
		
	func increase(amount : float):
		self.xp += amount;
		
		if self.xp >= to_level_up:
			var next_amnt = self.xp - self.to_level_up;
			self.level += 1;
			self.xp = 0;
			increase(next_amnt);

var energy : float = 100.0;
var running : Stat = Stat.new();
var climbing : Stat = Stat.new();
var jumping : Stat = Stat.new();
var skateboarding : Stat = Stat.new();

enum Type {
	RUNNING,
	CLIMBING,
	JUMPING,
	SKATEBOARDING
}

static func stat_to_text(i : Type) -> String:
	match i:
		Type.RUNNING:
			return "Running";
		Type.CLIMBING:
			return "Climbing";
		Type.JUMPING:
			return "Jumping";
		Type.SKATEBOARDING:
			return "Skateboarding";
		_:
			return "Unknown";

func increase_stat(t : Type, amount : float):
	match t:
		Type.RUNNING:
			running.increase(amount);
		Type.CLIMBING:
			climbing.increase(amount);
		Type.JUMPING:
			jumping.increase(amount);
		Type.SKATEBOARDING:
			skateboarding.increase(amount);

var name : String = "";

func from_dict(dict : Dictionary):
	self.running.from_dict(dict["running"]);
	self.climbing.from_dict(dict["climbing"]);
	self.jumping.from_dict(dict["jumping"]);
	self.skateboarding.from_dict(dict["skateboarding"]);
	self.energy = dict["energy"];
	self.name = dict["name"];

func to_dict() -> Dictionary:
	var out = {};
	out["running"] = self.running.to_dict();
	out["climbing"] = self.climbing.to_dict();
	out["jumping"] = self.jumping.to_dict();
	out["skateboarding"] = self.skateboarding.to_dict();
	out["name"] = self.name;
	out["energy"] = self.energy;
	return out;
