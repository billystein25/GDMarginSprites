## An extention of Sprite2D that allows for precise sprite scaling to a
## specified size.
##
## NOTE: [member Node2D.scale] is set by this class and thus should not be set
## by the user as it will be overwritten.[br]
## NOTE: Changes the local [member Node2D.scale], not
## [member Node2D.global_scale].[br]
@tool
class_name MarginSprite2D
extends Sprite2D

## TODO
# export min and max size in pixels
# Bound mode ENUM
# 	Exact: The texture is scaled to fit the pixel size exactly
# 	Contained: The texture is contained within min and max size
# 	max size or less: The texture is scaled to be equal to or lesser than max size
# 	min size or greater: The texture is scaled to be equal to or greater than min size
# Stretch mode ENUM
# 	Stretch Scale: The texture is stretched to fit the bound mode with no consideration for the 
# 	               scale ratio
# 	Stretch Keep: The texture is stretched to fit the bound mode while keeping the scale ratio to 
# 	              1 to 1
# 	Stretch fit Width: Height is ignored. The texture is stretched to fit the bound mode only 
# 	                   considering the Width
# 	Stretch fit Height: Width is ignored. The texture is stretched to fit the bound mode only
# 	                    considering the Height

# example. On stretch mode {stretch_fit_width} the texture will be scaled to fit the bounds of 
#          the width ie the x scale while the aspect ratio remains 1.
#          On stretch mode {stretch_scale} the texture will be scaled to fit the bounds of both
#          the width and the height of the texture with no regards for the aspect ratio.
#          On stretch mode {stretch_keep} the texture will be scaled to fit the bounds of both 
#          the width and the height of the texture while keeping the aspect ratio to 1.

## The modes that the sprite will scale to.
enum BOUND_MODES{
	CONTAINED_MAX_FIRST, ## Sprite size is within [member min_size] and
						 ## [member max_size]. [member max_size] takes priority.
	CONTAINED_MIN_FIRST, ## Sprite size is within [member min_size] and
						 ## [member max_size]. [member min_size] takes priority
	MAX_SIZE_OR_LESS,    ## Sprite size equal to or less than [member max_size].
	MIN_SIZE_OR_GREATER, ## Sprite size equal to or greater than [member min_size].
}

## The selected [enum BOUND_MODES] mode that the sprite will scale to.
var bound_mode : BOUND_MODES = BOUND_MODES.MAX_SIZE_OR_LESS:
	set(value):
		bound_mode = value
		_overwrite_scale()
		notify_property_list_changed()

## The modes that the sprite will stretch to.
enum STRETCH_MODES{
	STRETCH_SCALE,      ## The sprite will stretch to fit the [member bound_mode]
						## disregarding its scale ratio.
	STRETCH_KEEP,       ## The sprite will keep its scale ratio to
						## [code](1, 1)[/code].
	STRETCH_FIT_WIDTH,  ##
	STRETCH_FIT_HEIGHT, ##
}

## The selected [enum STRETCH_MODES] mode that the sprite will stretch to.
var stretch_mode : STRETCH_MODES = STRETCH_MODES.STRETCH_KEEP:
	set(value):
		stretch_mode = value
		_overwrite_scale()
		notify_property_list_changed()

## The minimum size in pixels that the sprite will scale to.
var min_size: Vector2 = Vector2(128, 128):
	set(value):
		min_size = value
		if min_size.x > max_size.x:
			max_size.x = min_size.x
		if min_size.y > max_size.y:
			max_size.y = min_size.y
		_overwrite_scale()

## The maximum size in pixels that the sprite will scale to.
var max_size: Vector2 = Vector2(128, 128):
	set(value):
		max_size = value
		if max_size.x < min_size.x:
			min_size.x = max_size.x
		if max_size.y < min_size.y:
			min_size.y = max_size.y
		_overwrite_scale()

#var min_side: float = 128:
	#set(value):
		#min_side = value
		#if min_side > max_side:
			#max_side = min_side
		#_overwrite_scale()
#
### The maximum size in pixels that the sprite will scale to.
#var max_side: float = 128:
	#set(value):
		#max_side = value
		#if max_side < min_side:
			#min_side = max_side
		#_overwrite_scale()

## The same as [method Texture2D.get_size]. Also calls [method _overwrite_scale]
## when is set.
var texture_size: Vector2:
	set(value):
		texture_size = value
		_overwrite_scale()

func _init() -> void:
	texture_changed.connect(_on_texture_change)

func _on_texture_change() -> void:
	texture_size = texture.get_size()
	print(self, " new texture_size: ", texture_size)

## Converts the [String] [param n] from screaming snake case to pascal case
## except words are seperated with spaces.
## [codeblock]
## var s : String = "MY_STRING"
## print(string_screaming_snake_to_normal(s)) # Prints "My String"
## [/codeblock]
func _string_screaming_snake_to_normal(n : String) -> String:
	
	var positions : Array[int] = []
	n = n.to_pascal_case()
	# find the positions that need a space to be added.
	for letter in n.length():
		if n[letter] == n[letter].capitalize():
			positions.append(letter)
	# count how many spaces have been added and offset the insert by that.
	var count : int = 0
	for pos in positions:
		n = n.insert(pos + count, " ")
		count += 1
	return n

## Converts an [Array] of keys making use of
## [method _string_screaming_snake_to_normal] to ensure they are in proper case.
## Used to set [member bound_list] and [member scaleList] which are used as
## hint_strings for the editor.
func _make_keys(arr : Array) -> Array:
	var new_arr : Array = []
	for key in arr:
		new_arr.append(_string_screaming_snake_to_normal(key))
	return new_arr

