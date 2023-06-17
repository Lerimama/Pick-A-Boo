extends Node


onready var game_camera: Camera2D = $GameView/Viewports/ViewportContainer_1/Viewport/GameCam
onready var viewport_1: Viewport = $GameView/Viewports/ViewportContainer_1/Viewport

onready var minimap_viewport: Viewport = $MinimapContainer/MinimapViewport
onready var minimap_camera: Camera2D = $MinimapContainer/MinimapViewport/MinimapCam


func _ready() -> void:
	
	minimap_viewport.world_2d = viewport_1.world_2d
	
	# višina minimape v razmerju s formatom levela
	var rect = Glo.level_tilemap.get_used_rect()
	minimap_viewport.size.y = minimap_viewport.size.x * rect.size.y / rect.size.x
	
	set_camera_limits()
	
	
func set_camera_limits():
	
	var tilemap_edge = Glo.level_tilemap.get_used_rect()	
	var tilemap_cell_size = Glo.level_tilemap.cell_size
	
	for camera in [minimap_camera, game_camera]:
		camera.limit_left = tilemap_edge.position.x * tilemap_cell_size.x # 0,0
		camera.limit_right = tilemap_edge.end.x * tilemap_cell_size.x # 0,0
		camera.limit_top = tilemap_edge.position.y * tilemap_cell_size.y # 0,0
		camera.limit_bottom = tilemap_edge.end.y * tilemap_cell_size.y # 0,0

