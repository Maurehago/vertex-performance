@tool
@icon("res://42/script/smart3D/csg_icon.svg")
extends CSGCombiner3D
class_name SmartCSG3D

@export_category("Smart Instance")
@export var mesh_instance: bool = false : set = _mesh_instance

var parent: Node3D


func _ready():
	# Eltern Node lesen
	parent = self.get_parent_node_3d()


func _mesh_instance(value):
	if value:
		create_instance()
		mesh_instance = false

func create_instance():
	# Shapes aktualiesieren
	self._update_shape()
	var mesh_info = self.get_meshes() # 0 = Transform, 1 = Mesh
	var mesh = mesh_info[1]
	var mi:MeshInstance3D = MeshInstance3D.new()
	mi.mesh = mesh
	
	# In Nodebaum hängen
	parent.add_child(mi)
	mi.owner = self.owner
	mi.transform = mesh_info[0]
