extends Node2D


# GLOBAL NODES ---------------------------------------------------------------------------------------------------------

var main_node = null
var sound_manager = null
var game_manager = null
var level_tilemap = null
var node_creation_parent = null # arena
var hud = null
var main_camera = null
var camera_target = null
var game_countdown = null
var gameover_gui = null

# GLOBAL VARS ---------------------------------------------------------------------------------------------------------

# groups
var group_players = "Players"
var group_strays = "Strays"
var group_ghosts = "Ghosts"
var group_tilemap = "Tilemap"

# sivi klin
var color_black = Color("#000000")
var color_gray0 = Color("#171a23") # najtemnejša
var color_gray1 = Color("#1d212d")
var color_gray2 = Color("#272d3d")
var color_gray3 = Color("#2f3649")
var color_gray4 = Color("#404954")
var color_gray5 = Color("#535b68") # najsvetlejša
var color_white = Color("#ffffff")

# colors
var color_blue = Color("#4b9fff")
var color_green = Color("#5effa9")
var color_red = Color("#f35b7f")
var color_yellow = Color("#fef98b")


# za scene switching
var current_scene = null # trenutno predvajana scena (za svičanje)
var scene_reload_time: float = 1


# SCENE MANAGER ---------------------------------------------------------------------------

# spawn scene
func spawn_new_scene(scene_path, parent_node):

	var scene_resource = ResourceLoader.load(scene_path)
	
	current_scene = scene_resource.instance()
	printt ("SCENE INSTANCED: ", current_scene.name, current_scene)	
	
	current_scene.modulate.a = 0
	parent_node.add_child(current_scene) # direct child of root
	printt ("SCENE ADDED: ", current_scene.name, current_scene)	
	

# release scene
func release_scene(scene_node):
	call_deferred("_free_scene", scene_node)	


func _free_scene(scene_node):
	printt ("SCENE RELEASED (next step): ", current_scene.name, current_scene)	
	scene_node.free()

# reload scene
func reload_scene(scene_node, scene_path, parent_node):
	
	release_scene(scene_node)
	yield(get_tree().create_timer(scene_reload_time), "timeout")
	spawn_new_scene(scene_path, parent_node)
	current_scene.modulate.a = 1
	

## INSTANCE FROM TILEMAPS ---------------------------------------------------------------------------

##func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent: Node2D, origin_zamik:Vector2 = Vector2.ZERO):	# primer dobre prakse ... static typing
##	print("COORD")
##	print(coord)
##	$BrickSet.set_cell(coord.x, coord.y, -1 )	# zbrišeš trenutni tile tako da ga zamenjaš z indexom -1 (prazen tile)
##	var pf = prefab.instance()
##	pf.position = $BrickSet.map_to_world(coord) - origin_zamik
##	parent.add_child(pf)
##	print("COORD")
##	print(coord)
