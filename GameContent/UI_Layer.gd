extends CanvasLayer

var start_time = OS.get_system_time_secs();
var show_move_gui = true;


func _ready():
	var _err = $Leave_Match_Button.connect("pressed", self, "_leave_match_button_pressed");
	_err = $Cancel_Button.connect("pressed", self, "_cancel_button_pressed");
	_err = $"../Chat_Layer/Options_Button".connect("button_up", self, "_options_button_clicked");
	get_tree().connect("screen_resized", self, "_screen_resized");
	_screen_resized();

func _process(delta):
	if Globals.isServer:
		return;
	# Show / Hide move gui depending on whether loadout is visible
	if Globals.displaying_loadout:
		show_move_gui = true;
	elif show_move_gui == true:
		show_move_gui = false;
		$Move_GUI_Fade_Timer.start();
	if show_move_gui:
		$Input_GUIs/Move_GUIs.modulate = Color(1,1,1,1);
		$Input_GUIs/Ability_GUIs.modulate = Color(0,0,0,0);
	elif $Move_GUI_Fade_Timer.time_left > 0:
		var progress = 1 - ($Move_GUI_Fade_Timer.time_left / $Move_GUI_Fade_Timer.wait_time);
		$Input_GUIs/Move_GUIs.modulate = Color(1,1,1,1-progress);
		$Input_GUIs/Ability_GUIs.modulate = Color(1,1,1,progress);
	else:
		$Input_GUIs/Move_GUIs.modulate = Color(0,0,0,0);
		$Input_GUIs/Ability_GUIs.modulate = Color(1,1,1,1);
	
	if get_tree().get_root().get_node("MainScene/NetworkController").isSkirmish:
		$Score_Label.bbcode_text = "[center][color=black]SEARCHING " + str(OS.get_system_time_secs() - start_time);
		$Time_Label.visible = false;
		$Skirmish_Subtext.visible = true;
		$Cancel_Button.visible = true;
	if Globals.experimental:
		$Score_Label.bbcode_text = "";
		$Skirmish_Subtext.visible = false;
		$Cancel_Button.visible = false;
	else:
		$Skirmish_Subtext.visible = false;
	if !Globals.is_typing_in_chat:
		if Input.is_key_pressed(KEY_E):
			$"Input_GUIs/Ability_GUIs/E_GUI".frame = 1;
		else:
			$"Input_GUIs/Ability_GUIs/E_GUI".frame = 0;
		if Input.is_key_pressed(KEY_SPACE):
			$"Input_GUIs/Ability_GUIs/SPACE_GUI".frame = 1;
		else:
			$"Input_GUIs/Ability_GUIs/SPACE_GUI".frame = 0;
		if Input.is_key_pressed(KEY_W):
			$"Input_GUIs/Move_GUIs/W_GUI".frame = 1;
		else:
			$"Input_GUIs/Move_GUIs/W_GUI".frame = 0;
		if Input.is_key_pressed(KEY_A):
			$"Input_GUIs/Move_GUIs/A_GUI".frame = 1;
		else:
			$"Input_GUIs/Move_GUIs/A_GUI".frame = 0;
		if Input.is_key_pressed(KEY_S):
			$"Input_GUIs/Move_GUIs/S_GUI".frame = 1;
		else:
			$"Input_GUIs/Move_GUIs/S_GUI".frame = 0;
		if Input.is_key_pressed(KEY_D):
			$"Input_GUIs/Move_GUIs/D_GUI".frame = 1;
		else:
			$"Input_GUIs/Move_GUIs/D_GUI".frame = 0;
		if Input.is_key_pressed(KEY_E):
			$"Input_GUIs/Ability_GUIs/E_GUI".frame = 1;
		else:
			$"Input_GUIs/Ability_GUIs/E_GUI".frame = 0;
		if Input.is_key_pressed(KEY_SHIFT):
			$"Input_GUIs/Ability_GUIs/SHIFT_GUI".frame = 1;
		else:
			$"Input_GUIs/Ability_GUIs/SHIFT_GUI".frame = 0;
		if Input.is_action_pressed("clickR"):
			$Input_GUIs/Ability_GUIs/Q_GUI.frame = 1;
		else:
			$Input_GUIs/Ability_GUIs/Q_GUI.frame = 0;
	
	var time = get_tree().get_root().get_node("MainScene/NetworkController/Match_Time_Limit_Timer").time_left;
	var seconds = int(time) % 60;
	$Time_Label.bbcode_text = "[center]" + str(int(time)/int(60)) + ":" + ((str(seconds)) if seconds > 9 else ("0" + str(seconds)));
	
	$Alert_Text.modulate = Color(1,1,1, ($Alert_Fade_Timer.time_left/$Alert_Fade_Timer.wait_time));
	var local_player;
	if Globals.testing:
		local_player = get_tree().get_root().get_node("MainScene/Test_Player");
	elif Globals.localPlayerID != null and get_tree().get_root().get_node("MainScene/Players").has_node("P" + str(Globals.localPlayerID)):
		local_player = get_tree().get_root().get_node("MainScene/Players/P" + str(Globals.localPlayerID));
	if local_player != null:
		# Teleport button
		var teleport_time_left = local_player.get_node("Teleport_Timer").time_left;
		var teleport_wait_time = local_player.get_node("Teleport_Timer").wait_time;
		if teleport_time_left == 0:
			$Input_GUIs/Ability_GUIs/Teleport_GUI_Text.text = "DASH";
			$Input_GUIs/Ability_GUIs/SPACE_GUI.modulate = Color(1,1,1,1);
		else:
			$Input_GUIs/Ability_GUIs/Teleport_GUI_Text.text = "%0.2f" % teleport_time_left;
			$Input_GUIs/Ability_GUIs/SPACE_GUI.modulate = Color(1,1,1,0.2 + 0.4 * ((teleport_wait_time - teleport_time_left) / teleport_wait_time) );
			
		# Ability button
		var ability_time_left = local_player.get_node("Ability_Node/Cooldown_Timer").time_left;
		var ability_wait_time = local_player.get_node("Ability_Node/Cooldown_Timer").wait_time;
		
		if ability_time_left == 0:
			var t = "";
			if Globals.current_ability == Globals.Abilities.Forcefield:
				t = "FORCEFIELD";
			elif Globals.current_ability == Globals.Abilities.Camo:
				t = "CAMO"
			$Input_GUIs/Ability_GUIs/Ability_GUI_Text.text = t;
			$Input_GUIs/Ability_GUIs/E_GUI.modulate = Color(1,1,1,1);
		else:
			$Input_GUIs/Ability_GUIs/Ability_GUI_Text.text = "%0.2f" % ability_time_left;
			$Input_GUIs/Ability_GUIs/E_GUI.modulate = Color(1,1,1,0.2 + 0.4 * ((ability_wait_time - ability_time_left) / ability_wait_time) );
		
		
		# Utility
		var utility_time_left = local_player.get_node("Utility_Node/Cooldown_Timer").time_left;
		var utility_wait_time = local_player.get_node("Utility_Node/Cooldown_Timer").wait_time;
		if utility_time_left == 0:
			var t = "";
			if Globals.current_utility == Globals.Utilities.Grenade:
				t = "GRENADE";
			elif Globals.current_utility == Globals.Utilities.Landmine:
				t = "LANDMINE"
			$Input_GUIs/Ability_GUIs/Utility_GUI_Text.text = t;
			$Input_GUIs/Ability_GUIs/Utility_GUI_Text.modulate = Color(1,1,1,1);
		else:
			$Input_GUIs/Ability_GUIs/Utility_GUI_Text.text = "%0.2f" % utility_time_left;
			$Input_GUIs/Ability_GUIs/Utility_GUI_Text.modulate = Color(1,1,1,0.2 + 0.4 * ((utility_wait_time - utility_time_left) / utility_wait_time) );
		
		# If player is holding a flag
		if local_player.get_node("Flag_Holder").get_child_count() > 0:
			$Input_GUIs/Ability_GUIs/Q_GUI.modulate = Color(1,1,1,0.4);

