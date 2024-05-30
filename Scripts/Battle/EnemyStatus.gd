extends Sprite

var enemy_selecting = false
var type : String
var poison
var stun

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and enemy_selecting:
		$Icons/Statuses.show()
		$Icons/Statuses/Attack_D.hide()
		$Icons/Statuses/Attack_B.hide()
		$Icons/Statuses/Magic_D.hide()
		$Icons/Statuses/Magic_B.hide()
		$Icons/Statuses/Defense_D.hide()
		$Icons/Statuses/Defense_B.hide()
		$Icons/Statuses/Poison.hide()
		$Icons/Statuses/Stun.hide()
		if poison:
			$Icons/Statuses/Poison.show()
		if stun:
			$Icons/Statuses/Stun.show()

	if Input.is_action_just_pressed("ui_right") and enemy_selecting:
		if type == "neutral":
			$Icons/Types/Neutral.show()
			$Icons/Types/Fire.hide()
			$Icons/Types/Water.hide()
			$Icons/Types/Air.hide()
			$Icons/Types/Earth.hide()
		if type == "fire":
			$Icons/Types/Fire.show()
			$Icons/Types/Neutral.hide()
			$Icons/Types/Water.hide()
			$Icons/Types/Air.hide()
			$Icons/Types/Earth.hide()
		if type == "water":
			$Icons/Types/Water.show()
			$Icons/Types/Neutral.hide()
			$Icons/Types/Fire.hide()
			$Icons/Types/Air.hide()
			$Icons/Types/Earth.hide()
		if type == "air":
			$Icons/Types/Air.show()
			$Icons/Types/Neutral.hide()
			$Icons/Types/Fire.hide()
			$Icons/Types/Water.hide()
			$Icons/Types/Earth.hide()
		if type == "earth":
			$Icons/Types/Earth.show()
			$Icons/Types/Neutral.hide()
			$Icons/Types/Fire.hide()
			$Icons/Types/Water.hide()
			$Icons/Types/Air.hide()

func _on_WorldRoot_attack_active():
	enemy_selecting = true

func _on_Enemies_enemy_chosen():
	enemy_selecting = false

func _on_Enemies_jinx_doll():
	enemy_selecting = false
