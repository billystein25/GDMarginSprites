class_name MarginSprites
extends RefCounted

# TODO: Implement keep_mode and smart_mode

## The modes that the node will stretch to.
enum STRETCH_MODES{
	## The scale will be modified so that it will keep its
	## ratio to [code](1, 1)[/code] while fitting within min_size and max_size.
	KEEP_RATIO, 
	## The scale will be modified to fit within
	## min_size and max_size disregarding
	## its scale ratio.   
	TO_FIT,
	## The scale will attempt to be modified so that it will keep its
	## ratio to [code](1, 1)[/code] while fitting within min_size and max_size.
	## If that fails then it will scale like [member STRETCH_MODES.TO_FIT]
	TO_FIT_SMART,
}

func _scale_mode(texture_size: Vector2, min_size: Vector2, max_size: Vector2) -> Vector2:
	
	return Vector2(
				clamp(texture_size.x, min_size.x, max_size.x),
				clamp(texture_size.y, min_size.y, max_size.y)
			  )

## Returns the desired target size in world units (pixels or meters).
func _keep_mode(
	texture_size: Vector2, old_scale: Vector2,
	min_size: Vector2, max_size: Vector2
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
	var texture_ratio: float = texture_size.x / texture_size.y
	var min_ratio : float = min_size.x / min_size.y
	var max_ratio : float = max_size.x / max_size.y
	
	# min ratio == 1
	# texture ratio == 128 / 256 ~= 0.5
	
	# limit min
	if ( min_ratio >= texture_ratio and min_size.x >= texture_size.x ):
		# stretch on x 
		desired = Vector2(min_size.x, min_size.x / texture_ratio)
	elif ( min_size.y >= texture_size.y ):
		# stretch on y
		desired = Vector2(min_size.y * texture_ratio, min_size.y)
	
	# limit max
	if ( max_ratio <= texture_ratio and max_size.x <= texture_size.x ):
		# stretch on x
		desired = Vector2(max_size.x, max_size.x / texture_ratio)
	elif ( max_size.y < texture_size.y ):
		# stretch on y
		desired = Vector2(max_size.y * texture_ratio, max_size.y)
	
	if not ( min_size.x <= desired.x and desired.x <= max_size.x
		and min_size.y <= desired.y and desired.y <= max_size.y
	):
		printerr("It is impossible to keep (1, 1) scale ratio with Min Size: ",
		min_size, " and Max Size: ", max_size)
		
		desired = texture_size * old_scale
	
	return desired

func _smart_mode(
	texture_size: Vector2, old_scale: Vector2,
	min_size: Vector2, max_size: Vector2
) -> Vector2:
	
	return Vector2.ONE

## Returns new scale 2d
func overwrite_scale(
	stretch_mode: STRETCH_MODES, texture_size: Vector2,
	old_scale: Vector2, min_size: Vector2, max_size: Vector2
) -> Vector2:
	
	var desired : Vector2
	
	match stretch_mode:
		STRETCH_MODES.TO_FIT:
			desired = _scale_mode(texture_size, min_size, max_size)
		STRETCH_MODES.KEEP_RATIO:
			desired = _keep_mode(texture_size, old_scale, min_size, max_size)
		STRETCH_MODES.TO_FIT_SMART:
			desired = _smart_mode(texture_size, old_scale, min_size, max_size)
	
	return desired / texture_size
	
