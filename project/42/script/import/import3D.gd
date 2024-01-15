@tool # Needed so it runs in the editor.
extends EditorScenePostImport

# Speicherpfade
var save_path: String
var mat_path: String = "res://42/mat/"
var scene_path: String = "res://scene/"

# DirAccess
var dir: DirAccess = DirAccess.open(scene_path)

var subName: String = ""	# Name vom Ordner und Scene
var check_map:Dictionary = {}


func check_mesh(node: Node3D) -> void:
	#print("check_mesh")
	if !node is Node3D:
		return
	
	# nur wenn MeshInstance mit Mesh
	if node is MeshInstance3D and node.mesh:
		var mesh: Mesh = node.mesh
		var instanceName = mesh.resource_name.substr(len(subName) +1)
		var res_path = save_path + instanceName + ".mesh"
		
		# nur wenn noch nicht vorhanden
		if !check_map.has(instanceName):
			# resource merken
			check_map[instanceName] = res_path
			
			# alle Surfaces durchgehen
			for i in range(mesh.get_surface_count()):
				# Material bearbeiten
				var mat:Material = mesh.surface_get_material(i)
				var mat_name:String = mat.resource_name
				var mat_file:String = mat_path + mat_name + ".material"
				if FileAccess.file_exists(mat_file):
					mesh.surface_set_material(i, load(mat_file))
				else:
					mesh.surface_set_material(i, null)
			
			# Mesh als Resource speichern
			#print("save")
			var err = ResourceSaver.save(mesh, res_path)

		# Node aktuallisiern
		mesh.resource_path = res_path
	pass

# Alle Nodes prüfen
func check_node(node):
	#print("check_node")
	if node != null:
		check_mesh(node)
		
		for child in node.get_children():
			check_node(child)


# wird nach dem Import ausgeführt
func _post_import(scene):
	#print("_post_import")
	
	# Namen lesen
	subName = scene.name
	if !subName:
		return

	# ordner prüfen
	save_path = scene_path + subName + "/"
	if !dir.dir_exists(save_path):
		dir.make_dir(save_path)

	# Startwerte
	var scene_url = save_path + subName + ".tscn"
	check_map = {}
	
	# Szene prüfen
	check_node(scene)
	
	# Neue Scene speichern
	var new_scene: PackedScene = PackedScene.new()
	var result = new_scene.pack(scene)
	if result == OK:
		var error = ResourceSaver.save(new_scene, scene_url)
		if error:
			push_error("Error: saving scene " + scene_url)

	# Do your stuff here.
	return scene # remember to return the imported scene
