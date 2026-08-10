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

PatternSample multiply(PatternSample a, float b) {
	return PatternSample(
			a.v * b,
			a.dx * b,
			a.dy * b,
			a.dz * b
	);
}
