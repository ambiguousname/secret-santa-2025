@tool
class_name Radial extends Control

@export var inner_width : float = 2.0:
	set(v):
		inner_width = v;
		queue_redraw();
@export var amount : float = 1.0:
	set(v):
		amount = v;
		queue_redraw();

@export var radial_color : Color = Color.WHITE:
	set(v):
		radial_color = v;
		queue_redraw();

@export var unfilled_color : Color = Color(0, 0, 0, 0):
	set(v):
		unfilled_color = v;
		queue_redraw();

@export var subdivisions : int = 75:
	set(v):
		subdivisions = v;
		queue_redraw();

func _draw() -> void:
	draw_arc(Vector2(size.x/2, size.y/2), size.x/2 - inner_width/2, 0.0, amount * 2 * PI, subdivisions, radial_color, inner_width, false);
	if amount < 2 * PI || unfilled_color.a == 0:
		draw_arc(Vector2(size.x/2, size.y/2), size.x/2 - inner_width/2, amount * 2 * PI, 2 * PI, subdivisions, unfilled_color, inner_width, false);
