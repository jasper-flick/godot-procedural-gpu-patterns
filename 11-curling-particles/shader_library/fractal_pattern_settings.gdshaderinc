/*
Declares the FractalPatternSettings struct used by fractal_pattern.gdshaderinc.

The following settings are supported:
- pattern_seed: The pattern seed value, potentially used for hashing.
- base_frequency: Frequency of first octave (default 1.0 for all components).
- octaves: The amount of octaves (default 1).
- lacunarity: Frequency multiplier for successive octaves (default 2.0).
- persistence: Amplitude multiplier for successive octaves (default 0.5).
- pattern_animation: Whether the pattern animates.
- base_animation: Animation speed for first octave (default 1.0).
- temporal_lacunarity: Animation multiplier for succesive octaves (default 2.0).
- pattern_smoothness: An integer representing the smoothness of the pattern.
- pattern_tiling: Whether the pattern tiles.
- adaptive_fractal_scale: How to scale the total amplitude (default false):
  - true: Based on actual octaves.
  - false: Based on infinite octaves.

Define PATTERN_FREQUENCY_TYPE to set the type of base_frequency.
The default is float. Other options are float2, float3, float4.

Define PATTERN_ANIMATION_TYPE to set the type of
base_animation and temporal_lacunarity.
The default is float. Other options are float2, float3, float4.
It must either be float or match the frequency type.
For example, float for a uniform animation and vec2 for separate 2D frequencies.

Define USE_STANDARD_FRACTAL_PATTERN_SETTINGS to declare:
- Uniform variables for the default fractal pattern settings.
  Define USE_FRACTAL_PATTERN_ANIMATION_SETTINGS to also declare:
  - Uniform variables for fractal pattern animation.
  Define USE_FRACTAL_PATTERN_SMOOTNESS_SETTING to also declare:
  - Uniform int enum variable for the pattern smoothness.
    Define FRACTAL_PATTERN_SMOOTHNESS_ENUM to set the enum hint. The default is:
	"Step", "Linear", "Smooth", "Smoother"
  Define USE_FRACTAL_PATTERN_TILING_SETTING to also declare:
  - Uniform bool variable to toggle tiling.
Otherwise the default_fractal_pattern_settings function is declared.
*/

#ifndef PATTERN_FREQUENCY_TYPE
#define PATTERN_FREQUENCY_TYPE float
#endif

#ifndef PATTERN_ANIMATION_TYPE
#define PATTERN_ANIMATION_TYPE float
#endif

#ifndef FRACTAL_PATTERN_SMOOTHNESS_ENUM
#define FRACTAL_PATTERN_SMOOTHNESS_ENUM "Step", "Linear", "Smooth", "Smoother"
#endif

struct FractalPatternSettings {
	uint pattern_seed;
	PATTERN_FREQUENCY_TYPE base_frequency;
	int octaves;
	float lacunarity;
	float persistence;
	bool pattern_animation;
	PATTERN_ANIMATION_TYPE base_animation;
	PATTERN_ANIMATION_TYPE temporal_lacunarity;
	int pattern_smoothness;
	bool pattern_tiling;
	bool adaptive_fractal_scale;
};

#ifdef USE_STANDARD_FRACTAL_PATTERN_SETTINGS
uniform uint pattern_seed = 0u;
/**
Seamlessly tile pattern for UV from 0 to 1.
Tiling works for UV in between -1 and 2.
Requires integer frequencies for all octaves.
Requires even frequencies for animation.
*/
uniform PATTERN_FREQUENCY_TYPE base_frequency = PATTERN_FREQUENCY_TYPE(1.0);
uniform int octaves : hint_range(1, 10) = 1;
uniform float lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
#ifdef USE_FRACTAL_PATTERN_ANIMATION_SETTINGS
uniform bool pattern_animation = false;
uniform PATTERN_ANIMATION_TYPE base_animation = PATTERN_ANIMATION_TYPE(1.0);
uniform PATTERN_ANIMATION_TYPE temporal_lacunarity = PATTERN_ANIMATION_TYPE(2.0);
#endif
#ifdef USE_FRACTAL_PATTERN_SMOOTNESS_SETTING
uniform int pattern_smoothness : hint_enum(FRACTAL_PATTERN_SMOOTHNESS_ENUM) = 0;
#endif
#ifdef USE_FRACTAL_PATTERN_TILING_SETTING
uniform bool pattern_tiling = false;
#endif
uniform bool adaptive_fractal_scale = true;

FractalPatternSettings standard_fractal_pattern_settings() {
	return FractalPatternSettings(
			pattern_seed,
			base_frequency,
			octaves,
			lacunarity,
			persistence,
#ifdef USE_FRACTAL_PATTERN_ANIMATION_SETTINGS
			pattern_animation,
			base_animation,
			temporal_lacunarity,
#else
			false,
			PATTERN_ANIMATION_TYPE(1.0),
			PATTERN_ANIMATION_TYPE(2.0),
#endif
#ifdef USE_FRACTAL_PATTERN_SMOOTNESS_SETTING
			pattern_smoothness,
#else
			0,
#endif
#ifdef USE_FRACTAL_PATTERN_TILING_SETTING
			pattern_tiling,
#else
			false,
#endif
			adaptive_fractal_scale
	);
}
#else
FractalPatternSettings default_fractal_pattern_settings() {
	FractalPatternSettings settings = FractalPatternSettings(
			0u,
			PATTERN_FREQUENCY_TYPE(1.0),
			1,
			2.0,
			0.5,
			false,
			PATTERN_ANIMATION_TYPE(1.0),
			PATTERN_ANIMATION_TYPE(2.0),
			0,
			false,
			false
	);
	return settings;
}
#endif
