class_name Item extends Resource

@export var name : String = "Placeholder";
@export var stat_one : Stats.Type;
@export var stat_increase : float = 500;
@export var stat_two : Stats.Type;
@export var energy_increase : float = 25;

@export var texture : Texture2D;
func to_dict() -> Dictionary:
	return {
		"name": name,
		"texture": texture.resource_path,
		"stat_one": stat_one,
		"stat_two": stat_two,
		"stat_increase": stat_increase,
		"energy_increase": energy_increase,
	};

static func from_dict(d : Dictionary) -> Item:
	var this := Item.new();
	if "name" in d:
		this.name = d["name"];
	if "texture" in d:
		this.texture = load(d["texture"]);
	if "stat_one" in d:
		this.stat_one = d["stat_one"];
	if "stat_two" in d:
		this.stat_two = d["stat_two"];
	if "stat_increase" in d:
		this.stat_increase = d["stat_increase"];
	if "energy_increase" in d:
		this.energy_increase = d["energy_increase"];
	return this;
