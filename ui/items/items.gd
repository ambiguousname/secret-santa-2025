class_name ItemManager extends Panel

@onready var grid : GridContainer = $GridContainer;
@onready var close : Button = $Close;

func _ready() -> void:
	close.pressed.connect(func():
		self.visible = false;
	);

@onready var item_display = preload("uid://1lmen782bmps");
func add_item(i : Item):
	var d : ItemDisplay = item_display.instantiate();
	d.texture = i.texture;
	grid.add_child(d);
