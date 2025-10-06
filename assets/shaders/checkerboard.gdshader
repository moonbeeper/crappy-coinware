shader_type canvas_item;

uniform float square_size = 10.0;
uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform float direction: hint_range(-360.0, 360.0) = 180.0f;
uniform float rotation: hint_range(-360.0, 360.0) = 0.0f;

vec2 degreesToPerpendicular(){
	return vec2(cos(radians((direction - rotation))), -sin(radians(direction - rotation)));
}

vec2 rotate(vec2 uv, float rotation_angle) {
    float radians_angle = radians(rotation_angle);
    float cos_angle = cos(radians_angle);
    float sin_angle = sin(radians_angle);
    mat2 rotation_matrix = mat2(vec2(cos_angle, -sin_angle), vec2(sin_angle, cos_angle));
    return uv * rotation_matrix;
}

void fragment() {
	vec2 pos = FRAGCOORD.xy / square_size;
	float time_offset = TIME * speed;

    vec2 movement = degreesToPerpendicular() * time_offset;
	pos = rotate(pos, rotation);
    pos -= movement;
    pos = floor(pos);

    float pattern_mask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    COLOR = mix(color1, color2, pattern_mask);
}