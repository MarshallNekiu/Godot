@tool
@icon("res://resources/icon/grid.png")
class_name Grid
extends Node3D

enum TILE{SPAWN, CHECKPOINT, FINISH, NORMAL, BOUNCER, DAMAGE, SLIDER,
	MOTOR, GRAVITOR, TELEPORT, TRIGGER, TESSERACT, ROTOR}

static var tile_icon := range(TILE.size()).map(func (x): return load("res://resources/icon/" + TILE.keys()[x].to_lower() + ".png"))

@export var tile_box: TileBox
@export var tile_selector: TileSelector
@onready var grid_data := {}
@export var size := Vector3i.ONE * 4:
	set(x):
		var gd := {}
		var p := []
		for i in  grid_data:
			gd[grid.get_index_resized(i, x)] = grid_data[i]
		size = x
		grid.resize(size)
		grid_data = gd
		tile_selector.size = x
		$Boundary/Collision.shape.size = Vector3(size)
		$Boundary/Collision.position = Vector3(size * 0.5)
		for i in 3:
			[$Limit/R, $Limit/U, $Limit/F][i].position[i] = x[i]

var instamtiate := TILE.NORMAL
var grid := BitMask64Grid.new()


func _ready() -> void:
	generate_tile([Vector3i.ONE])
	tile_box.box_set_face(-1, Global.ORIENTATION.UP, TILE.SPAWN)


func spawn(player: RigidBody3D):
	Autoload.main.camera_buffer.clear()
	Autoload.main.camera.find_parent("A").global_basis = tile_box.face_get_world_basis_override(Autoload.main.player.spawn)
	Autoload.main.player.global_position = tile_box.face_get_transform(Autoload.main.player.spawn).translated_local(Vector3.UP).origin
	player.linear_velocity *= 0
	player.angular_velocity *= 0
	Autoload.basis = Autoload.main.get_world_basis()


func _on_limit_body_entered(body: Node3D) -> void:
	if body is Player:
		spawn(body)


func generate_tile(pos: Array[Vector3i]) -> void:
	for i in pos:
		if not grid.has_v(i):
			var	index := tile_box.add_box(i)
			grid_data[grid.grid_v_get_index(i)] = index
			grid.append(i)
