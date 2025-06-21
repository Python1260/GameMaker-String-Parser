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

function draw_textbutton(bx1, by1, bx2, by2, bborder, btext) {
	var rmx = window_mouse_get_x()
	var rmy = window_mouse_get_y()
	
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