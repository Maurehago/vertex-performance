# meta-name: 3D First Person Movement 
# meta-description: Bewegungsvorlage für einen Spieler aus Kamera Sicht
# meta-default: true
# meta-space-indent: 4
extends CharacterBody3D

@export var camera : Camera3D
@export_group("Movement")
@export var max_speed: float = 5.0 			# Geschwindigkeit des Spielers
@export var accel: float = 0.5 			# Beschleunigung des Spielers
@export var deaccel: float = 1.0 			# Abbremsen des Spielers
@export var jump_velocity: float = 4.5	# Sprunghöhe
@export_group("Mouse")
@export var mouse_sensivity: float =  0.25	# Geschwindigkeit der Mausdrehung
@export var invert_mouse_y := false # Y-Achse invertieren
@export var invert_mouse_x := false # X-Achse invertieren
@export_group("Step")
@export var step_height := 0.25 # Wie hoch sind die stufen die bestiegen werden sollen


var mouse_captured := false	# Merkt sich ob die Maus gefangen ist
const min_camRotX := -PI/2	# kleinster Winkel in radians bis zu dem man nach unten sehen kann
const max_camRotX := PI/2	# größter Winkel in radians bis zu dem man nach oben sehen kann
var direction := Vector3.ZERO	# Tasten Bewegungs Richtung
var input_vector := Vector2.ZERO # Eingabe vektor
var step_ray:RayCast3D
var step_move:float = 0.0
var is_jump:bool = false

# Gravitation von den Projekt Einstellungen laden damit diese mit den RigidBody Nodes synchron ist.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# test: nur zum Testen drinnen
#var testy:MeshInstance3D

# Tastatur Eingabe Festlegen
func _set_inputs():
	# Tasten Codes
	var new_foreward = InputEventKey.new()
	var new_back = InputEventKey.new()
	var new_left = InputEventKey.new()
	var new_right = InputEventKey.new()
	var new_jump = InputEventKey.new()
	var new_switchmode = InputEventKey.new()

	new_foreward.keycode = KEY_W
	new_back.keycode = KEY_S
	new_left.keycode = KEY_A
	new_right.keycode = KEY_D
	new_jump.keycode = KEY_SPACE
	new_switchmode.keycode = KEY_TAB
	
	# Zuordnung speichern wenn noch nicht vorhanden
	if !InputMap.has_action("move_foreward"):
		InputMap.add_action("move_foreward")
		InputMap.action_add_event("move_foreward", new_foreward)
	if !InputMap.has_action("move_back"):
		InputMap.add_action("move_back")
		InputMap.action_add_event("move_back", new_back)
	if !InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		InputMap.action_add_event("move_left", new_left)
	if !InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		InputMap.action_add_event("move_right", new_right)
	if !InputMap.has_action("move_jump"):
		InputMap.add_action("move_jump")
		InputMap.action_add_event("move_jump", new_jump)
	if !InputMap.has_action("switchmode"):
		InputMap.add_action("switchmode")
		InputMap.action_add_event("switchmode", new_switchmode)


# Raystrahl für Treppen Erkennung
func _setup_step_ray() -> void:
	step_ray = RayCast3D.new()
	step_ray.position.y = step_height + 0.01
	
	# test: nur zum Testen
	#testy.position.y = step_height + 0.01
	
	step_ray.target_position = Vector3(0, -step_height, 0)
	add_child(step_ray)
	

# Prüfen ob mit einer Treppe kollidiert
func check_ray_collision() -> bool:
	#print("ray_pos: ", step_ray.global_position)
	if step_ray.is_colliding():
		# Y-Normale der Stufe lesen
		var n = step_ray.get_collision_normal().y
		#print("step Normal: ", n)
		if n >= 0.9 and n <= 1:
			step_move = step_ray.global_position.y - step_ray.get_collision_point().y
			return true
			
	return false


# Beim Start ausführen
func _ready() -> void:
	# test: nur zum Testen
	#testy = $testy
	
	# Auf vorhandene Kamera prüfen
	camera = $Camera3D
	if camera == null:
		push_warning("player_first_person.gd: Keine Kamera im Inspektor festgelegt. Suche nach Camera3D...")
		for child in get_children():
			if child is Camera3D:
				camera = child
	
	# Ray Strahl für Treppe 
	_setup_step_ray()
	
	# Tastenzuordnung festlegen
	_set_inputs()
	
	# Maus fangen
	capture_mouse()

# Eingaben prüfen
func _input(event):
	# Wenn Maus Bewegung (Umschauen)
	if event is InputEventMouseMotion and mouse_captured:
		var x_multiplier = -1 if invert_mouse_x else 1
		var y_multiplier = -1 if invert_mouse_y else 1
		rotate_y(-event.relative.x * 0.01 * mouse_sensivity * x_multiplier)
		camera.rotate_x(-event.relative.y * 0.01 * mouse_sensivity * y_multiplier)
		
		camera.rotation.x = clampf(camera.rotation.x, min_camRotX, max_camRotX)


func _process(_delta) -> void:
	# Maus Fang Modus umschalten
	if Input.is_action_just_pressed("switchmode"):
		capture_mouse()
	
	if !mouse_captured:
		return

	# Springen
	if Input.is_action_just_pressed("move_jump"):
		is_jump = true

	# Bewegungsrichtung bestimmen
	input_vector = Input.get_vector("move_left", "move_right", "move_back", "move_foreward")
	# Richtung Normalisieren, so dass in alle Richtungen die Geschwindigkeit konstant ist
	direction = (global_transform.basis.x * input_vector.x + -global_transform.basis.z * input_vector.y).normalized()
	#print("direction: ", direction)
	
	# Ray positionieren
	step_ray.position.x =  input_vector.x * 0.7 # .x = direction.x 
	step_ray.position.z =  -input_vector.y * 0.7
	#step_ray.position.z = -direction.z 

	# test: nur zum Testen
	#testy.position.x =  input_vector.x * 0.7 # .x = direction.x 
	#testy.position.z =  -input_vector.y * 0.7
	#testy.position.z = -direction.z 
	

func _physics_process(delta) -> void:
	var treppe:bool = check_ray_collision()
	# Treppe
	if input_vector != Vector2.ZERO and treppe:
		# kraft, die nur etwas größer als schwerkraft ist um spieler anzuheben
		#print("step_move: ", step_move)
		velocity.y += step_move #+ gravity * delta + 0.1
			
		# Springen
		if is_jump:
			velocity.y += jump_velocity
	elif is_on_floor():
		# Springen
		if is_jump:
			velocity.y += jump_velocity
	# Gravitation berücksichtigen
	elif !treppe and step_move:
		velocity = Vector3.ZERO
		step_move = 0.0
	elif !treppe:
		velocity.y -= gravity * delta
		is_jump = false
	
	# Beschleunigen oder Bremsen
	var accel_to_use = accel if direction != Vector3.ZERO else deaccel
	velocity = velocity.move_toward(Vector3(max_speed, velocity.y, max_speed) * Vector3(direction.x, 1, direction.z), accel_to_use)
	move_and_slide()


# zwischen Maus und Spielerbewegung umschalten
func capture_mouse() -> void:
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
