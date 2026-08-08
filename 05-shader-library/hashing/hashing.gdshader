shader_type spatial;

uniform uint hash_seed = 0u;
uniform int visualization : hint_enum("Grayscale", "RG", "RGB") = 0;

#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"

#define PATTERN_SAMPLE_VALUE_TYPE vec3
#include "res://shader_library/pattern_sample.gdshaderinc"
#include "res://shader_library/hasher.gdshaderinc"

PatternSample sample_hash(int octave, float frequency, vec2 uv) {
	vec2 coordinates = floor(frequency * uv);
	Hasher h = hasher(hash_seed + uint(octave));
	h = hasher(h, coordinates.x);
	h = hasher(h, coordinates.y);
	uint hash = hash(h);
	switch (visualization) {
		case 0: // Grayscale
			return PatternSample(vec3(hash_to_float(hash)));
		case 1: // RG
			return PatternSample(vec3(hash_to_vec2(hash), 0.0));
		case 2: // RGB
			return PatternSample(hash_to_vec3(hash));
	}
}

#define SAMPLE_PATTERN_FUNCTION sample_hash
#include "res://shader_library/fractal_pattern.gdshaderinc"

void fragment() {
	ALBEDO = sample_fractal_pattern(
			standard_fractal_pattern_settings(),
			UV - 0.5
	).v;
}
