@tool
@icon("res://42/script/smart3D/combine_icon.svg")
extends Node3D
class_name SmartCombine3D

@export_category("Combine Mesh to")
@export var multi_mesh_instance: bool = false : set = _multi_instance
@export var single_mesh_instance: bool = false : set = _mesh_instance

var parent: Node3D
var surface_list:Array = []
var material_list:Array = []
var mesh_list:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent_node_3d()
	pass # Replace with function body.

# SetGet
func _multi_instance(value):
	if value:
		mesh_list = []
		surface_list = []
		material_list = []
		iterate(self, 2)
		create_multi()
		multi_mesh_instance = false

func _mesh_instance(value):
	if value:
		mesh_list = []
		surface_list = []
		material_list = []
		iterate(self, 1)
		create_single()
		single_mesh_instance = false


# Alle Nodes durchgehen
# modus=1 -> Single Mesh
# modus=2 -> Multi Meshes or Single Meshes
func iterate(node:Node, modus:int):
	if !node:
		return
	
	# Wenn die Node eine MeshInstance3D ist
	if node is MeshInstance3D:
		match(modus):
			1:
				get_single(node)
			2:
				get_multi(node)
	elif node is MultiMeshInstance3D:
		match(modus):
			1:
				get_single_m(node)
			2:
				get_multi_m(node)

		
	# Alle Kind Nodes von der Node durchgehen
	for child in node.get_children():
		iterate(child, modus)


# MultiMesches prüfen 
func get_multi(meshinst:MeshInstance3D):
	var mesh:Mesh = meshinst.mesh
	
	# Prüfen ob schon vorhanden
	for i in range(mesh_list.size()):
		if mesh_list[i].mesh == mesh:
			# neues Transform
			mesh_list[i].transf.append(meshinst.transform)
			
			# Zurück
			return
			
	# wenn noch nicht vorhanden
	# neues Multimesh hinzufügen
	mesh_list.append({
		"mesh": mesh
		, "transf": [meshinst.transform]
	})
func get_multi_m(meshinst:MultiMeshInstance3D):
	var multi:MultiMesh = meshinst.multimesh
	var mesh:Mesh = meshinst.multimesh.mesh
	
	# Prüfen ob schon vorhanden
	for i in range(mesh_list.size()):
		if mesh_list[i].mesh == mesh:
			# neues Transform
			for j in range(multi.instance_count):
				var transf:Transform3D = multi.get_instance_transform(j)
				transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
				transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
				transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
				transf = transf.scaled(meshinst.scale)
				transf.origin = meshinst.transform.origin + transf.origin
				mesh_list[i].transf.append(transf)
			
			# Zurück
			return
			
	# wenn noch nicht vorhanden
	var new_mesh = {
		"mesh": mesh
		, "transf": []
	}
	
	# neues Transform
	for j in range(multi.instance_count):
		var transf:Transform3D = multi.get_instance_transform(j)
		transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
		transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
		transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
		transf = transf.scaled(meshinst.scale)
		transf.origin = meshinst.transform.origin + transf.origin
		new_mesh.transf.append(transf)
	
	# neues Multimesh hinzufügen
	mesh_list.append(new_mesh)


# Alle Surfaces prüfen 
# und alle mit gleichen Material zusammenführen
func get_single(meshinst: MeshInstance3D):
	var mesh:Mesh = meshinst.mesh

	# Alle Surfaces im Mesh durchgehen
	for i in range(mesh.get_surface_count()):	
		var mat:Material = mesh.surface_get_material(i)
		
		# SurfaceTool prüfen
		var st:SurfaceTool = SurfaceTool.new()
		var isMaterial:bool = false
		for j in range(material_list.size()):
			var test_mat = material_list[j]
			if test_mat == mat:
				st = surface_list[j]
				isMaterial = true
				break

		# Wenn noch kein Material
		if isMaterial == false:
			# Material und Surfacetool merken
			st.set_material(mat)
			material_list.append(mat)
			surface_list.append(st)
		
		# Surface Daten hinzufügen
		st.append_from(mesh, i, meshinst.transform)
		
func get_single_m(meshinst: MultiMeshInstance3D):
	var multi:MultiMesh = meshinst.multimesh
	var mesh:Mesh = multi.mesh

	# Alle Surfaces im Mesh durchgehen
	for i in range(mesh.get_surface_count()):	
		var mat:Material = mesh.surface_get_material(i)
		
		# SurfaceTool prüfen
		var st:SurfaceTool = SurfaceTool.new()
		var isMaterial:bool = false
		for j in range(material_list.size()):
			var test_mat = material_list[j]
			print("material_list: ", material_list)
			print("surface_list: ", surface_list)
			if test_mat == mat:
				st = surface_list[j]
				isMaterial = true
				break

		# Wenn noch kein Material
		if isMaterial == false:
			# Material und Surfacetool merken
			st.set_material(mat)
			material_list.append(mat)
			surface_list.append(st)
		
		# Surface Daten hinzufügen
		for j in range(multi.instance_count):
			var transf:Transform3D = multi.get_instance_transform(j)
			transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
			transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
			transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
			transf = transf.scaled(meshinst.scale)
			transf.origin = meshinst.transform.origin + transf.origin
			st.append_from(mesh, i, transf)
		
		#st.append_from(mesh, i, meshinst.transform)


# erzeuge Multimesh Instanzen
func create_multi():
	# Mesh Liste durchgehen
	for i in range(mesh_list.size()):
		var new_mesh = mesh_list[i]
		var count = new_mesh.transf.size()
		
		# wenn mehrere Instanzen
		if count > 1:
			var mm:MultiMesh = MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.instance_count = count
			mm.mesh = new_mesh.mesh
			for j in range(count):
				mm.set_instance_transform(j, new_mesh.transf[j])
			var mmi:MultiMeshInstance3D = MultiMeshInstance3D.new()
			mmi.multimesh = mm
			mmi.name = "multi_" + str(i)
			parent.add_child(mmi)
			mmi.owner = self.owner
		else:
			# nur eine Mesh
			var mi:MeshInstance3D = MeshInstance3D.new()
			mi.mesh = new_mesh.mesh
			mi.transform = new_mesh.transf[0]
			mi.name = "mesh_" + str(i)
			parent.add_child(mi)
			mi.owner = self.owner


# erzeuge (single) MeshInstance
func create_single():
	var am:ArrayMesh = ArrayMesh.new()
	
	# Alle Oberflächen durchgehen
	for i in range(surface_list.size()):
		var st:SurfaceTool = surface_list[i]
		st.commit(am)
	
	var mi:MeshInstance3D = MeshInstance3D.new()
	mi.mesh = am
	mi.transform = self.transform
	mi.name = "mesh_instance"
	parent.add_child(mi)
	mi.owner = self.owner
	
