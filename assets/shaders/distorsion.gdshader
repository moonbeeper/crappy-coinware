shader_type canvas_item;

uniform float time_scale = 1.0;
uniform float frequency = 5.0;
uniform float amplitude = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_nearest;

void fragment() {
	float wave_phase = (UV.x + UV.y) * frequency + TIME * time_scale;
	float wave = sin(wave_phase) * amplitude;

	// mr gpt did this to hide the gaps that are not distorted when distoring
	float dist_to_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float blend_mask = smoothstep(0.0, 0.3, dist_to_edge);
	float scaled_wave = wave * blend_mask;

	vec2 distorted_uv = SCREEN_UV;
	distorted_uv.x += scaled_wave * 0.5;
	distorted_uv.y -= scaled_wave * 0.5;

	distorted_uv = clamp(distorted_uv, 0.0, 1.0);

	COLOR = texture(screen_texture, distorted_uv);
}