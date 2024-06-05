extends Node2D

onready var party_members : int
onready var tween = $Tween
var fighters : Array = []
var fighters2 : Array = []
var fighter_index : int = -1
var BB_active = false
var f_current 
var f_position : Vector2
var attack_chosen = false
var max_turns : int = 0
var ongoing = false
var fighter_0_able = true
var fighter_1_able = true
var fighter_2_able = true
var item_selecting = false
var selector_index : int
var target_index : int
var fighter_turn_used = false
var fighters_active = false
var enemies_active = false
var enemy_item = false
var magic_selecting = false
var HP_amount : int
var SP_amount : int
var health : int
var f_health : int

var heal = false
var SP = false
var combo_heal
var restore = false
var strange = false
var perfect = false
var all_heal = false
var all_restore = false
var party_id : int
var halt = false

var e_attack : int
var e_magic : int
var e_move_base : int
var move_type : String
var move_spread : String
var move_kind : String
var fighter_name : String
var fighter_x : int

signal fighters_active
signal anim_finish
signal enemies_enabled
signal BB_move
signal item_chosen
signal ally_spell_chosen
signal fighter_damage_over
signal gary
signal jacques
signal irina
signal suzy
signal damien

func _ready():
	#fighters = get_children()
	set_positions()
	fighters2 = fighters.duplicate()
	fighter_turn_used = fighters[fighter_index].get_turn_value()
	
func f_array_size():
	var f_array_size: int = fighters.size()
	return f_array_size
	
func set_positions():
	if PartyStats.party_members == 1:
		if PartyStats.gary_id == 1:
			fighters.append($Gary_Battle)
			fighters[0].global_position = Vector2(-138, 136)
			
	if PartyStats.party_members == 2:
		if PartyStats.gary_id == 1:
			fighters.append($Gary_Battle)
			fighters[0].position = Vector2(-199, 112)
			
		if PartyStats.jacques_id == 1:
			fighters.append($Jacques_Battle)
			fighters[0].position = Vector2(-199, 112)
			
		if PartyStats.gary_id == 2:
			fighters.append($Gary_Battle)
			fighters[1].position = Vector2(-86, 168)
			
		if PartyStats.jacques_id == 2:
			fighters.append($Jacques_Battle)
			fighters[1].position = Vector2(-86, 168)
		
	
	if PartyStats.party_members == 3:
		if PartyStats.gary_id == 1:
			fighters.append($Gary_Battle)
			fighters[0].position = Vector2(-240, 86)
		
		if PartyStats.jacques_id == 1:
			fighters.append($Jacques_Battle)
			fighters[0].position = Vector2(-240, 86)
		
		if PartyStats.irina_id == 1:
			fighters.append($Irina_Battle)
			fighters[0].position = Vector2(-240, 86)
		
		if PartyStats.gary_id == 2:
			fighters.append($Gary_Battle)
			fighters[1].position = Vector2(-135, 144)
		
		if PartyStats.jacques_id == 2:
			fighters.append($Jacques_Battle)
			fighters[1].position = Vector2(-135, 144)
		
		if PartyStats.irina_id == 2:
			fighters.append($Irina_Battle)
			fighters[1].position = Vector2(-135, 144)
		
		if PartyStats.gary_id == 3:
			fighters.append($Gary_Battle)
			fighters[2].position = Vector2(-23, 194)
		
		if PartyStats.jacques_id == 3:
			fighters.append($Jacques_Battle)
			fighters[2].position = Vector2(-23, 194)
		
		if PartyStats.irina_id == 3:
			fighters.append($Irina_Battle)
			fighters[2].position = Vector2(-23, 194)
		
		
func _on_WorldRoot_BB_active():
		BB_active = true
		attack_chosen = false
		hide_cursors(fighter_index)
		
func select_next_fighter(index_offset):
	var last_fighter_index = fighter_index;
	var new_fighter_index = fposmod(last_fighter_index + index_offset, fighters.size())
	fighters[last_fighter_index].unfocus()
	fighters[new_fighter_index].focus()
	fighter_index = new_fighter_index
	
func select_next_fighter2(index_offset):
	var last_fighter_index = fighter_index;
	var new_fighter_index : int
	new_fighter_index = fposmod(last_fighter_index + index_offset, fighters2.size())
	fighters2[last_fighter_index].unfocus()
	fighters2[new_fighter_index].focus()
	fighter_index = new_fighter_index