func _screen_resized():
	var window_size = OS.get_window_size();
	$"../Chat_Layer/Chat_Box".rect_scale= Vector2(1,1);
	$"../Chat_Layer/Line_Edit".rect_scale= Vector2(1,1);
	$"../Chat_Layer/Chat_Box".margin_bottom = window_size.y * (0.6);
	$"../Chat_Layer/Chat_Box".margin_top = 73;
	$"../Chat_Layer/Options_Button".rect_scale = Vector2(0.5,0.5);
	$Cancel_Button.rect_scale = Vector2(0.5,0.5);
	if window_size.x < 500 or window_size.y < 200:
		$Input_GUIs.rect_scale = Vector2(0.5,0.5);
		$Input_GUIs.margin_top = -40;
		$Alert_Text.get_font("normal_font").size =6;
		$Alert_Text.margin_top = $Input_GUIs.margin_top - 50;
	elif window_size.x <= 1920 or window_size.y <= 1080:
		$Input_GUIs.rect_scale = Vector2(1,1);
		$Alert_Text.get_font("normal_font").size =12;
		$Input_GUIs.margin_top = -80;
		$Alert_Text.margin_top = $Input_GUIs.margin_top - 100;
	else:
		$Input_GUIs.rect_scale = Vector2(2,2);
		$Alert_Text.get_font("normal_font").size =24;
		$Alert_Text.margin_top = $Input_GUIs.margin_top - 200;
		$"../Chat_Layer/Chat_Box".rect_scale = Vector2(2,2);
		$"../Chat_Layer/Line_Edit".rect_scale = Vector2(2,2);
		$"../Chat_Layer/Options_Button".rect_scale = Vector2(1,1);
		$Cancel_Button.rect_scale = Vector2(1,1);
		$"../Chat_Layer/Chat_Box".margin_top = 160;
		
	var size = $"../Chat_Layer/Line_Edit".rect_size.y;
	$"../Chat_Layer/Line_Edit".margin_top = $"../Chat_Layer/Chat_Box".margin_bottom;
	$"../Chat_Layer/Line_Edit".margin_bottom = $"../Chat_Layer/Line_Edit".margin_top + size;


