var key_left = keyboard_check_pressed(vk_left)
var key_right = keyboard_check_pressed(vk_right)
var key_up = keyboard_check_pressed(vk_up)
var key_down = keyboard_check_pressed(vk_down)

var key_confirm = keyboard_check_pressed(vk_enter)
var key_back = keyboard_check_pressed(vk_shift)
var key_paste = keyboard_check(vk_control) and keyboard_check_pressed(ord("V"))

var key_click_press = mouse_check_button_pressed(mb_left)
var key_click_rel = mouse_check_button_released(mb_left)

var moveX = (key_right - key_left)
var moveY = (key_down - key_up)

var disw = display_get_gui_width()
var dish = display_get_gui_height()

var rmx = window_mouse_get_x()
var rmy = window_mouse_get_y()

var mouse_move = (mouse_wheel_down() - mouse_wheel_up())

log_addrel = approach(log_addrel, 1, 0.1)
documentation_rel = approach(documentation_rel, documentation_open, 0.1)

if key_click_rel {
	documentation_holdingbar = false
	
	draw_set_font(ft_big)
	
	if point_in_rectangle(rmx, rmy, disw * 0.1 + string_width(game_title) * 1.75 - string_width("?") * 0.5, dish * 0.1, disw * 0.1 + string_width(game_title) * 1.75 + string_width("?") * 1.5, dish * 0.1 + string_height("?")) {
		documentation_open = !documentation_open
	}
}

if current_mod == noone {
	var _previdx = selected_idx
	selected_idx = clamp(selected_idx + moveY, 0, array_length(mods) + 1)
	
	if selected_idx != _previdx and selected_idx == (array_length(mods) + 1) { keyboard_string = console_string; keyboard_string_prev = console_string; }
	if selected_idx == (array_length(mods) + 1) {
		if key_paste and clipboard_has_text() { keyboard_string += clipboard_get_text() }
		var _sdiff = string_difference(keyboard_string, keyboard_string_prev)
		
		if is_numeric(_sdiff) {
			if console_stringoffset != 0 {
				console_string = string_delete(console_string, console_stringoffset + _sdiff + 1, -_sdiff)
				console_stringoffset += _sdiff
			}
		}
		else {
			console_string = string_copy(console_string, 1, console_stringoffset) + _sdiff + string_copy(console_string, console_stringoffset + 1, string_length(console_string) - console_stringoffset)
			console_stringoffset += string_length(_sdiff)
		}
		
		console_stringoffset = clamp(console_stringoffset + moveX, 0, string_length(console_string))
		keyboard_string = console_string
	}
	
	if key_confirm {
		if selected_idx == array_length(mods) {
			var mfilepath = get_open_filename("GML File|*.gml", "")
			
			if mfilepath != "" {
				var _mfilename = array_last(string_split(mfilepath, "\\"))
				var _exists = file_exists(global.path_mods + _mfilename)
				
				file_copy(mfilepath, global.path_mods + _mfilename)
				
				if !_exists {
					array_push(mods, load_mod(global.path_mods, _mfilename))
					add_log($"Successfully loaded mod {_mfilename}")
				}
				else {
					add_log($"Successfully updated mod {_mfilename}")
				}
			}
		}
		else if selected_idx == (array_length(mods) + 1) {
			if console_string != "" {
				array_push(console_commands, console_string)
				
				var _parser = parse_string(console_string, console_sessionid)
				var _result = parser_run(_parser)
				
				if _result[0] {
					add_log($"{_result[1]}")
				}
				else {
					add_log($"Error occured: {_result[1]}")
				}
				
				keyboard_string = ""
				keyboard_string_prev = ""
				console_string = ""
			}
		}
		else {
			current_mod = selected_idx
		}
	}
}
else {
	current_idx = clamp(current_idx + moveX, 0, 2)
	
	if key_confirm {
		var _mod = mods[current_mod]
		
		switch (current_idx) {
			case 0:
				_mod.parser = parse_string(_mod.execstr)
				var _result = parser_run(_mod.parser)
				
				current_mod = noone
				current_idx = 0
				
				if _result[0] {
					add_log($"Mod {_mod.name} executed successfully with result: {_result[1]}")
				}
				else {
					add_log($"Mod {_mod.name} failed to execute with error: {_result[1]}")
				}
				break
				
			case 1:
				file_delete(_mod.path)
				array_delete(mods, current_mod, 1)
				
				current_mod = noone
				current_idx = 0
				selected_idx = clamp(selected_idx - 1, 0, array_length(mods) - 1)
				
				add_log($"Mod {_mod.name} was removed successfully")
				break
		}
	}
	else if key_back {
		current_mod = noone
		current_idx = 0
	}
}

if documentation_open and documentation_rel == 1 {
	var _drel = documentation_rel * documentation_rel
	var _dy = -(1 - _drel) * dish
	
	draw_set_font(ft_small)
	
	documentation_offset += mouse_move * documentation_scrollspd
	
	var _barsize = (dish / string_height(documentation_text)) * dish
	if !is_nan(_barsize) and _barsize < dish {
		var _barpos = (documentation_offset / (string_height(documentation_text) - dish + string_height("A") * 0.5)) * (dish - _barsize)
		
		if key_click_press and point_in_rectangle(rmx, rmy, disw - string_width("A"), _dy + _barpos, disw, _dy + _barpos + _barsize) {
			documentation_holdingbar = true
		}
		
		if documentation_holdingbar {
			var _dmy = window_mouse_get_delta_y() * 1.75
			
			documentation_offset += (_dmy / dish) * (max(string_height(documentation_text) - dish, 0) + string_height("A") * 0.5)
		}
	}
	
	documentation_offset = clamp(documentation_offset, 0, max(string_height(documentation_text) - dish, 0) + string_height("A") * 0.5)
}

keyboard_string_prev = keyboard_string