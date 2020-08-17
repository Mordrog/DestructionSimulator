extends Control

onready var ball_selected := $ItemList/Ball/IconSelected
onready var ball_number := $ItemList/Ball/Number
onready var laser_selected := $ItemList/Laser/IconSelected
onready var laser_number := $ItemList/Laser/Number
onready var rocket_selected := $ItemList/Rocket/IconSelected
onready var rocket_number := $ItemList/Rocket/Number

var player

var currently_selected_item

func update_ui_select():
	if currently_selected_item == Global.Items.BALL:
		ball_selected.hide()
		ball_number.show()
	elif currently_selected_item == Global.Items.LASER:
		laser_selected.hide()
		laser_number.show()
	elif currently_selected_item == Global.Items.ROCKET:
		rocket_selected.hide()
		rocket_number.show()
	
	if player.selected_item == Global.Items.BALL:
		ball_selected.show()
		ball_number.hide()
	elif player.selected_item == Global.Items.LASER:
		laser_selected.show()
		laser_number.hide()
	elif player.selected_item == Global.Items.ROCKET:
		rocket_selected.show()
		rocket_number.hide()
	
	currently_selected_item = player.selected_item

func _ready() -> void:
	player = get_node("/root/Root/Player")
	update_ui_select()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("item_1"):
		player.selected_item = 1
	if event.is_action_pressed("item_2"):
		player.selected_item = 2
	if event.is_action_pressed("item_3"):
		player.selected_item = 3
	update_ui_select()
