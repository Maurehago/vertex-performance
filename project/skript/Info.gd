extends CanvasLayer

var delay = 0.0

@onready var fpsLabel = $MarginContainer/CenterContainer/VBoxContainer/fpsLabel
@onready var timeProcess = $MarginContainer/CenterContainer/VBoxContainer/timeProcess
@onready var drawCalls = $MarginContainer/CenterContainer/VBoxContainer/drawCalls
@onready var vertices = $MarginContainer/CenterContainer/VBoxContainer/vertices
@onready var memory = $MarginContainer/CenterContainer/VBoxContainer/memory


func _physics_process(delta):
	delay += delta
	if delay >= 0.5:
		delay = 0.0
		fpsLabel.set_text("FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)))
		timeProcess.set_text("Time Process: " + str(Performance.get_monitor(Performance.TIME_PROCESS)))
		drawCalls.set_text("Render Draw Calls: ")
		vertices.set_text("Vertices (in millions): ")
		memory.set_text("Video Memory (Vertex, Texture) : " + str(Performance.get_monitor(Performance.MEMORY_STATIC) /1024/1024) + "MB (vert: " + "MB / tex: " +"MB )")
		# Performance.RENDER_MATERIAL_CHANGES_IN_FRAME
		# Performance.RENDER_SHADER_CHANGES_IN_FRAME
		# Performance.RENDER_VERTICES_IN_FRAME
		# MEMORY_STATIC 
		# RENDER_VIDEO_MEM_USED = 18The amount of video memory used, i.e. texture and vertex memory combined.
		# RENDER_TEXTURE_MEM_USED = 19The amount of texture memory used.
		# RENDER_VERTEX_MEM_USED = 20
