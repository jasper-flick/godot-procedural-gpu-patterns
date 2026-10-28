#include "res://shader_library/fractal_pattern.gdshaderinc"

void sample_fractal_curl(
	FractalPatternSettings settings,
	vec2 uv,
	float time,
	out PatternSample u,
	out PatternSample v
) {
	settings.pattern_seed ^= 255u;
	settings.base_frequency = settings.curl_frequency;
	settings.octaves = settings.curl_octaves;
	settings.base_animation = PATTERN_ANIMATION_TYPE(settings.curl_animation);
	PatternSample s = sample_fractal_pattern(settings, uv, time);
	float epsilon = 0.001;
	PatternSample sx = sample_fractal_pattern(
			settings, uv + vec2(epsilon, 0.0), time
	);
	PatternSample sy = sample_fractal_pattern(
			settings, uv + vec2(0.0, epsilon), time
	);
	
	float smoothness_normalization = 1.0;
	switch (settings.pattern_smoothness) {
		case 2:
			smoothness_normalization = 2.0 / 3.0;
			break;
		case 3:
			smoothness_normalization = 8.0 / 15.0;
			break;
	}
	vec2 scale = vec2(
			settings.curl_strength * smoothness_normalization / epsilon /
			settings.base_frequency
	);
	u = multiply(subtract(sy, s), scale.y);
	v = multiply(subtract(sx, s), -scale.x);
}
