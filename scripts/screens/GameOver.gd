extends Control


var pause_fade_time: float = 0.5



onready var score: Label = $Score

onready var time: Label = $DataContainer/Time
onready var level: Label = $DataContainer/Level
onready var points: Label = $DataContainer/Points


func _input(event: InputEvent) -> void:

	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_Q:
			fade_in()
			accept_event()


func _ready() -> void:
	
	Glo.gameover_gui = self
	visible = false

	
func fade_in():

	var final_player_stats: Dictionary = Glo.game_manager.player_stats
	var final_game_stats: Dictionary = Glo.game_manager.game_stats

	# write stats
	time.text = "SKILLS USED: %04d" % final_player_stats["skills_used"]
	points.text = "POINTS: %04d" % final_player_stats["player_points"]
	level.text = "LEVEL REACHED: %02d" % final_game_stats["level_no"]
	score.text = "Dosegel si %s tock." % final_player_stats["player_points"]
	
	modulate.a = 0
	visible = true
	set_process_input(false)
	
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(self, "modulate:a", 1, pause_fade_time)
	fade_in_tween.tween_callback(self, "pause_tree")
	

func pause_tree():
	
	get_tree().paused = true
#	set_process_input(true) # zato da se lahko animacija izvede


func unpause_tree():
	
	get_tree().paused = false
	visible = false
#	set_process_input(true) # zato da se lahko animacija izvede


func _on_RestartBtn_pressed() -> void:
	
	unpause_tree()
	Glo.main_node.reload_game()
	

func _on_QuitBtn_pressed() -> void:
	
	unpause_tree()
	Glo.main_node.game_out()
	
