extends Camera2D


export (OpenSimplexNoise) var noise # tekstura za vizualizacijo ma kopijo tega noisa


# šejkanje
export(float, 0, 1) var trauma = 0.0
export var trauma_time = 0 # decay delay
export var max_horizontal = 150
export var max_vertical = 150
export var max_rotation = 25
export(float, 0, 1) var decay = 0.5
export(float, 0, 1) var add_trauma = 0.05
export var time_speed: float = 150 # za offset noise
var time: float = 0 # za offset noise

# gejm šejk
var shake_on: bool = false
export (float, 0, 1) var bolt_explosion_shake = 0.5 # explosion add_trauma
export (float, 0, 1) var bullet_hit_shake = 0.2 # bullet add_trauma
export (float, 0, 1) var misile_hit_shake = 0.4 # misile add_trauma

# test hud
var test_view_on = false

# mouse drag 
var mouse_used: bool = false # če je miška ni redi za dreganje ekrana
var camera_center = Vector2(320, 180)
var mouse_position_on_drag_start: Vector2 # zamik pozicije miške ob kliku
var drag_on: bool = false

# ui
onready var trauma_bar = $UILayer/TestHud/TraumaBar
onready var shake_bar = $UILayer/TestHud/ShakeBar
onready var trauma_btn = $UILayer/TestHud/AddTraumaBtn
onready var reset_view_btn = $UILayer/TestHud/ResetViewBtn
onready var zoom_slider = $UILayer/TestHud/ZoomSlider
onready var time_slider = $UILayer/TestHud/TimeSlider
onready var seed_slider = $UILayer/TestHud/NoiseControl/Seed
onready var octaves_slider = $UILayer/TestHud/NoiseControl/Octaves
onready var period_slider = $UILayer/TestHud/NoiseControl/Period
onready var persistence_slider = $UILayer/TestHud/NoiseControl/Persistence
onready var lacunarity_slider = $UILayer/TestHud/NoiseControl/Lacunarity

onready var testhud_node = $UILayer/TestHud
onready var test_toggle_btn = $UILayer/TestToggle


func _ready():

	Glo.print_id(name)
	Glo.main_camera = self
	Glo.camera_target = null # da se nulira (pri quit game) in je naslednji play brez errorja ... seta se ob spawnanju plejerja

	position = Glo.level_start_position.global_position

	# ---

#	print("KAMERA")
	Glo.current_camera = self

	testhud_node.hide()
	test_toggle_btn.set_focus_mode(0)

	trauma_btn.set_focus_mode(0)
	reset_view_btn.set_focus_mode(0)
	zoom_slider.set_focus_mode(0)
	time_slider.set_focus_mode(0)
	seed_slider.set_focus_mode(0)
	octaves_slider.set_focus_mode(0)
	period_slider.set_focus_mode(0)
	persistence_slider.set_focus_mode(0)
	lacunarity_slider.set_focus_mode(0)

	zoom_slider.hide()

	# noise setup
	noise.seed = 2
	noise.octaves = 1
	noise.period = 10
	noise.persistence = 0
	noise.lacunarity = 1

	seed_slider.value = noise.seed
	octaves_slider.value = noise.octaves
	period_slider.value = noise.period 
	persistence_slider.value = noise.persistence
	lacunarity_slider.value = noise.lacunarity 


func _input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("left_click") and test_view_on and not mouse_used:
		drag_on = true
		mouse_position_on_drag_start = get_global_mouse_position() # definiraj zamik pozicije miške napram centru

	if Input.is_action_just_released("left_click"):
		drag_on = false

	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP) and test_view_on:
		zoom -= Vector2(0.1, 0.1)

	if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN) and test_view_on:
		zoom += Vector2(0.1, 0.1)
		drag_on = false


func _process(delta):
	time += delta

	# start decay
