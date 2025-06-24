# GameMaker-String-Parser

This is a **FREE** and **EASY-TO-USE** string parser for GameMaker Studio 2!  
It includes most of the necessary stuff to implement basic code!  
(Check out below for more info.)

## STRING PARSER 2.10 by Tymon Kubik (ME)
> _"It's not like I'm going to buy an extension for 30$!!! I'm gonna make it myself >:)"_

---

## 📄 Documentation

### ✅ Available Arithmetical Operators
'+', 
'-', 
'*', 
'/', 
'%', 
'<', 

'==', 
'!=', 
'<=', 

`and (&&), 
or (||), 
xor (|)`

---

### ✅ Available Keywords
`true, false, noone, infinity
vk_left, vk_right, vk_up, vk_down, vk_enter, vk_space
c_red, c_lime, c_blue, c_black, c_white, 
current_time, keyboard_string, mouse_x, mouse_y, 
room, room_width, room_height, view_camera`

---

### ✅ Available Functions
`show_message, show_debug_message, 
array_create, array_length, array_get, array_set, array_push, 
struct_get_names, struct_get, struct_set, struct_remove, 
instance_create_layer, instance_create_depth, instance_destroy, instance_exists, 
place_meeting, instance_place, collision_rectangle, 
lengthdir_x, lengthdir_y, point_distance, point_direction, angle_difference, 
clamp, min, max, round, floor, ceil, sin, 
random_range, irandom_range, 
keyboard_check, keyboard_check_pressed, keyboard_check_released, ord, 
draw_sprite, draw_sprite_ext, draw_text, draw_rectangle, 
draw_set_color, draw_set_alpha, draw_set_font, 
merge_color, make_color_rgb, make_color_hsv, 
audio_play_sound, audio_stop_sound, 
room_goto, 
camera_get_view_x, camera_get_view_y, 
camera_get_view_width, camera_get_view_height`

---

### ✅ Available Statements
`for,
while,
if, else if, else
with,
switch (supports "case" and "default")`

---
        
### ✅ Other
`return, exit
break
continue`

---

## 📝 Notes / TODO
- You should ALWAYS put a `;` at the end of each line!
  (except for the statements that need `{}`)
- Variables can be declared with nothing, `var `, or `global.` before their names,
  but when using `with` and declaring without a prefix will set the variable on the instance
- Parentheses work!  
- Single-line comments (`//`) and multi-line comments (`/* */`) work!  
- Array setting/getting is done using `array_set` and `array_get`  
  *(No `array[index]` support yet)*  
- Struct setting/getting is done using `struct_set` and `struct_get`  
- idk what to put here 🤷  
