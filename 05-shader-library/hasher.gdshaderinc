#include "bits_to_floats.gdshaderinc"

struct Hasher {
	uint bits;
};

Hasher hasher(uint seed) {
	Hasher h;
	h.bits = seed + 374761393u;
	return h;
}

Hasher hasher(Hasher h, float v) {
	Hasher new_h;
	uint b = h.bits + floatBitsToUint(v) * 3266489917u;
	new_h.bits = (b << 17u) | (b >> 32u - 17u);
	new_h.bits *= 668265263u;
	return new_h;
}

uint hash(Hasher h) {
	uint avalanche = h.bits;
	avalanche ^= avalanche >> 15u;
	avalanche *= 2246822519u;
	avalanche ^= avalanche >> 13u;
	avalanche *= 3266489917u;
	avalanche ^= avalanche >> 16u;
	return avalanche;
}

float hash_to_float(Hasher h) {
	return bits_to_float(hash(h));
}

vec2 square_vector(Hasher h) {
	uint bits = hash(h);
	uint check = bits & 0x03u;
	float f = bits_to_float(bits & ~check) * 2.0 - 1.0;
	switch (check) {
		case 0u:
			return vec2(f, -1.0);
		case 1u:
			return vec2(f, 1.0);
		case 2u:
			return vec2(-1.0, f);
		default:
			return vec2(1.0, f);
	}
}

vec2 diamond_vector(Hasher h) {
	vec2 v;
	v.x = hash_to_float(h) * 2.0 - 1.0;
	v.y = 0.5 - abs(v.x);
	v.x -= floor(v.x + 0.5f);
	return v;
}

vec2 circle_vector(Hasher h) {
	vec2 v = diamond_vector(h);
	return v * inversesqrt(dot(v, v));
}
