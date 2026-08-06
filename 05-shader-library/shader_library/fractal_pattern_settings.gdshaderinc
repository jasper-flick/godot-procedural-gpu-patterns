/*
Declares the FractalPatternSettings struct used by fractal_pattern.gdshaderinc.

Define PATTERN_FREQUENCY_TYPE to set the type of the base frequency.
The default is float. Other options are float2, float3, float4.

Define USE_STANDARD_FRACTAL_PATTERN_SETTINGS to declare:
- Uniform variables for all fractal pattern settings.
- The standard_fractal_pattern_settings() function to grab these settings.
*/

#ifndef PATTERN_FREQUENCY_TYPE
#define PATTERN_FREQUENCY_TYPE float
#endif

struct FractalPatternSettings {
	PATTERN_FREQUENCY_TYPE base_frequency;
	int octaves;
	float lacunarity;
	float persistence;
	bool adaptive_fractal_scale;
};

#ifdef USE_STANDARD_FRACTAL_PATTERN_SETTINGS
uniform PATTERN_FREQUENCY_TYPE base_frequency = PATTERN_FREQUENCY_TYPE(1.0);
uniform int octaves : hint_range(1, 10) = 1;
uniform float lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform bool adaptive_fractal_scale = false;

FractalPatternSettings standard_fractal_pattern_settings() {
	return FractalPatternSettings(
			base_frequency,
			octaves,
			lacunarity,
			persistence,
			adaptive_fractal_scale
	);
}
#endif
