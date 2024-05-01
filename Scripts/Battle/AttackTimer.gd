extends Timer

#onready var timer = $Timer
var active = false
var max_hits : int = 0
var Fighters : Node2D
var fighter_name : String
var max_time : int

signal attack_bonus

func _ready():
	Fighters = get_tree().get_root().get_node("WorldRoot/Fighters")
	
func _process(delta):
	return
	
func _on_WorldRoot_start_attack_timer():
	var hit_time = (max_time - int(time_left))
	fighter_name = Fighters.get_f_name()
	
	if fighter_name == "gary":
		wait_time = 2.4
		max_time = 2.4
	if fighter_name == "jacques":
		wait_time = 2.6
		max_time = 2.6
	if fighter_name == "irina":
		wait_time = 1.3
		max_time = 1.3
	start()
	if Input.is_action_just_pressed("ui_select") and fighter_name == "gary" and max_hits < 3 and hit_time in range(0.2, 0.6) or hit_time in range(0.7, 1.4) or hit_time in range(2, 2.4):
		max_hits += 1
		#print(hit_time)
	if Input.is_action_just_pressed("ui_select") and fighter_name == "jacques" and hit_time == 0.1 or hit_time == 1.3 and max_hits < 2:
		max_hits += 1
	if Input.is_action_just_pressed("ui_select") and fighter_name == "irina" and max_hits <= 1 and hit_time == 0.5:
		max_hits += 1

func _on_Timer_timeout():
	print(max_hits)
	if fighter_name == "gary" and max_hits ==3:
		emit_signal("attack_bonus")
		max_hits = 0
	if fighter_name == "jacques" and max_hits ==2:
		emit_signal("attack_bonus")
		max_hits = 0
	if fighter_name == "irina" and max_hits ==1:
		emit_signal("attack_bonus")
		max_hits = 0
	else:
		print("fail")
		max_hits = 0

#(0.1) or hit_time == 0.5 or hit_time == 1.2