func _process(delta):
	#fighter_turn_used = fighters[fighter_index].get_turn_value()
	if Input.is_action_just_pressed("ui_right") and not BB_active and not attack_chosen and not ongoing and not item_selecting and not enemies_active and not enemy_item and not magic_selecting and not halt:
		print(fighter_index)
		select_next_fighter(+1)
		fighters_active = true
		emit_signal("fighters_active")
		
	if Input.is_action_just_pressed("ui_left") and not BB_active and not attack_chosen and not ongoing and fighters_active and not item_selecting and not enemies_active and not enemy_item and not magic_selecting and not halt:
		print(fighter_index)
		select_next_fighter(-1)
	
	if Input.is_action_just_pressed("ui_select") and BB_active and not attack_chosen and not fighter_turn_used and not ongoing and fighters_active and not item_selecting and not enemies_active and not enemy_item and not magic_selecting and not halt:
		emit_signal("BB_move")
		fighters[fighter_index].turn()
		fighters_active = false
		fighter_name = get_f_name()
		if fighter_name == "gary":
			$AttackTimer.fighter_name = "gary"
			emit_signal("gary")
		if fighter_name == "jacques":
			$AttackTimer.fighter_name = "jacques"
			emit_signal("jacques")
		if fighter_name == "irina":
			$AttackTimer.fighter_name = "irina"
			emit_signal("irina")
		if fighter_name == "suzy":
			$AttackTimer.fighter_name = "suzy"
			emit_signal("suzy")
		if fighter_name == "damien":
			$AttackTimer.fighter_name = "damien"
			emit_signal("damien")
		
		####### Item Selection ##########
		
	if Input.is_action_just_pressed("ui_right") and item_selecting and not attack_chosen and not magic_selecting and not halt:
		select_next_fighter2(+1)
		emit_signal("fighters_active")
		print(fighter_index)
		
	if Input.is_action_just_pressed("ui_left") and item_selecting and not attack_chosen and not magic_selecting and not halt:
		select_next_fighter2(-1)
		print(fighter_index)
	
	if Input.is_action_just_pressed("ui_select") and item_selecting and not attack_chosen and not magic_selecting and not halt:
		emit_signal("item_chosen")
		hide_cursors2(fighter_index)
		target_index = fighter_index
		item_selecting = false
		
		######### Magic Selection ##########
		
	if Input.is_action_just_pressed("ui_right") and magic_selecting and not attack_chosen and not item_selecting and not halt:
		select_next_fighter2(+1)
		emit_signal("fighters_active")
		print(fighter_index)
		
	if Input.is_action_just_pressed("ui_left") and magic_selecting and not attack_chosen and not item_selecting and not halt:
		select_next_fighter2(-1)
		print(fighter_index)
	
	if Input.is_action_just_pressed("ui_select") and magic_selecting and not attack_chosen and not item_selecting and not halt:
		emit_signal("ally_spell_chosen")
		hide_cursors2(fighter_index)
		target_index = fighter_index
		magic_selecting = false
		
		
func switch_focus(x, y):
	fighters[x].focus()
	fighters[y].unfocus()
	
func hide_cursors(x):
	fighters[x].unfocus()
	
func show_cursors(x):
	fighters[x].focus()
	
func show_cursors2(x):
	fighters2[x].focus()
	
func show_cursors_remote():
	fighters[fighter_index].focus()
	
func hide_cursors2(x):
	fighters2[x].unfocus()

func hide_all_cursors():
	for x in range (fighters2.size()):
		fighters2[x].unfocus()
	
func hide_cursors_remote():
	#fighters = get_children()
	for x in range (fighters2.size()):
		fighters2[x].unfocus()
		
func get_f_name():
	var f_name = fighters[fighter_index].get_name()
	return f_name
	
func get_health():
	var health = fighters[fighter_index].get_health()
	return health
	
func get_f_health():
	var f_health = fighters[fighter_index].get_f_health()
	return f_health
	
func get_health_heal():
	var health = fighters2[target_index].get_health()
	return health
	
func get_f_health_heal():
	var f_health = fighters2[target_index].get_f_health()
	return f_health
		
func get_party_id():
	var party_id = fighters[fighter_index].get_id()
	return party_id
	
func get_f_OG_position():
	var f_OG_position = fighters[fighter_index].get_OG_position()
	return f_OG_position
	
func get_BB_position():
	var BB_position = fighters[fighter_index].get_BB_position()
	return BB_position
	

func _on_WorldRoot_defend_chosen():
	fighters[fighter_index].defend()
	_on_WorldRoot_f_index_reset()
	BB_active = false

func _on_WorldRoot_flee_chosen():
	#fighters = get_children()
	#set_positions()
	for x in range (fighters2.size()):
		fighters2[x].flee()
	
