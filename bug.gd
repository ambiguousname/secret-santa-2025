class_name Bug extends Sprite2D

@onready var window : Window = self.get_window();

var _screen_size : Vector2i;
var _adventuring : bool = false;

var extents : Rect2i;

class Stats:
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
	var smarts : Stat = Stat.new();
	var moxie : Stat = Stat.new();
	
	const BUG_FILE : String = "user://bug.json";
	static func load_st() -> Stats:
		if FileAccess.file_exists(BUG_FILE):
			var f = FileAccess.open(BUG_FILE, FileAccess.READ);
			var bug_save = JSON.parse_string(f.get_as_text());
			var this = Stats.new();
			if bug_save is Dictionary:
				this.running.from_dict(bug_save["running"]);
				this.climbing.from_dict(bug_save["climbing"]);
				this.smarts.from_dict(bug_save["smarts"]);
				this.moxie.from_dict(bug_save["moxie"]);
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
		out["smarts"] = self.smarts.to_dict();
		out["moxie"] = self.moxie.to_dict();

var stats : Stats;

func _ready():
	stats = Stats.load_st();
	_initialize_adventure();

func jump():
	var tween = create_tween();
	var squash_amount : float = 0.8;
	tween.tween_property(self, "scale", Vector2(1.2, squash_amount), 0.2);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2(0, (150.0 * (1.0 - squash_amount))/2.0), 0.2);
	
	tween.tween_property(self, "scale", Vector2(0.6, 1.5), 0.2).set_delay(0.05);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2.UP * 400, 0.2).set_delay(0.05);

func land(delay : float, start : Vector2, pos : Vector2, callback : Callable):
	var tween = create_tween();
	tween.tween_property(self, "position", pos, 0.1).from(start).set_delay(delay);
	tween.parallel();
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).from(Vector2(0.6, 1.5));
	tween.tween_callback(callback).set_delay(0.01);

func begin_adventure():
	_adventuring = true;
	_screen_size = DisplayServer.screen_get_size(window.current_screen);

var _adventure_dir : float = 1;

var _adventure_delta_update : float = 0;

var _adventure_noise : FastNoiseLite = FastNoiseLite.new();

func _initialize_adventure() -> void:
	_adventure_noise.noise_type = FastNoiseLite.TYPE_PERLIN;

func _process(delta: float) -> void:
	if _adventuring:
		_adventure_delta_update += delta;
		
		_adventure_dir = _adventure_noise.get_noise_1d(Time.get_ticks_msec()/500.0);
		if self.position.x + extents.size.x/2.0 > extents.end.x - 250 && _adventure_dir > 0:
			_adventure_dir = 0;
		elif self.position.x + extents.size.x/2.0 < extents.position.x + 250 && _adventure_dir < 0:
			_adventure_dir = 0;
		
		self.position.x += _adventure_dir;
