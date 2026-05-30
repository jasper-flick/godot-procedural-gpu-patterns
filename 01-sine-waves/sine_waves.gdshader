shader_type spatial;

uniform float bumpiness = 1.0;
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform float frequency = 1.0;

vec3 colorize(float v) {
	if (v >= 0.0) {
		return vec3(v);
	}
	else {
		return vec3(0.0, -v, 0.0);
	}
}

struct PatternSample {
	float v;
	float d;
};

PatternSample sample_pattern(vec2 uv) {
	float f = frequency * TAU;
	float t = f * uv.x;
	return PatternSample(
			sin(t),
			f * cos(t)
	);
}

void vertex() {
	PatternSample pattern_sample = sample_pattern(UV);
	COLOR.rgb = colorize(pattern_sample.v);
	VERTEX += NORMAL * (pattern_sample.v * displacement);
}

void fragment() {
	PatternSample pattern_sample = sample_pattern(UV);
	ALBEDO = colorize(pattern_sample.v);
	ALBEDO = COLOR.rgb;
	float d = pattern_sample.d * displacement * bumpiness;
	NORMAL = cross(
			TANGENT + NORMAL * d,
			BINORMAL
	);
}
