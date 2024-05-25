extends VBoxContainer

onready var Members = get_tree().get_root().get_node("PauseMenu/Members")

var trinkets_active = false
var empty_trinkets = false
var trinket_id : String
var trinket_holder : String

signal trinket_chosen()
signal empty_trinkets()
signal return_to_trinkets()
signal size_max()
signal size_ready()

onready var inventory : Array = []
var trinket_index : int

func _ready():
	inventory = Party.Trinkets
	for trinket_index in inventory.size():
		add_slot(trinket_index)
	if inventory.size() == 0:
		empty_trinkets = true
		emit_signal("empty_trinkets")
	if inventory.size() > 15:
		for x in range(15, inventory.size()):
			inventory[x].hide()
		
func add_slot(trinket_index):
	var trinket_slot = inventory[trinket_index]
	self.add_child(trinket_slot)
	
func scroll_down():
	inventory[trinket_index].show()
	inventory[trinket_index - 15].hide()
	
func scroll_up():
	inventory[trinket_index - 14].show()
	inventory[trinket_index + 1].hide()
	
	
func _process(delta):
	var size_max = inventory.size()
	var inventory_max = (inventory.size() -1)
	if Input.is_action_just_pressed("ui_down") and trinkets_active and trinket_index < inventory_max:
		trinket_index += 1
	if Input.is_action_just_pressed("ui_up") and trinkets_active and trinket_index > 0:
		trinket_index -= 1
	if Input.is_action_just_pressed("ui_down") and trinket_index >=15:
		scroll_down()
	if Input.is_action_just_pressed("ui_up") and trinket_index >=14:
		scroll_up()
	
		
func _input(event):
	var inventory_max = (inventory.size() -1)
	if Input.is_action_just_pressed("ui_select") and trinkets_active:
		get_id()
		emit_signal("trinket_chosen")
		trinkets_active = false
		
func get_id():
	if trinkets_active and not empty_trinkets:
		trinket_id = inventory[trinket_index].get_id()
		return trinket_id
		
func initial_id():
	if not empty_trinkets:
		trinket_id = inventory[0].get_id()
		return trinket_id
		
		
func get_holder_name():
	trinket_id = inventory[trinket_index].get_id()
	if not empty_trinkets:
		if PartyStats.gary_trinket == trinket_id or PartyStats.jacques_trinket == trinket_id or PartyStats.irina_trinket == trinket_id or PartyStats.suzy_trinket == trinket_id or PartyStats.damien_trinket == trinket_id:
			trinket_holder = inventory[trinket_index].get_holder_name()
			return trinket_holder
		else:
			return "-"

func _on_TrinketsCursor_retread():
	if inventory.size() > 15:
		for x in range(15, inventory.size()):
			inventory[x].hide()
		for x in range(0, 14):
			inventory[x].show()
	trinket_index = 0
	trinkets_active = false

func _on_MenuCursor_trinket_selecting():
	trinkets_active = true

func _on_Members_trinket_equipped():
	var selector_name = Members.selector_name
	PartyStats.holder_name = Members.selector_name
	var equipped = inventory[trinket_index].get_trinket()
	var trinket_name = inventory[trinket_index].get_id()
	if trinket_name == "Unequip Trinket":
		inventory[trinket_index].trinket_unequip()
	if equipped:
		inventory[trinket_index].trinket_relocate()
		inventory[trinket_index].trinket_equip()
	else:
		inventory[trinket_index].trinket_equip()
	if selector_name == "Gary":
		PartyStats.gary_trinket = trinket_name
	if selector_name == "Jacques":
		PartyStats.jacques_trinket = trinket_name
	if selector_name == "Irina":
		PartyStats.irina_trinket = trinket_name
	if selector_name == "Suzy":
		PartyStats.suzy_trinket = trinket_name
	if selector_name == "Damien":
		PartyStats.damien_trinket = trinket_name
	for x in range(inventory.size()):
		inventory[x].trinket_scan()

	print(trinket_id)
	yield(get_tree().create_timer(0.9), "timeout")
	emit_signal("return_to_trinkets")
	trinket_index = 0
	trinkets_active = true
