function load_mod(path, filename) {
	var _newmod = {
		"name": filename,
		"path": path + filename,
		"execstr": get_text_fromfile(path + filename),
		"parser": noone
	}
	
	return _newmod
}

function get_mods_fromdir(path) {
	var mods = []
	
	var filename = file_find_first(path + "*.gml", fa_none)
	while filename != "" {
		array_push(mods, load_mod(path, filename))
		
		filename = file_find_next()
	}
	file_find_close()
	
	return mods
}

function add_log(_message) {
	array_push(obj_modloader.log_messages, {
		"text": _message
	})
	
	obj_modloader.log_addrel = 0
}

function string_difference(target, sub) {
	if string_length(target) > string_length(sub) {
		return string_copy(target, string_length(sub) + 1, string_length(target) - string_length(sub))
	}
	else if string_length(target) < string_length(sub) {
		return (string_length(target) - string_length(sub))
	}
	
	return ""
}