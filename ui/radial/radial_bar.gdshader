shader_type canvas_item;

uniform float angle = 0.0;
uniform float inner_radius = 0.4;
uniform float outer_radius = 0.48;
uniform vec3 color : source_color = vec3(1.0);
uniform vec4 unfilled_color : source_color = vec4(0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 centered = vec2(UV.x - 0.5, UV.y - 0.5);
	float r = length(centered);
	float theta = atan(centered.y, centered.x);
	
	float outer = step(r, outer_radius);
	float inner = step(r, inner_radius);
	
	if (theta >= angle - PI) {
		COLOR = vec4(unfilled_color.rgb, unfilled_color.a * (outer - inner));
	} else {
		COLOR = vec4(color.rgb, outer - inner);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
