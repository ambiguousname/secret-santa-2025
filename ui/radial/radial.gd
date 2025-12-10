@tool
extends ColorRect

@export var amount : float = 1.0:
	get():
		return amount;
	set(v):
		amount = v;
		self.material.set_shader_parameter("angle", 2 * PI * amount);

@export var radial_color : Color = Color.WHITE:
	get():
		return radial_color;
	set(v):
		radial_color = v;
		self.material.set_shader_parameter("color", radial_color);
