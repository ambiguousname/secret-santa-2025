class_name AdventureInfo extends Object

## We're stored in the same save object (this is just mostly for organization purposes), so being able to access this save's stats is okay:
var _stats : Stats;
var items : Array = [];

func _init(s : Stats) -> void:
	_stats = s;

## Called when we want to save:
signal mark_dirty();

func can_regain_energy() -> bool:
	return false;

var day_progress_time : float = 100.0;
var day : int = 0;
var week : int = 0;

func from_dict(d : Dictionary):
	if "day_progress_time" in d:
		day_progress_time = d["day_progress_time"];
	if "day" in d:
		day = d["day"];
	if "week" in d:
		week = d["week"];
	if "items" in d:
		items = d["items"].map(func(i : Dictionary): var it = Item.new(); return it.from_dict(i));

func to_dict() -> Dictionary:
	return {
		"day_progress_time": day_progress_time,
		"day": day,
		"week": week,
		"items": items.map(func(i : Item): return i.to_dict()),
	};

var mark_dirty_timer : float = 0.0;

var _focus_timer : float = 0.0;
var _focus : int = randi() % 4;

var _item_timer : float = 0.0;
const MIN_ITEM_TIME : float = 30;
const MAX_ITEM_TIME : float = 900;
var _item_duration : float = randf_range(MIN_ITEM_TIME, MAX_ITEM_TIME);

func adventure_update(delta: float):
	# 100 energy/30 minutes = 3.3333333 energy per minute * 1/60 minute/seconds = 0.5555555 energy/second
	var time_delta = 0.05555555 * delta;
	_stats.energy -= time_delta;
	day_progress_time -= time_delta;
	
	# Gain 1 XP every second:
	match _focus:
		0:
			_stats.running.increase(delta);
		1:
			_stats.climbing.increase(delta);
		2:
			_stats.skateboarding.increase(delta);
		3:
			_stats.jumping.increase(delta);
	
	_focus_timer += delta;
	mark_dirty_timer += delta;
	_item_timer += delta;
	
	if mark_dirty_timer > 5.0:
		mark_dirty_timer = 0.0;
		mark_dirty.emit();
	if _focus_timer >= 60:
		_focus_timer = 0;
		_focus = randi() % 4;
	
	if _item_timer >= _item_duration:
		_item_timer = 0;
		_item_duration = randf_range(MIN_ITEM_TIME, MAX_ITEM_TIME);
		items.push_back(Item.new());
