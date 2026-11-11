/*
Square value noise sampling function.
2D noise made by blending hashes across a square lattice grid.

Requires PATTERN_DIMENSIONS to be 2.
*/
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"
#include "res://shader_library/lattice_hasing.gdshaderinc"
#include "res://shader_library/pattern_sample.gdshaderinc"

PatternSample value_sample(Hasher h, float time, bool use_animation) {
	return hasher_to_value_sample(h, time, use_animation);
}

PatternSample sample_square_blended_value_noise(
		FractalPatternSettings settings,
		int octave,
		vec2 frequency,
		vec2 uv,
		float time
) {
	LatticeSquare square = get_lattice_square(
			settings.seed + uint(octave), uv, frequency, time, settings.tiling
	);
	PatternSample s = blend_square(
			value_sample(square.h00, square.time_a, settings.animating),
			value_sample(square.h10, square.time_b, settings.animating),
			value_sample(square.h01, square.time_b, settings.animating),
			value_sample(square.h11, square.time_a, settings.animating),
			square.uv,
			settings.main.smoothness
	);
	return scale_derivatives(s, frequency);
}
