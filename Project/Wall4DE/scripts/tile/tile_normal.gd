@icon("res://resources/icon/normal.png")
class_name TileBox
extends StaticBody3D

signal shape_index_changed

@export var box_shape := BoxShape3D.new()
@export var face_shape := SphereShape3D.new()
var data: Array[Dictionary]


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released():
			var t := Autoload.cast_ray(get_viewport().get_camera_3d(), event.position, 1 << Global.LAYER.TILE_FACE)
			if t.size():
				box_set_face(t.shape / 6, t.shape % 6, Autoload.main.grid.instamtiate)


func add_box(pos: Vector3i) -> int:
	var box := box_shape.duplicate()
	data.append({"shape": box})
	PhysicsServer3D.body_add_shape(get_rid(), box.get_rid(), Transform3D(Basis.IDENTITY, global_position + Vector3(pos) + Vector3.ONE * 0.5))
	data[-1]["face"] = []
	for i in 6:
		data[-1]["face"].append({"shape": face_shape.duplicate(), "type": Grid.TILE.NORMAL})
		PhysicsServer3D.area_add_shape($Face.get_rid(), data[-1]["face"][-1]["shape"].get_rid(),
			Transform3D($M/F.get_child(i).global_basis, PhysicsServer3D.body_get_shape_transform(get_rid(), data.size() - 1).origin).translated_local(Vector3.UP * 0.4))
	($MMIBox.multimesh as MultiMesh).visible_instance_count = data.size()
	($MMIBox.multimesh as MultiMesh).set_instance_transform(data.size() - 1, PhysicsServer3D.body_get_shape_transform(get_rid(), data.size() - 1))
	return data.size() - 1


func box_set_face(box: int, face: Global.ORIENTATION, type: Grid.TILE):
	if not data[box]["face"][face]["type"] == type:
		data[box]["face"][face]["type"] = type
	var mmic := range(Grid.TILE.size())
	mmic.fill(0)
	for i in data.size():
		for j in 6:
			if ($MMIFace.get_child(data[i]["face"][j]["type"])) is MultiMeshInstance3D:
				($MMIFace.get_child(data[i]["face"][j]["type"]).multimesh as MultiMesh).set_instance_transform(mmic[data[i]["face"][j]["type"]],
					Transform3D($M/F.get_child(j).global_basis, PhysicsServer3D.body_get_shape_transform(get_rid(), i).origin))
			elif data[i]["face"][j]["type"] == Grid.TILE.TRIGGER:
				($MMIFace.get_child(data[i]["face"][j]["type"]).get_child(0).multimesh as MultiMesh).set_instance_transform(mmic[data[i]["face"][j]["type"]],
					Transform3D($M/F.get_child(j).global_basis, PhysicsServer3D.body_get_shape_transform(get_rid(), i).origin))
			mmic[data[i]["face"][j]["type"]] += 1
	for i: Node3D in $MMIFace.get_children():
		if i.get_index() == Grid.TILE.TRIGGER:
			i.get_child(0).multimesh.visible_instance_count = mmic[i.get_index()]
		elif i is MultiMeshInstance3D:
			i.multimesh.visible_instance_count = mmic[i.get_index()]


func face_get_type(face: int):
	if face / 6 < data.size():
		return data[face / 6]["face"][face % 6]["type"]
	return -1


func face_get_transform(face: int) -> Transform3D:
	return PhysicsServer3D.area_get_shape_transform($Face.get_rid(), face)


func face_get_world_basis_override(face: int):
	if face / 6 < data.size():
		return data[face / 6]["face"][face % 6].get("basis_override",Basis.IDENTITY)
	return Basis.IDENTITY


func orientation_get_default_rotation(face: Global.ORIENTATION) -> Quaternion:
	return $M/F.get_child(face).quaternion

#
#func _on_face_slider_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#if body is Player:
		#if get_face_active(local_shape_index):
			#var bas := $MMIF.multimesh.get_instance_transform(local_shape_index) as Transform3D
			#if body.bas_w.y.round() == bas.basis.y.round():
				#body.constant_torque += -bas.basis.x * 10
				#body.angular_damp = 15
				#col += 1
#
#
#func _on_face_slidee_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#if body is Player:
		#if get_face_active(local_shape_index):
			#var bas := $MMIF.multimesh.get_instance_transform(local_shape_index) as Transform3D
			#if body.bas_w.y.round() == bas.basis.y.round():
				#body.constant_torque -= -bas.basis.x * 10
				#col -= 1
				#if col <= 0:
					#col = 0
					#body.constant_torque = Vector3.ZERO
					#body.angular_damp = 10
