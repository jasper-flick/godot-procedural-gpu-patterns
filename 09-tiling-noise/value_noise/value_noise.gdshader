shader_type spatial;

uniform uint hash_seed = 0u;

/**
Seamlessly tile pattern for UV from 0 to 1.
Requires integer frequencies for all octaves.
Use even frequencies for best animation.
*/
uniform bool tiling = false;
uniform bool animation = true;
uniform bool colored = true;
uniform vec3 color_min : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_mid : source_color = vec3(0.0);
uniform vec3 color_max : source_color = vec3(1.0);
uniform int smoothness : hint_enum("Step", "Linear", "Smooth", "Smoother") = 3;
uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform bool vertex_displacement = true;

#define PATTERN_FREQUENCY_TYPE vec2
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

PatternSample value_sample(Hasher h, float time) {
	PatternSample sample = zero_pattern_sample();
	sample.v = animated_hash_to_float(h, time);
	return sample;
}

vec2 lattice01(float lattice_coordinate, float frequency) {
	float l0 = lattice_coordinate;
	if (tiling) {
		if (l0 < 0.0) {
			l0 += frequency;
		}
		else if (l0 >= frequency) {
			l0 -= frequency;
		}
	}
	float l1 = l0 + 1.0;
	if (tiling && l1 >= frequency) {
		l1 -= frequency;
	}
	return vec2(l0, l1);
}

PatternSample sample_value_noise(
		int octave,
		vec2 frequency,
		vec2 uv,
		float time
) {
	vec2 sample_coordinates = frequency * uv;
	vec2 lattice_coordinates = floor(sample_coordinates);
	vec2 fractional_coordinates = sample_coordinates - lattice_coordinates;
	
	vec2 uLattice = lattice01(lattice_coordinates.x, frequency.x);
	vec2 vLattice = lattice01(lattice_coordinates.y, frequency.y);
	
	Hasher h = hasher(hash_seed + uint(octave));
	Hasher h0 = hasher(h, uLattice.x);
	Hasher h1 = hasher(h, uLattice.y);
	Hasher h00 = hasher(h0, vLattice.x);
	Hasher h10 = hasher(h1, vLattice.x);
	Hasher h01 = hasher(h0, vLattice.y);
	Hasher h11 = hasher(h1, vLattice.y);
	float time_stagger = fract(
			(lattice_coordinates.x + lattice_coordinates.y) * 0.5
	);
	float timeA = time + time_stagger;
	float timeB = time + (0.5 - time_stagger);
	PatternSample v00 = value_sample(h00, timeA);
	PatternSample v10 = value_sample(h10, timeB);
	PatternSample v01 = value_sample(h01, timeB);
	PatternSample v11 = value_sample(h11, timeA);
	
	vec2 t = fractional_coordinates;
	PatternSample tx = zero_pattern_sample();
	tx.v = t.x;
	tx.dx = 1.0;
	tx = smooth01(tx, smoothness);
	PatternSample ty = zero_pattern_sample();
	ty.v = t.y;
	ty.dy = 1.0;
	ty = smooth01(ty, smoothness);
	PatternSample s = blend(
			blend(v00, v10, tx),
			blend(v01, v11, tx),
			ty
	);
	s.dx *= frequency.x;
	s.dy *= frequency.y;
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

PatternSample sample_noise(vec2 uv) {
	return sample_fractal_pattern(
			standard_fractal_pattern_settings(),
			uv,
			TIME
	);
}

void vertex() {
	if (vertex_displacement) {
		PatternSample pattern_sample = sample_noise(UV);
		VERTEX += NORMAL * (pattern_sample.v * displacement);
	}
}

void fragment() {
	PatternSample pattern_sample = sample_noise(UV);
	ALBEDO = colorize(pattern_sample.v);
	
	vec2 d =
			vec2(pattern_sample.dx, pattern_sample.dy) *
			displacement * bumpiness;
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
