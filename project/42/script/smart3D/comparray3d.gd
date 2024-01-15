@tool
@icon("res://42/script/smart3D/array_icon.svg")
extends Node3D
class_name CompArray3D

# Linear, Array, radial
# Deform
@export_category("Array")
@export_group("Count")
@export var count_x: int = 1 : set = _count_x
@export var count_y: int = 1 : set = _count_y
@export var count_z: int = 1 : set = _count_z

@export_group("Margin")
@export_range(0.0, 3.0, 0.01) var margin_x:float = 0.0 : set = _margin_x
@export_range(0.0, 3.0, 0.01) var margin_y:float = 0.0 : set = _margin_y
@export_range(0.0, 3.0, 0.01) var margin_z:float = 0.0 : set = _margin_z

#@export_group("Random")
#@export var random_pos: Vector3 = Vector3(0, 0 ,0) : set = _random_pos
#@export var random_scale: Vector3 = Vector3(0.0, 0.0 ,0.0) : set = _random_scale
#@export var random_rotation: Vector3 = Vector3(0.0, 0.0 ,0.0) : set = _random_rotation

# ================================
#   Variablen
# ------------

var parent:Node3D = null	# Parent
var box:AABB
var mesh:Mesh = null
var multimesh:MultiMesh = null
var is_multimesh:bool = false

# ====================================
#   Setter
# ---------
func _count_x(value):
	if value < 1:
		value = 1
	count_x = value
	is_multimesh = false
	calculate_pos()
func _count_y(value):
	if value < 1:
		value = 1
	count_y = value
	is_multimesh = false
	calculate_pos()
func _count_z(value):
	if value < 1:
		value = 1
	count_z = value
	is_multimesh = false
	calculate_pos()

func _margin_x(value):
	margin_x = value
	calculate_pos()
func _margin_y(value):
	margin_y = value
	calculate_pos()
func _margin_z(value):
	margin_z = value
	calculate_pos()


#func _random_pos(value:Vector3):
	#random_pos = value
	#calculate_pos()
#func _random_scale(value:Vector3):
	#random_scale = value
	#calculate_pos()
#func _random_rotation(value:Vector3):
	#random_rotation = value
	#calculate_pos()


# Eltern Element lesen
func search_parent():
	is_multimesh = false
	parent = self.get_parent_node_3d()
	if parent is MeshInstance3D:
		mesh = parent.mesh
		if !mesh:
			return
		var new_parent:MultiMeshInstance3D = MultiMeshInstance3D.new()
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = mesh
		new_parent.multimesh = multimesh
		new_parent.transform = parent.transform
		
		# Ersetzen und löschen
		parent.replace_by(new_parent)
		parent.queue_free()
		parent = new_parent
	elif parent is MultiMeshInstance3D:
		multimesh = parent.multimesh
		mesh = multimesh.mesh
	else:
		return
		
	# Göße bestimmen
	box = mesh.get_aabb()
	#box.size *= parent.scale
	
	# Signal verbinden
	#if !parent.property_list_changed.is_connected(_parent_changed):
	#parent.property_list_changed.connect(_parent_changed)
	
	# ist Multimesh
	is_multimesh = true


# Größe ermitteln
func get_box():
	if !is_multimesh:
		return
	
	if !mesh:
		return
	
	box = mesh.get_aabb()
	


func calculate_pos():
	if !is_multimesh:
		search_parent()
	if !is_multimesh:
		return
		
	# Position
	var base:Basis = Basis()
	var pos:Vector3 = Vector3.ZERO
	var change_x:float = box.size.x + margin_x / parent.scale.x
	var change_y:float = box.size.y + margin_y / parent.scale.y
	var change_z:float = box.size.z + margin_z / parent.scale.z
	
	# Anzahl der Elemente zurücksetzen
	var count = 0
	multimesh.instance_count = count_x * count_y * count_z

	# Alle Richtungen durchgehen
	for x in range(count_x):
		for y in range(count_y):
			for z in range(count_z):
				pos = Vector3(change_x * x, change_y * y, change_z * z)
				multimesh.set_instance_transform(count, Transform3D(base, pos))
				count += 1
				#print("box.size: ", box.size)
				#print("count: ", count, " - transform: ", Transform3D(base, pos))

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	search_parent()

