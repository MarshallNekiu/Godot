extends Node

@export var camera: Camera3D
@export var grid: Grid
@export var player: PhysicsBody3D

@onready var identity := $"Node3D/Node3D/Node3D^1/Pivot/Camera".global_basis as Basis

var player_buffer: Array
var camera_buffer: Array
var camera_tweening := false
var camera_up := 1


func _ready() -> void:
	var pc := [[$Canvas/PlayerControl/A/F, $Canvas/PlayerControl/C/B], [$Canvas/PlayerControl/B/R, $Canvas/PlayerControl/B/L]]
	for i in 2:
		pc[0][i].pressed.connect(_on_player_control_pressed.bind([Vector3i.BACK, Vector3i.FORWARD][i]))
		pc[1][i].pressed.connect(_on_player_control_pressed.bind([Vector3i.RIGHT, Vector3i.LEFT][i]))
	var cc := [$Canvas/CameraControl/A/XL, $Canvas/CameraControl/C/XR, $Canvas/CameraControl/B/L, $Canvas/CameraControl/B/R, $Canvas/CameraControl/C/B, $Canvas/CameraControl/A/F]
	for i in 6:
		cc[i].pressed.connect(_on_camera_control_pressed.bind([Vector3i.LEFT, Vector3i.RIGHT, Vector3i(1, 1, 0), Vector3i(-1, 1, 0), Vector3i.FORWARD, Vector3i.BACK][i]))
	for i: SpinBox in $Canvas/GridSize.get_children():
		i.value_changed.connect(func (x): grid.size = Vector3i($Canvas/GridSize/X.value, $Canvas/GridSize/Y.value, $Canvas/GridSize/Z.value))
	#grid.size = Vector3i(20, 12, 20)
	#_on_zoom_value_changed(30)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released():
			player.c = true
			if event.double_tap:
				player.apply_central_impulse(get_world_basis().y * 10)
	elif event is InputEventScreenDrag:
		player.c = false


func _process(delta: float) -> void:
	if camera_buffer.size():
		if camera_buffer[1]:
			$"Node3D/Node3D".global_rotate(camera_buffer[1], deg_to_rad(5 * sign(camera_buffer[2])))
			camera_buffer[2] -= 5 * sign(camera_buffer[2])
			if not camera_buffer[2]:
				player.velocity *= 0
				player.up_direction = get_world_basis().y
				camera_buffer = camera_buffer.slice(3)
		else:
			$Canvas/BoxRotAudio.play()
			camera_buffer[1] = get_world_basis()[camera_buffer[0]].rotated(get_world_basis().y * (1 if camera_buffer[0] == 0 else -1), 0 if camera_up == 1 else deg_to_rad(-90))
	#amera.h_offset = ($"Node3D/Node3D/Node3D^1/Pivot/Camera/Camera3D".unproject_position(player.global_position) - get_viewport().get_visible_rect().size * 0.5).x
	#camera.v_offset = camera.unproject_position(player.global_position).y - (get_viewport().get_visible_rect().size * 0.5).y
	#camera.h_offset += delta
	$"Node3D/Node3D/Node3D^1/Pivot/Camera/Camera3D".position = (camera.to_local(player.global_position) * Vector3(1, 1, 0))
	#var bit := BitMask64Grid._append(BitMask64Grid.from_mask(grid.grid.get_mask(), grid.size).grid, grid.size, Vector3i(player.global_position))
	$Canvas/Label.text = str("", "\n", $Map/Grid/TileSelector.select, "\n", grid.grid.grid)
	#BitMask64Grid.from_mask([Vector3i(player.global_position)], grid.size).grid, "\n",
	#BitMask64Grid.from_mask([Vector3i(player.global_position)], grid.size).get_mask(), "\n")
	#bit, "\n",
	#BitMask64Grid._get_mask(bit, grid.size))


func spawn_player(spawner: int) -> void:
	for i in grid.grid_data:
		if grid.grid_data[i].class == Grid.TILE.SPAWN and player.spawner == grid.grid_data[i].index:
			if not player.is_inside_tree():
				grid.spawn(player)
			player.global_position = Vector3(BitMask64Grid._get_mask([i], grid.grid_size)[0]) + Vector3.UP
			break


func _on_area_3d_input_event(camera: Node, event: InputEvent, evueent_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and not camera_tweening:
			if shape_idx == 0:
				camera_buffer.append_array([0, Vector3.ZERO, 90 * sign(camera.unproject_position($"Node3D/Control3D/UI/X".global_position).direction_to(event.position).x)])
			elif shape_idx == 1:
				camera_buffer.append_array([1, Vector3.ZERO, 90 * -sign(camera.unproject_position($"Node3D/Control3D/UI/Y".global_position).direction_to(event.position).x)])
			elif shape_idx == 2:
				camera_buffer.append_array([2, Vector3.ZERO, 90 * sign(camera.unproject_position($"Node3D/Control3D/UI/Z".global_position).direction_to(event.position).x)])
			elif shape_idx == 3:
				if not camera_buffer.size():
					$Canvas/BoxRotAudio.play()
					camera_tweening = true
					var tween := create_tween()
					tween.finished.connect(set.bind("camera_tweening", false))
					tween.tween_method((func (v, a: Transform3D):
						camera.global_basis = a.basis.rotated(a.basis.x, deg_to_rad(v))
						camera.global_position = a.origin.rotated(a.basis.x, deg_to_rad(v))).bind(
							camera.global_transform), 0.0, 70.6 * camera_up, 0.25)
					camera_up = -camera_up


func get_world_basis() -> Basis:
	var bas := camera.global_basis *\
	(Basis.IDENTITY.rotated(Vector3.RIGHT, deg_to_rad(-70.6)) if camera_up == -1 else Basis.IDENTITY) *\
	identity.inverse()
	return bas#Basis(bas.x, -bas.x.cross(bas.z), bas.z).orthonormalized()


func _on_grid_size_value_changed() -> void:
	grid.size = Vector3i($Canvas/GridSize/X.value, $Canvas/GridSize/Y.value, $Canvas/GridSize/Z.value)


func _on_zoom_value_changed(value: float) -> void:
	camera.size = value
	$"Node3D/Node3D/Node3D^1/Pivot/Camera/Camera3D".size = value


func _on_player_control_pressed(extra_arg_0: Vector3i) -> void:
	if extra_arg_0.x:
		player.x(extra_arg_0.x, get_world_basis())
	elif extra_arg_0.z:
		player.z(extra_arg_0.z, get_world_basis())


func _on_camera_control_pressed(extra_arg_0: Vector3i) -> void:
	if extra_arg_0.y:
		camera_buffer.append_array([1, Vector3.ZERO, 90 * sign(extra_arg_0.x)])
	elif extra_arg_0.x:
		camera_buffer.append_array([2, Vector3.ZERO, 90 * sign(extra_arg_0.x)])
	elif extra_arg_0.z:
		camera_buffer.append_array([0, Vector3.ZERO, 90 * sign(extra_arg_0.z)])
