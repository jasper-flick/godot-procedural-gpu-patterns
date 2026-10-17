shader_type spatial;

/**
Seamlessly tile pattern for UV from 0 to 1.
Tiling works for UV in between -1 and 2.
Requires integer frequencies for all octaves.
Requires even frequencies for animation.
*/
uniform bool tiling = false;
uniform bool animation = true;
uniform vec2 slide_velocity = vec2(0.0, 0.0);
uniform bool colored = true;
uniform vec3 color_min : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 color_mid : source_color = vec3(0.0);
uniform vec3 color_max : source_color = vec3(1.0);
uniform int smoothness : hint_enum("Step", "Linear", "Smooth", "Smoother") = 3;
uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform bool vertex_displacement = true;
uniform float curl_strength : hint_range(-1.0, 1.0) = 0.0;

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
	if (!tiling) {
		return vec2(lattice_coordinate, lattice_coordinate + 1.0);
	}
	else {
		float l0 = lattice_coordinate;
		if (l0 < 0.0) {
			l0 += frequency;
		}
		else if (l0 >= frequency) {
			l0 -= frequency;
		}
		float l1 = l0 + 1.0;
		if (l1 >= frequency) {
			l1 -= frequency;
		}
		return vec2(l0, l1);
	}
}

PatternSample sample_value_noise(
		uint seed,
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
	
	Hasher h = hasher(seed + uint(octave));
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

void sample_vector_noise(vec2 uv, out PatternSample u, out PatternSample v) {
	FractalPatternSettings curl_settings = standard_fractal_pattern_settings();
	curl_settings.pattern_seed += 1u;
	PatternSample s = sample_fractal_pattern(curl_settings, uv, TIME);
	//u = zero_pattern_sample();
	//u.v = s.dy;
	//v = zero_pattern_sample();
	//v.v = -s.dx;
	float epsilon = 0.001;
	PatternSample sx = sample_fractal_pattern(
			curl_settings, uv + vec2(epsilon, 0.0), TIME
	);
	PatternSample sy = sample_fractal_pattern(
			curl_settings, uv + vec2(0.0, epsilon), TIME
	);
	
	float smoothness_normalization = 1.0;
	switch (smoothness) {
		case 2:
			smoothness_normalization = 2.0 / 3.0;
			break;
		case 3:
			smoothness_normalization = 8.0 / 15.0;
			break;
	}
	vec2 scale = curl_strength * smoothness_normalization / epsilon /
			curl_settings.base_frequency;
	u = multiply(subtract(sy, s), scale.y);
	v = multiply(subtract(sx, s), -scale.x);
}

PatternSample sample_noise(vec2 uv) {
	if (animation) {
		uv += slide_velocity * TIME;
		if (tiling) {
			uv = fract(uv);
		}
	}
	
	PatternSample u, v;
	sample_vector_noise(uv, u, v);
	u.v += uv.x;
	u.dx += 1.0;
	v.v += uv.y;
	v.dy += 1.0;
	
	uv = vec2(u.v, v.v);
	if (tiling) {
		uv = fract(uv);
	}
	PatternSample s = sample_fractal_pattern(
			standard_fractal_pattern_settings(),
			uv,
			TIME
	);
	float dx = s.dx;
	s.dx = u.dx * dx + v.dx * s.dy;
	s.dy = u.dy * dx + v.dy * s.dy;
	return s;
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
