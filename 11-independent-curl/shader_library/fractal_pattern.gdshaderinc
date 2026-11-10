/*
Functions for fractal pattern sampling.

Typical use case is to only call sample_fractal.
It takes care of pattern sliding and applies curl if enabled.
Its parameters are:
- FractalPatternSettings for the fractal settings.
- SAMPLE_PATTERN_COORDINATES_TYPE for the sample coordinates.
- float for the time used for animation.

Define SAMPLE_PATTERN_FUNCTION to set the function for sampling an octave.
Only define the function name, without parameter list.
The matching function declaration must have three parameters:
- FractalPatternSettings for the pattern settings.
- int for the octave's index.
- PATTERN_DIMENSION_TYPE for the octave's sample frequency.
- PATTERN_DIMENSION_TYPE for the sample coordinates.
- float for the octave's animation offset.

Curl requires PATTERN_DIMENSIONS to be 2.
Curl is based on the first pattern sample's value component.

Define SAMPLE_CURL_FUNCTION for curl as for SAMPLE_PATTERN_FUNCTION.
By default it is the same as SAMPLE_PATTERN_FUNCTION.
*/
#include "fractal_pattern_settings.gdshaderinc"
#include "pattern_sample.gdshaderinc"

#ifndef SAMPLE_PATTERN_FUNCTION
#define SAMPLE_PATTERN_FUNCTION dummy_sample_pattern

PatternSample dummy_sample_pattern(
		FractalPatternSettings settings,
		int octave,
		PATTERN_DIMENSION_TYPE frequency,
		PATTERN_DIMENSION_TYPE coordinates,
		float animation_offset
) {
	return zero_pattern_sample();
}
#endif

#ifndef SAMPLE_CURL_FUNCTION
#define SAMPLE_CURL_FUNCTION SAMPLE_PATTERN_FUNCTION
#endif

PatternSample normalize_fractal_sample(
		FractalSettings settings,
		PatternSample s
) {
	float scale = 1.0 - settings.persistence;
	if (settings.adaptive_scale) {
		scale /= 1.0 - pow(settings.persistence, float(settings.octaves));
	}
	return multiply(s, scale);
}

PatternSample sample_fractal_pattern(
		FractalPatternSettings settings,
		PATTERN_DIMENSION_TYPE coordinates,
		float time
) {
	FractalSettings pattern = settings.main;
	PatternSample sum = zero_pattern_sample();
	PATTERN_DIMENSION_TYPE frequency = pattern.base_frequency;
	float animation_offset = pattern.base_animation * time;
	float amplitude = 1.0;
	for (int i = 0; i < pattern.octaves; i++) {
		PatternSample sample = SAMPLE_PATTERN_FUNCTION(
				settings, i, frequency, coordinates, animation_offset
		);
		sum = add(sum, multiply(sample, amplitude));
		frequency *= pattern.lacunarity;
		animation_offset *= pattern.temporal_lacunarity;
		amplitude *= pattern.persistence;
	}
	return normalize_fractal_sample(pattern, sum);
}

#ifdef USE_FRACTAL_PATTERN_CURL
PatternSample sample_fractal_curl(
		FractalPatternSettings settings,
		vec2 uv,
		float time
) {
	FractalSettings pattern = settings.main;
	PatternSample sum = zero_pattern_sample();
	PATTERN_DIMENSION_TYPE frequency = pattern.base_frequency;
	float animation_offset = pattern.base_animation * time;
	float amplitude = 1.0;
	for (int i = 0; i < pattern.octaves; i++) {
		PatternSample sample = SAMPLE_CURL_FUNCTION(
				settings, i, frequency, uv, animation_offset
		);
		sum = add(sum, multiply(sample, amplitude));
		frequency *= pattern.lacunarity;
		animation_offset *= pattern.temporal_lacunarity;
		amplitude *= pattern.persistence;
	}
	return normalize_fractal_sample(pattern, sum);
}

void sample_fractal_curl(
	FractalPatternSettings settings,
	vec2 uv,
	float time,
	out PatternSample u,
	out PatternSample v
) {
	settings.seed ^= 255u;
	settings.main = settings.curl;
	
	PatternSample s = sample_fractal_curl(settings, uv, time);
	float epsilon = 0.001;
	PatternSample sx = sample_fractal_curl(
			settings, uv + vec2(epsilon, 0.0), time
	);
	PatternSample sy = sample_fractal_curl(
			settings, uv + vec2(0.0, epsilon), time
	);
	
	float smoothness_normalization = 1.0;
	switch (settings.main.smoothness) {
		case 2:
			smoothness_normalization = 2.0 / 3.0;
			break;
		case 3:
			smoothness_normalization = 8.0 / 15.0;
			break;
	}
	vec2 scale = vec2(
			settings.curl_strength * smoothness_normalization / epsilon /
			settings.main.base_frequency
	);
	u = multiply(subtract(sy, s), scale.y);
	v = multiply(subtract(sx, s), -scale.x);
}

PatternSample sample_fractal_pattern_with_curl(
	FractalPatternSettings settings,
	vec2 uv,
	float time
) {
	PatternSample u, v;
	if (settings.curl_enabled) {
		sample_fractal_curl(settings, uv, time, u, v);
		u.v += uv.x;
		u.dx += 1.0;
		v.v += uv.y;
		v.dy += 1.0;
		
		#if PATTERN_SAMPLE_DIMENSIONS == 1
		uv = vec2(u.v, v.v);
		#else
		uv = vec2(u.v.x, v.v.x);
		#endif
		if (settings.tiling) {
			uv = fract(uv);
		}
	}
	PatternSample s = sample_fractal_pattern(settings, uv, TIME);
	if (settings.curl_enabled) {
		PATTERN_SAMPLE_VALUE_TYPE dx = s.dx;
		s.dx = u.dx * dx + v.dx * s.dy;
		s.dy = u.dy * dx + v.dy * s.dy;
	}
	return s;
}
#endif

PatternSample sample_fractal(
	FractalPatternSettings settings,
	PATTERN_DIMENSION_TYPE coordinates,
	float time
) {
	if (settings.sliding) {
		coordinates += settings.slide_velocity * time;
		if (settings.tiling) {
			coordinates = fract(coordinates);
		}
	}
	#ifdef USE_FRACTAL_PATTERN_CURL
	return sample_fractal_pattern_with_curl(settings, coordinates, time);
	#else
	return sample_fractal_pattern(settings, coordinates, time);
	#endif
}