#	var shake = pow(trauma, 2) # narašča s kvadratno funkcijo 
	var shake = trauma
	offset.x = noise.get_noise_3d(time * time_speed, 0, 0) * max_horizontal * shake
	offset.y = noise.get_noise_3d(0, time * time_speed, 0) * max_vertical * shake
	rotation_degrees = noise.get_noise_3d(0, 0, time * time_speed) * max_rotation * shake

	# start decay
	if trauma > 0:
		yield(get_tree().create_timer(trauma_time), "timeout")
		trauma = clamp(trauma - (delta * decay), 0, 1)

	# UI
	trauma_bar.value = trauma
	shake_bar.value = shake
	seed_slider.value = noise.seed
	octaves_slider.value = noise.octaves
	period_slider.value = noise.period 
	persistence_slider.value = noise.persistence
	lacunarity_slider.value = noise.lacunarity 

	# drag
	if drag_on:
		position += mouse_position_on_drag_start - get_global_mouse_position()


func _physics_process(delta: float) -> void:

#	if camera_target:
#		position = camera_target.position
	if Glo.camera_target:
		position = Glo.camera_target.position

	pass


func reset_camera_position():
	
	drag_margin_top = 0
	drag_margin_bottom = 0
	drag_margin_left = 0
	drag_margin_right = 0
	position = Glo.level_start_position.global_position

	yield(get_tree().create_timer(1), "timeout")

	drag_margin_top = 0.2
	drag_margin_bottom = 0.2
	drag_margin_left = 0.3
	drag_margin_right = 0.3


func add_trauma(added_trauma):
	trauma = clamp(trauma + added_trauma, 0, 1)

# TESTHUD

func _on_CheckBox_toggled(button_pressed: bool) -> void:

	if test_view_on:
		test_view_on = false
		testhud_node.hide()
	else:
		testhud_node.show()
		test_view_on = true
func _on_CheckBox_mouse_entered() -> void:
	mouse_used = true
func _on_CheckBox_mouse_exited() -> void:
	mouse_used = false

func _on_AddTraumaBtn_pressed() -> void:
	mouse_used = true
	add_trauma(add_trauma)
func _on_AddTraumaBtn_mouse_entered() -> void:
	mouse_used = true
func _on_AddTraumaBtn_mouse_exited() -> void:
	mouse_used = false

# noise

func _on_Control_mouse_entered() -> void:
	mouse_used = true
func _on_Control_mouse_exited() -> void:
	mouse_used = false

func _on_Seed_value_changed(value: float) -> void:
	noise.seed = value
func _on_SeedSlider_mouse_entered() -> void:
	mouse_used = true
func _on_SeedSlider_mouse_exited() -> void:
	mouse_used = false

func _on_Octaves_value_changed(value: float) -> void:
	noise.octaves = value
func _on_Octaves_mouse_entered() -> void:
	mouse_used = true
func _on_Octaves_mouse_exited() -> void:
	mouse_used = false

func _on_Period_value_changed(value: float) -> void:
	noise.period = value
func _on_Period_mouse_entered() -> void:
	mouse_used = true
func _on_Period_mouse_exited() -> void:
	mouse_used = false

func _on_Persistence_value_changed(value: float) -> void:
	noise.persistence = value
func _on_Persistance_mouse_entered() -> void:
	mouse_used = true
func _on_Persistance_mouse_exited() -> void:
	mouse_used = false

func _on_Lacunarity_value_changed(value: float) -> void:
	noise.lacunarity = value
func _on_Lacunarity_mouse_entered() -> void:
	mouse_used = true
func _on_Lacunarity_mouse_exited() -> void:
	mouse_used = false

# os time

func _on_TimeSlider_value_changed(value: float) -> void:
	Engine.time_scale = value
func _on_TimeSlider_mouse_entered() -> void:
	mouse_used = true
func _on_TimeSlider_mouse_exited() -> void:
	mouse_used = false

# zoom

func _on_ResetView_mouse_entered() -> void:
	mouse_used = true
func _on_ResetView_mouse_exited() -> void:
	mouse_used = false
func _on_ResetView_pressed() -> void:
	position = Vector2.ZERO + camera_center 
	zoom = Vector2.ONE

func _on_ZoomSlider_mouse_entered() -> void:
	mouse_used = true
func _on_ZoomSlider_mouse_exited() -> void:
	mouse_used = false
func _on_ZoomSlider_value_changed(value: float) -> void:
	zoom = Vector2(value, value)
