extends Node

var main: Main
var basis := Basis.IDENTITY
var time_flag := {"delta": 0.0}


func get_elapsed_time(key: Variant) -> float:
	return Time.get_ticks_msec() - time_flag.get(key, Time.get_ticks_msec())


func cast_ray(camera: Camera3D, pos: Vector2, mask: int) -> Dictionary:
	var ray := PhysicsRayQueryParameters3D.new()
	ray.collide_with_areas = true
	ray.collision_mask = mask
	ray.from = camera.project_ray_origin(pos)
	ray.to = camera.project_position(pos, 1000)
	return camera.get_world_3d().direct_space_state.intersect_ray(ray)
