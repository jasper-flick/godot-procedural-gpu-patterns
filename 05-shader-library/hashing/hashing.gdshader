shader_type spatial;

uniform float frequency = 1.0;
uniform uint hash_seed = 0u;
uniform int visualization : hint_enum("Grayscale", "RG", "RGB") = 0;

#include "res://shader_library/hasher.gdshaderinc"

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
