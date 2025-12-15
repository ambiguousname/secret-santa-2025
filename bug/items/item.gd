class_name Item extends Resource

@export var name : String = "Placeholder";
func to_dict() -> Dictionary:
	return {
		"name": name,
	};

func from_dict(d : Dictionary):
	if "name" in d:
		name = d["name"];
