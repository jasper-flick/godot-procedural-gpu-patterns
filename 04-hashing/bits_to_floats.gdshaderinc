// Float exponent for 1, which is 127.
//const uint float_one_exponent = 0x3F800000u;

float bits_to_float(uint bits) {
	// Mask all 23 float mantissa bits.
	// Combine with float exponent for 1, which is 127.
	// Subtract 1 to go from [1-2) to [0-1).
	return uintBitsToFloat(bits & 0x007FFFFFu | 0x3F800000u) - 1.0;
}

vec2 bits_to_vec2(uint u) {
	// Shift low and high 16 bits into high mantissa bits.
	// Mask high 16 float mantissa bits.
	return uintBitsToFloat(uvec2(
			(u << 7u) & 0x007FFF80u | 0x3F800000u,
			(u >> 9u) & 0x007FFF80u | 0x3F800000u
	)) - 1.0;
}
