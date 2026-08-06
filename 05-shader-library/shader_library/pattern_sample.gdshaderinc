#ifndef PATTERN_SAMPLE_VALUE_TYPE
#define PATTERN_SAMPLE_VALUE_TYPE float
#endif

#ifndef PATTERN_SAMPLE_DERIVATIVE_COUNT
#define PATTERN_SAMPLE_DERIVATIVE_COUNT 0
#endif

#define PATTERN_SAMPLE PatternSample

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
