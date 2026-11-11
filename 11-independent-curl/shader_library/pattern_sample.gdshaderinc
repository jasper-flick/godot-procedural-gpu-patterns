/*
Declares the PatternSample struct used by fractal_pattern.gdshaderinc.

Define PATTERN_SAMPLE_DIMENSIONS to set the value dimensions.
Allowed values are 1, 2, 3, and 4. The default is 1.
The corresponding coordinate types are float, vec2, vec3, and vec4.
The value field is named v.

Up to three derivatives are supported, with the same type as the value.
The derivative fields are named dx, dy, dz.
*/
#include "res://shader_library/hasher.gdshaderinc"

#ifndef PATTERN_SAMPLE_DIMENSIONS
#define PATTERN_SAMPLE_DIMENSIONS 1
#endif

#if PATTERN_SAMPLE_DIMENSIONS == 1
#define PATTERN_SAMPLE_VALUE_TYPE float
#elif PATTERN_SAMPLE_DIMENSIONS == 2
#define PATTERN_SAMPLE_VALUE_TYPE vec2
#elif PATTERN_SAMPLE_DIMENSIONS == 3
#define PATTERN_SAMPLE_VALUE_TYPE vec3
#else
#define PATTERN_SAMPLE_VALUE_TYPE vec4
#endif

struct PatternSample {
	PATTERN_SAMPLE_VALUE_TYPE v, dx, dy, dz;
};

PatternSample zero_pattern_sample() {
	return PatternSample(
			PATTERN_SAMPLE_VALUE_TYPE(0.0),
			PATTERN_SAMPLE_VALUE_TYPE(0.0),
			PATTERN_SAMPLE_VALUE_TYPE(0.0),
			PATTERN_SAMPLE_VALUE_TYPE(0.0)
	);
}

PatternSample add(PatternSample a, PatternSample b) {
	return PatternSample(
			a.v + b.v,
			a.dx + b.dx,
			a.dy + b.dy,
			a.dz + b.dz
	);
}

PatternSample subtract(PatternSample a, PatternSample b) {
	return PatternSample(
			a.v - b.v,
			a.dx - b.dx,
			a.dy - b.dy,
			a.dz - b.dz
	);
}

PatternSample multiply(PatternSample a, float b) {
	return PatternSample(
			a.v * b,
			a.dx * b,
			a.dy * b,
			a.dz * b
	);
}

PatternSample multiply(PatternSample a, PatternSample b) {
	return PatternSample(
			a.v * b.v,
			b.v * a.dx + a.v * b.dx,
			b.v * a.dy + a.v * b.dy,
			b.v * a.dz + a.v * b.dz
	);
}

PatternSample blend(PatternSample a, PatternSample b, PatternSample t) {
	return add(a, multiply(subtract(b, a), t));
}

PatternSample smooth01(PatternSample t) {
	PATTERN_SAMPLE_VALUE_TYPE d = (6.0 - 6.0 * t.v) * t.v;
	return PatternSample(
		smoothstep(0.0, 1.0, t.v),
		d * t.dx,
		d * t.dy,
		d * t.dz
	);
}

PatternSample smoother01(PatternSample t) {
	PATTERN_SAMPLE_VALUE_TYPE d =
			t.v * t.v * (t.v * (30.0 * t.v - 60.0) + 30.0);
	return PatternSample(
		t.v * t.v * t.v * (t.v * (6.0 * t.v - 15.0) + 10.0),
		d * t.dx,
		d * t.dy,
		d * t.dz
	);
}

PatternSample smooth01(PatternSample t, int smoothness_type) {
	switch(smoothness_type) {
		case 1:
			return t;
		case 2:
			return smooth01(t);
		case 3:
			return smoother01(t);
		default:
			PatternSample s = zero_pattern_sample();
			s.v = step(PATTERN_SAMPLE_VALUE_TYPE(0.5), t.v);
			return s;
	}
}

PatternSample blend_square(
		PatternSample s00,
		PatternSample s10,
		PatternSample s01,
		PatternSample s11,
		vec2 uv,
		int smoothness_type
) {
	PatternSample u = zero_pattern_sample();
	u.v = PATTERN_SAMPLE_VALUE_TYPE(uv.x);
	u.dx = PATTERN_SAMPLE_VALUE_TYPE(1.0);
	PatternSample v = zero_pattern_sample();
	v.v = PATTERN_SAMPLE_VALUE_TYPE(uv.y);
	v.dy = PATTERN_SAMPLE_VALUE_TYPE(1.0);

	u = smooth01(u, smoothness_type);
	v = smooth01(v, smoothness_type);
	return blend(
			blend(s00, s10, u),
			blend(s01, s11, u),
			v
	);
}

PatternSample scale_derivatives(PatternSample s, vec3 scale) {
	s.dx *= scale.x;
	s.dy *= scale.y;
	s.dz *= scale.z;
	return s;
}

PatternSample scale_derivatives(PatternSample s, vec2 scale) {
	return scale_derivatives(s, vec3(scale, 0.0));
}

PATTERN_SAMPLE_VALUE_TYPE hasher_to_value(Hasher h) {
#if PATTERN_SAMPLE_DIMENSIONS == 1
	return hash_to_float(hash(h));
#elif PATTERN_SAMPLE_DIMENSIONS == 2
	return hash_to_vec2(hash(h));
#elif PATTERN_SAMPLE_DIMENSIONS == 3
	return hash_to_vec3(hash(h));
#else
	return hash_to_vec4(hash(h));
#endif
}

PatternSample hasher_to_value_sample(Hasher h, float time, bool animating) {
	PatternSample s = zero_pattern_sample();
	if (animating) {
		float t0 = floor(time);
		float t1 = t0 + 1.0;
		s.v = mix(
				hasher_to_value(hasher(h, t0)),
				hasher_to_value(hasher(h, t1)),
				smoothstep(0.0, 1.0, time - t0)
		);
	}
	else {
		s.v = hasher_to_value(h);
	}
	return s;
}
