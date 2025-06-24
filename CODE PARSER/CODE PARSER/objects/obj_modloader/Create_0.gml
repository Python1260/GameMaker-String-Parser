global.path_mods = "Mods/"
global.lang = "en"

if !directory_exists(global.path_mods) { directory_create(global.path_mods) }

token_memory_init()

game_version = 2.0
game_title = $"GML EXECUTOR {game_version}"

mods = get_mods_fromdir(global.path_mods)

selected_idx = 0

current_mod = noone
current_idx = 0

log_messages = []
log_addrel = 1

keyboard_string_prev = keyboard_string

console_sessionid = 0
console_commands = []
console_string = ""
console_stringoffset = 1

documentation_open = false
documentation_rel = 0
documentation_text = get_text_fromfile($"documentation_{global.lang}.txt")
documentation_offset = 0
documentation_scrollspd = 40
documentation_holdingbar = false