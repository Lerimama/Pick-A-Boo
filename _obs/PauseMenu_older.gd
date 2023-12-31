extends Control


var pause_fade_time: float = 0.5
var pause_on: bool = false
var new_tween: SceneTreeTween

var home_scene_path: String = "res://scenes/Home.tscn"
var game_scene_path: String = "res://scenes/Game.tscn"


func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if not pause_on:
				pause()
			else:
				unpause()
			accept_event()


func _ready() -> void:

	visible = false
	modulate.a = 0

	
func pause():
	
	visible = true
	set_process_input(false) # zato da se lahko animacija izvede
	new_tween = get_tree().create_tween()
	new_tween.tween_property(self, "modulate:a", 1, pause_fade_time)
	new_tween.tween_callback(self, "pause_tree")


func pause_tree():
	
	pause_on = true
	get_tree().paused = true
	set_process_input(true) # zato da se lahko animacija izvede
	

func unpause():
	
	set_process_input(false) # zato da se lahko animacija izvede
	new_tween = get_tree().create_tween()
	new_tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	new_tween.tween_property(self, "modulate:a", 0, pause_fade_time)
	new_tween.tween_callback(self, "unpause_tree")
	
	
func unpause_tree():
	
	get_tree().paused = false
	pause_on = false
	visible = false
	set_process_input(true) # zato da se lahko animacija izvede
	
	
func _on_PlayBtn_pressed() -> void:
	unpause()


func _on_RestartBtn_pressed() -> void:
	set_process_input(false) # zato da se lahko animacija izvede
#	Glo.switch_to_scene(game_scene_path)
	
	Glo.game_manager.restart_game()
	unpause()
	

func _on_QuitBtn_pressed() -> void:
	
	unpause_tree()
	Glo.switch_to_scene(home_scene_path)
