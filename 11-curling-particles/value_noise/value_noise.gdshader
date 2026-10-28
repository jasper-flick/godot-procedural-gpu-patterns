shader_type spatial;

uniform vec2 slide_velocity = vec2(0.0, 0.0);
uniform bool colored = true;
uniform vec3 color_min : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_mid : source_color = vec3(0.0);
uniform vec3 color_max : source_color = vec3(1.0);
uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform bool vertex_displacement = true;
uniform float curl_strength : hint_range(-1.0, 1.0) = 0.0;
uniform vec2 curl_frequency = vec2(1.0, 1.0);
uniform int curl_octaves : hint_range(1, 3) = 1;
uniform float curl_animation = 0.0;

#define PATTERN_FREQUENCY_TYPE vec2
#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#define USE_FRACTAL_PATTERN_ANIMATION_SETTINGS
#define USE_FRACTAL_PATTERN_SMOOTNESS_SETTING
#define USE_FRACTAL_PATTERN_TILING_SETTING
#include "res://shader_library/square_value_noise.gdshaderinc"

#define SAMPLE_PATTERN_FUNCTION sample_square_value_noise
#include "res://shader_library/fractal_pattern.gdshaderinc"

vec3 colorize(float v) {
	if (colored) {
		v *= 2.0;
		if (v > 1.0) {
			return mix(color_mid, color_max, v - 1.0);
		}
		else {
			return mix(color_min, color_mid, v);
		}
	}
	else {
		return vec3(v);
	}
}

void sample_curl_noise(vec2 uv, out PatternSample u, out PatternSample v) {
	FractalPatternSettings curl_settings = standard_fractal_pattern_settings();
	curl_settings.pattern_seed ^= 255u;
	curl_settings.base_frequency = curl_frequency;
	curl_settings.octaves = curl_octaves;
	curl_settings.base_animation = curl_animation;
	PatternSample s = sample_fractal_pattern(curl_settings, uv, TIME);
	float epsilon = 0.001;
	PatternSample sx = sample_fractal_pattern(
			curl_settings, uv + vec2(epsilon, 0.0), TIME
	);
	PatternSample sy = sample_fractal_pattern(
			curl_settings, uv + vec2(0.0, epsilon), TIME
	);
	
	float smoothness_normalization = 1.0;
	switch (curl_settings.pattern_smoothness) {
		case 2:
			smoothness_normalization = 2.0 / 3.0;
			break;
		case 3:
			smoothness_normalization = 8.0 / 15.0;
			break;
	}
	vec2 scale = curl_strength * smoothness_normalization / epsilon /
			curl_settings.base_frequency;
	u = multiply(subtract(sy, s), scale.y);
	v = multiply(subtract(sx, s), -scale.x);
}

PatternSample sample_noise(vec2 uv) {
	FractalPatternSettings settings = standard_fractal_pattern_settings();
	if (settings.pattern_animation) {
		uv += slide_velocity * TIME;
		if (settings.pattern_tiling) {
			uv = fract(uv);
		}
	}
	
	PatternSample u, v;
	sample_curl_noise(uv, u, v);
	u.v += uv.x;
	u.dx += 1.0;
	v.v += uv.y;
	v.dy += 1.0;
	
	uv = vec2(u.v, v.v);
	if (settings.pattern_tiling) {
		uv = fract(uv);
	}
	PatternSample s = sample_fractal_pattern(settings, uv, TIME);
	float dx = s.dx;
	s.dx = u.dx * dx + v.dx * s.dy;
	s.dy = u.dy * dx + v.dy * s.dy;
	return s;
}

void vertex() {
	if (vertex_displacement) {
		PatternSample pattern_sample = sample_noise(UV);
		VERTEX += NORMAL * (pattern_sample.v * displacement);
	}
}

void fragment() {
	PatternSample pattern_sample = sample_noise(UV);
	ALBEDO = colorize(pattern_sample.v);
	
	vec2 d =
			vec2(pattern_sample.dx, pattern_sample.dy) *
			displacement * bumpiness;
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
