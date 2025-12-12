## An extention of Sprite2D that allows for precise scaling to a specified size.
## in pixels.
##
## An extention of Sprite2D with added functionality allowing for presice scaling
## in pixels. You set your desired minimum and maximum size through the
## [member min_size] and [member max_size] properties and the sprite will
## automatically scale to fit these bounds while respecting the set
## [member stretch_mode].[br]
## [b]Note[/b]: [member Node2D.scale] is set by this class and thus there is no reason
## to be set by the user as it will be overwritten.[br]
## [b]Note[/b]: This class changes the local [member Node2D.scale], not
## [member Node2D.global_scale].[br]
## [b]Note[/b]: This class does not account for [member Node2D.scew] or
## [member Node2D.rotation]. The node will only be scaled according to its regular size
## as a rectangle texture.
@tool
class_name MarginSprite2D
extends Sprite2D

#region global-properties

## Emitted when the [member Node2D.scale] is set and new [member Node2D.scale]
## is different to [member _old_scale].[br]
## [b]Note[/b]: The first time [member Node2D.scale] is set [member _old_scale] is not
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

## The same as the [method Texture2D.get_size] method of
## [member Sprite2D.texture]. Also calls [method _overwrite_scale] when it is set.
var texture_size: Vector2:
	set(value):
		texture_size = value
		if is_node_ready():
			_overwrite_scale()

## The selected [enum STRETCH_MODES] mode that the node will stretch to.
@export var stretch_mode : MarginSprites.STRETCH_MODES = MarginSprites.STRETCH_MODES.KEEP_RATIO:
	set(value):
		stretch_mode = value
		if is_node_ready():
			_overwrite_scale()

## The minimum size in pixels that the node will scale to.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var min_size: Vector2 = Vector2(128, 128):
	set(value):
		min_size = value
		if not is_node_ready():
			return
		if min_size.x > max_size.x:
			max_size.x = min_size.x
		if min_size.y > max_size.y:
			max_size.y = min_size.y
		_overwrite_scale()

## The maximum size in pixels that the node will scale to.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var max_size: Vector2 = Vector2(128, 128):
	set(value):
		max_size = value
		if not is_node_ready():
			return
		if max_size.x < min_size.x:
			min_size.x = max_size.x
		if max_size.y < min_size.y:
			min_size.y = max_size.y
		_overwrite_scale()

#endregion

#region virtual-methods

func _init() -> void:
	texture_changed.connect(
		func(): texture_size = texture.get_size()
	)
	
	if not texture_size and texture:
		texture_size = texture.get_size()

#endregion

#region private-methods

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
	
	scale = MarginSprites.get_contained_scale(stretch_mode, texture_size, min_size, max_size, scale)
	
	if _old_scale != scale:
		if not _old_scale:
			scale_changed.emit(scale, scale)
		else:
			scale_changed.emit(_old_scale, scale)
		_old_scale = scale
	overwrite_scale_ran.emit(scale)

#endregion

#region global-methods

## Forces [method _overwrite_scale] to run even if [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite2D.texture] are not set.
func force_overwrite_scale() -> void:
	_overwrite_scale()

#endregion
