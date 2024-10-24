@tool
extends Area3D

signal select_input(input: InputEvent)

@export var size := Vector3i.ONE * 4:
	set(x):
		size = x
		set_size(x)

var lock := false
var focus := -1
var select := Vector3.ZERO
var plane := Vector3.ZERO


func _ready() -> void:
	set_size(size)



func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if lock:
			return
		var camera := get_viewport().get_camera_3d()
		if focus == 0:
			$X.position = Plane(Vector3.FORWARD, plane).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(1, 1, 0)
			$Y.position = Vector3($X.position.x, 0, select.z)
			$Z.position =Vector3(0, $X.position.y, select.z)
			select = Vector3($X.position.x, $X.position.y, select.z)
		elif focus == 1:
			$Y.position = Plane(Vector3.UP, plane).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(1, 0, 1)
			$X.position = Vector3($Y.position.x, select.y, 0)
			$Z.position = Vector3(0, select.y, $Y.position.z)
			select = Vector3($Y.position.x, select.y, $Y.position.z)
		elif focus == 2:
			$Z.position = Plane(Vector3.RIGHT, plane).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position)).snappedf(1) * Vector3(0, 1, 1)
			$X.position = Vector3(select.x, $Z.position.y, 0)
			$Y.position = Vector3(select.x, 0, $Z.position.z)
			select = Vector3(select.x, $Z.position.y, $Z.position.z)
		$X.position = $X.position.clamp(Vector3.ZERO, size - Vector3i.ONE)
		$Y.position = $Y.position.clamp(Vector3.ZERO, size - Vector3i.ONE)
		$Z.position = $Z.position.clamp(Vector3.ZERO, size - Vector3i.ONE)
		select = select.clamp(Vector3.ZERO, size - Vector3i.ONE)
		$O.position = select
	elif event is InputEventScreenTouch:
		if focus == 3:
			select_input.emit(event)
		if lock:
			return
		if event.is_pressed():
			var target := Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, collision_layer)
			if target.size():
				focus = target.shape
				plane = target.position
		elif event.is_released():
			focus = -1


func set_size(_size: Vector3i):
	for i in 3:
		var shape := ConvexPolygonShape3D.new()
		shape.points = ([Vector3.ZERO, Vector3.UP, Vector3.RIGHT, Vector3(1, 1, 0)] + [Vector3.ZERO, Vector3.UP, Vector3.RIGHT, Vector3(1, 1, 0)].map(func (x): return Vector3.ZERO + x + Vector3.FORWARD * _size[i]))
		[$Z, $Y, $X][i].shape.points = shape.points
		var mesh = ArrayMesh.new()
		var arr := BoxMesh.new().surface_get_arrays(0)
		arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(Array(arr[Mesh.ARRAY_VERTEX]).map(func (x): return Vector3.BACK + (x + Vector3.ONE * 0.5) + ((Vector3.FORWARD * _size[i]) if x.z < 0 else Vector3.ZERO)))
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		[$Z/Node3D, $Y/Node3D, $X/Node3D][i].scale.z = -_size[i]
		#[$Z/Mesh, $Y/Mesh, $X/Mesh][i].mesh = mesh
	$X.position = $X.position.clamp(Vector3.ZERO, size)
	$Y.position = $Y.position.clamp(Vector3.ZERO, size)
	$Z.position = $Z.position.clamp(Vector3.ZERO, size)
	select = select.clamp(Vector3.ZERO, size)
	$O.position = select
