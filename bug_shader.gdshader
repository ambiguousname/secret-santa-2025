shader_type canvas_item;

uniform vec3 eye_color : source_color = vec3(0, 0, 0);
uniform vec3 body_tint : source_color = vec3(1, 1, 1);
uniform vec3 secondary_tint : source_color = vec3(0, 0, 0);
uniform int pattern = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.g == 1.0 && COLOR.r <= 0.0) {
		COLOR = vec4(eye_color, 1.0);
	} else {
		float amnt = 1.0;
		vec2 uv = vec2((UV.x - 0.5) * 0.4, UV.y - 0.5);
		switch (pattern) {
			case 0:
				amnt = 1.0;
				break;
			case 1:
				amnt = step(mod(UV.x + UV.y, 0.2), 0.1);
				break;
			case 2:
				amnt = step(sin(length(uv)), 0.2);
				break;
			case 3:
				amnt = step(atan(uv.x/uv.y), 0.5);
				break;
		}
		COLOR = vec4(COLOR.rgb * (body_tint * amnt + secondary_tint * (1.0 - amnt)), COLOR.a);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
