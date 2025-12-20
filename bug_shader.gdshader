shader_type canvas_item;

uniform vec3 eye_color : source_color = vec3(0, 0, 0);
uniform vec3 body_tint : source_color = vec3(1, 1, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.g == 1.0 && COLOR.r <= 0.0) {
		COLOR = vec4(eye_color, 1.0);
	} else {
		COLOR = vec4(COLOR.rgb * body_tint, COLOR.a);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
