/*
Declares the sample_fractal_pattern function and whatever else it needs.
Its parameters are:
- FractalPatternSettings for the fractal settings.
- SAMPLE_PATTERN_COORDINATES_TYPE for the sample coordinates.
- float for the time used for animation.

Include fractal_pattern_settings and pattern_sample first.

Define SAMPLE_PATTERN_COORDINATES_TYPE to set the sample coordinates type.
The default is vec2. Other options are float, vec3, vec4.

Define SAMPLE_PATTERN_FUNCTION to set the function for sampling an octave.
Only define the function name, without parameter list.
The matching function declaration must have three parameters:
- int for the octave's index.
- PATTERN_FREQUENCY_TYPE for the octave's sample frequency.
- SAMPLE_PATTERN_COORDINATES_TYPE for the sample coordinates.
- PATTERN_ANIMATION_TYPE for the octave's animation offset.
Frequency must either be float or match the coordinates type.
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
		int octave,
		PATTERN_FREQUENCY_TYPE frequency,
		SAMPLE_PATTERN_COORDINATES_TYPE coordinates,
		PATTERN_ANIMATION_TYPE animation_offset
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
		SAMPLE_PATTERN_COORDINATES_TYPE coordinates,
		float time
) {
	PatternSample sum = zero_pattern_sample();
	PATTERN_FREQUENCY_TYPE frequency = settings.base_frequency;
	PATTERN_ANIMATION_TYPE animation_offset = settings.base_animation * time;
	float amplitude = 1.0;
	for (int i = 0; i < settings.octaves; i++) {
		PatternSample sample = SAMPLE_PATTERN_FUNCTION(
				i, frequency, coordinates, animation_offset
		);
		sum = add(sum, multiply(sample, amplitude));
		frequency *= settings.lacunarity;
		animation_offset *= settings.temporal_lacunarity;
		amplitude *= settings.persistence;
	}
	return normalize_fractal_sample(settings, sum);
}
