extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("area_entered",self, "_area_entered");

# Called when this area enters another area
func _area_entered(body):
	# Ignore collisons after the round ends
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: 
		return;
	# If this player is dead, ignore any collisions
	if get_parent().alive == false:
		return;
	if body.is_in_group("Flag_Home_Bodies"):
		collided_with_flag_home(body.get_parent());	
	if body.is_in_group("Powerup_Bodies"):
		collided_with_powerup_body(body.get_parent());
	# Only detect collisions for these cases if we are the server
	if !Globals.testing and get_tree().is_network_server():
		if body.is_in_group("Bullet_Bodies"):
			collided_with_bullet(body.get_parent());
		if body.is_in_group("Laser_Bodies"):
			collided_with_laser_body(body.get_parent());
		if body.is_in_group("Grenade_Bodies"):
			collided_with_grenade_body(body.get_parent());

# Called when this player collides with a bullet
func collided_with_bullet(bullet):
	# Ignore collisons after the round ends
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: 
		return;
	var player = get_parent();
	# If we're invincible, ignore it
	if player.invincible:
		return;
	# If our team shot this, ignore it
	if get_tree().get_root().get_node("MainScene/NetworkController").players[bullet.player_id]['team_id'] == player.team_id:
		return;
	# If we're currently in a forcefield, ignore it
	for area in get_overlapping_areas():
		if area.is_in_group("Forcefield_Bodies"):
			return;
	# Else we've been hit by an enemy
	player.rpc("receive_hit", bullet.player_id, 0);
	bullet.rpc("receive_death");

# Called when this player collides with a flag_home
func collided_with_flag_home(flag_home):
	# If the round is already over ignore new events
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: 
		return;
	var player = get_parent();
	# If this is the other team's Flag Home, ignore it
	if flag_home.team_id != player.team_id:
		return;
	# Else if this is our Flag_Home, and we have a flag
	elif player.get_node("Flag_Holder").get_child_count() > 0:
		var flag = null;
		for each_flag in get_tree().get_nodes_in_group("Flags"):
			if each_flag.flag_id == flag_home.flag_id:
				flag = each_flag;
		# If this flag_home's flag is not at home, ignore it because you can't score yet
		if !flag.is_at_home:
			# Only display message if this is our local player
			if get_parent().player_id == Globals.localPlayerID:
				get_tree().get_root().get_node("MainScene/UI_Layer").set_alert_text("[center][color=black]* YOUR FLAG MUST BE HOME TO SCORE *");
		elif get_tree().is_network_server(): # Otherwise score if we're the server
			print("Scoring : " + str(get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended));
			get_tree().get_root().get_node("MainScene/NetworkController").rpc("round_ended", player.team_id, player.player_id);
# Called when this player collides with a laser
func collided_with_laser_body(laser_parent):
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: return;
	var player = get_parent();
	# If this is our team's laser, ignore it
	if laser_parent.team_id == player.team_id:
		return;
	# If this player is invincible, dont get hit
	if player.invincible:
		return;
	# Otherwise receive a hit from the laser
	player.rpc("receive_hit", laser_parent.player_id, 1);
# Called when this player collides with a laser
func collided_with_grenade_body(grenade_parent):
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: return;
	var player = get_parent();
	# If this is our team's grenade, ignore it
	if grenade_parent.team_id == player.team_id:
		return;
	# If this player is invincible, dont get hit
	if player.invincible:
		return;
	# Otherwise receive a hit from the grenade
	player.rpc("receive_hit", grenade_parent.player_id, 2);
func collided_with_powerup_body(powerup_parent):
	if get_tree().get_root().get_node("MainScene/NetworkController").round_is_ended: return;
	var player = get_parent();
	powerup_parent.call_deferred("queue_free");
	powerup_parent._used();
	player.enable_powerup(powerup_parent.type);