func _get_property_list() -> Array[Dictionary]:
	
	var properties : Array[Dictionary] = []
	
	# Arrays of keys and comma seperated strings. Used as hint_strings for
	# editor properties
	var bound_keys : Array = _make_keys(BOUND_MODES.keys())
	var bound_list : String = ",".join(bound_keys)
	
	var stretch_keys : Array = _make_keys(STRETCH_MODES.keys())
	var stretch_list : String = ",".join(stretch_keys)
	
	# add enums
	properties.append({
		"name": "bound_mode",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": bound_list,
	})
	properties.append({
		"name": "stretch_mode",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": stretch_list,
	})
	
	# add min size Vector2
	if not bound_mode == BOUND_MODES.MAX_SIZE_OR_LESS:
		properties.append({
			"name": "min_size",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint_string": "suffix:px",
		})
	
	# add max size Vector2
	if not bound_mode == BOUND_MODES.MIN_SIZE_OR_GREATER:
		properties.append({
			"name": "max_size",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint_string": "suffix:px",
		})
	
	return properties

## Overwrites the scale of the sprite to match the desired [member bound_mode]
## and [member stretch_mode].[br]
## It is called automatically when [member bound_mode], [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite2D.texture] are set.
func _overwrite_scale() -> void:
	
	if not texture:
		return
	if not texture_size:
		texture_size = texture.get_size()
	
	match stretch_mode:
		STRETCH_MODES.STRETCH_SCALE:
			_scale_mode()
		STRETCH_MODES.STRETCH_KEEP:
			_keep_mode()
		STRETCH_MODES.STRETCH_FIT_WIDTH:
			_width_mode()
		STRETCH_MODES.STRETCH_FIT_HEIGHT:
			_height_mode()

# TODO: fix CONTAINED_MAX_FIRST and CONTAINED_MIN_FIRST modes so that when 
# the respective side will take priority

## The sprite is scaled to fit the [member bound_mode] disregarding the
## [member Node2D.scale]'s aspect ratio.
func _scale_mode() -> void:
	
	var desired := texture_size
	
	match bound_mode:
		BOUND_MODES.MAX_SIZE_OR_LESS:
			desired = desired.min(max_size)
		BOUND_MODES.MIN_SIZE_OR_GREATER:
			desired = desired.max(min_size)
		_:
			desired = Vector2(
						clamp(desired.x, min_size.x, max_size.x),
						clamp(desired.y, min_size.y, max_size.y)
					  )
	scale = desired / texture_size

## Sets [member Node2D.size] to fit the [member bound_mode] while keeping the 
## aspect ratio to [code](1, 1)[/code].
func _keep_mode() -> void:
	
	var desired := texture_size
	
	match bound_mode:
		BOUND_MODES.CONTAINED_MAX_FIRST:
			#if max_size.x > texture_size.x and max_size.y > texture_size.y and min_size.x < texture_size.x and min_size.y < texture_size.y:
				#scale = Vector2(1, 1)
				#return
			var ratio: float = texture_size.x / texture_size.y
			
			var max_side : int = maxi(min_size.x, min_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(max_side, max_side * ratio)
			else:
				desired = Vector2(max_side / ratio, max_side)
			
			var min_side : int = mini(max_size.x, max_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(min_side, min_side * ratio)
			else:
				desired = Vector2(min_side / ratio, min_side)
		BOUND_MODES.CONTAINED_MIN_FIRST:
			#if max_size.x > texture_size.x and max_size.y > texture_size.y and min_size.x < texture_size.x and min_size.y < texture_size.y:
				#scale = Vector2(1, 1)
				#return
			var ratio: float = texture_size.x / texture_size.y
			
			var min_side : int = mini(max_size.x, max_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(min_side, min_side * ratio)
			else:
				desired = Vector2(min_side / ratio, min_side)
			
			var max_side : int = maxi(min_size.x, min_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(max_side, max_side * ratio)
			else:
				desired = Vector2(max_side / ratio, max_side)
		BOUND_MODES.MAX_SIZE_OR_LESS:
			if max_size.x > texture_size.x and max_size.y > texture_size.y:
				scale = Vector2(1, 1)
				return
			var ratio: float = texture_size.x / texture_size.y
			var min_side : int = mini(max_size.x, max_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(min_side, min_side * ratio)
			else:
				desired = Vector2(min_side / ratio, min_side)
		BOUND_MODES.MIN_SIZE_OR_GREATER:
			if min_size.x < texture_size.x and min_size.y < texture_size.y:
				scale = Vector2(1, 1)
				return
			var ratio: float = texture_size.x / texture_size.y
			var max_side : int = maxi(min_size.x, min_size.y)
			if texture_size.x > texture_size.y:
				desired = Vector2(max_side, max_side * ratio)
			else:
				desired = Vector2(max_side / ratio, max_side)
	
	scale = desired / texture_size

## Sets [member Node2D.size.x] to fit the [member bound_mode]. Ignores height.
func _width_mode() -> void:
	match bound_mode:
		BOUND_MODES.CONTAINED_MAX_FIRST:
			pass
		BOUND_MODES.MAX_SIZE_OR_LESS:
			pass
		BOUND_MODES.MIN_SIZE_OR_GREATER:
			pass
		

## Sets [member Node2D.size.y] to fit the [member bound_mode]. Ignores width.
func _height_mode() -> void:
	match bound_mode:
		BOUND_MODES.CONTAINED_MIN_FIRST:
			pass
		BOUND_MODES.MAX_SIZE_OR_LESS:
			pass
		BOUND_MODES.MIN_SIZE_OR_GREATER:
			pass
		
	