func get_f_current():
	var f_self = fighters[fighter_index].get_self()
	return f_self
	
func get_f_position():
	var f_position: Vector2 = fighters[fighter_index].get_position()
	return f_position
	
func get_f_index():
	var f_index: int = fighter_index
	return f_index
	
func damage():
	randomize()
	var damage : int
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if move_spread == "single":
		fighter_index = rng.randi_range(0, fighters.size() - 1)
	else:
		fighter_index = fighter_x
	var f_defense = fighters[fighter_index].get_f_defense()
	if move_kind == "attack":
		var total = e_attack + e_move_base
		damage = max(0, ((total) + int(total * (rand_range(0.05, 0.15)))) - f_defense)
	if move_kind == "magic":
		var total = e_magic + e_move_base
		damage = max(0, ((total) + int(total * (rand_range(0.05, 0.15)))) - f_defense)
	fighters[fighter_index].damage(damage, move_type)
	huds_update()
	yield(get_tree().create_timer(1.7), "timeout")
	emit_signal("fighter_damage_over")
	
func huds_update():
	fighter_name = fighters[fighter_index].get_name()
	health = get_health()
	f_health = get_f_health()
	$HUDS.health = health
	$HUDS.f_health = f_health
	if fighter_name == "gary":
		$HUDS.gary_update()
	if fighter_name == "jacques":
		$HUDS.jacques_update()
	if fighter_name == "irina":
		$HUDS.irina_update()
	
func huds_heal_update():
	health = get_health_heal()
	f_health = get_f_health_heal()
	$HUDS.health = health
	$HUDS.f_health = f_health
	if fighter_name == "gary":
		$HUDS.gary_update()
	if fighter_name == "jacques":
		$HUDS.jacques_update()
	if fighter_name == "irina":
		$HUDS.irina_update()
		
func all_heal_update():
	if fighter_name == "gary":
		$HUDS.gary_update()
	if fighter_name == "jacques":
		$HUDS.jacques_update()
	if fighter_name == "irina":
		$HUDS.irina_update()
		
func fighter_attack():
	fighters[fighter_index].attack()
	emit_signal("anim_finish")
	BB_active = false

func sp_recovery():
	var amount = 2
	fighters[fighter_index].weapon_SP(amount)

func pre_attack():
	fighters[fighter_index].pre_attack()

func _on_Enemies_enemy_chosen():
	attack_chosen = true
	fighters[fighter_index].pre_attack()
	
func get_turn_value():
	if not item_selecting and fighters_active:
		var turn_value = fighters[fighter_index].get_turn_value()
		return turn_value
	
func _on_WorldRoot_f_turn_used():
	var array_size = fighters2.size()
	fighters[fighter_index].turn_used()
	max_turns += 1

func f_turn_used():
	var array_size = fighters2.size()
	fighters[selector_index].turn_used()
	max_turns += 1
	
func fighters_active_check():
	var array_size = fighters2.size()
	for x in range (fighters2.size()):
		var dead = fighters2[x].death_count()
		if dead:
			array_size = array_size - 1
			fighters.remove(x)
	if max_turns == array_size:
		emit_signal ("enemies_enabled")
		enemies_active = true

func _on_WorldRoot_f_index_reset():
	fighters.remove(fighter_index)
	fighter_index = clamp(fighter_index, 0, fighters.size() - 1)
	attack_chosen = false
	#ongoing = false
	fighter_index = -1
	if fighters.size() <=0:
		set_positions()
		#fighters = get_children()

func get_f_attack():
	var f_attack = fighters[fighter_index].get_f_attack()
	return f_attack
	
func get_f_magic():
	var f_magic = fighters[fighter_index].get_f_magic()
	return f_magic
	
func get_f_magic_base():
	var f_magic_base = fighters[fighter_index].get_f_magic_base()
	return f_magic_base
	
func get_f_attack_base():
	var f_attack_base = fighters[fighter_index].get_f_attack_base()
	return f_attack_base
	
func get_f_defense():
	var f_defense = fighters[fighter_index].get_f_defense()
	return f_defense
	
func idle():
	fighters[fighter_index].idle()

func victory():
	#fighters = get_children()
	for x in range(fighters2.size()):
		fighters2[x].victory()

func _on_WorldRoot_action_ongoing():
	ongoing = true

func _on_WorldRoot_action_ended():
	yield(get_tree().create_timer(0.3), "timeout")
	ongoing = false
	fighter_index = -1

func _on_ItemInventory_heal_item_chosen():
	print(fighter_index)
	selector_index = fighter_index
	fighters[fighter_index].idle()
	yield(get_tree().create_timer(0.15), "timeout")
	item_selecting = true
	hide_all_cursors()
	fighter_index = -1
	(select_next_fighter2(+1))
	
