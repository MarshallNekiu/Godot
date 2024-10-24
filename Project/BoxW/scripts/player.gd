extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var c := true
var spawner := 0
var moving := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity -= up_direction * delta * 10
	move_and_slide()


func x(dir := -1, identity := Basis.IDENTITY):
	if not moving and is_on_floor():
		moving = true
		var tween := create_tween().tween_method((func (v, t: Transform3D): global_transform = Transform3D(t.basis.rotated(Vector3.BACK * identity.inverse(), dir * deg_to_rad(-v)), t.origin + Vector3.RIGHT * identity.inverse() * dir * (v / 90.0))).bind(
			global_transform), 0.0, 90.0, 0.3)
		tween.finished.connect(set.bind("moving", false))


func z(dir := -1, identity = Basis.IDENTITY):
	if not moving and is_on_floor():
		moving = true
		var tween := create_tween().tween_method((func (v, t: Transform3D): global_transform = Transform3D(t.basis.rotated(Vector3.RIGHT * identity.inverse(), dir * deg_to_rad(-v)), t.origin + Vector3.FORWARD * identity.inverse() * dir * (v / 90.0))).bind(
			global_transform), 0.0, 90.0, 0.3)
		tween.finished.connect(set.bind("moving", false))
