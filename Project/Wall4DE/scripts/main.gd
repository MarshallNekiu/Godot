class_name Main
extends Node

@export var camera: Camera3D
@export var grid: Grid
@export var player: Player

var camera_buffer: Array
var player_focused := false


func _init() -> void:
	Autoload.main = self


func _ready() -> void:
	for i: String in Grid.TILE.keys():
		$Canvas/Generate/Tile.add_item(i.capitalize())
		$Canvas/Generate/Tile.set_item_icon($Canvas/Generate/Tile.item_count - 1, load("res://resources/icon/" + i.to_lower() + ".png"))
	$Canvas/Generate/Tile.select(Grid.TILE.NORMAL)
	for i: SpinBox in $Canvas/GridSize.get_children():
		i.value_changed.connect(func (x): grid.size = Vector3i($Canvas/GridSize/X.value, $Canvas/GridSize/Y.value, $Canvas/GridSize/Z.value))
	player.face_tile_changed.connect(_on_player_face_tile_changed)
	var c := [$Canvas/Generate/Trigger/HBC2/U, $Canvas/Generate/Trigger/HBC3/D,
		$Canvas/Generate/Trigger/HBC4/R, $Canvas/Generate/Trigger/HBC/L,
		$Canvas/Generate/Trigger/HBC4/F, $Canvas/Generate/Trigger/HBC/B]
	for i in c.size():
		c[i].pressed.connect(_on_trigger_button_pressed.bind(i))


func _on_trigger_button_pressed(idx: Global.ORIENTATION):
	if player.face_tile[idx] >= 0:
		if grid.tile_box.face_get_type(player.face_tile[idx]) == Grid.TILE.BOUNCER:
			player.charge_impulse(grid.tile_box.face_get_transform(player.face_tile[idx]).basis.y, 4.0)


func _on_player_face_tile_changed():
	for i in player.face_tile.size():
		var c := [$Canvas/Generate/Trigger/HBC2/Ui, $Canvas/Generate/Trigger/HBC3/Di,
			$Canvas/Generate/Trigger/HBC4/Ri, $Canvas/Generate/Trigger/HBC/Li,
			$Canvas/Generate/Trigger/HBC4/Fi, $Canvas/Generate/Trigger/HBC/Bi]
		(c[i] as TextureRect).texture = Grid.tile_icon[grid.tile_box.face_get_type(player.face_tile[i])]


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			player_focused = not Autoload.cast_ray(camera, event.position, player.collision_layer).is_empty()
		else:
			player_focused = false


func _process(delta: float) -> void:
	if camera_buffer.size():
		if camera_buffer[1]:
			$"Node3D/A".global_rotate(camera_buffer[1], deg_to_rad(5 * sign(camera_buffer[2])))
			camera_buffer[2] -= 5 * sign(camera_buffer[2])
			if not camera_buffer[2]:
				Autoload.basis = get_world_basis()
				camera_buffer = camera_buffer.slice(3)
		else:
			(player).axis_lock_linear_x = true
			(player).axis_lock_linear_y = true
			(player).axis_lock_linear_z = true
			camera_buffer[1] = get_world_basis()[camera_buffer[0]]
			$BoxRotAudio.play()
	else:
		(player).axis_lock_linear_x = false
		(player).axis_lock_linear_y = false
		(player).axis_lock_linear_z = false
	camera.position = ($Node3D/A/B/C/D.to_local(player.global_position) * Vector3(1, 1, 0))
	if player_focused:
		var pos := get_viewport().get_mouse_position()
		var p = Plane(Autoload.basis.y, player.global_position).intersects_ray(camera.project_ray_origin(pos), camera.project_ray_normal(pos))
		if p:
			_on_player_control_pressed(Vector3i(
				Vector3.RIGHT.rotated(Vector3.UP, deg_to_rad(snappedf(rad_to_deg(Autoload.basis.x.signed_angle_to(p - player.global_position, Autoload.basis.y)), 90))).round()))
		$Canvas/PlayerControl/TextureButton/Line2D.rotation = Vector3.RIGHT.signed_angle_to(p, Vector3.UP)
	elif $Canvas/PlayerControl/TextureButton.button_pressed:
		var oct := Global.rad_to_deg360($Canvas/PlayerControl/TextureButton/Line2D.global_position.angle_to_point(get_viewport().get_mouse_position()))
		var req := Vector3i.ZERO
		if oct < 90:
			req = Vector3.FORWARD
		elif oct < 180:
			req = Vector3.RIGHT
		elif oct < 270:
			req = Vector3.BACK
		elif oct < 360:
			req = Vector3.LEFT
		_on_player_control_pressed(req)
		$Canvas/PlayerControl/TextureButton/Line2D.rotation_degrees = oct
	$Canvas/Label.text = str(delta, "\n", delta * 3600, "\n", "\n", "\n")


