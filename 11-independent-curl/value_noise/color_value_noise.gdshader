shader_type spatial;

uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform bool vertex_displacement = true;

#define PATTERN_SAMPLE_DIMENSIONS 4
#define USE_FRACTAL_PATTERN_CURL
#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#define SAMPLE_PATTERN_FUNCTION sample_square_blended_value_noise
#include "res://shader_library/square_blended_value_noise.gdshaderinc"
#include "res://shader_library/fractal_pattern.gdshaderinc"

PatternSample sample_noise(vec2 uv) {
	return sample_fractal(standard_fractal_pattern_settings(), uv, TIME);
}

void vertex() {
	if (vertex_displacement) {
		PatternSample pattern_sample = sample_noise(UV);
		VERTEX += NORMAL * (pattern_sample.v.w * displacement);
	}
}

void fragment() {
	PatternSample pattern_sample = sample_noise(UV);
	ALBEDO = pattern_sample.v.xyz;
	
	vec2 d =
			vec2(pattern_sample.dx.w, pattern_sample.dy.w) *
			displacement * bumpiness;
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
