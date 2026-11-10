shader_type spatial;

uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;

uniform int function : hint_enum("U", "V", "UV Average", "UV Product") = 0;
uniform bool colors_per_vertex = false;
uniform bool derivatives_per_vertex = false;
uniform bool vertex_displacement = true;

#define USE_FRACTAL_PATTERN_CURL
#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"

varying vec2 derivatives;

vec3 colorize(float v) {
	if (abs(v) > 1.0) {
		return vec3(1.0, 0.0, 1.0);
	}
	if (v >= 0.0) {
		return vec3(v);
	}
	else {
		return vec3(0.0, -v, 0.0);
	}
}

#include "res://shader_library/pattern_sample.gdshaderinc"

PatternSample sample_pattern(
		FractalPatternSettings settings,
		int octave,
		vec2 frequency,
		vec2 uv,
		float time
) {
	if (settings.sliding) {
		uv += settings.slide_velocity * time;
	}
	vec2 f = frequency * TAU;
	vec2 t = f * uv;
	PatternSample s;
	switch (function) {
		case 0: // U
			s.v = sin(t.x);
			s.dx = f.x * cos(t.x);
			s.dy = 0.0;
			break;
		case 1: // V
			s.v = sin(t.y);
			s.dx = 0.0;
			s.dy = f.y * cos(t.y);
			break;
		case 2: // UV Average
			s.v = (sin(t.x) + sin(t.y)) * 0.5;
			s.dx = f.x * cos(t.x) * 0.5;
			s.dy = f.y * cos(t.y) * 0.5;
			break;
		case 3: // UV Product
			s.v = sin(t.x) * sin(t.y);
			s.dx = f.x * cos(t.x) * sin(t.y);
			s.dy = f.y * sin(t.x) * cos(t.y);
			break;
	}
	return s;
}

#define SAMPLE_PATTERN_FUNCTION sample_pattern
#include "res://shader_library/square_blended_value_noise.gdshaderinc"
#define SAMPLE_CURL_FUNCTION sample_square_blended_value_noise
#include "res://shader_library/fractal_pattern.gdshaderinc"

PatternSample sample_waves(vec2 uv) {
	return sample_fractal(standard_fractal_pattern_settings(), uv, TIME);
}

void vertex() {
	PatternSample pattern_sample = sample_waves(UV);
	if (colors_per_vertex) {
		COLOR.rgb = colorize(pattern_sample.v);
	}
	if (vertex_displacement) {
		VERTEX += NORMAL * (pattern_sample.v * displacement);
	}
	if (derivatives_per_vertex) {
		derivatives =
				vec2(pattern_sample.dx, pattern_sample.dy) *
				displacement * bumpiness;
	}
}

void fragment() {
	PatternSample pattern_sample = sample_waves(UV);
	if (colors_per_vertex) {
		ALBEDO = COLOR.rgb;
	}
	else {
		ALBEDO = colorize(pattern_sample.v);
	}
	vec2 d;
	if (derivatives_per_vertex) {
		d = derivatives;
	}
	else {
		d =
				vec2(pattern_sample.dx, pattern_sample.dy) *
				displacement * bumpiness;
	}
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