func get_world_basis() -> Basis:
	var bas := camera.global_basis * Basis(Global.IDENTITY).inverse()
	return Basis(bas.x.round(), bas.y.round(), bas.z.round())


func _on_grid_size_value_changed() -> void:
	grid.size = Vector3i($Canvas/GridSize/X.value, $Canvas/GridSize/Y.value, $Canvas/GridSize/Z.value)


func _on_zoom_value_changed(value: float) -> void:
	camera.size = value


func _on_player_control_pressed(extra_arg_0: Vector3i) -> void:
	if extra_arg_0.x:
		player.impulse(Vector3i(extra_arg_0.x, 0, 0), extra_arg_0.abs().x)
	elif extra_arg_0.z:
		player.impulse(Vector3i(0, 0, extra_arg_0.z), extra_arg_0.abs().z)


func _on_camera_control_pressed(extra_arg_0: Vector3i) -> void:
	if extra_arg_0.y:
		camera_buffer.append_array([1, Vector3.ZERO, 90 * sign(extra_arg_0.x)])
	elif extra_arg_0.x:
		camera_buffer.append_array([2, Vector3.ZERO, 90 * sign(extra_arg_0.x)])
	elif extra_arg_0.z:
		camera_buffer.append_array([0, Vector3.ZERO, 90 * sign(extra_arg_0.z)])


func _on_tile_item_selected(index: int) -> void:
	grid.instamtiate = index


func _on_area_pressed() -> void:
	grid.generate_tile(grid.tile_selector.get_area())


func _on_orthogonal_pressed() -> void:
	grid.generate_tile(grid.tile_selector.select_orthogonal)


func _on_camera_texture_button_pressed() -> void:
	var oct := Global.rad_to_deg360($Canvas/CameraControl/TextureButton/Line2D.global_position.angle_to_point(get_viewport().get_mouse_position()))
	var req := Vector3i.ZERO
	if oct < 60:
		req = Vector3.BACK
	elif oct < 120:
		req = Vector3(-1, 1, 0)
	elif oct < 180:
		req = Vector3.RIGHT
	elif oct < 240:
		req = Vector3.FORWARD
	elif oct < 300:
		req = Vector3(1, 1, 0)
	elif oct < 360:
		req = Vector3.LEFT
	_on_camera_control_pressed(req)
	$Canvas/CameraControl/TextureButton/Line2D.rotation_degrees = oct


func _on_player_texture_button_pressed() -> void:
	var oct := Global.rad_to_deg360($Canvas/PlayerControl/TextureButton/Line2D.global_position.angle_to_point(get_viewport().get_mouse_position()))
	var req := Vector3i.ZERO
	if oct < 90:
		req = Vector3.FORWARD
	elif oct < 180:
		req = Vector3.RIGHT
	elif oct < 270:
		req = Vector3.BACK
	elif oct < 360:
		req = Vector3.LEFT
	_on_player_control_pressed(req)
	$Canvas/PlayerControl/TextureButton/Line2D.rotation_degrees = oct


func _on_border_toggled(toggled_on: bool) -> void:
	$Map/Grid/TileBorder.draw = toggled_on


func _on_selector_a_toggled(toggled_on: bool) -> void:
	grid.tile_selector.collision_layer = int(toggled_on) * (1 << Global.LAYER.TILE_SELECTOR)


func _on_selector_b_toggled(toggled_on: bool) -> void:
	grid.tile_selector.active_b = toggled_on
