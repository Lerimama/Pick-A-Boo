extends Node


# PROFILES ---------------------------------------------------------------------------------------------------------

var default_player_profiles: Dictionary = { # ime profila ime igralca ... pazi da je CAPS, ker v kodi tega ne pedenam	
	"P1" : { # ključi bodo kasneje samo indexi
		"player_name" : "Moe",
		"player_color" : Glo.color_blue, # color_yellow, color_green, color_red
		"controller_profile" : "ARROWS",
	},
}

# STATS ---------------------------------------------------------------------------------------------------------

var default_player_stats : Dictionary = { # tole ne uporabljam v zadnji varianti
	"player_life" : 1,
	"player_points": 0,
	"player_energy" : 172, # max, da se lepo ujema s pixli
	"skills_used" : 0,
	"cells_travelled" : 0,
}

var default_game_stats : Dictionary = { # tole ne uporabljam v zadnji varianti
	"level_no" : 88,
	"game_time" : 900, # sekund
	"stray_pixels_count" : 32, # items in game
}

var game_rules : Dictionary = { # tole ne uporabljam v zadnji varianti
	"points_color_picked": 10,
	"energy_color_picked": 20,
	"energy_cell_travelled": -1,
}

#enum Levels {FIRST, SQUARE, CIRCLE, TRIANGLE
#}
#
#var default_level_stats : Dictionary = { # tole ne uporabljam v zadnji varianti
#	Levels.FIRST: {
##		"player_start_position" : Vector2(0, 0),
#		"game_time" : 5,
#		"level" : 0,
#		"stray_pixels_count" : 32,
#	}
#}

