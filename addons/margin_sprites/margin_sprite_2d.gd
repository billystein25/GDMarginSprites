## An extention of Sprite2D that allows for precise scaling to a specified size.
## in pixels.
##
## An extention of Sprite2D with added functionality allowing for presice scaling
## in pixels. You set your desired minimum and maximum size through the
## [member min_size] and [member max_size] properties and the sprite will
## automatically scale to fit these bounds while respecting the set
## [member stretch_mode].[br]
## NOTE: [member Node2D.scale] is set by this class and thus there is no reason
## to be set by the user as it will be overwritten.[br]
## NOTE: This class changes the local [member Node2D.scale], not
## [member Node2D.global_scale].[br]
## NOTE: This class does not account for a [member Node2D.scew] value other than
## [code]0.0[/code]. The node will only be scaled according to its regular size
## as a rentagle texture.
@tool
class_name MarginSprite2D
extends Sprite2D

#region global-properties

## Emitted when the [member Node2D.scale] is set and new [member Node2D.scale]
## is different to [member _old_scale].[br]
## NOTE: The first time [member Node2D.scale] is set [member _old_scale] is not
## set yet and has value of [code]<null>[/code]. In that case both [param old]
## and [param new] will have a value of [member Node2D.scale].
signal scale_changed(old_scale: Vector2, new_scale: Vector2)

## Emitted every time [method _overwrite_scale] is called even if the
## [member Node2D.scale] didn't change.
signal overwrite_scale_ran(new_scale: Vector2)

## Set to [member Node2D.scale] whenever it is set through
## [method _overwrite_scale]. Used to determine of the scale has been altered to
## emit [signal scale_changed].
var _old_scale : Vector2

## The modes that the node will stretch to.
enum STRETCH_MODES{
	## The [member Node2D.scale] will be modified so that it will keep its
	## ratio to [code](1, 1)[/code].
	KEEP_RATIO, 
	## The [member Node2D.scale] will be modified to fit within
	## [member min_size] and [member max_size] disregarding
	## its Node2D.scale ratio.   
	TO_FIT,
	## Only the [code]x[/code] value of [member Node2D.scale] will be set through
	## the algorithm to fit within [member min_size] and [member max_size].
	## While the [code]y[/code] value is set to the [code]x[/code] value
	## of [member texture_size].
	TO_FIT_WIDTH,
	## Only the [code]y[/code] value of [member Node2D.scale] will be set through
	## the algorithm to fit within [member min_size] and [member max_size].
	## While the [code]x[/code] value is set to the [code]y[/code] value
	## of [member texture_size].
	TO_FIT_HEIGHT,
}

## The selected [enum STRETCH_MODES] mode that the node will stretch to.
var stretch_mode : STRETCH_MODES = STRETCH_MODES.KEEP_RATIO:
	set(value):
		stretch_mode = value
		_overwrite_scale()
		notify_property_list_changed()

## The minimum size in pixels that the node will scale to.
var min_size: Vector2 = Vector2(128, 128):
	set(value):
		min_size = value
		if min_size.x > max_size.x:
			max_size.x = min_size.x
		if min_size.y > max_size.y:
			max_size.y = min_size.y
		_overwrite_scale()

## The maximum size in pixels that the node will scale to.
var max_size: Vector2 = Vector2(128, 128):
	set(value):
		max_size = value
		if max_size.x < min_size.x:
			min_size.x = max_size.x
		if max_size.y < min_size.y:
			min_size.y = max_size.y
		_overwrite_scale()

## The same as the [method Texture2D.get_size] method of
## [member Sprite2D.texture]. Also calls [method _overwrite_scale] when is set.
var texture_size: Vector2:
	set(value):
		texture_size = value
		_overwrite_scale()

#endregion

#region virtual-methods

func _init() -> void:
	texture_changed.connect(
		func(): texture_size = texture.get_size()
	)

func _get_property_list() -> Array[Dictionary]:
	
	var properties : Array[Dictionary] = []
	
	# Array of keys and comma seperated string. Used as hint_string for
	# editor property
	var stretch_keys : Array = _make_keys(STRETCH_MODES.keys())
	var stretch_list : String = ",".join(stretch_keys)
	
	# add enum
	properties.append({
		"name": "stretch_mode",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": stretch_list,
	})
	
	# add min size Vector2
	properties.append({
		"name": "min_size",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint_string": "suffix:px",
	})
	
	# add max size Vector2
	properties.append({
		"name": "max_size",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint_string": "suffix:px",
	})
	
	return properties

