@icon("res://icon.svg")
class_name Player
extends RigidBody3D

signal face_tile_changed

var req := Vector2.ZERO
var spawn := 0
var checkpoint := -1
var face_tile := {
	Global.ORIENTATION.UP: -	1,
	Global.ORIENTATION.DOWN: -1,
	Global.ORIENTATION.RIGHT: -1,
	Global.ORIENTATION.LEFT: -1,
	Global.ORIENTATION.FORWARD: -1,
	Global.ORIENTATION.BACK: -1,
}


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if event.velocity.length() >= get_viewport().get_visible_rect().size.y * 0.4:
			req = event.velocity.normalized().rotated(deg_to_rad(-30))


func charge_impulse(direction: Vector3, force: float):
	var t := create_tween()
	t.tween_method((func (v: float, g: Vector3):
		linear_damp = 1.0 + v * 10.0
		apply_torque((global_position.direction_to(g + direction.normalized()) * (1.0 + v) * 1.25 * 10.0))
		apply_force(global_position.direction_to(g) * (1.0 + v) * 1.25 * 10.0)).bind(global_position + direction.normalized()), 0.0, 1.0, 0.5)
	t.tween_callback(apply_central_impulse.bind(direction.normalized() * force * 2 * 5))
	t.tween_interval(0.3)
	t.tween_callback(set.bind("linear_damp", 1.0))
	t.tween_callback((func ():
		if req:
			apply_central_impulse(Vector3(req.x, 0, req.y).normalized() * Autoload.basis.inverse() * 2)
		req = Vector2.ZERO))


func _physics_process(delta: float) -> void:
	apply_central_force(-Autoload.basis.y * 10)
	var ray := PhysicsRayQueryParameters3D.new()
	ray.collision_mask = 1 << 1
	ray.from =  global_position
	for i in 4:
		ray.to = global_position - Autoload.basis.y + Autoload.basis.x.rotated(Autoload.basis.y, deg_to_rad(90 * i)) * 0.1
		var res := get_world_3d().direct_space_state.intersect_ray(ray)
		if res.size():
			apply_torque(Autoload.basis.y.cross(global_position.direction_to(PhysicsServer3D.body_get_shape_transform(res.rid, res.shape).origin + res.normal)) * 5)
			break
	if get_tree().get_frame() % 10 == 0:
		_update_colliding_face()


func impulse(direction: Vector3i, force: int):
	apply_torque((Autoload.basis.y).cross(Vector3(direction) * Autoload.basis.inverse()) * force * 10)


func _update_colliding_face():
	$Raycast.global_transform = Transform3D(Autoload.basis, global_position)
	for i in range(6):
		var r := $Raycast.get_child(i) as RayCast3D
		if r.is_colliding():
			face_tile[i] = r.get_collider_shape()
			continue
		face_tile[i] = -1
	face_tile_changed.emit()
