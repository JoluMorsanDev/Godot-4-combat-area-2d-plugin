@tool
extends Area2D

@export var active = true

@export_enum("Select one in list", "Player Hurtbox","Player Projectile","Enemy Hurtbox", "Enemie Projectile", "Coin", "Bomb", "Heal Pills","Heal Area3D", "Fireball") var template ="Select one in list" ## (String, "Select one in list", "Player Hurtbox","Player Projectile","Enemy Hurtbox", "Enemie Projectile", "Coin", "Bomb", "Heal Pills","Heal Area3D", "Fireball")

@export_enum("Body", "Heal", "Damage", "Item") var area_type 
@export var destroy_on_collision = false
@export var damage = float(0)
@export var heal = float(0)
@export var potency = float(0)
@export var item = ""
@export var effect = ""
@export var rotated_knockback = true
@export var knocback_dir: Vector2 = Vector2(0,0)
@export var team = int(1)


@export var print_combat_info = false
#if you are modigying the script and want to simulate an enter tree, decoment this
#export var reload_propieties_devs = false


signal damage_signal(damage,potency,effect,knocback_dir,rotated_knockback)
signal heal_signal(heal,effect,knocback_dir,rotated_knockback)
signal item_signal(item,effect,knocback_dir,rotated_knockback)
signal destroyed


func enable(delay : float = 0.0):
	if delay:
		await  get_tree().create_timer(delay).timeout
	active = true

func disable(delay : float = 0.0):
	if delay:
		await  get_tree().create_timer(delay).timeout
	active = false

func _enter_tree():
	reload()

func reload():
	if !is_connected("area_entered", Callable(self, "collide")):
		connect("area_entered", Callable(self, "collide"))
	add_to_group("combat_area")

func collide(area:Area2D):
	if !Engine.is_editor_hint() and active:
		if area_type != 0 and area.is_in_group("combat_area_body"):
			if area.active:
				if area_type == 2 and area.team != team:
					area.damage_func(damage,potency,effect,knocback_dir,rotated_knockback)
					if destroy_on_collision:
						destroyed.emit()
						queue_free()
				if area_type == 1 and area.team == team:
					area.heal_func(heal,effect,knocback_dir,rotated_knockback)
					if destroy_on_collision:
						destroyed.emit()
						queue_free()
				if area_type == 3 and area.team == team:
					area.item_func(item,effect,knocback_dir,rotated_knockback)
					if destroy_on_collision:
						destroyed.emit()
						queue_free()

func item_func(item,effect,knocback_dir,rotated_knockback):
	emit_signal("item_signal",item,effect,knocback_dir,rotated_knockback)

func damage_func(damage,potency,effect,knocback_dir,rotated_knockback):
	emit_signal("damage_signal",damage,potency,effect,knocback_dir,rotated_knockback)

func heal_func(heal,effect,knocback_dir,rotated_knockback):
	emit_signal("heal_signal",heal,effect,knocback_dir,rotated_knockback)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if area_type == null:
		area_type = 0
	monitorable = active
	monitoring = active
	add_to_group("combat_area")
	change_groups()
	change_to_template()
	if Engine.is_editor_hint():
		change_collision_color()
		print_info()
		#if you are modigying the script and want to simulate an enter tree, decoment this
		#if reload_propieties_devs:
		#	reload_propieties_devs = false
		#	reload()

func print_info():
	if print_combat_info == true:
		print_combat_info = false
		print(str(self.name) + " properties:")
		print(get_groups())
		print("Team " + str(team))
		if area_type == 3:
			print("Damage " + str(damage))
			print("Potency " + str(potency))
		if area_type == 1:
			print("Heal " + str(heal))
		if area_type == 2:
			if item != "":
				print("Item: " + str(item))
			else:
				print("No item")
		if effect != "":
			print("Effect: " + str(effect))
		else:
			print("No effect")
		print("Knockback dir: " + str(knocback_dir))
		if rotated_knockback:
			print("Rotated Knockback")
		else:
			print("Fixed Knockback")
		if destroy_on_collision:
			print("Will destroy when collide")
		match area_type:
			2:
				print("Damaging area")
			1:
				print("Healing area")
			0:
				print("Body area")
			3:
				print("Item area")
		if active:
			print("active")
		else:
			print("inactive")

