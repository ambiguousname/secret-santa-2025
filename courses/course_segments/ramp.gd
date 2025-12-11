@tool
extends StaticBody2D

@onready var path : Path2D = $Path2D;
@onready var polygon : CollisionPolygon2D = $CollisionPolygon2D;

@export var color : Color = Color.WHITE;
@export_tool_button("Redraw Polygon") 
var d = queue_redraw;

func _draw() -> void:
	var points := PackedVector2Array();
	# Add bottom:
	points.push_back(Vector2(path.curve.sample(0, 0).x, 500));
	for i in range(26):
		var point : Vector2 = path.curve.sample_baked(path.curve.get_baked_length() * i/(25.0));
		points.push_back(point);
	
	points.push_back(Vector2(path.curve.sample(path.curve.point_count, 1).x, 500));
	polygon.polygon = points;
	
	draw_colored_polygon(points, color);
