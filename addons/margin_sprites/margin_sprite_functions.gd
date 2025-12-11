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
	
	
	var desired := texture_size
	var texture_ratio: float = texture_size.x / texture_size.y
	var min_ratio : float = min_size.x / min_size.y
	var max_ratio : float = max_size.x / max_size.y
	
	# limit min
	if (min_size.x > texture_size.x and min_ratio > texture_ratio):
		pass
	
	
	# limit max
	
	
	
	# old
	var max_of_min_side_px : float = maxf(min_size.x, min_size.y)
	var min_of_max_side_px : float = minf(max_size.x, max_size.y)
	
	# if box already in bounds return scale (1, 1)
	if (max_of_min_side_px < texture_size.x and max_of_min_side_px < texture_size.y
		and min_of_max_side_px > texture_size.x and min_of_max_side_px > texture_size.y
		):
		return texture_size
	
	# limit min
	if max_of_min_side_px > texture_size.x or max_of_min_side_px > texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(max_of_min_side_px * texture_ratio, max_of_min_side_px)
		else:
			desired = Vector2(max_of_min_side_px, max_of_min_side_px / texture_ratio)
	
	# limit max
	elif min_of_max_side_px < texture_size.x or min_of_max_side_px < texture_size.y:
		if texture_size.x > texture_size.y:
			desired = Vector2(min_of_max_side_px, min_of_max_side_px / texture_ratio)
		else:
			desired = Vector2(min_of_max_side_px * texture_ratio, min_of_max_side_px)
	
	# TODO: fix it so that the error is pushed in the condition below
	
	if (minf(desired.x, desired.y) < max_of_min_side_px or 
		maxf(desired.x, desired.y) > min_of_max_side_px
	):
		printerr("It is impossible to keep (1, 1) scale ratio with Min Size: ",
		min_size, " and Max Size: ", max_size)
		return texture_size * old_scale
	
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
	