func change_collision_color():
	if get_node_or_null("CollisionShape2D") != null:
		if active:
			match area_type:
				2:
					get_node_or_null("CollisionShape2D").debug_color = Color(Color.RED,0.41)
				1:
					get_node_or_null("CollisionShape2D").debug_color = Color(Color.LIME_GREEN,0.41)
				0:
					get_node_or_null("CollisionShape2D").debug_color = Color(Color.NAVY_BLUE,0.41)
				3:
					get_node_or_null("CollisionShape2D").debug_color = Color(Color.YELLOW,0.41)
		else:
			get_node_or_null("CollisionShape2D").debug_color = Color(Color.BLACK,0.2)
	if get_node_or_null("CollisionPolygon2D") != null:
		if active:
			match area_type:
				2:
					get_node_or_null("CollisionPolygon2D").modulate = Color(Color.RED,0.41)
				1:
					get_node_or_null("CollisionPolygon2D").modulate = Color(Color.LIME_GREEN,0.41)
				0:
					get_node_or_null("CollisionPolygon2D").modulate = Color(Color.NAVY_BLUE,0.41)
				3:
					get_node_or_null("CollisionPolygon2D").modulate = Color(Color.YELLOW,0.41)
		else:
			get_node_or_null("CollisionPolygon2D").modulate = Color(Color.BLACK,0.2)


func change_groups():
	if is_in_group("combat_area_null"):
		remove_from_group("combat_area_null")
	match area_type:
		2:
			if !is_in_group("combat_area_damage"):
				add_to_group("combat_area_damage")
			if is_in_group("combat_area_heal"):
				remove_from_group("combat_area_heal")
			if is_in_group("combat_area_body"):
				remove_from_group("combat_area_body")
			if is_in_group("combat_area_item"):
				remove_from_group("combat_area_item")
		1:
			if is_in_group("combat_area_damage"):
				remove_from_group("combat_area_damage")
			if !is_in_group("combat_area_heal"):
				add_to_group("combat_area_heal")
			if is_in_group("combat_area_body"):
				remove_from_group("combat_area_body")
			if is_in_group("combat_area_item"):
				remove_from_group("combat_area_item")
		0:
			if is_in_group("combat_area_damage"):
				remove_from_group("combat_area_damage")
			if is_in_group("combat_area_heal"):
				remove_from_group("combat_area_heal")
			if !is_in_group("combat_area_body"):
				add_to_group("combat_area_body")
			if is_in_group("combat_area_item"):
				remove_from_group("combat_area_item")
		3:
			if is_in_group("combat_area_damage"):
				remove_from_group("combat_area_damage")
			if is_in_group("combat_area_heal"):
				remove_from_group("combat_area_heal")
			if is_in_group("combat_area_body"):
				remove_from_group("combat_area_body")
			if !is_in_group("combat_area_item"):
				add_to_group("combat_area_item")

func change_to_template():
	match template:
		"Select one in list":
			pass
		"Player Hurtbox":
			area_type = 0
			destroy_on_collision = false
			damage = 0
			heal = 0
			potency = 0
			item = ""
			effect = ""
			team = 1
			template = "Select one in list"
			notify_property_list_changed()
		"Player Projectile":
			area_type = 2
			destroy_on_collision = true
			damage = 1
			heal = 0
			potency = 1
			item = ""
			effect = ""
			team = 1
			template = "Select one in list"
			notify_property_list_changed()
		"Enemy Hurtbox":
			area_type = 0
			destroy_on_collision = false
			damage = 0
			heal = 0
			potency = 0
			item = ""
			effect = ""
			team = 2
			template = "Select one in list"
			notify_property_list_changed()
		"Enemie Projectile":
			area_type = 2
			destroy_on_collision = true
			damage = 1
			heal = 0
			potency = 1
			item = ""
			effect = ""
			team = 2
			template = "Select one in list"
			notify_property_list_changed()
		"Coin":
			area_type = 3
			destroy_on_collision = true
			damage = 0
			heal = 0
			potency = 0
			item = "coin"
			effect = ""
			team = 1
			template = "Select one in list"
			notify_property_list_changed()
		"Bomb":
			area_type = 2
			destroy_on_collision = true
			damage = 3
			heal = 0
			potency = 5
			item = ""
			effect = ""
			team = 3
			template = "Select one in list"
			notify_property_list_changed()
		"Heal Pills":
			area_type = 3
			destroy_on_collision = true
			damage = 0
			heal = 0
			potency = 0
			item = "heal pills"
			effect = "regeneration"
			team = 1
			template = "Select one in list"
			notify_property_list_changed()
		"Heal Area3D":
			area_type = 1
			destroy_on_collision = false
			damage = 0
			heal = 1
			potency = 0
			item = ""
			effect = ""
			team = 1
			template = "Select one in list"
			notify_property_list_changed()
		"Fireball":
			area_type = 2
			destroy_on_collision = true
			damage = 2
			heal = 0
			potency = 0
			item = ""
			effect = "burning"
			team = 2
			template = "Select one in list"
			notify_property_list_changed()
