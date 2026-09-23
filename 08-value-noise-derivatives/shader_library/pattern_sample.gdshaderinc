/*
Declares the PatternSample struct used by fractal_pattern.gdshaderinc.

Define PATTERN_SAMPLE_VALUE_TYPE to set the sample value's type.
The value field is named v.
The default is float. Other options are vec2, vec3, vec4.

Up to three derivatives are supported, with the same type as the value.
The derivative fields are named dx, dy, dz.
*/

#ifndef PATTERN_SAMPLE_VALUE_TYPE
#define PATTERN_SAMPLE_VALUE_TYPE float
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
			return PatternSample(t.v < 0.5 ? 0.0 : 1.0, 0.0, 0.0, 0.0);
	}
}
