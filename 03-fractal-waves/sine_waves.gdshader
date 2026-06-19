shader_type spatial;

uniform vec2 animation_speed = vec2(0.0);
uniform vec2 bumpiness = vec2(1.0);
uniform float displacement : hint_range(-1.0, 1.0) = 0.2;
uniform vec2 base_frequency = vec2(1.0);
uniform int octaves : hint_range(1, 10) = 1;
uniform float lacunarity : hint_range(1.0, 5.0, 0.1) = 2.0;
uniform float persistence : hint_range(0.0, 0.95, 0.05) = 0.5;
uniform bool adaptive_fractal_scale = false;
uniform int function : hint_enum("U", "V", "UV Average", "UV Product") = 0;
uniform bool colors_per_vertex = false;
uniform bool derivatives_per_vertex = false;
uniform bool vertex_displacement = true;

varying vec2 derivatives;

vec3 colorize(float v) {
	if (abs(v) > 1.0) {
		return vec3(1.0, 0.0, 1.0);
	}
	if (v >= 0.0) {
		return vec3(v);
	}
	else {
		return vec3(0.0, -v, 0.0);
	}
}

struct PatternSample {
	float v;
	vec2 d;
};

PatternSample zero_pattern_sample() {
	return PatternSample(0.0, vec2(0.0));
}

PatternSample add(PatternSample a, PatternSample b) {
	return PatternSample(a.v + b.v, a.d + b.d);
}

PatternSample multiply(PatternSample a, float b) {
	return PatternSample(a.v * b, a.d * b);
}

PatternSample sample_pattern(vec2 frequency, vec2 uv) {
	vec2 f = frequency * TAU;
	vec2 t = f * uv;
	PatternSample s;
	switch (function) {
		case 0: // U
			s.v = sin(t.x);
			s.d.x = f.x * cos(t.x);
			s.d.y = 0.0;
			break;
		case 1: // V
			s.v = sin(t.y);
			s.d.x = 0.0;
			s.d.y = f.y * cos(t.y);
			break;
		case 2: // UV Average
			s.v = (sin(t.x) + sin(t.y)) * 0.5;
			s.d.x = f.x * cos(t.x) * 0.5;
			s.d.y = f.y * cos(t.y) * 0.5;
			break;
		case 3: // UV Product
			s.v = sin(t.x) * sin(t.y);
			s.d.x = f.x * cos(t.x) * sin(t.y);
			s.d.y = f.y * sin(t.x) * cos(t.y);
			break;
	}
	return s;
}

PatternSample normalize_fractal_sample(PatternSample s) {
	float scale = 1.0 - persistence;
	if (adaptive_fractal_scale) {
		scale /= 1.0 - pow(persistence, float(octaves));
	}
	return multiply(s, scale);
}

PatternSample sample_fractal_pattern(vec2 uv) {
	PatternSample sum = zero_pattern_sample();
	vec2 frequency = base_frequency;
	float amplitude = 1.0;
	for (int i = 0; i < octaves; i++) {
		sum = add(sum, multiply(sample_pattern(frequency, uv), amplitude));
		frequency *= lacunarity;
		amplitude *= persistence;
	}
	return normalize_fractal_sample(sum);
}

void vertex() {
	PatternSample pattern_sample = sample_fractal_pattern(
			UV + animation_speed * TIME
	);
	if (colors_per_vertex) {
		COLOR.rgb = colorize(pattern_sample.v);
	}
	if (vertex_displacement) {
		VERTEX += NORMAL * (pattern_sample.v * displacement);
	}
	if (derivatives_per_vertex) {
		derivatives = pattern_sample.d * displacement * bumpiness;
	}
}

void fragment() {
	PatternSample pattern_sample = sample_fractal_pattern(
			UV + animation_speed * TIME
	);
	if (colors_per_vertex) {
		ALBEDO = COLOR.rgb;
	}
	else {
		ALBEDO = colorize(pattern_sample.v);
	}
	vec2 d;
	if (derivatives_per_vertex) {
		d = derivatives;
	}
	else {
		d = pattern_sample.d * displacement * bumpiness;
	}
	NORMAL = cross(
			TANGENT + NORMAL * d.x,
			BINORMAL - NORMAL * d.y
	);
}
