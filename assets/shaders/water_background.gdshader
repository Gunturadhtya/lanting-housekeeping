shader_type canvas_item;

uniform vec4 deep_color : source_color = vec4(0.02, 0.12, 0.22, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.06, 0.35, 0.45, 1.0);

uniform float wave_speed : hint_range(0.0, 2.0) = 0.35;
uniform float wave_scale : hint_range(1.0, 40.0) = 10.0;
uniform float wave_strength : hint_range(0.0, 0.2) = 0.05;

uniform int color_bands : hint_range(2, 6) = 3;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * wave_speed;

	float flow = uv.y * wave_scale - t * 3.0;
	float ripple = sin(flow) * wave_strength;
	float wobble = sin(flow * 0.5 + uv.x * wave_scale * 0.4) * wave_strength * 0.5;
	vec2 distorted_uv = vec2(uv.x + wobble, uv.y + ripple);

	float depth = clamp(distorted_uv.y, 0.0, 1.0);
	float banded_depth = floor(depth * float(color_bands)) / max(float(color_bands) - 1.0, 1.0);
	vec3 base_color = mix(shallow_color.rgb, deep_color.rgb, banded_depth);
	COLOR = vec4(base_color, 1.0);
}