func _on_ItemInventory_all_heal_item_chosen():
	hide_cursors(fighter_index)
	selector_index = fighter_index
	target_index = selector_index
	fighters[fighter_index].idle()
	emit_signal("item_chosen")

func get_selector_position():
	var f_position: Vector2 = fighters[selector_index].get_position()
	return f_position
	
func get_target_position():
	var f_position: Vector2 = fighters[target_index].get_position()
	return f_position

func item_used():
	f_turn_used()
	fighters[selector_index].item_used()
	yield(get_tree().create_timer(0.5), "timeout")
	if heal:
		fighters2[target_index].heal(HP_amount)
		fighter_name = fighters2[target_index].get_name()
		#health = fighters2[target_index].get_health()
		#f_health = fighters2[target_index].get_f_health()
		huds_heal_update()
	if SP:
		fighters[target_index].SP(SP_amount)
	if combo_heal:
		fighter_name = fighters2[target_index].get_name()
		fighters2[target_index].heal(HP_amount)
		fighters2[target_index].combo_heal(SP_amount)
		huds_heal_update()
	if all_heal:
		for x in range(fighters2.size()):
			fighters2[x].heal(HP_amount)
			fighter_name = fighters2[x].get_name()
			health = fighters2[x].get_health()
			f_health = fighters2[x].get_f_health()
			$HUDS.health = health
			$HUDS.f_health = f_health
			all_heal_update()
			#fighters2[x].huds_update_heal()
	if restore:
		fighters2[target_index].restore()
	fighter_index = selector_index
	_on_WorldRoot_f_index_reset()
	BB_active = false
	heal = false
	SP = false
	combo_heal = false
	restore = false
	strange = false
	perfect = false
	all_heal = false
	all_restore = false
	item_selecting = false

func buff():
	fighters2[target_index].buff()

func _on_ItemInventory_battle_item_chosen():
	selector_index = fighter_index
	item_selecting = false
	enemy_item = true

func _on_ItemInventory_all_battle_item_chosen():
	selector_index = fighter_index
	item_selecting = false
	enemy_item = true

func battle_item_used():
	f_turn_used()
	fighters[selector_index].item_used()
	yield(get_tree().create_timer(0.5), "timeout")
	fighter_index = selector_index
	_on_WorldRoot_f_index_reset()
	BB_active = false
	item_selecting = false
	enemy_item = false

func _on_SpellList_single_ally_spell():
	selector_index = fighter_index
	fighters[fighter_index].idle()
	yield(get_tree().create_timer(0.2), "timeout")
	magic_selecting = true
	hide_all_cursors()
	fighter_index = -1
	(select_next_fighter2(+1))
	
func _on_SpellList_all_ally_spell():
	selector_index = fighter_index
	fighters[fighter_index].idle()
	magic_selecting = false
	emit_signal("ally_spell_chosen")
	
func _on_Enemies_fighters_active():
	for x in range (fighters2.size()):
		fighters2[x].turn_restored()
	max_turns = 0
	enemies_active = false
	fighter_index = -1
	
	##### Spell Animations #####
	
func spell_1():
	fighters[fighter_index].spell_1()
	
func spell_2():
	fighters[fighter_index].spell_2()
	
	##### Ally Spells ######
func Sweet_gift():
	f_turn_used()
	fighters2[target_index].heal(50)
	health = fighters2[target_index].get_health()
	f_health = fighters2[target_index].get_f_health()
	#fighters2[target_index].huds_update_heal()
	yield(get_tree().create_timer(0.5), "timeout")
	fighter_index = selector_index
	_on_WorldRoot_f_index_reset()
	BB_active = false
	
	
func Blossom():	
	f_turn_used()
	for x in range(fighters2.size()):
		fighters2[x].heal(100)
		health = fighters2[x].get_health()
		f_health = fighters2[x].get_f_health()
		#fighters2[x].huds_update_heal()
	yield(get_tree().create_timer(0.5), "timeout")
	fighter_index = selector_index
	_on_WorldRoot_f_index_reset()
	BB_active = false

func _on_WorldRoot_update_party():
	for x in range(fighters2.size()):
		fighter_name = fighters2[x].get_name()
		health = fighters2[x].get_health()
		if health == 0:
			health = 1
		if fighter_name == "gary":
			PartyStats.gary_current_health = health
		if fighter_name == "jacques":
			PartyStats.jacques_current_health = health
		if fighter_name == "irina":
			PartyStats.irina_current_health = health
