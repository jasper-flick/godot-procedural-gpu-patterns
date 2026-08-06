shader_type spatial;

uniform uint hash_seed = 0u;
uniform int visualization : hint_enum("Grayscale", "RG", "RGB") = 0;
uniform float base_frequency = 1.0;
uniform int octaves : hint_range(1, 10) = 1;
uniform float lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform bool adaptive_fractal_scale = false;

struct PatternSample {
	vec3 v;
};

PatternSample zero_pattern_sample() {
	return PatternSample(vec3(0.0));
}

PatternSample add(PatternSample a, PatternSample b) {
	return PatternSample(a.v + b.v);
}

PatternSample multiply(PatternSample a, float b) {
	return PatternSample(a.v * b);
}

#include "res://shader_library/hasher.gdshaderinc"

PatternSample sample_pattern(float frequency, vec2 uv) {
	vec2 coordinates = floor(frequency * uv);
	Hasher h = hasher(hash_seed);
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

#define PATTERN_SAMPLE PatternSample
#define PATTERN_FREQUENCY_TYPE float
#define SAMPLE_PATTERN_FUNCTION sample_pattern
#include "res://shader_library/fractal_pattern.gdshaderinc"

FractalPatternSettings get_fractal_pattern_settings() {
	return FractalPatternSettings(
			base_frequency,
			octaves,
			lacunarity,
			persistence,
			adaptive_fractal_scale
	);
}

void fragment() {
	ALBEDO = sample_fractal_pattern(
			get_fractal_pattern_settings(),
			UV - 0.5
	).v;
}
