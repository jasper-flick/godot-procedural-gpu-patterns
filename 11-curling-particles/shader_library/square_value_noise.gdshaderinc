#define PATTERN_FREQUENCY_TYPE vec2
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"
#include "res://shader_library/pattern_sample.gdshaderinc"
#include "res://shader_library/lattice_hasing.gdshaderinc"

PatternSample value_sample(Hasher h, float time, bool use_animation) {
	PatternSample sample = zero_pattern_sample();
	sample.v = animated_hash_to_float(h, time, use_animation);
	return sample;
}

PatternSample sample_square_value_noise(
		FractalPatternSettings settings,
		int octave,
		vec2 frequency,
		vec2 uv,
		float time
) {
	LatticeSquare square = get_lattice_square(
			settings.pattern_seed + uint(octave),
			uv, frequency, time, settings.pattern_tiling
	);
	PatternSample s = blend_square(
			value_sample(square.h00, square.time_a, settings.pattern_animation),
			value_sample(square.h10, square.time_b, settings.pattern_animation),
			value_sample(square.h01, square.time_b, settings.pattern_animation),
			value_sample(square.h11, square.time_a, settings.pattern_animation),
			square.uv,
			settings.pattern_smoothness
	);
	return scale_derivatives(s, frequency);
}
