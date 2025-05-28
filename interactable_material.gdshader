shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float width : hint_range(0, 10) = 1.0;

varying flat vec4 modulate;

void vertex() {
	modulate = COLOR;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		offset = width - abs(x);
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if (xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	vec2 image_top_left = floor(uv);
	vec2 image_bottom_right = image_top_left + vec2(1.0);
	
	COLOR = texture(TEXTURE, uv) * modulate;
	
	if (COLOR.a > 0.0 && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
		COLOR.rgb = mix(COLOR.rgb, color.rgb * modulate.rgb, opacity * color.a * modulate.a);
		COLOR.a += (1.0 - COLOR.a) * (color.a * opacity) * modulate.a;
	}
}