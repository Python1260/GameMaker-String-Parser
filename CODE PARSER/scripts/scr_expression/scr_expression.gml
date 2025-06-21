function expression_strip(str) {
	var result = ""
	
	var _string_opened = false
	var _basepos = 1
	
	while _basepos <= string_length(str) {
		var _nextpos = string_pos_ext("\"", str, _basepos)
		if _nextpos == 0 { _nextpos = string_length(str) }
		var _chunk = string_copy(str, _basepos, (_nextpos - _basepos) + 1)
		
		if !_string_opened {
			_chunk = string_replace_all(_chunk, " ", "")
			_chunk = string_replace_all(_chunk, "\n", "")
			_chunk = string_replace_all(_chunk, "\r", "")
			result += _chunk
		}
		else { result += _chunk }
		
		_basepos = _nextpos + 1
		_string_opened = !_string_opened
	}
	
	return result
}

function expression_split_region(str, delimiter, regionelems, deepdelimiter, abortchar, removeempty=false) {
	var result = []
	
	var _rstart = {}
	var _rend = {}
	for (var e = 0;e < array_length(regionelems);e++) {
		struct_set(_rstart, regionelems[e][0], regionelems[e][1])
		struct_set(_rend, regionelems[e][1], 0)
	}
	
	var _lastsplit = 1
	var _open = true
	
	for (var c = 1;c <= string_length(str);c++) {
		var _char = string_char_at(str, c)
		
		if _char == delimiter {
			if _open {
				array_push(result, [false, string_copy(str, _lastsplit, c - _lastsplit)])
				_lastsplit = c + 1
			}
		}
		else if _char == abortchar and _open {
			array_push(result, [2, string_copy(str, _lastsplit, c - _lastsplit)])
			_lastsplit = string_length(str)
			break
		}
		else if struct_exists(_rend, _char) {
			if struct_exists(_rstart, _char) { // When the opening and closing char are the same
				struct_set(_rend, _char, (struct_get(_rend, _char) != 0))
			}
			else {
				struct_set(_rend, _char, struct_get(_rend, _char) - 1)
			}
			
			_open = true
			
			var _enames = struct_get_names(_rend)
			for (var n = 0;n < array_length(_enames);n++) {
				if struct_get(_rend, _enames[n]) > 0 {
					_open = false
					break
				}
			}
			
			if _open and _char == deepdelimiter {
				array_push(result, [true, string_copy(str, _lastsplit, (c - _lastsplit) + 1)])
				_lastsplit = c + 1
			}
		}
		else if struct_exists(_rstart, _char) {
			var _echar = struct_get(_rstart, _char)
			struct_set(_rend, _echar, struct_get(_rend, _echar) + 1)
			
			_open = false
		}
	}
	
	if _lastsplit <= string_length(str) {
		array_push(result, [false, string_copy(str, _lastsplit, string_length(str) - _lastsplit + 1)])
	}
	
	if removeempty {
		for (var r = array_length(result) - 1;r >= 0;r--) {
			if result[r][1] == "" { array_delete(result, r, 1) }
		}
	}
	
	return result
}

function expression_get_assign(str, assignchar="=") {
	var _basepos = 1
	var _count = string_count(assignchar, str)
	
	for (var p = 0;p < _count;p++) {
		var _charpos = string_pos_ext(assignchar, str, _basepos)
		var _ppos = string_char_at(str, _charpos - 1)
		var _lpos = string_char_at(str, _charpos + 1)
		
		if _ppos != "=" and _ppos != "<" and _ppos != ">" and _ppos != "!" and _lpos != "=" {
			return _charpos
		}
		
		_basepos = _charpos + 1
	}
	
	return noone
}

function expression_is_inlayer(str, pos, regionelems) {
	var _rstart = {}
	var _rend = {}
	for (var e = 0;e < array_length(regionelems);e++) {
		struct_set(_rstart, regionelems[e][0], regionelems[e][1])
		struct_set(_rend, regionelems[e][1], 0)
	}
	
	var _open = true
	
	for (var c = 1;c < pos;c++) {
		var _char = string_char_at(str, c)
		
		if struct_exists(_rend, _char) {
			if struct_exists(_rstart, _char) { // When the opening and closing char are the same
				struct_set(_rend, _char, (struct_get(_rend, _char) == 0))
			}
			else {
				struct_set(_rend, _char, struct_get(_rend, _char) - 1)
			}
			
			_open = true
			
			var _enames = struct_get_names(_rend)
			for (var n = 0;n < array_length(_enames);n++) {
				if struct_get(_rend, _enames[n]) > 0 {
					_open = false
					break
				}
			}
		}
		else if struct_exists(_rstart, _char) {
			var _echar = struct_get(_rstart, _char)
			struct_set(_rend, _echar, struct_get(_rend, _echar) + 1)
			
			_open = false
		}
	}
	
	return _open
}

function expression_remove_comments(str, startchar, endchar) {
	var result = ""
	
	var _linecount = string_count(startchar, str)
	var _linepos = 1
	for (var l = 0;l < _linecount;l++) {
		if string_count(startchar, str) <= 0 { break }
		var _lines = string_pos_ext(startchar, str, _linepos)
		var _linee = string_pos_ext(endchar, str, _lines) > 0 ? string_pos_ext(endchar, str, _lines) : string_length(str)
		
		result += string_copy(str, _linepos, (_lines - _linepos))
		_linepos = _linee + string_length(endchar)
	}
	
	result += string_copy(str, _linepos, (string_length(str) - _linepos) + 1)
	
	return result
}

function expression_get_saveplace(_left, sessionid) {
	var _setterplace = "memory"
	
	if string_starts_with(_left, "var") {
		_setterplace = "memory_force"
		_left = string_copy(_left, 4, string_length(_left) - 4 + 1)
	}
	else if struct_exists(global.token_vars_environment, _left) {
		_setterplace = "builtin"
	}
	else if string_starts_with(_left, "global.") {
		_setterplace = "global"
		_left = string_copy(_left, 8, string_length(_left) - 8 + 1)
	}
	else if string_starts_with(_left, "self.") {
		_setterplace = "self"
		_left = string_copy(_left, 6, string_length(_left) - 6 + 1)
	}
	else if string_count(".", _left) > 0 {
		var _elems = string_split(_left, ".")
		
		_setterplace = parse_value(_elems[0], sessionid)
		_left = _elems[1]
	}
	
	return [_left, _setterplace]
}