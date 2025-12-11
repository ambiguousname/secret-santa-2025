@tool
extends StaticBody2D

@onready var path : Path2D = $Path2D;
@onready var polygon : CollisionPolygon2D = $CollisionPolygon2D;

@export var color : Color = Color.WHITE:
	set(v):
		color = v;
		queue_redraw();
@export var subdivisions : int = 25:
	set(v):
		subdivisions = v;
		queue_redraw();
@export var bottom : float = 500:
	set(v):
		bottom = v;
		queue_redraw();
@export_tool_button("Redraw Polygon") 
var d = queue_redraw;

func _draw() -> void:
	var points := PackedVector2Array();
	# Add bottom:
	points.push_back(Vector2(path.curve.sample(0, 0).x, bottom));
	for i in range(subdivisions + 1):
		var point : Vector2 = path.curve.sample_baked(path.curve.get_baked_length() * i/float(subdivisions));
		points.push_back(point);
	
	points.push_back(Vector2(path.curve.sample(path.curve.point_count, 1).x, bottom));
	polygon.polygon = points;
	
	draw_colored_polygon(points, color);
