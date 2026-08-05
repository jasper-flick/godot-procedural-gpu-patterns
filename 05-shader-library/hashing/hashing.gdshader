shader_type spatial;

uniform float frequency = 1.0;
uniform uint hash_seed = 0u;
uniform int visualization : hint_enum("Grayscale", "RG", "RGB") = 0;

struct Hasher {
	uint bits;
};

Hasher hasher(uint seed) {
	return Hasher(seed + 374761393u);
}

Hasher hasher(Hasher h, float f) {
	h.bits += floatBitsToUint(f) * 3266489917u;
	h.bits = (h.bits << 17u) | (h.bits >> 32u - 17u);
	h.bits *= 668265263u;
	return h;
}

uint hash(Hasher h) {
	h.bits ^= h.bits >> 15u;
	h.bits *= 2246822519u;
	h.bits ^= h.bits >> 13u;
	h.bits *= 3266489917u;
	h.bits ^= h.bits >> 16u;
	return h.bits;
}

float hash_to_float(uint hash) {
	return uintBitsToFloat(hash & 0x007FFFFFu | 0x3F800000u) - 1.0;
}

vec2 hash_to_vec2(uint hash) {
	return uintBitsToFloat(uvec2(
			hash << 7u,
			hash >> 9u
	) & uvec2(0x007FFF80u) | uvec2(0x3F800000u)) - 1.0;
}

vec3 hash_to_vec3(uint hash) {
	return uintBitsToFloat(uvec3(
			(hash << 12u) & 0x007FF000u,
			(hash << 1u) & 0x007FF000u,
			(hash >> 9u) & 0x007FE000u
	) | uvec3(0x3F800000u)) - 1.0;
}

void fragment() {
	vec2 coordinates = floor(frequency * (UV - 0.5));
	Hasher h = hasher(hash_seed);
	h = hasher(h, coordinates.x);
	h = hasher(h, coordinates.y);
	uint hash = hash(h);
	switch (visualization) {
		case 0: // Grayscale
			ALBEDO = vec3(hash_to_float(hash));
			break;
		case 1: // RG
			ALBEDO = vec3(hash_to_vec2(hash), 0.0);
			break;
		case 2: // RGB
			ALBEDO = hash_to_vec3(hash);
			break;
	}
}
