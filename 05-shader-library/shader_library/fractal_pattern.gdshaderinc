/*
Declares the sample_fractal_pattern function and whatever else it needs.
Its parameters are:
	FractalPatternSettings containing the fractal settings,
	SAMPLE_PATTERN_COORDINATES_TYPE for the sample coordinates.

Include fractal_pattern_settings and pattern_sample first.

Define SAMPLE_PATTERN_COORDINATES_TYPE to set the sample coordinates type.
The default is vec2. Other options are float, vec3, vec4.

Define SAMPLE_PATTERN_FUNCTION to set the function used for a single sample.
Only define the function name.
The matching function declaration must have two parameters:
	PATTERN_FREQUENCY_TYPE for the sample frequency,
	SAMPLE_PATTERN_COORDINATES_TYPE for the sample coordinates.
Note that these parameter types can be different.
For example, float for a uniform frequency and vec2 for 2D sample coordinates.
*/

#include "fractal_pattern_settings.gdshaderinc"
#include "pattern_sample.gdshaderinc"

#ifndef SAMPLE_PATTERN_COORDINATES_TYPE
#define SAMPLE_PATTERN_COORDINATES_TYPE vec2
#endif

#ifndef SAMPLE_PATTERN_FUNCTION
#define SAMPLE_PATTERN_FUNCTION dummy_sample_pattern

PatternSample dummy_sample_pattern(
		PATTERN_FREQUENCY_TYPE frequency,
		SAMPLE_PATTERN_COORDINATES_TYPE coordinates
) {
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

PatternSample sample_fractal_pattern(
		FractalPatternSettings settings,
		SAMPLE_PATTERN_COORDINATES_TYPE coordinates
) {
	PatternSample sum = zero_pattern_sample();
	PATTERN_FREQUENCY_TYPE frequency = settings.base_frequency;
	float amplitude = 1.0;
	for (int i = 0; i < settings.octaves; i++) {
		sum = add(sum, multiply(
				SAMPLE_PATTERN_FUNCTION(frequency, coordinates), amplitude));
		frequency *= settings.lacunarity;
		amplitude *= settings.persistence;
	}
	return normalize_fractal_sample(settings, sum);
}
