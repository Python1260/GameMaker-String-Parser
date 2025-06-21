// HELPERS
function token_updatechildren(children, newssid) {
	if is_array(children) {
		for (var c = 0;c < array_length(children);c++) {
			if is_instanceof(children[c], TokenRunner) {
				children[c].ChangeSession(newssid)
			}
			else if is_array(children[c]) or is_struct(children[c]) {
				token_updatechildren(children[c], newssid)
			}
		}
	}
	else if is_struct(children) {
		if is_instanceof(children, TokenRunner) {
			children.ChangeSession(newssid)
		}
		else {
			var _names = struct_get_names(children)
			
			for (var n = 0;n < array_length(_names);n++) {
				var _name = _names[n]
				var _value = struct_get(children, _name)
				
				if is_instanceof(_value, TokenRunner) {
					_value.ChangeSession(newssid)
				}
				else if is_array(_value) or is_struct(_value) {
					token_updatechildren(_value, newssid)
				}
			}
		}
	}
}

function struct_clear(struct) {
	var _names = struct_get_names(struct)
	
	for (var n = 0;n < array_length(_names);n++) {
		struct_remove(struct, _names[n])
	}
}

function struct_copy(dest, target) {
	var _names = struct_get_names(target)
	
	for (var n = 0;n < array_length(_names);n++) {
		var _name = _names[n]
		struct_set(dest, _name, struct_get(target, _name))
	}
}

function TokenRunner(_children = [], _typeargument = undefined, ssid = -1) constructor {
	children = _children
	typeargument = _typeargument
	sessionid = ssid
	
	static Run = function() {
		var _results = []
		
		for (var c = 0;c < array_length(children);c++) {
			var _res = children[c].Run()
			if !is_undefined(_res) { array_push(_results, _res) }
			
			if global.token_returned[$ sessionid] { break }
		}
		
		return _results
	}
	
	static ChangeSession = function(newssid) {
		sessionid = newssid
		
		token_updatechildren(children, newssid)
		token_updatechildren(typeargument, newssid)
	}
}

function TokenValue(_, value, ssid = -1) : TokenRunner(_, value, ssid = -1) constructor {
	sessionid = ssid
	typeargument_parsed = noone
	
	static Run = function() {
		if is_array(typeargument) {
			if typeargument_parsed != noone {
				typeargument = typeargument_parsed
			}
			
			if typeargument_parsed == noone { typeargument_parsed = [] }
			array_delete(typeargument_parsed, 0, array_length(typeargument_parsed))
			array_copy(typeargument_parsed, 0, typeargument, 0, array_length(typeargument))
		
			for (var a = 0;a < array_length(typeargument);a++) {
				if is_struct(typeargument[a]) and is_instanceof(typeargument[a], TokenRunner) {
					typeargument[a] = typeargument[a].Run()
				}
			}
			
			return typeargument
		}
		else if is_struct(typeargument) and !is_method(typeargument) {
			if typeargument_parsed != noone {
				typeargument = typeargument_parsed
			}
			
			if typeargument_parsed == noone { typeargument_parsed = {} }
			struct_clear(typeargument_parsed)
			struct_copy(typeargument_parsed, typeargument)
			
			var _names = struct_get_names(typeargument)
			for (var n = 0;n < array_length(_names);n++) {
				var _name = _names[n]
				var _value = struct_get(typeargument, _name)
				
				if is_struct(_value) and is_instanceof(_value, TokenRunner) {
					_value = _value.Run()
				}
				
				struct_remove(typeargument, _name)
				struct_set(typeargument, _name, _value)
			}
			
			return typeargument
		}
		
		return typeargument
	}
}

function TokenContinue(_, parentrunner, ssid = -1) : TokenRunner(_, parentrunner, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		typeargument.skip = true
	}
}

function TokenBreak(_, parentrunner, ssid = -1) : TokenRunner(_, parentrunner, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		typeargument.running = false
	}
}

function TokenReturn(_, value, ssid = -1) : TokenRunner(_, value, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		global.token_returned[$ sessionid] = true
		
		return typeargument
	}
}

function TokenArythmetic(values, symbol, ssid = -1) : TokenRunner(values, symbol, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		if array_length(children) <= 0 { return 0 }
		
		var _result = children[0].Run()
		
		for (var v = 1;v < array_length(children);v++) {
			var _opdata = struct_get(global.token_operators, typeargument)
			
			if !is_undefined(_opdata) {
				var _res = children[v].Run()
				_result = _opdata[0](_result, _res)
			}
		}
		
		return new TokenValue(0, _result, sessionid).Run()
	}
}

function TokenSetter(pair, place, ssid = -1) : TokenRunner(pair, place, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {	
		switch (typeargument) {
			case "self":
				variable_instance_set(id, children[0].Run(), children[1].Run())
				break
				
			case "global":
				struct_set(global, children[0].Run(), children[1].Run())
				break
				
			case "memory":
				var _cinst = global.token_currentinstance[$ sessionid]
				
				if !is_undefined(_cinst) and _cinst != noone {
					variable_instance_set(_cinst, children[0].Run(), children[1].Run())
				}
				else {
					struct_set(global.token_memory[$ sessionid], children[0].Run(), children[1].Run())
				}
				
				break
				
			case "memory_force":
				struct_set(global.token_memory[$ sessionid], children[0].Run(), children[1].Run())
				break
			
			case "builtin":
				var _valfunc = struct_get(global.token_vars_environment, children[0].Run())
				_valfunc(children[1].Run())
				break
				
			default:
				var _tarun = typeargument.Run()
				
				if instance_exists(_tarun) {
					variable_instance_set(_tarun, children[0].Run(), children[1].Run())
				}
				else if is_struct(_tarun) {
					struct_set(_tarun, children[0].Run(), children[1].Run())
				}
				else {
					typeargument.children = children
					typeargument.Run()
				}
				break
		}
	}
}

