#include "fractal_pattern_settings.gdshaderinc"
#include "pattern_sample.gdshaderinc"

#ifndef SAMPLE_PATTERN_FUNCTION
#define SAMPLE_PATTERN_FUNCTION dummy_sample_pattern

PatternSample dummy_sample_pattern(PATTERN_FREQUENCY_TYPE frequency, vec2 uv) {
	return zero_pattern_sample();
}
#endif

PatternSample normalize_fractal_sample(
		FractalPatternSettings settings,
		PatternSample s
) {
	float scale = 1.0 - settings.persistence;
	if (settings.adaptive_fractal_scale) {
		scale /= 1.0 - pow(settings.persistence, float(settings.octaves));
	}
	return multiply(s, scale);
}

PatternSample sample_fractal_pattern(FractalPatternSettings settings, vec2 uv) {
	PatternSample sum = zero_pattern_sample();
	PATTERN_FREQUENCY_TYPE frequency = settings.base_frequency;
	float amplitude = 1.0;
	for (int i = 0; i < settings.octaves; i++) {
		sum = add(sum, multiply(
				SAMPLE_PATTERN_FUNCTION(frequency, uv), amplitude));
		frequency *= settings.lacunarity;
		amplitude *= settings.persistence;
	}
	return normalize_fractal_sample(settings, sum);
}
