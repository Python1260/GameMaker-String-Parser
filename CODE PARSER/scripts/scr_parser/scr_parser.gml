function parse_value(str, sessionid) {
	// String
	if string_starts_with(str, "\"") and string_ends_with(str, "\"") {
		var _strresult = string_copy(str, 2, string_length(str) - 2)
		return new TokenValue(0, _strresult, sessionid)
	}
	
	// Array
	if string_starts_with(str, "[") and string_ends_with(str, "]") {
		var _valstring = string_copy(str, 2, string_length(str) - 2)
		var _arrvals = expression_split_region(_valstring, ",", global.token_regionelems, "..", "..", true)
		
		for (var a = 0;a < array_length(_arrvals);a++) {
			_arrvals[a] = parse_declaration(_arrvals[a][1], sessionid)
		}
		
		return new TokenValue(0, _arrvals, sessionid)
	}
	
	// Struct
	if string_starts_with(str, "{") and string_ends_with(str, "}") {
		var _valstring = string_copy(str, 2, string_length(str) - 2)
		var _arrvals = expression_split_region(_valstring, ",", global.token_regionelems, "..", "..", true)
		var _strvals = {}
		
		for (var a = 0;a < array_length(_arrvals);a++) {
			var _dstr = expression_split_region(_arrvals[a][1], ":", global.token_regionelems, "..", "..", false)
			if string_starts_with(_dstr[0][1], "\"") and string_ends_with(_dstr[0][1], "\"") { _dstr[0][1] = string_copy(_dstr[0][1], 2, string_length(_dstr[0][1]) - 2) }
			
			struct_set(_strvals, _dstr[0][1], parse_declaration(_dstr[1][1], sessionid))
		}
		
		return new TokenValue(0, _strvals, sessionid)
	}
	
	// Int (or real)
	try {
		var _intresult = real(str)
		return new TokenValue(0, _intresult, sessionid)
	}
	catch (exception) {}
	
	// Asset name
	var _assetresult = asset_get_index(str)
	if _assetresult > -1 {
		return new TokenValue(0, _assetresult, sessionid)
	}
	
	// Function declaration
	if string_starts_with(str, "function") {
		var _params = expression_split_region(string_copy(str, 9, string_length(str) - 9 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
		var _args = expression_split_region(string_copy(_params, 2, string_length(_params) - 2), ",", global.token_regionelems, "..", "..", false)
		
		for (var a = 0;a < array_length(_args);a++) { _args[a] = _args[a][1] }
		
		var _rspos = string_pos_ext("{", str, 9 + string_length(_params))
		var _frunner = string_copy(str, _rspos + 1, string_length(str) - _rspos - 1)
		
		var _funcresult = function() {
			var _mymemory = global.token_memory[$ self.parser.sessionid]
			
			for (var s = 0;s < argument_count;s++) {
				struct_set(_mymemory, self.args[s], argument[s])
			}
			
			//self.parser.ChangeSession(get_timer())
			
			return parser_run(self.parser, self.inherit, true)
		}
		
		return new TokenDeclaration({ args: _args, parser: parse_string(_frunner) }, _funcresult, sessionid)
	}
	
	// Function call
	if string_count("(", str) > 0 and string_count(")", str) > 0 {
		var _opos = string_pos("(", str)
		var _cpos = string_last_pos(")", str)
		
		var _funcname = string_copy(str, 1, _opos - 1)
		var _func = struct_get(global.token_functions, _funcname)
		if is_undefined(_func) {
			var _inenv = struct_get(global.token_memory_environment, _funcname)
			
			if !is_undefined(_inenv) {
				_func = new TokenValue(0, _inenv, sessionid)
			}
			else {
				var _getterplace = "memory"
				_func = new TokenGetter(new TokenValue(0, _funcname, sessionid), _getterplace, sessionid)
			}
		}
		else { _func = new TokenValue(0, _func, sessionid) }
		
		var _arguments = expression_split_region(string_copy(str, _opos + 1, string_length(str) - (_opos + 1)), ",", global.token_regionelems, "..", "..", true)
		
		for (var a = 0;a < array_length(_arguments);a++) {
			_arguments[a] = parse_declaration(_arguments[a][1], sessionid)
		}
		
		return new TokenFunction(_arguments, _func, sessionid)
	}
	
	// Variable
	if string_starts_with(str, "self.") {
		var _nameresult = string_copy(str, 6, string_length(str) - 6 + 1)
		return new TokenGetter(new TokenValue(0, _nameresult, sessionid), "self", sessionid)
	}
	else if string_starts_with(str, "global.") {
		var _nameresult = string_copy(str, 8, string_length(str) - 8 + 1)
		return new TokenGetter(new TokenValue(0, _nameresult, sessionid), "global", sessionid)
	}
	else if string_count(".", str) > 0 {
		var _elems = string_split(str, ".")
		var _getter = parse_value(_elems[0], sessionid)
		return new TokenGetter(new TokenValue(0, _elems[1], sessionid), _getter, sessionid)
	}
	
	// Environment variable
	if struct_exists(global.token_memory_environment, str) {
		var _resfunc = struct_get(global.token_memory_environment, str)
		return new TokenFunction([], new TokenValue(0, _resfunc, sessionid), sessionid)
	}
	
	var _getterplace = "memory"
	return new TokenGetter(new TokenValue(0, str, sessionid), _getterplace, sessionid)
}

function parse_declaration(str, sessionid) {
	var _opnames = struct_get_names(global.token_operators)
	array_sort(_opnames, function(a, b) {
		return struct_get(global.token_operators, a)[1] - struct_get(global.token_operators, b)[1]
	})
	
	for (var o = 0;o < array_length(_opnames);o++) {
		var _opchar = _opnames[o]
		var _basepos = 1
		
		for (var p = 0;p < string_count(_opchar, str);p++) {
			var _oppos = string_pos_ext(_opchar, str, _basepos)
			
			if _oppos and expression_is_inlayer(str, _oppos, global.token_regionelems) {
				var _left = string_copy(str, 1, _oppos - 1)
				var _right = string_copy(str, _oppos + string_length(_opchar), string_length(str) - (_oppos + string_length(_opchar)) + 1)
				
				if _left != "" and _right != "" {
					return new TokenArythmetic([parse_declaration(_left, sessionid), parse_declaration(_right, sessionid)], _opchar, sessionid)
				}
				else {
					_basepos = _oppos + 1
				}
			}
			else {
				_basepos = _oppos + 1
			}
		}
	}
	
	if string_starts_with(str, "(") and string_ends_with(str, ")") {
		str = string_copy(str, 2, string_length(str) - 2)
		return parse_declaration(str, sessionid)
	}
	
	return parse_value(str, sessionid)
}

function parse_snippet(str, sessionid) {
	var _assignpos = expression_get_assign(str, "=")
	
	if _assignpos {
		var _assignchar = string_char_at(str, _assignpos - 1)
		var _left = string_copy(str, 1, _assignpos - 1)
		var _right = string_copy(str, _assignpos + 1, string_length(str) - _assignpos)
		
		var _rightparse = parse_declaration(_right, sessionid)
		
		var _saveresult = expression_get_saveplace(_left, sessionid)
		_left = _saveresult[0]
		var _setterplace = _saveresult[1]
		
		if struct_exists(global.token_operators, _assignchar) {
			_left = string_copy(_left, 1, string_length(_left) - string_length(_assignchar))
			
			_rightparse = new TokenArythmetic([
				new TokenGetter(new TokenValue(0, _left, sessionid), _setterplace, sessionid),
				_rightparse
			], _assignchar, sessionid)
		}
		
		return new TokenSetter([
			new TokenValue(0, _left, sessionid),
			_rightparse,
		], _setterplace, sessionid)
	}
	else {
		var _addassign = expression_get_assign(str, "++")
		var _subassign = expression_get_assign(str, "--")
		
		if _addassign or _subassign {
			var _fassign = _addassign ? _addassign : _subassign
			var _foperator = _addassign ? "+" : "-"
			var _left = string_copy(str, 1, _fassign - 1)
			
			var _saveresult = expression_get_saveplace(_left, sessionid)
			_left = _saveresult[0]
			var _setterplace = _saveresult[1]
			
			var _rightparse = new TokenArythmetic([
				new TokenGetter(new TokenValue(0, _left, sessionid), _setterplace, sessionid),
				new TokenValue(0, 1, sessionid)
			], _foperator, sessionid)
			
			return new TokenSetter([
				new TokenValue(0, _left, sessionid),
				_rightparse
			], _setterplace, sessionid)
		}
		
		return new TokenRunner([parse_declaration(str, sessionid)], 0, sessionid)
	}
}

function parse_region(str, parentrunner, sessionid) {
	if is_undefined(parentrunner) { parentrunner = noone }
	
	var regions = expression_split_region(str, ";", global.token_regionelems, "}", "..", false) // Use any combination of 2 or more chars for no abort char
	
	// Build parser here
	var parserchildren = []
	for (var r = 0;r < array_length(regions);r++) {
		var region = regions[r]
		var _isdeep = region[0]
		var rstring = expression_strip(region[1])
		
		if _isdeep { // Region is deep (contains "{" or (should be AND!) "}")
			if string_starts_with(rstring, "for") {
				var _fparams = expression_split_region(string_copy(rstring, 4, string_length(rstring) - 4 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
				var _fargs = expression_split_region(string_copy(_fparams, 2, string_length(_fparams) - 2), ";", global.token_regionelems, "..", "..", false)
				
				var _rspos = string_pos_ext("{", rstring, 4 + string_length(_fparams))
				var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
				var _start = parse_snippet(_fargs[0][1], sessionid)
				var _stop = parse_snippet(_fargs[1][1], sessionid)
				var _step = parse_snippet(_fargs[2][1], sessionid)
				
				var _runner = new TokenFor([], [_start, _stop, _step], sessionid)
				_runner.children = parse_region(_frunner, _runner, sessionid).children
				array_push(parserchildren, _runner)
			}
			else if string_starts_with(rstring, "while") {
				var _fparams = expression_split_region(string_copy(rstring, 6, string_length(rstring) - 6 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
				var _fargs = string_starts_with(_fparams, "(") and string_ends_with(_fparams, ")") ? string_copy(_fparams, 2, string_length(_fparams) - 2) : _fparams
				
				var _rspos = string_pos_ext("{", rstring, 6 + string_length(_fparams))
				var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
				var _cond = parse_snippet(_fargs, sessionid)
				
				var _runner = new TokenWhile([], _cond, sessionid)
				_runner.children = parse_region(_frunner, _runner, sessionid).children
				array_push(parserchildren, _runner)
			}
			else if string_starts_with(rstring, "if") {
				var _fparams = expression_split_region(string_copy(rstring, 3, string_length(rstring) - 3 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
				var _fargs = string_starts_with(_fparams, "(") and string_ends_with(_fparams, ")") ? string_copy(_fparams, 2, string_length(_fparams) - 2) : _fparams
				
				var _rspos = string_pos_ext("{", rstring, 3 + string_length(_fparams))
				var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
				var _cond = parse_snippet(_fargs, sessionid)
				
				var _runner = new TokenCondition([[]], [_cond], sessionid)
				_runner.children[0] = parse_region(_frunner, parentrunner, sessionid).children
				array_push(parserchildren, _runner)
			}
			else if string_starts_with(rstring, "else") {
				var _prevcondition = array_last(parserchildren)
				
				if string_copy(rstring, 5, 2) == "if" {
					var _fparams = expression_split_region(string_copy(rstring, 7, string_length(rstring) - 7 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
					var _fargs = string_starts_with(_fparams, "(") and string_ends_with(_fparams, ")") ? string_copy(_fparams, 2, string_length(_fparams) - 2) : _fparams
					
					var _rspos = string_pos_ext("{", rstring, 7 + string_length(_fparams))
					var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
					var _cond = parse_snippet(_fargs, sessionid)
					
					array_push(_prevcondition.children, [parse_region(_frunner, parentrunner, sessionid)])
					array_push(_prevcondition.typeargument, _cond)
				}
				else {
					var _rspos = string_pos("{", rstring)
					var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
					var _cond = new TokenRunner([new TokenValue(0, true)], 0, sessionid)
				
					array_push(_prevcondition.children, [parse_region(_frunner, parentrunner, sessionid)])
					array_push(_prevcondition.typeargument, _cond)
				}
			}
			else if string_starts_with(rstring, "with") {
				var _fparams = expression_split_region(string_copy(rstring, 5, string_length(rstring) - 5 + 1), "..", global.token_regionelems, "..", "{", false)[0][1]
				var _fargs = string_starts_with(_fparams, "(") and string_ends_with(_fparams, ")") ? string_copy(_fparams, 2, string_length(_fparams) - 2) : _fparams
				
				var _rspos = string_pos_ext("{", rstring, 5 + string_length(_fparams))
				var _frunner = string_copy(rstring, _rspos + 1, string_length(rstring) - _rspos - 1)
				
				var _runner = new TokenWith([], parse_declaration(_fargs, sessionid), sessionid)
				_runner.children = parse_region(_frunner, parentrunner, sessionid).children
				array_push(parserchildren, _runner)
			}
			else if string_count("function", rstring) > 0 {
				array_push(parserchildren, parse_snippet(rstring, sessionid))
			}
			else {
				// This is a struct!
				array_push(parserchildren, parse_snippet(rstring, sessionid))
			}
		}
		else {
			if string_starts_with(rstring, "return") {
				var _fstring = string_copy(rstring, 7, string_length(rstring) - 7 + 1)
				
				array_push(parserchildren, new TokenReturn(0, parse_declaration(_fstring, sessionid), sessionid))
			}
			else if string_starts_with(rstring, "continue") {
				array_push(parserchildren, new TokenContinue(0, parentrunner, sessionid))
			}
			else if string_starts_with(rstring, "break") {
				array_push(parserchildren, new TokenBreak(0, parentrunner, sessionid))
			}
			else {
				array_push(parserchildren, parse_snippet(rstring, sessionid))
			}
		}
	}
	
	var parser = new TokenRunner(parserchildren, 0, sessionid)
	
	return parser
}

function parse_string(str, sessionid=undefined) {
	if is_undefined(sessionid) { sessionid = get_timer() }
	
	global.token_returned[$ sessionid] = false
	global.token_currentinstance[$ sessionid] = noone
	if sessionid > 0 or !struct_exists(global.token_memory, sessionid) { global.token_memory[$ sessionid] = {} }
	
	str = expression_remove_comments(str, "//", "\n")
	str = expression_remove_comments(str, "/*", "*/")
	var result = parse_region(str, noone, sessionid)
	
	return result
}

function parse_string_fromfile(path, sessionid=undefined) {
	var _file = file_text_open_read(path)
	
	var _filecontent = ""
	while !file_text_eof(_file) {
		_filecontent += file_text_readln(_file)
	}
	
	file_text_close(_file)
	
	return parse_string(_filecontent, sessionid)
}

function parser_run(parser, inherit=noone, debug=false) {
	global.token_returned[$ parser.sessionid] = false
	global.token_currentinstance[$ parser.sessionid] = noone
	if parser.sessionid > 0 { global.token_memory[$ parser.sessionid] = {} }
	
	if inherit != noone {
		global.token_currentinstance[$ parser.sessionid] = inherit.token_currentinstance
	}
	
	var status = true
	var result = ""
	
	try {
		result = parser.Run()
	}
	catch (exception) { status = false; result = exception.message; }
	
	while is_array(result) { result = array_last(result) }
	if is_instanceof(result, TokenRunner) { result = result.Run() }
	
	return [status, result]
}