/*
Declares the FractalPatternSettings struct used by fractal_pattern.gdshaderinc.

The following settings are supported:
- base_frequency: Frequency of first octave (default 1.0 for all components).
- octaves: The amount of octaves (default 1).
- lacunarity: Frequency multiplier for successive octaves (default 2.0).
- persistence: Amplitude multiplier for successive octaves (default 0.5).
- adaptive_fractal_scale: How to scale the total amplitude (default false):
  - true: Based on actual octaves.
  - false: Based on infinite octaves.

Define PATTERN_FREQUENCY_TYPE to set the type of base_frequency.
The default is float. Other options are float2, float3, float4.

Define PATTERN_ANIMATION_TYPE to set the type of base_velocity.
The default is float. Other options are float2, float3, float4.
Note that the animation and frequency can have different types.
Animation must either be float or match the frequency type.
For example, float for a uniform animation and vec2 for separate 2D frequencies.

Define USE_STANDARD_FRACTAL_PATTERN_SETTINGS to declare:
- Uniform variables for the default fractal pattern settings.
  Define USE_PATTERN_ANIMATION_SETTINGS to also declare:
  - Uniform variables for fractal pattern animation.
- The standard_fractal_pattern_settings function to grab these settings.
Otherwise the default_fractal_pattern_settings function is declared.
*/

#ifndef PATTERN_FREQUENCY_TYPE
#define PATTERN_FREQUENCY_TYPE float
#endif

#ifndef PATTERN_ANIMATION_TYPE
#define PATTERN_ANIMATION_TYPE float
#endif

struct FractalPatternSettings {
	PATTERN_FREQUENCY_TYPE base_frequency;
	int octaves;
	float lacunarity;
	float persistence;
	bool adaptive_fractal_scale;
	PATTERN_ANIMATION_TYPE base_animation;
	PATTERN_ANIMATION_TYPE temporal_lacunarity;
};

#ifdef USE_STANDARD_FRACTAL_PATTERN_SETTINGS
uniform PATTERN_FREQUENCY_TYPE base_frequency = PATTERN_FREQUENCY_TYPE(1.0);
uniform int octaves : hint_range(1, 10) = 1;
uniform float lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform bool adaptive_fractal_scale = false;

#ifdef USE_PATTERN_ANIMATION_SETTINGS
uniform PATTERN_ANIMATION_TYPE base_animation = PATTERN_ANIMATION_TYPE(1.0);
uniform PATTERN_ANIMATION_TYPE temporal_lacunarity = PATTERN_ANIMATION_TYPE(2.0);
#endif

FractalPatternSettings standard_fractal_pattern_settings() {
	return FractalPatternSettings(
			base_frequency,
			octaves,
			lacunarity,
			persistence,
			adaptive_fractal_scale
#ifdef USE_PATTERN_ANIMATION_SETTINGS
			, base_animation
			, temporal_lacunarity
#else
			, PATTERN_ANIMATION_TYPE(1.0)
			, PATTERN_ANIMATION_TYPE(1.0)
#endif
	);
}
#else
FractalPatternSettings default_fractal_pattern_settings() {
	FractalPatternSettings settings = FractalPatternSettings(
			PATTERN_FREQUENCY_TYPE(1.0),
			1,
			2.0,
			0.5,
			false,
			PATTERN_ANIMATION_TYPE(1.0),
			PATTERN_ANIMATION_TYPE(1.0)
	);
	return settings;
}
#endif
