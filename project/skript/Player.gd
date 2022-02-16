extends RigidDynamicBody3D
var move : Vector3 = Vector3(0,0,0)
var rotate: Vector3 = Vector3(0,0,0)
var camera_rotate: Vector3 = Vector3(0,0,0)
var gravity : float = 0.66743*1.2
var gravity_force : Vector3 = Vector3(0,-1,0)
var ball_mass : int = 2
var purse_count : int = 0
func _ready():
	set_physics_process(true);
func _physics_process(_delta):
	get_parent().get_node("cambase").position = self.position
	if Input.is_action_pressed("view_up"):
		if camera_rotate.x <= deg2rad(90):
			camera_rotate.x = camera_rotate.x+0.02
	elif Input.is_action_pressed("view_down"):
		if camera_rotate.x >= -deg2rad(90):
			camera_rotate.x = camera_rotate.x-0.02
	if Input.is_action_pressed("view_right"):
		rotate.y = rotate.y-0.04
	elif Input.is_action_pressed("view_left"):
		rotate.y = rotate.y+0.04
	if Input.is_action_pressed("move_forward"):
		if move.x < 2:
			move.x = move.x-0.04
	elif Input.is_action_pressed("move_backward"):
		if move.x > -2:
			move.x = move.x+0.04
	if Input.is_action_pressed("move_right"):
		if move.z < 2:
			move.z = move.z-0.04
	elif Input.is_action_pressed("move_left"):
		if move.z > -2:
			move.z = move.z+0.04
	if Input.is_action_pressed("move_jump") and get_colliding_bodies().size() != 0:
			add_constant_central_force(150*Vector3(0,1,0))
	else:
		constant_force = Vector3(0,0,0)
	move *= 0.95
	angular_velocity = move.rotated(Vector3(0,1,0), rotate.y)*32
	get_parent().get_node("cambase").rotation = rotate
	get_parent().get_node("cambase/Camera3D").rotation = camera_rotate
