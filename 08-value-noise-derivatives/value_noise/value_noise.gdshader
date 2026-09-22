shader_type spatial;

uniform uint hash_seed = 0u;
uniform bool animation = true;
uniform bool colored = true;
uniform vec3 color_min : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_mid : source_color = vec3(0.0);
uniform vec3 color_max : source_color = vec3(1.0);
uniform float bumpiness = 1.0;
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;

#define USE_STANDARD_FRACTAL_PATTERN_SETTINGS
#define USE_FRACTAL_PATTERN_ANIMATION_SETTINGS
#include "res://shader_library/fractal_pattern_settings.gdshaderinc"

#include "res://shader_library/pattern_sample.gdshaderinc"
#include "res://shader_library/hasher.gdshaderinc"

float animated_hash_to_float(Hasher h, float t) {
	if (animation) {
		float t0 = floor(t);
		float t1 = t0 + 1.0;
		float v0 = hash_to_float(hash(hasher(h, t0)));
		float v1 = hash_to_float(hash(hasher(h, t1)));
		return mix(v0, v1, smoothstep(0.0, 1.0, t - t0));
	}
	else {
		return hash_to_float((hash(h)));
	}
}

PatternSample blend(PatternSample a, PatternSample b, PatternSample t) {
	PatternSample sample = zero_pattern_sample();
	sample.v = mix(a.v, b.v, t.v);
	return sample;
}

PatternSample value_sample(Hasher h, float time) {
	PatternSample sample = zero_pattern_sample();
	sample.v = animated_hash_to_float(h, time);
	return sample;
}

PatternSample sample_value_noise(
		int octave,
		float frequency,
		vec2 uv,
		float time
) {
	vec2 sample_coordinates = frequency * uv;
	vec2 lattice_coordinates = floor(sample_coordinates);
	vec2 fractional_coordinates = sample_coordinates - lattice_coordinates;
	Hasher h = hasher(hash_seed + uint(octave));
	Hasher h0 = hasher(h, lattice_coordinates.x);
	Hasher h1 = hasher(h, lattice_coordinates.x + 1.0);
	Hasher h00 = hasher(h0, lattice_coordinates.y);
	Hasher h10 = hasher(h1, lattice_coordinates.y);
	Hasher h01 = hasher(h0, lattice_coordinates.y + 1.0);
	Hasher h11 = hasher(h1, lattice_coordinates.y + 1.0);
	float time_stagger = fract(
			(lattice_coordinates.x + lattice_coordinates.y) * 0.5
	);
	float timeA = time + time_stagger;
	float timeB = time + (0.5 - time_stagger);
	PatternSample v00 = value_sample(h00, timeA);
	PatternSample v10 = value_sample(h10, timeB);
	PatternSample v01 = value_sample(h01, timeB);
	PatternSample v11 = value_sample(h11, timeA);
	//PatternSample s = zero_pattern_sample();
	vec2 t = smoothstep(0.0, 1.0, fractional_coordinates);
	PatternSample tx = zero_pattern_sample();
	tx.v = t.x;
	PatternSample ty = zero_pattern_sample();
	ty.v = t.y;
	PatternSample s = blend(
			blend(v00, v10, tx),
			blend(v01, v11, tx),
			ty
	);
	return s;
}

#define SAMPLE_PATTERN_FUNCTION sample_value_noise
#include "res://shader_library/fractal_pattern.gdshaderinc"

vec3 colorize(float v) {
	if (colored) {
		v *= 2.0;
		if (v > 1.0) {
			return mix(color_mid, color_max, v - 1.0);
		}
		else {
			return mix(color_min, color_mid, v);
		}
	}
	else {
		return vec3(v);
	}
}

void fragment() {
	PatternSample pattern_sample = sample_fractal_pattern(
			standard_fractal_pattern_settings(),
			UV - 0.5,
			TIME
	);
	ALBEDO = colorize(pattern_sample.v);
	
	vec2 d =
			vec2(pattern_sample.dx, pattern_sample.dy) *
			displacement * bumpiness;
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
