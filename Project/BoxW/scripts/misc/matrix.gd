class_name Matrix


static func basis_x(x: Vector3, bas: Basis) -> Basis:
	if x == bas.x: return bas
	return Basis(
		x,
		x * bas.rotated(bas.z, deg_to_rad(90)),
		x * bas.rotated(bas.x, deg_to_rad(90))).orthonormalized()


static func basis_y(y: Vector3, bas: Basis) -> Basis:
	if y == bas.y: return bas
	return Basis(
		y * bas.rotated(bas.z, deg_to_rad(90)),
		y,
		y * bas.rotated(bas.x, deg_to_rad(90))).orthonormalized()


static func basid_z(z: Vector3, bas: Basis) -> Basis:
	if z == bas.z: return bas
	return Basis(
		z * bas.rotated(bas.z, deg_to_rad(90)),
		z,
		z).orthonormalized()
