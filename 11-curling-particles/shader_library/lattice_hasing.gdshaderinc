#include "res://shader_library/hasher.gdshaderinc"

vec2 lattice01(float lattice_coordinate, float frequency, bool use_tiling) {
	if (!use_tiling) {
		return vec2(lattice_coordinate, lattice_coordinate + 1.0);
	}
	else {
		float l0 = lattice_coordinate;
		if (l0 < 0.0) {
			l0 += frequency;
		}
		else if (l0 >= frequency) {
			l0 -= frequency;
		}
		float l1 = l0 + 1.0;
		if (l1 >= frequency) {
			l1 -= frequency;
		}
		return vec2(l0, l1);
	}
}

struct LatticeSquare {
	Hasher h00, h10, h01, h11;
	vec2 uv;
	float time_a, time_b;
};

LatticeSquare get_lattice_square(
		uint seed,
		vec2 uv,
		vec2 frequency,
		float time,
		bool use_tiling
) {
	LatticeSquare s;
	vec2 sample_coordinates = frequency * uv;
	vec2 lattice_coordinates = floor(sample_coordinates);
	s.uv = sample_coordinates - lattice_coordinates;
	
	vec2 uLattice = lattice01(lattice_coordinates.x, frequency.x, use_tiling);
	vec2 vLattice = lattice01(lattice_coordinates.y, frequency.y, use_tiling);
	
	Hasher h = hasher(seed);
	Hasher h0 = hasher(h, uLattice.x);
	Hasher h1 = hasher(h, uLattice.y);
	s.h00 = hasher(h0, vLattice.x);
	s.h10 = hasher(h1, vLattice.x);
	s.h01 = hasher(h0, vLattice.y);
	s.h11 = hasher(h1, vLattice.y);
	
	float time_stagger = fract(
			(lattice_coordinates.x + lattice_coordinates.y) * 0.5
	);
	s.time_a = time + time_stagger;
	s.time_b = time + (0.5 - time_stagger);

	return s;
}
