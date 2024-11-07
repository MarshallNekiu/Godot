@tool
@icon("res://resources/icon/tile_selector.png")
class_name TileSelector
extends Area3D

signal selected
@export var ref: Array[Node3D]
@export var size := Vector3i.ONE * 4:
	set(x):
		size = (x.abs() / 4) * 4
		set_size.call_deferred(size)
@export var select_area := Vector3i.ONE:
	set(x):
		select_area = x.clamp(Vector3i.ZERO - select, size - select)
		set_select_area.call_deferred(select_area)
var select_orthogonal: Array[Vector3i]

var focus := -1
@export var select := Vector3i.ZERO:
	set(x):
		select = x.clamp(Vector3.ZERO, size - Vector3i.ONE)
		select_area = select_area
var plane := Plane(Vector3.UP)
var center := Vector3.ZERO
var active := true
var active_b := true


func _ready() -> void:
	set_size(size)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var camera := get_viewport().get_camera_3d()
		if focus == 0:
			var pos:= plane.intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(1, 1, 0) as Vector3
			select = Vector3(pos.x, pos.y, select.z)
		elif focus == 1:
			var pos := plane.intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(1, 0, 1) as Vector3
			select = Vector3(pos.x, select.y, pos.z)
		elif focus == 2:
			var pos := plane.intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(0, 1, 1) as Vector3
			select = Vector3(select.x, pos.y, pos.z)
		elif focus == 3:
			if plane.normal.x:
				var pos := to_local(Plane(plane.normal, center).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))).snappedf(1) as Vector3
				select_area = Vector3(select_area.x, pos.y, pos.z)
			elif plane.normal.y:
				var pos := to_local(Plane(plane).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))).snappedf(1) as Vector3
				select_area = Vector3(pos.x, select_area.y, pos.z)
			elif plane.normal.z:
				var pos := to_local(Plane(plane.normal, center).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))).snappedf(1) as Vector3
				select_area = Vector3(pos.x, pos.y, select_area.z)
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			if event.double_tap:
				if active_b:
					set_select_orthogonal(event.position)
			var target := Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.TILE_FOCUS)
			if not target.size():
				target = Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.TILE_SELECTOR)
			if target.size() and not Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.PLAYER).size():
				if target.collider == $Select:
					focus = 3
					plane = Plane(target.normal, target.position)
					center = target.position
				elif target.collider == self:
					focus = target.shape
					plane = Plane([Vector3.FORWARD, Vector3.UP, Vector3.RIGHT][target.shape], target.position)
					center = target.position
		elif event.is_released():
			if focus >= 0:
				focus = -1
				selected.emit()


func set_size(_size: Vector3i):
	for i in 3:
		[$Z, $Y, $X][i].shape.points = (
			[Vector3.ZERO, Vector3.UP, Vector3.RIGHT, Vector3(1, 1, 0)] + [Vector3.ZERO, Vector3.UP, Vector3.RIGHT, Vector3(1, 1, 0)].map(
				func (x): return Vector3.ZERO + x + Vector3.FORWARD * _size[i]))
		[$Z/Node3D, $Y/Node3D, $X/Node3D][i].get_child(1).position.z = -_size[i] - 0.7
		[$Z/Node3D, $Y/Node3D, $X/Node3D][i].get_node("Node3D").scale.z = -_size[i]
	select = select


func set_select_area(area: Vector3i):
	$Select/Mesh.position = Vector3(area.sign().clampi(-1, 0)).abs()
	$Select/Mesh.scale = Vector3(area) - $Select/Mesh.position
	$X.position = Vector3(select.x, select.y, 0).clamp(Vector3.ZERO, size - Vector3i.ONE)
	$Y.position = Vector3(select.x, 0, select.z).clamp(Vector3.ZERO, size - Vector3i.ONE)
	$Z.position = Vector3(0, select.y, select.z).clamp(Vector3.ZERO, size - Vector3i.ONE)
	$Select.position = select



func get_area()-> Array[Vector3i]:
	var a: Array[Vector3i]
	for i in select_area.abs().x + select_area.clampi(-1, 0).abs().x:
		for j in select_area.abs().y + select_area.clampi(-1, 0).abs().y:
			for k in select_area.abs().z + select_area.clampi(-1, 0).abs().z:
				a.append(select + Vector3i(i, j, k) * select_area.sign())
	return a



func set_select_orthogonal(origin: Vector2):
	var sel: Array[Vector3i]
	var o := Autoload.cast_ray(get_viewport().get_camera_3d(), origin, 1 << Global.LAYER.GRID_BOUNDARY)
	if o.size():
		var s = [size.x, size.y, size.z]
		s.sort()
		($MMI.multimesh as MultiMesh).visible_instance_count = 0
		var j = 0
		for i: int in s[1] * s[2]:
			i = clampi(i - j, 0, 1 << 32)
			var cell := Vector3i(to_local(o.position).floor()).clamp(Vector3.ZERO, Vector3(size) - Vector3.ONE)
			var proj :=  (cell + Vector3i(get_viewport().get_camera_3d().global_basis.z * -2) * i)
			if proj == proj.clamp(Vector3i.ZERO, size - Vector3i.ONE):
				($MMI.multimesh as MultiMesh).set_instance_transform(i, Transform3D(Basis.IDENTITY, proj))
				sel.append(proj)
			else:
				j += 1
	if sel.size():
		($MMI.multimesh as MultiMesh).visible_instance_count = sel.size()
		select_orthogonal = sel
	selected.emit()
