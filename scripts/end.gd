extends Node2D

var reason = ""
func _ready() -> void:
	$Line2D2.default_color = Color(Global.colors[0])
	$Title.text = "GAME OVER"
	$Restart.text = "Replay"
	$End.text = "Exit Game"
	if Global.reason:
		if Global.reason == "finished":
			reason = "Good Work! You successfully trained an AI."
		elif Global.reason == "budget":
			reason = "Why were you just burning down budget? :("
		elif Global.reason == "evilness":
			$Line2D2.default_color = Color(Global.colors[3])
			reason = "No way you just made an evil AI."
	$Reason.text = reason

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_end_pressed() -> void:
	get_tree().quit()
