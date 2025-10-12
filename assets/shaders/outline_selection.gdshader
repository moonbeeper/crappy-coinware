shader_type canvas_item;

uniform bool out_of_bounds = true;
uniform bool stop = false;
uniform float outline_thickness: hint_range(0.0, 16.0, 1.0) = 1.0;
uniform vec4 outline_color: source_color = vec4(1.0);
uniform float sweep_speed = 1.0;
uniform float sweep_width = 0.1;
uniform float sweep_intensity: hint_range(0.7, 2.0) = 1.0;

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
    float alpha = top.a + bottom.a * (1.0 - top.a);
    if (alpha < 0.0001) return vec4(0.0);

    vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
    return vec4(color, alpha);
}

varying vec4 modulate_color;

void vertex() {
	modulate_color = COLOR;
	if (out_of_bounds && !stop) VERTEX += (UV * 2.0 - 1.0) * outline_thickness;
}

void fragment() {
	if (outline_thickness > 0.0 && outline_color.a > 0.0) {
		vec2 uv = UV;
		vec4 texture_color = texture(TEXTURE, UV);

		if (out_of_bounds) {
			vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(outline_thickness * 2.0));
			uv = (uv - texture_pixel_size * outline_thickness) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

			if (is_inside_usquare(uv)) {
				texture_color = texture(TEXTURE, uv);
			} else {
				texture_color = vec4(0.0);
			}
		}

		float alpha = 0.0;

		for (float y = 1.0; y <= outline_thickness; y++) {
			for (float x = 0.0; x <= y; x++) {
				if (length(vec2(x, y - 0.5)) > outline_thickness) break;

				float look_at_alpha;
				vec2 look_at_uv[8] = {
					uv + vec2(x, y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-x, y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(x, -y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-x, -y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(y, x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-y, x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(y, -x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-y, -x) * TEXTURE_PIXEL_SIZE
				};

				for (int i = 0; i < 8; i++) {
					if (is_inside_usquare(look_at_uv[i])) {
						look_at_alpha = texture(TEXTURE, look_at_uv[i]).a;
						if (look_at_alpha > alpha) alpha = look_at_alpha;
						if (1.0 - alpha < 0.0001) break;
					}
				}

				if (1.0 - alpha < 0.0001) break;
			}

			if (1.0 - alpha < 0.0001) break;
		}

		// sweep
		vec3 final_outline_rgb = outline_color.rgb;
		if (alpha > 0.0) {
			vec2 pos = UV - 0.5;
			float angle = atan(pos.y, pos.x) / (2.0 * PI) + 0.5;
			float sweep_pos = fract(TIME * sweep_speed);
			float dist = min(abs(angle - sweep_pos), 1.0 - abs(angle - sweep_pos));
			float sweep_factor = smoothstep(sweep_width, 0.0, dist);

			final_outline_rgb = mix(outline_color.rgb, vec3(1.0), sweep_factor * sweep_intensity);
		}

		vec4 outline = vec4(final_outline_rgb, alpha * outline_color.a);
		COLOR = blend(outline, texture_color) * modulate_color;
	} else {
		COLOR = texture(TEXTURE, UV);
	}

	if (stop) {
		COLOR = texture(TEXTURE, UV);
	}
}