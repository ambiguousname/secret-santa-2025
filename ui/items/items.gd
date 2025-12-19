class_name ItemManager extends Panel

@onready var grid : GridContainer = $GridContainer;
@onready var close : Button = $Close;
@onready var item_confirm : ItemConfirm = $"../ItemConfirm";
@onready var no_items : Label = $NoItems;

var item_to_use : Item;
var active_item_display : ItemDisplay;

signal item_added();
signal use_item(i : Item, choice : int);

func _ready() -> void:
	item_confirm.item_used.connect(func(i : int):
		item_confirm.visible = false;
		self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED;
		if i > -1:
			use_item.emit(item_to_use, i);
			active_item_display.queue_free();
		if grid.get_child_count() <= 1:
			no_items.visible = true;
	);

func clear():
	for c in grid.get_children():
		c.queue_free();
	no_items.visible = true;

@onready var item_display = preload("uid://1lmen782bmps");
func add_item(i : Item, notify : bool = false):
	if notify:
		item_added.emit();
	var d : ItemDisplay = item_display.instantiate();
	d.texture = i.texture;
	grid.add_child(d);
	d.pressed.connect(func():
		item_confirm.pick_item(i);
		item_to_use = i;
		active_item_display = d;
		item_confirm.visible = true;
		self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED;
	);
	no_items.visible = false;
