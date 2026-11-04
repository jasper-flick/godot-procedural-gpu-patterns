shader_type spatial;

uniform int visualization : hint_enum("Grayscale", "RG", "RGB") = 0;
uniform bool staggered_animation = true;

#define USE_FRACTAL_PATTERN_CURL
#define PATTERN_SAMPLE_DIMENSIONS 3
#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"
#include "res://shader_library/pattern_sample.gdshaderinc"
#include "res://shader_library/hasher.gdshaderinc"

PatternSample sample_hash(
		FractalPatternSettings settings,
		int octave,
		vec2 frequency,
		vec2 uv,
		float time
) {
	vec2 coordinates = floor(frequency * uv);
	Hasher h = hasher(settings.seed + uint(octave));
	h = hasher(h, coordinates.x);
	h = hasher(h, coordinates.y);
	if (settings.animation) {
		if (staggered_animation) {
			time += fract((coordinates.x + coordinates.y) * 0.5);
		}
		h = hasher(h, floor(time));
	}
	uint hash = hash(h);
	PatternSample s = zero_pattern_sample();
	switch (visualization) {
		case 0: // Grayscale
			s.v = vec3(hash_to_float(hash));
			break;
		case 1: // RG
			s.v = vec3(hash_to_vec2(hash), 0.0);
			break;
		case 2: // RGB
			s.v = hash_to_vec3(hash);
			break;
	}
	return s;
}

#define SAMPLE_PATTERN_FUNCTION sample_hash
#include "res://shader_library/square_value_noise.gdshaderinc"
#define SAMPLE_CURL_FUNCTION sample_square_value_noise
#include "res://shader_library/fractal_pattern.gdshaderinc"

void fragment() {
	ALBEDO = sample_fractal(
			standard_fractal_pattern_settings(),
			UV - 0.5,
			TIME
	).v;
}