func _options_button_clicked():
	Globals.toggle_options_menu();
	$"../Chat_Layer/Options_Button".release_focus();

# Color 0 = blue, 1 = red
func set_big_label_text(text, color):
	clear_big_label_text();
	if color == 0:
		$Big_Label_Blue.text = text;
	if color == 1:
		$Big_Label_Red.text = text;
# Clears the text in the big labels
func clear_big_label_text():
	$Big_Label_Blue.text = "";
	$Big_Label_Red.text = "";
func set_alert_text(text):
	$Alert_Text.bbcode_text = text;
	$Alert_Fade_Timer.start();

# Sets the score label values
func set_score_text(team0_score, team1_score, isSkirmish = false):
	if isSkirmish:
		$Score_Label.bbcode_text = "[center][color=black]SKIRMISH LOBBY";
	else:
		$Score_Label.bbcode_text = "[center]" + "[color=#4C70BA]" + str(team0_score) + "[/color]" + "-" + "[color=#FF0000]" + str(team1_score) + "[/color]" + "[/center]";
		
	
func enable_leave_match_button():
	$Leave_Match_Button.visible = true;

func _leave_match_button_pressed():
	print("pressed");
	get_tree().get_root().get_node("MainScene/NetworkController").leave_match();

func _cancel_button_pressed():
	Globals.leave_MMQueue();
func disappear():
	$Score_Label.visible = false;
	$Time_Label.visible = false;
	$Countdown_Label.visible = false;
	$Big_Label_Blue.visible = false;
	$Big_Label_Red.visible = false;
	$Input_GUIs.visible = false;
	$Alert_Text.visible = false;
	$Skirmish_Subtext.visible = false;
	$"../Loadout_Menu".hidden = true;
func appear():
	$Score_Label.visible = true;
	$Time_Label.visible = true;
	$Countdown_Label.visible = true;
	$Big_Label_Blue.visible = true;
	$Big_Label_Red.visible = true;
	$Input_GUIs.visible = true;
	$Alert_Text.visible = true;
	$Skirmish_Subtext.visible = true;
	$"../Loadout_Menu".hidden = false;
