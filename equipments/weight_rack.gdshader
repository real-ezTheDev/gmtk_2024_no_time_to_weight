shader_type canvas_item;

uniform vec4 line_color: source_color;
uniform bool outline;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	vec4 right = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
	vec4 left = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0));
	vec4 top = texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y));
	vec4 bottom = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
	
	if (outline && (right.a > 0. || left.a >0. || top.a >0. || bottom.a >0.) && current_color.a == 0.) {
		COLOR = line_color;
	} else {
		COLOR = texture(TEXTURE, UV);
	}

	// Called for every pixel the material is visible on.
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