#endregion

#region private-methods

## Converts the [String] [param n] from screaming snake case to pascal case
## except words are seperated with spaces. Used by [method _make_keys] to
## properly display the enum key names of [enum STRETCH_MODES] in the inspector.
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

## Overwrites the [member Node2D.scale] to fit within [member min_size] and
## [member max_size] according to [member stretch_mode].
## See [enum STRETCH_MODES].[br]
## It is called automatically when [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite2D.texture] are set.
func _overwrite_scale() -> void:
	
	if not texture:
		return
	if not texture_size:
		texture_size = texture.get_size()
	
	match stretch_mode:
		STRETCH_MODES.TO_FIT:
			_scale_mode()
		STRETCH_MODES.KEEP_RATIO:
			_keep_mode()
		STRETCH_MODES.TO_FIT_WIDTH:
			_width_mode()
		STRETCH_MODES.TO_FIT_HEIGHT:
			_height_mode()
	
	if _old_scale != scale:
		if not _old_scale:
			scale_changed.emit(scale, scale)
		else:
			scale_changed.emit(_old_scale, scale)
		_old_scale = scale
	overwrite_scale_ran.emit(scale)

## The node is scaled to fit within [member min_size] and [member max_size]
## according to [member stretch_mode] disregarding the [member Node2D.scale]'s
## aspect ratio.
func _scale_mode() -> void:
	
	var desired := texture_size
	
	desired = Vector2(
				clamp(desired.x, min_size.x, max_size.x),
				clamp(desired.y, min_size.y, max_size.y)
			  )
	
	scale = desired / texture_size
	
	return

## Sets [member Node2D.size] to fit the within [member min_size] and
## [member max_size] according to [member stretch_mode] while keeping the 
## aspect ratio to [code](1, 1)[/code].
func _keep_mode() -> void:
	
	var desired := texture_size
	
	# confirm that min_size < max_size on all axis. if not push error.
	if min_size.x > max_size.y or min_size.y > max_size.x:
		printerr("Min Size is not smaller than Max Size on both axis. This is required to keep the (1, 1) aspect ratio. Scale was not modified.")
		return
	
	var ratio: float = texture_size.x / texture_size.y
	
	var max_of_min_side_px : int = maxi(min_size.x, min_size.y)
	var min_of_max_side_px : int = mini(max_size.x, max_size.y)
	
	if (min_size.x < texture_size.x and min_size.y < texture_size.y
		and max_size.x > texture_size.x and max_size.y > texture_size.y
		):
		scale = Vector2.ONE
		return
	
	# limit min
	if max_of_min_side_px > texture_size.x or max_of_min_side_px > texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(max_of_min_side_px, max_of_min_side_px * ratio)
		else:
			desired = Vector2(max_of_min_side_px / ratio, max_of_min_side_px)
	
	# limit max
	elif min_of_max_side_px < texture_size.x or min_of_max_side_px < texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(min_of_max_side_px, min_of_max_side_px * ratio)
		else:
			desired = Vector2(min_of_max_side_px / ratio, min_of_max_side_px)
	
	scale = desired / texture_size
	
	return

## Sets the [code]x[/code] value of [member Node2D.size] to fit within
## [member min_size] and [member max_size] according to [member stretch_mode].
## The [code]x[/code] value is set to the [code]x[/code] value of
## [member texture_size].
func _width_mode() -> void:
	var desired := texture_size
	
	desired = Vector2(
				clamp(desired.x, min_size.x, max_size.x),
				texture_size.y
			  )
	
	scale = desired / texture_size
	
	return

## Sets the [code]y[/code] value of [member Node2D.size] to fit within
## [member min_size] and [member max_size] according to [member stretch_mode].
## The [code]y[/code] value is set to the [code]y[/code] value of
## [member texture_size].
func _height_mode() -> void:
	var desired := texture_size
	
	desired = Vector2(
				texture_size.x,
				clamp(desired.y, min_size.y, max_size.y)
			  )
	
	scale = desired / texture_size
	
	return

#endregion

#region global-methods

## Forces [method _overwrite_scale] to run even if [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite2D.texture] are not set.
func force_overwrite_scale() -> void:
	_overwrite_scale()

#endregion
