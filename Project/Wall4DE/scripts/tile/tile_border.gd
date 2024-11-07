@icon("res://resources/icon/border.png")
class_name TileBorder
extends Node3D

enum BORDER{OOOO, IOOO, IIOO, IOIO, IIIO, IIII}

var draw := true
var grid_data:Dictionary
var plane := Plane()
var center := Vector3.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if draw:
				var o := Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.TILE_BOX)
				if o.size():
					plane = Plane(o.normal, PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin)
					center = PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin - Vector3.ONE * 0.5
					var npo := (Vector3i(center.round()))
					var npn := Global.NORMAL_ORIENTATION[Vector3i(plane.normal.round())] as int
					if not grid_data.has(npo):
						grid_data.merge({npo: {npn: 0}})
					if not grid_data[npo].has(npn):
						grid_data[npo].merge({npn: 0})
					redraw()
		else:
			plane = Plane(Vector3.ZERO, Vector3.ZERO)
			center = Vector3.ZERO
	elif event is InputEventScreenDrag:
		var o := Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.TILE_BOX)
		if o.size() and  plane.normal == o.normal and not center + Vector3.ONE * 0.5 == PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin:
			if plane.has_point(PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin):
				var new_plane = Plane(plane.normal, PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin)
				var new_tile = PhysicsServer3D.body_get_shape_transform(o.rid, o.shape).origin - Vector3.ONE * 0.5
				var npo := (Vector3i(new_tile.round()))
				var npn := Global.NORMAL_ORIENTATION[Vector3i(plane.normal.round())] as int
				if not grid_data.has(npo):
					grid_data.merge({npo: {npn: 0}})
				if not grid_data[npo].has(npn):
					grid_data[npo].merge({npn: 0})
				grid_data[npo][npn] = BitMask64._append(grid_data[npo][npn],
					Global.ORIENTED_DIRECTION[npn].find(Vector3i(center.round()) - (Vector3i(new_tile.round()))))
				plane = new_plane
				center = new_tile
				redraw()


func get_tile_face_border_data(center: Vector3i, face: Global.ORIENTATION, up: bool, right: bool, down: bool, left: bool) -> Dictionary:
	var arr := [up, right, down, left]
	var arr1 := [[up, right], [right, down], [down, left], [left, up]]
	if arr.count(true) == 4:
		return {"border": BORDER.OOOO, "rotation": 0}
	elif arr.count(false) == 4:
		return {"border": BORDER.IIII, "rotation": 0}
	elif arr.count(false) == 1:
		return {"border": BORDER.IOOO, "rotation": -(arr.find(false) - 1) + 2}
	elif arr.count(true) == 2:
		if arr[arr.find(true) - 2]:
			return {"border": BORDER.IOIO, "rotation": -(arr.find(false) - 1) + 1}
		else:
			return {"border": BORDER.IIOO, "rotation": -(arr1.find([true, true]) - 1)}
	elif arr.count(false) == 3:
		return {"border": BORDER.IIIO, "rotation": -(arr.find(true) - 1)}
	else:
		return {"border": BORDER.OOOO, "rotation": 0}
		printerr("???")


func redraw():
	var mmi := Array([$MMIF0, $MMIF1, $MMIF2, $MMIF3, $MMIF4, $MMIF5].map(func(x): return x.multimesh), TYPE_OBJECT, "MultiMesh", null) as Array[MultiMesh]
	var vic := PackedInt32Array(range(mmi.size()))
	vic.fill(0)
	for i: Vector3i in grid_data:
		for j: int in grid_data[i]:
			var border := get_tile_face_border_data.callv([i, j] + Array(BitMask64._has_array(grid_data[i][j], Global.DIRECTION.values()))) as Dictionary
			vic[border.border] += 1
			mmi[border.border].set_instance_transform(vic[border.border] - 1,
				$M/F.get_child(j).global_transform.translated(Vector3(i)).rotated_local(Vector3.UP, deg_to_rad(90 * border.rotation)))
	for i in mmi.size():
		mmi[i].visible_instance_count = vic[i]
