shader_type spatial;

uniform bool colored = true;
uniform vec3 color_min : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_mid : source_color = vec3(0.0);
uniform vec3 color_max : source_color = vec3(1.0);
uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform bool vertex_displacement = true;

#define USE_FRACTAL_PATTERN_CURL
#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#define SAMPLE_PATTERN_FUNCTION sample_square_blended_value_noise
#include "res://shader_library/square_blended_value_noise.gdshaderinc"
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

PatternSample sample_noise(vec2 uv) {
	return sample_fractal(standard_fractal_pattern_settings(), uv, TIME);
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
