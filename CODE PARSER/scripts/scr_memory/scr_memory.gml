function memory_clear() {
	delete global.token_currentinstance
	delete global.token_returned
	delete global.token_memory
	
	global.token_currentinstance = {}
	global.token_returned = {}
	global.token_memory = {}
}

function token_memory_init() {
	global.token_regionelems = [["{", "}"], ["(", ")"], ["[", "]"], ["\"", "\""]]
	
	global.token_functions = {};
	struct_set(global.token_functions, "show_debug_message", function(msg) { show_debug_message(msg); });
	struct_set(global.token_functions, "show_message", function(msg) { show_message(msg); });
	struct_set(global.token_functions, "array_create", function(length, fill) { return array_create(length, fill); });
	struct_set(global.token_functions, "array_length", function(array) { return array_length(array); });
	struct_set(global.token_functions, "array_get", function(array, index) { return array_get(array, index); });
	struct_set(global.token_functions, "array_set", function(array, index, value) { return array_set(array, index, value); });
	struct_set(global.token_functions, "array_push", function(array, value) { return array_push(array, value); });
	struct_set(global.token_functions, "struct_get_names", function(struct) { return struct_get_names(struct); });
	struct_set(global.token_functions, "struct_get", function(struct, key) { return struct_get(struct, key); });
	struct_set(global.token_functions, "struct_set", function(struct, key, value) { return struct_set(struct, key, value); });
	struct_set(global.token_functions, "struct_remove", function(struct, key) { return struct_remove(struct, key); });
	struct_set(global.token_functions, "instance_create_layer", function(ix, iy, ilayer, iobj) { return instance_create_layer(ix, iy, ilayer, iobj); });
	struct_set(global.token_functions, "instance_create_depth", function(ix, iy, idepth, iobj) { return instance_create_depth(ix, iy, idepth, iobj); });
	struct_set(global.token_functions, "instance_destroy", function(inst) { return instance_destroy(inst); });
	struct_set(global.token_functions, "instance_exists", function(inst) { return instance_exists(inst); });
	struct_set(global.token_functions, "lengthdir_x", function(len, dir) { return lengthdir_x(len, dir); });
	struct_set(global.token_functions, "lengthdir_y", function(len, dir) { return lengthdir_y(len, dir); });
	struct_set(global.token_functions, "point_distance", function(x1, y1, x2, y2) { return point_distance(x1, y1, x2, y2); });
	struct_set(global.token_functions, "point_direction", function(x1, y1, x2, y2) { return point_direction(x1, y1, x2, y2); });
	struct_set(global.token_functions, "angle_difference", function(dir1, dir2) { return angle_difference(dir1, dir2); });
	struct_set(global.token_functions, "place_meeting", function(px, py, obj) { return place_meeting(px, py, obj); });
	struct_set(global.token_functions, "instance_place", function(px, py, obj) { return instance_place(px, py, obj); });
	struct_set(global.token_functions, "clamp", function(val, mi, ma) { return clamp(val, mi, ma); });
	struct_set(global.token_functions, "min", function(a, b) { return min(a, b); });
	struct_set(global.token_functions, "max", function(a, b) { return max(a, b); });
	struct_set(global.token_functions, "round", function(a) { return round(a); });
	struct_set(global.token_functions, "floor", function(a) { return floor(a); });
	struct_set(global.token_functions, "ceil", function(a) { return ceil(a); });
	struct_set(global.token_functions, "sin", function(a) { return sin(a); });
	struct_set(global.token_functions, "random_range", function(a, b) { return random_range(a, b); });
	struct_set(global.token_functions, "irandom_range", function(a, b) { return irandom_range(a, b); });
	struct_set(global.token_functions, "keyboard_check", function(key) { return keyboard_check(key); });
	struct_set(global.token_functions, "keyboard_check_pressed", function(key) { return keyboard_check_pressed(key); });
	struct_set(global.token_functions, "keyboard_check_released", function(key) { return keyboard_check_released(key); });
	struct_set(global.token_functions, "ord", function(key) { return ord(key); });
	struct_set(global.token_functions, "collision_rectangle", function(x1, y1, x2, y2, obj, prec, notme) { return collision_rectangle(x1, y1, x2, y2, obj, prec, notme); });
	struct_set(global.token_functions, "draw_text", function(tx, ty, text) { return draw_text(tx, ty, text); });
	struct_set(global.token_functions, "draw_rectangle", function(px1, py1, px2, py2, outline) { return draw_rectangle(px1, py1, px2, py2, outline); });
	struct_set(global.token_functions, "draw_set_color", function(color) { return draw_set_color(color); });
	struct_set(global.token_functions, "draw_set_alpha", function(alpha) { return draw_set_alpha(alpha); });
	struct_set(global.token_functions, "draw_set_font", function(findex) { return draw_set_font(findex); });
	struct_set(global.token_functions, "merge_color", function(col1, col2, rel) { return merge_color(col1, col2, rel); });
	struct_set(global.token_functions, "make_color_rgb", function(r, g, b) { return make_color_rgb(r, g, b); });
	struct_set(global.token_functions, "make_color_hsv", function(h, s, v) { return make_color_hsv(h, s, v); });
	struct_set(global.token_functions, "draw_sprite", function(ssprite, sframe, sx, sy) { return draw_sprite(ssprite, sframe, sx, sy); });
	struct_set(global.token_functions, "draw_sprite_ext", function(ssprite, sframe, sx, sy, sxscale, syscale, sangle, sblend, salpha) { return draw_sprite_ext(ssprite, sframe, sx, sy, sxscale, syscale, sangle, sblend, salpha); });
	struct_set(global.token_functions, "audio_play_sound", function(sindex, spriority, sloop) { return audio_play_sound(sindex, spriority, sloop); })
	struct_set(global.token_functions, "audio_stop_sound", function(sindex) { return audio_stop_sound(sindex); })
	struct_set(global.token_functions, "room_goto", function(rindex) { return room_goto(rindex); })
	struct_set(global.token_functions, "camera_get_view_x", function(cam) { return camera_get_view_x(cam); })
	struct_set(global.token_functions, "camera_get_view_y", function(cam) { return camera_get_view_y(cam); })
	struct_set(global.token_functions, "camera_get_view_width", function(cam) { return camera_get_view_width(cam); })
	struct_set(global.token_functions, "camera_get_view_height", function(cam) { return camera_get_view_height(cam); })
	struct_set(global.token_functions, "sprite_add", function(path, imgnum, rmback, smooth, xorig, yorig) { return sprite_add(path, imgnum, rmback, smooth, xorig, yorig); })
	struct_set(global.token_functions, "sprite_delete", function(sprite) { return sprite_delete(sprite); })
	struct_set(global.token_functions, "audio_create_stream", function(path) { return audio_create_stream(path) })
	struct_set(global.token_functions, "audio_delete_stream", function(audio) { return audio_destroy_stream(audio) })
	
	global.token_operators = {}
	struct_set(global.token_operators, "+", [function(a, b) { return a + b }, 1])
	struct_set(global.token_operators, "-", [function(a, b) { return a - b }, 1])
	struct_set(global.token_operators, "*", [function(a, b) { return a * b }, 2])
	struct_set(global.token_operators, "/", [function(a, b) { return a / b }, 2])
	struct_set(global.token_operators, "%", [function(a, b) { return a % b }, 2])
	struct_set(global.token_operators, "<", [function(a, b) { return a < b }, -1])
	struct_set(global.token_operators, ">", [function(a, b) { return a > b }, -1])
	struct_set(global.token_operators, "==", [function(a, b) { return a == b }, -2])
	struct_set(global.token_operators, "!=", [function(a, b) { return a != b }, -2])
	struct_set(global.token_operators, "<=", [function(a, b) { return a <= b }, -2])
	struct_set(global.token_operators, ">=", [function(a, b) { return a >= b }, -2])
	struct_set(global.token_operators, "and", [function(a, b) { return a and b }, 0])
	struct_set(global.token_operators, "or", [function(a, b) { return a or b }, 0])
	struct_set(global.token_operators, "xor", [function(a, b) { return a xor b }, 0])
	struct_set(global.token_operators, "&&", [function(a, b) { return a && b }, 0])
	struct_set(global.token_operators, "||", [function(a, b) { return a || b }, 0])
	struct_set(global.token_operators, "|", [function(a, b) { return a | b }, 0])
	
	global.token_memory = {}
	
	global.token_memory_environment = {}
	struct_set(global.token_memory_environment, "true", function() { return true })
	struct_set(global.token_memory_environment, "false", function() { return false })
	struct_set(global.token_memory_environment, "noone", function() { return noone })
	struct_set(global.token_memory_environment, "infinity", function() { return infinity })
	struct_set(global.token_memory_environment, "vk_left", function() { return vk_left })
	struct_set(global.token_memory_environment, "vk_right", function() { return vk_right })
	struct_set(global.token_memory_environment, "vk_up", function() { return vk_up })
	struct_set(global.token_memory_environment, "vk_down", function() { return vk_down })
	struct_set(global.token_memory_environment, "vk_enter", function() { return vk_enter })
	struct_set(global.token_memory_environment, "vk_space", function() { return vk_space })
	struct_set(global.token_memory_environment, "c_red", function() { return c_red })
	struct_set(global.token_memory_environment, "c_lime", function() { return c_lime })
	struct_set(global.token_memory_environment, "c_blue", function() { return c_blue })
	struct_set(global.token_memory_environment, "c_black", function() { return c_black })
	struct_set(global.token_memory_environment, "c_white", function() { return c_white })
	struct_set(global.token_memory_environment, "current_time", function() { return current_time })
	struct_set(global.token_memory_environment, "mouse_x", function() { return mouse_x })
	struct_set(global.token_memory_environment, "mouse_y", function() { return mouse_y })
	struct_set(global.token_memory_environment, "keyboard_string", function() { return keyboard_string })
	struct_set(global.token_memory_environment, "room", function() { return room })
	struct_set(global.token_memory_environment, "room_width", function() { return room_width })
	struct_set(global.token_memory_environment, "room_height", function() { return room_height })
	struct_set(global.token_memory_environment, "view_camera", function() { return view_camera })
	
	global.token_vars_environment = {}
	struct_set(global.token_vars_environment, "keyboard_string", function(newval) { keyboard_string = newval })
	struct_set(global.token_memory_environment, "room", function(newval) { room = newval })
	struct_set(global.token_vars_environment, "room_width", function(newval) { room_width = newval })
	struct_set(global.token_vars_environment, "room_height", function(newval) { room_height = newval})
	
	global.token_returned = {}
	global.token_currentinstance = {}
}