function TokenGetter(name, place, ssid = -1) : TokenRunner(name, place, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		var _value = undefined
		
		switch (typeargument) {
			case "self":
				_value = variable_instance_get(id, children.Run())
				break
				
			case "global":
				_value = struct_get(global, children.Run())
				break
				
			case "memory":
				var _cinst = global.token_currentinstance[$ sessionid]
				var _crun = children.Run()
				
				if struct_exists(global.token_memory[$ sessionid], _crun) {
					_value = struct_get(global.token_memory[$ sessionid], _crun)
				}
				else if !is_undefined(_cinst) and _cinst != noone and variable_instance_exists(_cinst, _crun) {
					_value = variable_instance_get(_cinst, _crun)
				}
				break
				
			default:
				var _tarun = typeargument.Run()
				
				if instance_exists(_tarun) {
					_value = variable_instance_get(_tarun, children.Run())
				}
				else if is_struct(_tarun) {
					_value = struct_get(_tarun, children.Run())
				}
				else {
					typeargument.children = children
					_value = typeargument.Run()
				}
				break
		}
		
		return new TokenValue(0, _value, sessionid).Run()
	}
}

function TokenFunction(arguments, func, ssid = -1) : TokenRunner(arguments, func, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		var _value = undefined
		var _func = typeargument.Run()
		
		switch (array_length(children)) {
			case 0:
				_value = _func()
				break
			case 1:
				_value = _func(children[0].Run())
				break
			case 2:
				_value = _func(children[0].Run(), children[1].Run())
				break
			case 3:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run())
				break
			case 4:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run())
				break
			case 5:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run())
				break
			case 6:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run())
				break
			case 7:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run())
				break
			case 8:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run(), children[7].Run())
				break
			case 9:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run(), children[7].Run(), children[8].Run())
				break
			case 10:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run(), children[7].Run(), children[8].Run(), children[9].Run())
				break
			case 11:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run(), children[7].Run(), children[8].Run(), children[9].Run(), children[10].Run())
				break
			case 12:
				_value = _func(children[0].Run(), children[1].Run(), children[2].Run(), children[3].Run(), children[4].Run(), children[5].Run(), children[6].Run(), children[7].Run(), children[8].Run(), children[9].Run(), children[10].Run(), children[11].Run())
				break
		}
		
		return new TokenValue(0, _value, sessionid).Run()
	}
}

function TokenFor(children, startstopstep, ssid = -1) : TokenRunner(children, startstopstep, ssid = -1) constructor {
	sessionid = ssid
	
	running = true
	skip = false
	
	static Run = function() {
		var _results = []
		
		for (typeargument[0].Run();typeargument[1].Run()[0];typeargument[2].Run()) {
			for (var c = 0;c < array_length(children);c++) {
				var _res = children[c].Run()
				if !is_undefined(_res) { array_push(_results, _res) }
				
				if skip { skip = false; break; }
				if global.token_returned[$ sessionid] or !running { break }
			}
			if global.token_returned[$ sessionid] or !running { break }
		}
		
		return _results
	}
}

function TokenWhile(children, condition, ssid = -1) : TokenRunner(children, condition, ssid = -1) constructor {
	sessionid = ssid
	
	running = true
	skip = false
	
	static Run = function() {
		var _results = []
		
		while typeargument.Run()[0] {
			for (var c = 0;c < array_length(children);c++) {
				var _res = children[c].Run()
				if !is_undefined(_res) { array_push(_results, _res) }
				
				if skip { skip = false; break; }
				if global.token_returned[$ sessionid] or !running { break }
			}
			if global.token_returned[$ sessionid] or !running { break }
		}
		
		return _results
	}
}

function TokenCondition(children, conditions, ssid = -1) : TokenRunner(children, conditions, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		for (var i = 0;i < array_length(typeargument);i++) {
			if typeargument[i].Run()[0] {
				var _results = []
		
				for (var c = 0;c < array_length(children[i]);c++) {
					var _res = children[i][c].Run()
					if !is_undefined(_res) { array_push(_results, _res) }
				}
		
				return _results
			}
		}
	}
}

function TokenWith(children, obj, ssid = -1) : TokenRunner(children, obj, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		var _results = []
		var _csave = children
		var _ssave = sessionid
		
		var _rresult = typeargument.Run()
		with (_rresult) {
			for (var c = 0;c < array_length(_csave);c++) {
				global.token_currentinstance[$ _ssave] = _rresult
				var _res = _csave[c].Run()
				if !is_undefined(_res) { array_push(_results, _res) }
				
				if global.token_returned[$ _ssave] { break }
			}
			if global.token_returned[$ _ssave] { break }
		}
		global.token_currentinstance[$ sessionid] = noone
		
		return _results
	}
}

function TokenDeclaration(funcinfo, funchandle, ssid = -1) : TokenRunner(funcinfo, funchandle, ssid = -1) constructor {
	sessionid = ssid
	
	static Run = function() {
		children.inherit = {
			"token_currentinstance": global.token_currentinstance[$ sessionid]
		}
		
		var _funcbuild = method(children, typeargument)
		
		return new TokenValue(0, _funcbuild, sessionid).Run()
	}
}