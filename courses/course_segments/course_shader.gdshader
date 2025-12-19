shader_type canvas_item;

uniform vec3 col : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = SCREEN_UV - vec2(0.5, 0.5);
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);

	vec2 pixel_size = vec2(0.01, 0.01);

	vec2 uv_pixels = uv / pixel_size;
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;

	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);

	uv = uv_pixels_floor * pixel_size;

	vec3 c = col * (0.5 + mod(uv.x * uv.y + TIME/100.0, 0.05));
	COLOR = vec4(c, 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
