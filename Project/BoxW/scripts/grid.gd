@tool
class_name Grid
extends Node3D

enum TILE{SPAWN, FINISH, NORMAL, SLOPE, BRIDGE, SPIKE, BOUNCER, SLIDER, MOTOR, GRAVITOR, TELEPORT, TRIGGER, ELECTRIC_CIRCUIT}

enum REQUEST{Y, YX, X, XZ, Z, ZY}

@export var size := Vector3i.ONE * 4:
	set(x):
		size = x
		grid.resize(size)
		$TileSelector.size = x
		$Limit/Node3D.scale = size
		for i in 3:
			[$Limit/R, $Limit/U, $Limit/F][i].position[i] = x[i]
		available.clear()
		for i in x.x:
			for j in x.y:
				for k in x.z:
					available.append(Vector3(i, j, k))

var grid := BitMask64Grid.from_mask([Vector3i.ZERO], size)
var grid_buffer := BitMask64Grid.new()
var grid_data := {0: {"class": TILE.SPAWN, "index": 0}}
var grid_data_buffer: Dictionary
var bridge_request := [-1, -1]
var available: Array


func _ready() -> void:
	size = size


func recreate():
	pass


func spawn(player: PhysicsBody3D):
	pass


func get_octant(vector: Vector2) -> Dictionary:
	var a := rad_to_deg360(vector.angle())
	var d := {"sign": 1 if a < 180 else -1}
	d["request"] = REQUEST.Y if a < 30 else\
		REQUEST.YX if a < 60 else\
		REQUEST.X if a < 90 else\
		REQUEST.XZ if a < 120 else\
		REQUEST.Z if a < 150 else\
		REQUEST.ZY if a < 180 else\
		REQUEST.Y if a < 210 else\
		REQUEST.YX if a < 240 else\
		REQUEST.X if a < 270 else\
		REQUEST.XZ if a < 300 else\
		REQUEST.Z if a < 330 else\
		REQUEST.ZY
	return d


func rad_to_deg360(rad: float) -> float:
	return fmod(rad_to_deg(rad) + 450, 360)


func _on_tile_selector_select_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not grid.has_v($TileSelector.select):
			var tile := load("res://scenes/block.tscn").instantiate() as StaticBody3D
			tile.position = Vector3($TileSelector.select)
			$Tile.add_child(tile, true)
			grid.append($TileSelector.select)
