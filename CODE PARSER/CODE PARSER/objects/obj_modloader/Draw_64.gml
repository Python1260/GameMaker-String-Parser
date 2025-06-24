var disw = display_get_gui_width()
var dish = display_get_gui_height()
var winw = window_get_width()
var winh = window_get_height()

var rmx = window_mouse_get_x()
var rmy = window_mouse_get_y()

draw_set_font(ft_small)
draw_text(0, 0, $"FPS: {fps_real}")

draw_set_font(ft_big)
draw_set_color(c_white)
draw_text(disw * 0.1, dish * 0.1, game_title)

draw_set_font(ft_medium)

for (var m = 0;m <= array_length(mods);m++) {
	var mx = disw * 0.2
	var my = dish * 0.25 + (string_height("A") * m * 1.5)
	
	draw_set_color(m == selected_idx ? (m == current_mod ? merge_color(c_yellow, c_black, 0.5) : c_yellow) : c_white)
	
	if m == array_length(mods) {
		draw_text(mx, my, "ADD +")
	}
	else {
		var _mod = mods[m]
		
		draw_text(mx, my, _mod.name)
		
		if m == current_mod {
			draw_set_color(current_idx == 0 ? c_yellow : c_white)
			draw_text(mx + disw * 0.25, my, "-RUN-")
			draw_set_color(current_idx == 1 ? c_yellow : c_white)
			draw_text(mx + disw * 0.5, my, "-DELETE-")
		}
	}
}

draw_set_font(ft_small)

gpu_set_scissor(0, winh * 0.85, winw, winh * 0.15)

var _rrel = log_addrel
for (var l = 0;l < array_length(log_messages);l++) {
	var _log = log_messages[l]
	var _ltext = (l == array_length(log_messages) - 1) ? "-> " + _log.text : _log.text
	
	var _lx = (l == array_length(log_messages) - 1) ? -string_width(_ltext) * (1 - _rrel) : 0
	var _ly = dish + (string_height(_ltext) * ((l - _rrel) + 1 - 1 - array_length(log_messages)))
	
	draw_set_color((l == array_length(log_messages) - 1) ? c_white : c_gray)
	
	draw_text(_lx, _ly, _ltext)
}

gpu_set_scissor(0, 0, winw, winh)

var _addchar = (current_time / 1000 * room_speed) % (room_speed / 2) >= (room_speed / 4) ? "|" : " "
var _fullcstring = string_copy(console_string, 1, console_stringoffset) + _addchar + string_copy(console_string, console_stringoffset + 1, string_length(console_string) - console_stringoffset)
draw_set_color(selected_idx == (array_length(mods) + 1) ? c_yellow : c_white)
draw_text(0, dish - string_height("A"), $"---> {_fullcstring}")

draw_set_font(ft_small)

draw_set_color(c_white)

if documentation_rel > 0 {
	var _drel = documentation_rel * documentation_rel
	var _dy = -(1 - _drel) * dish
	
	draw_set_color(make_color_rgb(0, 35, 100))
	draw_rectangle(0, _dy, disw, _dy + dish, false)
	
	var _barsize = (dish / string_height(documentation_text)) * dish
	if !is_nan(_barsize) and _barsize < dish {
		var _barpos = (documentation_offset / (string_height(documentation_text) - dish + string_height("A") * 0.5)) * (dish - _barsize)
		
		draw_set_color(make_color_rgb(0, 18, 50))
		draw_roundrect_ext(disw - string_width("A"), _dy + _barpos, disw, _dy + _barpos + _barsize, 12, 12, false)
	}
	
	gpu_set_scissor(0, _dy * (winh / dish), winw, winh)
	
	draw_set_color(c_white)
	draw_text(string_width("A"), _dy + string_height("A") * 0.5 - documentation_offset, documentation_text)
	
	gpu_set_scissor(0, 0, winw, winh)
}

draw_set_font(ft_big)
draw_textbutton(disw * 0.1 + string_width(game_title) * 1.75 - string_width("?") * 0.5, dish * 0.1, disw * 0.1 + string_width(game_title) * 1.75 + string_width("?") * 1.5, dish * 0.1 + string_height("?"), string_width("?") * 0.15, "?")

draw_set_font(ft_medium)
draw_set_color(c_white)