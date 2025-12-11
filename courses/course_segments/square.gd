@tool
extends StaticBody2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D;
@onready var shape : Shape2D = collision_shape.shape;

@export var color : Color = Color.WHITE:
	set(v):
		color = v;
		queue_redraw();

func _ready() -> void:
	shape.changed.connect(queue_redraw);


func _draw() -> void:
	if shape is RectangleShape2D:
		var rect : Rect2 = self.shape.get_rect();
		rect.position += collision_shape.position;
		draw_rect(rect, color);
	else:
		printerr("Shape must be RectangleShape2D!");
