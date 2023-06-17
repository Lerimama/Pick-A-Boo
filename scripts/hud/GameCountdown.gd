extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	Glo.game_countdown = self
	
func start_countdown():
	Glo.game_manager.start_game() # preskok odštevanja
#	animation_player.play("countdown_5")
	
func _on_AnimationPlayer_animation_finished(coundown_5) -> void:
	
	Glo.game_manager.start_game()
