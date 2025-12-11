# TODO: By 2062 when traits get merged this whole script should probably be a trait

## The base component containing the functions that [MarginSprite2D] and
## [MarginSprite3D] use.
##
## This class acts as a library which implements the different stretch functions
## that [MarginSprite2D] and [MarginSprite3D] use when they are scaled.
class_name MarginSprites
extends RefCounted

#region constants

## The modes that the node can stretch to.
enum STRETCH_MODES{
	## The scale of the sprite will be modified so that the texture will keep
	## its ratio to [code](1, 1)[/code] while fitting within the margins set by
	## Min Size and Max Size.[br][br]
	## See [member MarginSprite2D.min_size], [member MarginSprite2D.max_size], [member MarginSprite3D.min_size], and [member MarginSprite3D.max_size].
	KEEP_RATIO, 
	## The scale of the sprite will be modified so that the texture will fit
	## within the margins set by Min Size and Max Size with no regard for the 
	## ratio of the texture. [br][br]
	## See [member MarginSprite2D.min_size], [member MarginSprite2D.max_size], [member MarginSprite3D.min_size], and [member MarginSprite3D.max_size].
	TO_FIT,
	## There will be an attempt to modify the scale of the sprite so that the
	## texture will keep its ratio to [code](1, 1)[/code] while fitting within
	## Min Size and Max Size. If that fails then it will scale like [constant TO_FIT].[br][br]
	## See [member MarginSprite2D.min_size], [member MarginSprite2D.max_size], [member MarginSprite3D.min_size], and [member MarginSprite3D.max_size].
	TO_FIT_SMART,
}

#endregion

#region private-methods

## Returns the desired size in world units (Pixels for 2D and Meters for 3D)
## according to [constant TO_FIT].[br][br]
## It is called internally by [method overwrite_scale].
func get_desired_fit(
	texture_size: Vector2, min_size: Vector2, max_size: Vector2
	) -> Vector2:
	
	return Vector2(
				clamp(texture_size.x, min_size.x, max_size.x),
				clamp(texture_size.y, min_size.y, max_size.y)
			  )

## Returns the desired size in world units (Pixels for 2D and Meters for 3D)
## according to [constant KEEP_RATIO].[br][br]
## If it is impossible to keep the scale ratio of the texture to [code](1, 1)[/code]
## then an error is printed and no change is applied.[br][br]
## It is called internally by [method overwrite_scale].
func get_desired_keep(
	texture_size: Vector2, min_size: Vector2, max_size: Vector2,
	old_scale: Vector2,
) -> Vector2:
	
	# early returns
	
	# confirm that min_size < max_size on all axis. if not push error.
	if min_size.x > max_size.y:
		printerr("min_size.x is greater than max_size.y. This is required to keep the (1, 1) aspect ratio. Scale was not modified.")
		return texture_size * old_scale
	if min_size.y > max_size.x:
		printerr("min_size.y is greater than max_size.x. This is required to keep the (1, 1) aspect ratio. Scale was not modified.")
		return texture_size * old_scale
	
	# if texture already in bounds return scale (1, 1)
	if (
		min_size.x < texture_size.x and min_size.y < texture_size.y
		and max_size.x > texture_size.x and max_size.y > texture_size.y
	):
		return texture_size
	
	## Desired size in world units (pixels or meters).
	var desired := texture_size
	
	desired = get_desired_keep_no_check(texture_size, min_size, max_size)
	
	if not ( min_size.x <= desired.x and desired.x <= max_size.x
		and min_size.y <= desired.y and desired.y <= max_size.y
	):
		printerr("It is impossible to keep (1, 1) scale ratio with Min Size: ",
		min_size, " and Max Size: ", max_size)
		
		desired = texture_size * old_scale
	
	return desired

## Returns the desired size in world units (Pixels for 2D and Meters for 3D)
## according to [constant TO_FIT_SMART].[br][br]
## It is called internally by [method overwrite_scale].
func get_desired_smart(
	texture_size: Vector2, min_size: Vector2, max_size: Vector2
) -> Vector2:
	
	var desired := get_desired_keep_no_check(texture_size, min_size, max_size)
	
	desired = Vector2(
		clampf(desired.x, min_size.x, max_size.x),
		clampf(desired.y, min_size.y, max_size.y)
	)
	
	return desired

## Returns the desired size in world units (Pixels for 2D and Meters for 3D) so
## that the ratio of the texture remains at [code](1, 1)[/code].[br][br]
## [b]Note[/b]: If a ratio of [code](1, 1)[/code] cannot be achieved then a wrong
## value will be returned and no error will be printed.[br][br]
## It is called internally by [method get_desired_keep] and [method get_desired_smart].
func get_desired_keep_no_check(
	texture_size : Vector2, min_size: Vector2, max_size: Vector2
) -> Vector2:
	
	var texture_ratio: float = texture_size.x / texture_size.y
	var min_ratio : float = min_size.x / min_size.y
	var max_ratio : float = max_size.x / max_size.y
	
	# limit min
	if ( min_ratio >= texture_ratio and min_size.x >= texture_size.x ):
		# stretch on x 
		return Vector2(min_size.x, min_size.x / texture_ratio)
	elif ( min_size.y >= texture_size.y ):
		# stretch on y
		return Vector2(min_size.y * texture_ratio, min_size.y)
	
	# limit max
	if ( max_ratio <= texture_ratio and max_size.x <= texture_size.x ):
		# stretch on x
		return Vector2(max_size.x, max_size.x / texture_ratio)
	elif ( max_size.y < texture_size.y ):
		# stretch on y
		return Vector2(max_size.y * texture_ratio, max_size.y)
	
	return texture_size

#endregion

#region global-methods

## Returns a [Vector2] to act as the new scale of the sprite so that it will
## fit within the [param min_size] and [param max_size] margins according to
## [param stretch_mode]. See [enum STRETCH_MODES].
func get_contained_scale(
	stretch_mode: STRETCH_MODES, texture_size: Vector2,
	min_size: Vector2, max_size: Vector2, old_scale: Vector2
) -> Vector2:
	
	var desired : Vector2 = texture_size
	
	match stretch_mode:
		STRETCH_MODES.TO_FIT:
			desired = get_desired_fit(texture_size, min_size, max_size)
		STRETCH_MODES.KEEP_RATIO:
			desired = get_desired_keep(texture_size, min_size, max_size, old_scale)
		STRETCH_MODES.TO_FIT_SMART:
			desired = get_desired_smart(texture_size, min_size, max_size)
	
	return desired / texture_size

#region
