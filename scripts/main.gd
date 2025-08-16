extends Node2D

var level = 0
var exp_point = 0
var base_exp = 100
var budget = 1000

var size = 1
var connections = 1
var activity = 1

var bad_data_risk = 0.05
var passive_rate = 0.5

var evilness = 0
var cooldown = false

var level_images = [
	preload("res://assets/images/unevolved.png"),
	preload("res://assets/images/1.png"),
	preload("res://assets/images/2.png"),
	preload("res://assets/images/3.png"),
	preload("res://assets/images/4.png"),
	preload("res://assets/images/5.png"),
	preload("res://assets/images/evil/1.png"),
	preload("res://assets/images/evil/2.png"),
	preload("res://assets/images/evil/3.png"),
	preload("res://assets/images/evil/4.png"),
	preload("res://assets/images/evil/5.png"),
]

var timeout_quotes = [
	"Please have some patience!",
	"Show some mercy on me :(",
	"Can't you just wait a second?"
]
	
func _check_level_up():
	if level <= 5:
		if exp_point >= base_exp * (level):
			if level == 5:
				Global.reason = "finished"
				_game_over()
				return
			level += 1
			exp_point = 0
			budget += 50
			$NeuralNetwork.scale = Vector2(0.2 + 0.05 * level, 0.2 + 0.05 * level)
			$Level.text = "Level " + str(level)
			$SizeProgress.value = 100 * level / 6 
			$ConnectionsProgress.value = 100 * pow(level / 6.0, 1.5)
			$ActivityProgress.value = 100 * sin(level / 6.0 * PI / 2) 
	_update_nextwork_visual()
		
func _update_nextwork_visual():
	if (!has_node("NeuralNetwork") || !has_node("Main") || !has_node("Line2D3")):
		return
	if evilness > 0.5:
		if level >= 1:
			$NeuralNetwork/Sprite2D.texture = level_images[5 + level]
		$Main.default_color = Color(Global.colors[3])
		$Line2D3.default_color = Color(Global.colors[5])
	else:
		$Main.default_color = Color(Global.colors[0])
		$Line2D3.default_color = Color(Global.colors[2])
		$NeuralNetwork/Sprite2D.texture = level_images[level]
	
func _add_evilness(value):
	evilness += value
	if has_node("Evilness"):
		$Evilness.text = "Evilness " + str(evilness) 
	_update_nextwork_visual()
	if evilness >= 1:
		Global.reason = "evilness"
		_game_over()
	
func _game_over():
	set_process(false)
	get_tree().change_scene_to_file("res://scenes/end.tscn")
	
func _on_train_pressed() -> void:
	if cooldown:
		$Notification.text = timeout_quotes[randi_range(0, 2)]
		return
	$Notification.text = ""
	if budget <= 10:
		Global.reason = "budget"
		_game_over()
	exp_point += randi_range(10, 40)
	budget -= 10
	if randf() < bad_data_risk:
		_add_evilness(0.1)
	if evilness > 0:
		if evilness <= 0.01:
			evilness = 0
		else:
			_add_evilness(-0.02)
		if evilness > 0.2:
			budget -= 20
	$Evilness.text = "Evilness " + str(evilness) 
	$ExpPoints.text = "Experience " + str(exp_point)
	$ExpProgress.value = exp_point * 100 / (base_exp * (level + 1))
	$Balance.text = "Balance " + str(budget)
	_check_level_up()
	
	cooldown = true
	var cd_time = randf_range(2.0, 3.0)
	$Timer.wait_time = cd_time
	$Timer.start()
	
func _process(delta):
	if randf() < passive_rate * delta:
		_add_evilness(0.01)

func _on_timer_timeout() -> void:
	cooldown = false
	
func _ready():
	if Global.reason:
		Global.reason = null
		get_tree().reload_current_scene()
