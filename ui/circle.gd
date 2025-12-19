@tool
class_name Circle extends Control

@export var radius : float:
	set(v):
		radius = v;
		queue_redraw();

@export var color : Color:
	set(v):
		color = v;
		queue_redraw();

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color);
