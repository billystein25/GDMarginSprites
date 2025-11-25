## An extention of Sprite3D that allows for precise scaling to a specified size.
## in pixels.
##
## An extention of Sprite3D with added functionality allowing for presice scaling
## in pixels. You set your desired minimum and maximum size through the
## [member min_size] and [member max_size] properties and the sprite will
## automatically scale to fit these bounds while respecting the set
## [member stretch_mode].[br]
## [b]Note[/b]: [member Node3D.scale] is set by this class and thus there is no reason
## to be set by the user as it will be overwritten.[br]
## [b]Note[/b]: This class changes the local [member Node3D.scale], not
## [member Node3D.global_scale].[br]
## [b]Note[/b]: This class does not account for [member Node3D.scew] or
## [member Node3D.rotation]. The node will only be scaled according to its regular size
## as a rectangle texture.
@tool
class_name MarginSprite3D
extends Sprite3D

#region global-properties

## Emitted when the [member Node3D.scale] is set and new [member Node3D.scale]
## is different to [member _old_scale].[br]
## [b]Note[/b]: The first time [member Node3D.scale] is set [member _old_scale] is not
## set yet and has value of [code]<null>[/code]. In that case both [param old]
## and [param new] will have a value of [member Node3D.scale].
signal scale_changed(old_scale: Vector2, new_scale: Vector2)

## Emitted every time [method _overwrite_scale] is called even if the
## [member Node3D.scale] didn't change.
signal overwrite_scale_ran(new_scale: Vector2)

## Set to [member Node3D.scale] whenever it is set through
## [method _overwrite_scale]. Used to determine of the scale has been altered to
## emit [signal scale_changed].
var _old_scale : Vector2

## Is set to true when the node is ready. Used to prevent min size and max size
## setters from messing with the values while the node is constructed and they
## aren't fully loaded. Once it gets sets to [code]true[/code] it runs the
## [method _overwrite_scale] method.
var _node_is_ready : bool = false:
	set(value):
		_node_is_ready = value
		if _node_is_ready:
			_overwrite_scale()

## The modes that the node will stretch to.
enum STRETCH_MODES{
	## The [member Node3D.scale] will be modified so that it will keep its
	## ratio to [code](1, 1)[/code].
	KEEP_RATIO, 
	## The [member Node3D.scale] will be modified to fit within
	## [member min_size] and [member max_size] disregarding
	## its Node3D.scale ratio.   
	TO_FIT,
	## Only the [code]x[/code] value of [member Node3D.scale] will be set through
	## the algorithm to fit within [member min_size] and [member max_size].
	## While the [code]y[/code] value is set to the [code]x[/code] value
	## of [member texture_size].
	TO_FIT_WIDTH,
	## Only the [code]y[/code] value of [member Node3D.scale] will be set through
	## the algorithm to fit within [member min_size] and [member max_size].
	## While the [code]x[/code] value is set to the [code]y[/code] value
	## of [member texture_size].
	TO_FIT_HEIGHT,
}

## The selected [enum STRETCH_MODES] mode that the node will stretch to.
@export var stretch_mode : STRETCH_MODES = STRETCH_MODES.KEEP_RATIO:
	set(value):
		stretch_mode = value
		if _node_is_ready:
			_overwrite_scale()

## The minimum size in pixels that the node will scale to.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var min_size: Vector2 = Vector2.ONE:
	set(value):
		min_size = value
		if not _node_is_ready:
			return
		if min_size.x > max_size.x:
			max_size.x = min_size.x
		if min_size.y > max_size.y:
			max_size.y = min_size.y
		_overwrite_scale()

## The maximum size in pixels that the node will scale to.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var max_size: Vector2 = Vector2.ONE:
	set(value):
		max_size = value
		if not _node_is_ready:
			return
		if max_size.x < min_size.x:
			min_size.x = max_size.x
		if max_size.y < min_size.y:
			min_size.y = max_size.y
		_overwrite_scale()

## The size of the texture translated to meters in 3D. The ratio on Godot is
## [code]100[/code] equals [code]1[/code] meters. This value is the same as
## [code]Texture2D.get_size() / 100[/code]. Also calls [method _overwrite_scale]
## when it is set.
var texture_size: Vector2:
	set(value):
		texture_size = value / 100
		if _node_is_ready:
			_overwrite_scale()

## The desired 2D scale. Since the z axis doesn't matter with 3D sprites the
## algorithm runs in 2D and sets this property. Then through a setter
## [Node3D.scale] is set to [code]Vector3(scale_2d.x, scale_2d.y, scale.z)[/code].
## So the z axis isn't affected.
var scale_2d := Vector2.ONE:
	set(value):
		scale_2d = value
		scale = Vector3(scale_2d.x, scale_2d.y, scale.z)

