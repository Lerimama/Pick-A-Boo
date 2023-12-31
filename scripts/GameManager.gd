extends Node


export var pick_neighbour_mode = false
var colors_to_pick: Array # za hud nejbrhud pravila

# states
var game_on: bool = false
var deathmode_on = false

# spawning
var spawned_player_index: int = 0
var spawned_stray_index: int = 0
var players_in_game: Array = []
var strays_in_game: Array = []
var floor_positions: Array # po signalu ob kreaciji tilemapa ... tukaj, da ga lahko grebam do zunaj
var available_floor_positions: Array # dplikat floor_positions za spawnanje pixlov
var revive_time: float = 3 # pavza med die in revive funkcijo


onready var StrayPixel = preload("res://scenes/game/Pixel.tscn")
onready var PlayerPixel = preload("res://scenes/game/Pixel.tscn")
onready var spectrum_rect: TextureRect = $Spectrum
onready var player_start_position: Position2D = $"../StartPosition"

# stats
onready var player_stats: Dictionary = Pro.default_player_stats.duplicate() # duplikat default profila
onready var game_stats: Dictionary = Pro.default_game_stats.duplicate() # duplikat default profila
onready var game_rules: Dictionary = Pro.game_rules 



func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("r"):
		start_game()
	if Input.is_action_pressed("no1"):
#		player_stats["player_life"] -= 1
		player_stats["player_energy"] -= 1
	if Input.is_action_pressed("no2"):
#		player_stats["player_life"] += 1
		player_stats["player_energy"] += 10
	if Input.is_action_pressed("no3"):
		# pavziram plejerja
		if not players_in_game.empty():
			for player in players_in_game:
				player_stats["player_energy"] = 0
				player.die() # s te metode s spet kliče stat change "player_life"
				yield(get_tree().create_timer(revive_time), "timeout")
				player.revive()

		pass
		
		
func _ready() -> void:
	
	Glo.game_manager = self	
	
	randomize()
	
	# štartej igro
	yield(get_tree().create_timer(0.1), "timeout") # zato da se vse naloži
	set_game()
	
	
func _process(delta: float) -> void:
	
	players_in_game = get_tree().get_nodes_in_group(Glo.group_players)
	# strays_in_game = get_tree().get_nodes_in_group(Glo.group_strays)
	
	if players_in_game.empty():
		Glo.camera_target = null


# GAME LOOP --------------------------------------------------------------------------------------------------------------------------------

func set_game():
	
#	player_start_position.global_position = Pro.game_rules["player_start_position"]
	
	spawn_player(player_start_position.global_position)
	yield(get_tree().create_timer(1), "timeout")
	
	split_stray_colors(game_stats["stray_pixels_count"])
	yield(get_tree().create_timer(1), "timeout")
	
	Glo.hud.fade_in() # hud zna vse sam ... vseskozi je GM njegov "mentor"
	
	# tukaj pride poziv intro
	yield(get_tree().create_timer(1), "timeout")
	Glo.game_countdown.start_countdown()

	
func start_game():
	
	game_on = true
	Glo.hud.start_timer()
	
	# aktiviram plejerja
	if not players_in_game.empty():
		for player in players_in_game:
			player.set_physics_process(true)
			
	
func game_over():
	
	# ustavim igro
	game_on = false
	deathmode_on =  false
	
	# pavziram plejerja
	if not players_in_game.empty():
		for player in players_in_game:
			player.set_physics_process(false)
	
	yield(get_tree().create_timer(3), "timeout")
#
	# gameover fade-in ... podatke si pobere sam slovarja statistik
	Glo.gameover_gui.fade_in()

	# kamera target off
	Glo.camera_target = null


# SPAWNANJE --------------------------------------------------------------------------------------------------------------------------------

func spawn_player(spawn_position):
	
	spawned_player_index += 1
	
	# instance
	var new_player_pixel = PlayerPixel.instance()
	new_player_pixel.name = "P%s" % str(spawned_player_index)
	new_player_pixel.pixel_color = Glo.color_white
	new_player_pixel.add_to_group(Glo.group_players)
	
	new_player_pixel.global_position = spawn_position # + grid_cell_size/2 ... ne rabim snepat ker se v pixlu na redi funkciji
	
	# _temp
	new_player_pixel.pixel_is_player = true # ta pixel je plejer in ne računalnik
	
	#spawn
	Glo.node_creation_parent.add_child(new_player_pixel)
	
	# povežem
	new_player_pixel.connect("stat_changed", self, "_on_stat_changed")
	
	# aktiviram plejerja (hud mora vedet)
	player_stats["player_active"] = true

	# camera target
	Glo.camera_target = new_player_pixel
	Glo.main_camera.reset_camera_position()
	
	# premik kamere na štartu
	yield(get_tree().create_timer(1), "timeout")
	Glo.main_camera.drag_margin_top = 0.2
	Glo.main_camera.drag_margin_bottom = 0.2
	Glo.main_camera.drag_margin_left = 0.3
	Glo.main_camera.drag_margin_right = 0.3
	

