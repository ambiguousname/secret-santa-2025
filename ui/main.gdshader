shader_type canvas_item;

uniform vec3 light_col : source_color;
uniform vec3 dark_col : source_color;
uniform vec3 mid_col : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.r >= 0.8) {
		COLOR = vec4(light_col, COLOR.a);
	} else if (COLOR.r >= 0.5) {
		COLOR = vec4(mid_col, COLOR.a);
	} else {
		COLOR = vec4(dark_col, COLOR.a);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
