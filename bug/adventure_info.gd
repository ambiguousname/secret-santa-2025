class_name AdventureInfo extends Object

## We're stored in the same save object (this is just mostly for organization purposes), so being able to access this save's stats is okay:
var _stats : Stats;

func _init(s : Stats) -> void:
	_stats = s;

## Called when we want to save:
signal mark_dirty();

func from_dict(d : Dictionary):
	pass;

func to_dict() -> Dictionary:
	var out = {};
	return out;

var mark_dirty_timer : float = 0.0;

func adventure_update(delta: float):
	# 100 energy/30 minutes = 3.3333333 energy per minute * 1/60 minute/seconds = 0.5555555 energy/second
	_stats.energy -= 0.05555555 * delta;
	mark_dirty_timer += delta;
	if mark_dirty_timer > 5.0:
		mark_dirty_timer = 0.0;
		mark_dirty.emit();