func split_stray_colors(stray_pixels_count):
	
	# split colors
	var color_count: int = stray_pixels_count 
	color_count = clamp(color_count, 1, color_count) # za vsak slučaj klempam, da ne more biti nikoli 0 ...  ker je error			
	
	# poberem sliko
	var spectrum_texture: Texture = spectrum_rect.texture
	var spectrum_image: Image = spectrum_texture.get_data()
	spectrum_image.lock()
	
	# izračun razmaka med barvami
	var spectrum_texture_width = spectrum_rect.rect_size.x
	var color_skip_size = spectrum_texture_width / color_count # razmak barv po spektru ... - 1 je zato ker je razmakov za 1 manj kot barv
	
	# nabiranje barv za vsak pixel
	var all_colors: Array = []
	var loop_count = 0
	for color in color_count:
		
		# pozicija pixla na sliki
		var selected_color_position_x = loop_count * color_skip_size
		
		# zajem barve na lokaciji pixla
		var current_color = spectrum_image.get_pixel(selected_color_position_x, 0)
		spawn_stray(current_color)
		all_colors.append(current_color)
		
		# spawn indikatorja na poziciji
#		hud.spawn_color_indicator(selected_color_position_x,selected_color_position_y, selected_color)				
#		Glo.hud.spawn_color_indicator(selected_color)				
		loop_count += 1		
		
	Glo.hud.spawn_color_indicators(all_colors)				


func spawn_stray(stray_color):
	
	
	
	spawned_stray_index += 1

	# instance
	var new_stray_pixel = StrayPixel.instance()
	new_stray_pixel.name = "Stray%s" % str(spawned_player_index)
	new_stray_pixel.pixel_color = stray_color
	new_stray_pixel.add_to_group(Glo.group_strays)
	
	# random grid pozicija
	var random_range = available_floor_positions.size()
	var selected_cell_index: int = randi() % int(random_range) # + offset
	new_stray_pixel.global_position = available_floor_positions[selected_cell_index] # + grid_cell_size/2
	new_stray_pixel.z_index = 1
	
	#spawn
	Glo.node_creation_parent.add_child(new_stray_pixel)
	
	# connect
	new_stray_pixel.connect("stat_changed", self, "_on_stat_changed")			
	
	# odstranim uporabljeno pozicijo
	available_floor_positions.remove(selected_cell_index) #... generira snap to cornenr error	

	
# SIGNALI ----------------------------------------------------------------------------------

func _on_FloorMap_floor_completed(floor_cells_global_positions: Array) -> void:

	floor_positions = floor_cells_global_positions 
	available_floor_positions = floor_positions.duplicate()
	

func _on_stat_changed(stat_owner, changed_stat, stat_change):
	
	match changed_stat:
	# stat_change ima predznak (s pixla ali s def profila) ... tukaj je vse +, če je sprememba -1, se tukaj zgodi -1
		
		# od playerja
		"player_life": 
			if player_stats["player_life"] > 0:
				player_stats["player_life"] += stat_change
			else:
				game_over()
		"cells_travelled": 
			if player_stats["player_energy"] > 0:
				player_stats["player_energy"] += game_rules["energy_cell_travelled"]
		# od tarče
		"off_pixels_count":
			# točke
			player_stats["player_points"] += game_rules["points_color_picked"]
			# energija
			player_stats["player_energy"] += game_rules["energy_color_picked"]		
		
	# loose life
	player_stats["player_energy"] = clamp(player_stats["player_energy"], 0, Pro.default_player_stats["player_energy"])
	
	if player_stats["player_energy"] <= 0:
		
		# resetiram energijo ... nujno že tukaj, ker če ne se kliče ob vsaki spremembi statistike in je stack oversize error
		player_stats["player_energy"] = Pro.default_player_stats["player_energy"]

		stat_owner.die() # s te metode s spet pošlje statistika change "player_life"
		yield(get_tree().create_timer(revive_time), "timeout")
		stat_owner.revive()


	

