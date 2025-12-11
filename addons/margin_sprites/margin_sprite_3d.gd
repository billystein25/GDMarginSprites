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

## The size of the texture translated to meters in 3D. The ratio on Godot is
## [code]100[/code] equals [code]1[/code] meters. This value is the same as
## [code]Texture2D.get_size() / 100[/code]. Also calls [method _overwrite_scale]
## when it is set.
var texture_size: Vector2:
	set(value):
		texture_size = value / 100
		if is_node_ready():
			_overwrite_scale()

## The translated 2D scale. Since the z axis doesn't matter in 3D sprites the
## algorithm runs in 2D and sets this property. Then through a setter
## [Node3D.scale] is set to [code]Vector3(scale_2d.x, scale_2d.y, scale.z)[/code].
## So the z axis isn't affected.
var scale_2d := Vector2.ONE:
	set(value):
		scale_2d = value
		scale = Vector3(scale_2d.x, scale_2d.y, scale.z)

## A reference to [MarginSprites] which contains the necessary functions.
var gms := MarginSprites.new()

## The selected [enum STRETCH_MODES] mode that the node will stretch to.
@export var stretch_mode : MarginSprites.STRETCH_MODES = MarginSprites.STRETCH_MODES.KEEP_RATIO:
	set(value):
		stretch_mode = value
		if is_node_ready():
			_overwrite_scale()

## The minimum size in pixels that the node will scale to.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var min_size: Vector2 = Vector2.ONE:
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
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var max_size: Vector2 = Vector2.ONE:
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
	
	scale_2d = gms.get_contained_scale(stretch_mode, texture_size, min_size, max_size, scale_2d)
	
	if _old_scale != scale_2d:
		if not _old_scale:
			scale_changed.emit(scale, scale)
		else:
			scale_changed.emit(_old_scale, scale)
		_old_scale = scale_2d
	overwrite_scale_ran.emit(scale)
	

#endregion

#region global-methods

## Forces [method _overwrite_scale] to run even if [member stretch_mode], 
## [member min_size], [member max_size], or [member Sprite3D.texture] are not set.
func force_overwrite_scale() -> void:
	_overwrite_scale()

#endregion
