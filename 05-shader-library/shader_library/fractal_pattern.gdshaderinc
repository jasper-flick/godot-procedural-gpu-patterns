#ifndef PATTERN_SAMPLE
#define PATTERN_SAMPLE _DummyPatternSample

struct _DummyPatternSample {
	float v;
};

_DummyPatternSample zero_pattern_sample() {
	return _DummyPatternSample(0.0);
}

_DummyPatternSample add(_DummyPatternSample a, _DummyPatternSample b) {
	return _DummyPatternSample(a.v + b.v);
}

_DummyPatternSample multiply(_DummyPatternSample a, float b) {
	return _DummyPatternSample(a.v * b);
}
#endif

#ifndef PATTERN_FREQUENCY_TYPE
#define PATTERN_FREQUENCY_TYPE float
#endif

#ifndef SAMPLE_PATTERN_FUNCTION
#define SAMPLE_PATTERN_FUNCTION dummy_sample_pattern

PATTERN_SAMPLE dummy_sample_pattern(PATTERN_FREQUENCY_TYPE frequency, vec2 uv) {
	return zero_pattern_sample();
}
#endif

struct FractalPatternSettings {
	PATTERN_FREQUENCY_TYPE base_frequency;
	int octaves;
	float lacunarity;
	float persistence;
	bool adaptive_fractal_scale;
};

PATTERN_SAMPLE normalize_fractal_sample(
		FractalPatternSettings settings,
		PATTERN_SAMPLE s
) {
	float scale = 1.0 - settings.persistence;
	if (settings.adaptive_fractal_scale) {
		scale /= 1.0 - pow(settings.persistence, float(settings.octaves));
	}
	return multiply(s, scale);
}

PATTERN_SAMPLE sample_fractal_pattern(
		FractalPatternSettings settings,
		vec2 uv
) {
	PATTERN_SAMPLE sum = zero_pattern_sample();
	PATTERN_FREQUENCY_TYPE frequency = settings.base_frequency;
	float amplitude = 1.0;
	for (int i = 0; i < settings.octaves; i++) {
		sum = add(sum, multiply(
				SAMPLE_PATTERN_FUNCTION(frequency, uv), amplitude));
		frequency *= settings.lacunarity;
		amplitude *= settings.persistence;
	}
	return normalize_fractal_sample(settings, sum);
}
