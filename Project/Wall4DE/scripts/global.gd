class_name Global

enum DIRECTION{UP, RIGHT,DOWN, LEFT}
enum ORIENTATION{UP, DOWN, RIGHT, LEFT, FORWARD, BACK}
enum DIAGONAL{OOO, XOO, OYO, OOZ, XYO, XOZ, OYZ, XYZ}
enum OCTANT{Y, YX, X, XZ, Z, ZY}
enum LAYER{PLAYER, PLAYER_AREA, TILE_BOX, TILE_FACE,
	GRID_LIMIT, GRID_BOUNDARY, TILE_SELECTOR, TILE_FOCUS}

const IDENTITY = Quaternion(-0.280121, 0.364669, 0.11603, 0.880389)
const NORMAL_ORIENTATION := {
	Vector3i.UP: ORIENTATION.UP, Vector3i.DOWN: ORIENTATION.DOWN,
	Vector3i.RIGHT: ORIENTATION.RIGHT, Vector3i.LEFT: ORIENTATION.LEFT,
	Vector3i(0, 0, 1): ORIENTATION.FORWARD, Vector3i(0, 0, -1): ORIENTATION.BACK,
}
const ORIENTATION_NORMAL := {
	ORIENTATION.UP: Vector3i.UP, ORIENTATION.DOWN: Vector3i.DOWN,
	ORIENTATION.RIGHT: Vector3i.RIGHT, ORIENTATION.LEFT: Vector3i.LEFT,
	ORIENTATION.FORWARD: Vector3i(0, 0, 1), ORIENTATION.BACK: Vector3i(0, 0, -1),
}
const ORIENTED_DIRECTION := {
	ORIENTATION.UP: [Vector3i.FORWARD, Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT],
	ORIENTATION.DOWN: [Vector3i.FORWARD, Vector3i.LEFT, Vector3i.BACK, Vector3i.RIGHT],
	ORIENTATION.RIGHT: [Vector3i.UP, Vector3i.FORWARD, Vector3i.DOWN, Vector3i.BACK],
	ORIENTATION.LEFT: [Vector3i.DOWN, Vector3i.FORWARD, Vector3i.UP, Vector3i.BACK],
	ORIENTATION.FORWARD: [Vector3i.UP, Vector3i.RIGHT, Vector3i.DOWN, Vector3i.LEFT],
	ORIENTATION.BACK: [Vector3i.DOWN, Vector3i.RIGHT, Vector3i.UP, Vector3i.LEFT]}
const V := 1.41421353816986
const W := 1.73205077648163


static func rad_to_deg360(rad: float) -> float:
	return fmod(rad_to_deg(rad) + 450, 360)


static func get_octant(vector: Vector2) -> Dictionary:
	var a := rad_to_deg360(vector.angle())
	var d := {"sign": 1 if a < 180 else -1}
	d["octant"] = OCTANT.Y if a < 30 else\
		OCTANT.YX if a < 60 else\
		OCTANT.X if a < 90 else\
		OCTANT.XZ if a < 120 else\
		OCTANT.Z if a < 150 else\
		OCTANT.ZY if a < 180 else\
		OCTANT.Y if a < 210 else\
		OCTANT.YX if a < 240 else\
		OCTANT.X if a < 270 else\
		OCTANT.XZ if a < 300 else\
		OCTANT.Z if a < 330 else\
		OCTANT.ZY
	return d
