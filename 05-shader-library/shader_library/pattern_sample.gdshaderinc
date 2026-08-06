/*
Declares the PatternSample struct used by fractal_pattern.gdshaderinc.

Define PATTERN_SAMPLE_VALUE_TYPE to set the sample value's type.
The value field is named v.
The default is float. Other options are vec2, vec3, vec4.

Define PATTERN_SAMPLE_DERIVATIVE_COUNT to set how many derivatives there are.
Up to four derivatives are supported.
The derivative fields, if they exist, are named dx, dy, dz, dw.
The default is 0.
*/

#ifndef PATTERN_SAMPLE_VALUE_TYPE
#define PATTERN_SAMPLE_VALUE_TYPE float
#endif

#ifndef PATTERN_SAMPLE_DERIVATIVE_COUNT
#define PATTERN_SAMPLE_DERIVATIVE_COUNT 0
#endif

struct PatternSample {
	PATTERN_SAMPLE_VALUE_TYPE v;
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 0
	PATTERN_SAMPLE_VALUE_TYPE dx;
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 1
	PATTERN_SAMPLE_VALUE_TYPE dy;
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 2
	PATTERN_SAMPLE_VALUE_TYPE dz;
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 3
	PATTERN_SAMPLE_VALUE_TYPE dw;
#endif
};

PatternSample zero_pattern_sample() {
	return PatternSample(
			PATTERN_SAMPLE_VALUE_TYPE(0.0)
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 0
			, PATTERN_SAMPLE_VALUE_TYPE(0.0)
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 1
			, PATTERN_SAMPLE_VALUE_TYPE(0.0)
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 2
			, PATTERN_SAMPLE_VALUE_TYPE(0.0)
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 3
			, PATTERN_SAMPLE_VALUE_TYPE(0.0)
#endif
	);
}

PatternSample add(PatternSample a, PatternSample b) {
	return PatternSample(
			a.v + b.v
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 0
			, a.dx + b.dx
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 1
			, a.dy + b.dy
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 2
			, a.dz + b.dz
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 3
			, a.dw + b.dw
#endif
	);
}

PatternSample multiply(PatternSample a, float b) {
	return PatternSample(
			a.v * b
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 0
			, a.dx * b
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 1
			, a.dy * b
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 2
			, a.dz * b
#endif
#if PATTERN_SAMPLE_DERIVATIVE_COUNT > 3
			, a.dw * b
#endif
	);
}