#endregion

#region virtual-methods

func _init() -> void:
	if not texture_size and texture:
		texture_size = texture.get_size()
	
	texture_changed.connect(
		func(): texture_size = texture.get_size()
	)
	
	ready.connect(
		func(): _node_is_ready = true
	)

#endregion

#region private-methods

## Overwrites the [member Node3D.scale] to fit within [member min_size] and
## [member max_size] according to [member stretch_mode].
## See [enum STRETCH_MODES].[br]
## It is called automatically when [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite3D.texture] are set.
func _overwrite_scale() -> void:
	
	if not texture:
		return
	if not texture_size:
		texture_size = texture.get_size()
	
	var desired : Vector2
	
	match stretch_mode:
		STRETCH_MODES.TO_FIT:
			desired = _scale_mode()
		STRETCH_MODES.KEEP_RATIO:
			desired = _keep_mode()
		STRETCH_MODES.TO_FIT_WIDTH:
			desired = _width_mode()
		STRETCH_MODES.TO_FIT_HEIGHT:
			desired = _height_mode()
	
	scale_2d = desired / texture_size
	
	if _old_scale != scale_2d:
		if not _old_scale:
			scale_changed.emit(scale, scale)
		else:
			scale_changed.emit(_old_scale, scale)
		_old_scale = scale_2d
	overwrite_scale_ran.emit(scale)

## The node is scaled to fit within [member min_size] and [member max_size]
## according to [member stretch_mode] disregarding the [member Node3D.scale]'s
## aspect ratio.
func _scale_mode() -> Vector2:
	
	var desired := texture_size
	desired = Vector2(
				clamp(desired.x, min_size.x, max_size.x),
				clamp(desired.y, min_size.y, max_size.y)
			  )
	
	return desired

## Sets [member Node3D.size] to fit the within [member min_size] and
## [member max_size] according to [member stretch_mode] while keeping the 
## aspect ratio to [code](1, 1)[/code].
func _keep_mode() -> Vector2:
	
	var desired := texture_size
	
	# confirm that min_size < max_size on all axis. if not push error.
	if min_size.x > max_size.y:
		printerr("min_size.x is greater than max_size.y. This is required to keep the (1, 1) aspect ratio. Scale was not modified.")
		return texture_size * scale_2d
	if min_size.y > max_size.x:
		printerr("min_size.y is greater than max_size.x. This is required to keep the (1, 1) aspect ratio. Scale was not modified.")
		return texture_size * scale_2d
	
	var ratio: float = texture_size.x / texture_size.y
	
	var max_of_min_side_px : float = maxf(min_size.x, min_size.y)
	var min_of_max_side_px : float = minf(max_size.x, max_size.y)
	
	if (min_size.x < texture_size.x and min_size.y < texture_size.y
		and max_size.x > texture_size.x and max_size.y > texture_size.y
		):
		scale_2d = texture_size
		return scale_2d
	
	# limit min
	if max_of_min_side_px > texture_size.x or max_of_min_side_px > texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(max_of_min_side_px * ratio, max_of_min_side_px)
		else:
			desired = Vector2(max_of_min_side_px, max_of_min_side_px / ratio)
	
	# limit max
	elif min_of_max_side_px < texture_size.x or min_of_max_side_px < texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(min_of_max_side_px, min_of_max_side_px / ratio)
		else:
			desired = Vector2(min_of_max_side_px * ratio, min_of_max_side_px)
	
	
	return desired

## Sets the [code]x[/code] value of [member Node3D.size] to fit within
## [member min_size] and [member max_size] according to [member stretch_mode].
## The [code]x[/code] value is set to the [code]x[/code] value of
## [member texture_size].
func _width_mode() -> Vector2:
	var desired := texture_size
	
	desired = Vector2(
				clamp(desired.x, min_size.x, max_size.x),
				texture_size.y
			  )
	
	return desired

## Sets the [code]y[/code] value of [member Node3D.size] to fit within
## [member min_size] and [member max_size] according to [member stretch_mode].
## The [code]y[/code] value is set to the [code]y[/code] value of
## [member texture_size].
func _height_mode() -> Vector2:
	var desired := texture_size
	
	desired = Vector2(
				texture_size.x,
				clamp(desired.y, min_size.y, max_size.y)
			  )
	
	return desired

#endregion

#region global-methods

## Forces [method _overwrite_scale] to run even if [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite3D.texture] are not set.
func force_overwrite_scale() -> void:
	_overwrite_scale()

#endregion
