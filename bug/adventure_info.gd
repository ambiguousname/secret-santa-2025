class_name AdventureInfo extends RefCounted

## We're stored in the same save object (this is just mostly for organization purposes), so being able to access this save's stats is okay:
var _stats : WeakRef;
var items : Array = [];

const COLORS : Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.AQUA, Color.TOMATO, Color.BLACK, Color.BROWN, Color.GOLD, Color.NAVAJO_WHITE, Color.PURPLE, Color.WEB_PURPLE, Color.MAROON, Color.WHITE];
var color : Color = Color.WHITE;

var generate_item : Callable;

func _init(s : Stats) -> void:
	_stats = weakref(s);

## Called when we want to save:
signal mark_dirty();

func can_regain_energy() -> bool:
	return items.size() > 0;

var day_progress_time : float = 100.0;
var day : int = 0;
var week : int = 0;
var nature : Array = [0.25, 0.25, 0.25, 0.25];

func from_dict(d : Dictionary):
	if "day_progress_time" in d:
		day_progress_time = d["day_progress_time"];
	if "day" in d:
		day = d["day"];
	if "week" in d:
		week = d["week"];
	if "items" in d:
		items = d["items"].map(func(i : Dictionary): return Item.from_dict(i));
	if "nature" in d:
		nature = d["nature"];
	if "color" in d:
		color = d["color"];

func to_dict() -> Dictionary:
	return {
		"day_progress_time": day_progress_time,
		"day": day,
		"week": week,
		"items": items.map(func(i : Item): return i.to_dict()),
		"nature": nature,
		"color": color.to_html(),
	};

func clear():
	day_progress_time = 100;
	day = 0;
	week = 0;
	items = [];
	nature = [0.25, 0.25, 0.25, 0.25];

func select_nature():
	var stats = [0, 1, 2, 3];
	var primary = randi() % stats.size();
	nature[stats[primary]] = 0.5;
	stats.remove_at(primary);
	
	var secondary = randi() % stats.size();
	nature[stats[secondary]] = 0.25;
	stats.remove_at(secondary);
	
	nature[stats[0]] = 0.125;
	nature[stats[1]] = 0.125;

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
	var s = _stats.get_ref();
	s.energy -= time_delta;
	day_progress_time -= time_delta;
	
	# Gain 1 XP every second:
	match _focus:
		0:
			s.running.increase(delta);
		1:
			s.climbing.increase(delta);
		2:
			s.skateboarding.increase(delta);
		3:
			s.jumping.increase(delta);
	
	_focus_timer += delta;
	mark_dirty_timer += delta;
	_item_timer += delta;
	
	if mark_dirty_timer > 5.0:
		mark_dirty_timer = 0.0;
		mark_dirty.emit();
	if _focus_timer >= 60:
		_focus_timer = 0;
		var selection = randf();
		var cumulative = 0.0;
		for i in range(nature.size()):
			cumulative += nature[i];
			if selection <= cumulative:
				_focus = i;
				break;
	
	if _item_timer >= _item_duration:
		_item_timer = 0;
		_item_duration = randf_range(MIN_ITEM_TIME, MAX_ITEM_TIME);
		items.push_back(generate_item.call());
