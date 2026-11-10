/*
Settings for generating fractal patterns.

FractalPatternSettings struct has the following settings:
- seed: The seed value, potentially used for hashing (default 0).
- tiling: Whether the whole pattern tiles (default false).
- animation: Whether the  whole pattern animates (default false).
- sliding: Whether the whole pattern slides (default false).
- slide_velocity: How fast the pattern slides (default 1.0).
- curl_enabled: Whether the main pattern is curled (default false).
- curl_strength: How much curl is applied (default 0.0).
- main: FractalSettings for the main pattern.
- curl: FractalSettings for the curl pattern.

The FractalSettings struct has the following settings:
- base_frequency: Frequency of first octave (default 1.0).
- octaves: The amount of octaves (default 1).
- lacunarity: Frequency multiplier for successive octaves (default 2.0).
- persistence: Amplitude multiplier for successive octaves (default 0.5).
- base_animation: Animation speed for first octave (default 1.0).
- temporal_lacunarity: Animation multiplier for succesive octaves (default 2.0).
- smoothness: An integer representing the smoothness of the pattern.
- adaptive_scale: How to scale the total amplitude (default false):
  - true: Based on actual octaves.
  - false: Based on infinite octaves.

Define PATTERN_DIMENSIONS to set the amount of dimenions of the pattern.
Allowed values are 2 and 3. The default is 2.
The corresponding coordinate and frequency types are vec2 and vec3.

Define USE_FRACTAL_PATTERN_CURL to indicate that curl is supported.
Curl requires PATTERN_DIMENSIONS to be 2.

Define USE_STANDARD_FRACTAL_PATTERN_SETTINGS for:
- Uniform variables to configure the fractal pattern.
- The standard_fractal_pattern_settings function to get the matching settings.
*/
#ifndef PATTERN_DIMENSIONS
#define PATTERN_DIMENSIONS 2
#endif

#if PATTERN_DIMENSIONS == 2
#define PATTERN_DIMENSION_TYPE vec2
#else
#define PATTERN_DIMENSION_TYPE vec3
#endif

struct FractalSettings {
	PATTERN_DIMENSION_TYPE base_frequency;
	int octaves;
	float lacunarity;
	float persistence;
	float base_animation;
	float temporal_lacunarity;
	int smoothness;
	bool adaptive_scale;
};

struct FractalPatternSettings {
	uint seed;
	bool tiling;
	bool animation;
	bool sliding;
	PATTERN_DIMENSION_TYPE slide_velocity;
	bool curl_enabled;
	float curl_strength;
	FractalSettings main;
	FractalSettings curl;
};

FractalPatternSettings default_fractal_pattern_settings() {
	FractalPatternSettings s;
	s.seed = 0u;
	s.tiling = false;
	s.animation = false;
	s.sliding = false;
	s.slide_velocity = PATTERN_DIMENSION_TYPE(1.0);
	s.curl_enabled = false;
	s.curl_strength = 0.0;
	
	s.main.base_frequency = PATTERN_DIMENSION_TYPE(1.0);
	s.main.octaves = 1;
	s.main.lacunarity = 2.0;
	s.main.persistence = 0.5;
	s.main.base_animation = 1.0;
	s.main.temporal_lacunarity = 2.0;
	s.main.smoothness = 0;
	s.main.adaptive_scale = true;
	
	s.curl = s.main;
	return s;
}

#ifdef USE_STANDARD_FRACTAL_PATTERN_SETTINGS
group_uniforms Fractal;
uniform uint fractal_seed = 0u;
uniform bool fractal_tiling = false;
uniform bool fractal_animation = false;
uniform bool fractal_sliding = false;
uniform PATTERN_DIMENSION_TYPE fractal_slide_velocity =
		PATTERN_DIMENSION_TYPE(1.0);

#ifdef USE_FRACTAL_PATTERN_CURL
uniform bool fractal_curl = false;
uniform float fractal_curl_strength : hint_range(-1.0, 1.0) = 0.0;
#endif

group_uniforms Fractal.Pattern;
uniform PATTERN_DIMENSION_TYPE pattern_frequency = PATTERN_DIMENSION_TYPE(1.0);
uniform int pattern_octaves : hint_range(1, 10) = 1;
uniform float pattern_lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float pattern_persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform float pattern_base_animation = 1.0;
uniform float pattern_temporal_lacunarity = 2.0;

uniform int pattern_smoothness :
		hint_enum("Step", "Linear", "Smooth", "Smoother") = 0;
uniform bool pattern_adaptive_scale = true;

#ifdef USE_FRACTAL_PATTERN_CURL
group_uniforms Fractal.Curl;
uniform PATTERN_DIMENSION_TYPE curl_frequency = PATTERN_DIMENSION_TYPE(1.0);
uniform int curl_octaves : hint_range(1, 3) = 1;
uniform float curl_lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float curl_persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform float curl_base_animation = 1.0;
uniform float curl_temporal_lacunarity = 2.0;

uniform int curl_smoothness :
		hint_enum("Step", "Linear", "Smooth", "Smoother") = 0;
uniform bool curl_adaptive_scale = true;
#endif

FractalPatternSettings standard_fractal_pattern_settings() {
	FractalPatternSettings s = default_fractal_pattern_settings();
	s.seed = fractal_seed;
	s.tiling = fractal_tiling;
	s.animation = fractal_animation;
	s.sliding = fractal_sliding;
	s.slide_velocity = fractal_slide_velocity;
	
	s.main.base_frequency = pattern_frequency;
	s.main.octaves = pattern_octaves;
	s.main.lacunarity = pattern_lacunarity;
	s.main.persistence = pattern_persistence;
	s.main.base_animation = pattern_base_animation;
	s.main.temporal_lacunarity = pattern_temporal_lacunarity;
	s.main.smoothness = pattern_smoothness;
	s.main.adaptive_scale = pattern_adaptive_scale;

#ifdef USE_FRACTAL_PATTERN_CURL
	s.curl_enabled = fractal_curl;
	s.curl_strength = fractal_curl_strength;
	s.curl.base_frequency = curl_frequency;
	s.curl.octaves = curl_octaves;
	s.curl.lacunarity = curl_lacunarity;
	s.curl.persistence = curl_persistence;
	s.curl.base_animation = curl_base_animation;
	s.curl.temporal_lacunarity = curl_temporal_lacunarity;
	s.curl.smoothness = curl_smoothness;
	s.curl.adaptive_scale = curl_adaptive_scale;
#endif
	return s;
}
#endif
