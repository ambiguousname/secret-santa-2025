@tool
extends StaticBody2D

@onready var polygon : CollisionPolygon2D = $CollisionPolygon2D;

@export var color : Color = Color.WHITE;
@export_tool_button("Redraw Polygon") 
var d = queue_redraw;

func _draw() -> void:
	draw_colored_polygon(polygon.polygon, color);
