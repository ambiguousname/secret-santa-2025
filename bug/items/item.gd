class_name Item extends Resource

@export var name : String = "Placeholder";
func to_dict() -> Dictionary:
	return {
		"name": name,
	};

static func from_dict(d : Dictionary) -> Item:
	var this := Item.new();
	if "name" in d:
		this.name = d["name"];
	return this;
