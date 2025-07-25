function approach(num, target, val) {
	if num < target {
		return num + val > target ? target : num + val
	}
	else if num > target {
		return num - val < target ? target : num - val
	}
	
	return num
}

function get_text_fromfile(path) {
	var file = file_text_open_read(path)
	var filecontent = ""
	
	while !file_text_eof(file) {
		filecontent += file_text_readln(file)
	}
	file_text_close(file)
	
	return filecontent
}

function get_real_mouse_x() {
	return window_mouse_get_x() * (display_get_gui_width() / window_get_width())
}

function get_real_mouse_y() {
	return window_mouse_get_y() * (display_get_gui_height() / window_get_height())
}

function get_real_mouse_delta_y() {
	return window_mouse_get_delta_y() * (display_get_gui_height() / window_get_height())
}

function draw_textbutton(bx1, by1, bx2, by2, bborder, btext) {
	var rmx = get_real_mouse_x()
	var rmy = get_real_mouse_y()
	
	var _inrect = point_in_rectangle(rmx, rmy, bx1, by1, bx2, by2)
	var _pressing = mouse_check_button(mb_left)
	
	if _inrect and _pressing {
		bx1 += bborder
		by1 += bborder
		bx2 -= bborder
		by2 -= bborder
	}
	
	draw_roundrect_ext(bx1 - bborder, by1 - bborder, bx2 + bborder, by2 + bborder, 25, 25, false)
	draw_set_color(_inrect ? (_pressing ? c_dkgray : c_gray) : c_black)
	draw_roundrect_ext(bx1, by1, bx2, by2, 25, 25, false)
	draw_set_color(c_white)
	draw_text((bx1 + bx2) / 2 - string_width(btext) / 2, (by1 + by2) / 2 - string_height(btext) / 2, btext)
}