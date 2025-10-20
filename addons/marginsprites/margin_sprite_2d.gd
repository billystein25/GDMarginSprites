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

enum boundModeEnums{
	CONTAINED,
	MAX_SIZE_OR_LESS,
	MIN_SIZE_OR_GREATER,
	#EXACT,
}
var boundKeys : Array = boundModeEnums.keys()
var boundList : String = ",".join(boundKeys)
var boundMode : boundModeEnums = boundModeEnums.MAX_SIZE_OR_LESS:
	set(value):
		boundMode = value
		_overwrite_scale()

enum stretchModeEnums{
	STRETCH_SCALE,
	STRETCH_KEEP,
	STRETCH_FIT_WIDTH,
	STRETCH_FIT_HEIGHT,
}
var stretchKeys : Array = stretchModeEnums.keys()
var stretchList : String = ",".join(stretchKeys)
var stretchMode : stretchModeEnums = stretchModeEnums.STRETCH_KEEP:
	set(value):
		stretchMode = value
		_overwrite_scale()

var minSize: Vector2 = Vector2.ZERO:
	set(value):
		minSize = value
		if minSize > maxSize:
			maxSize = minSize
		_overwrite_scale()

var maxSize: Vector2 = Vector2.ZERO:
	set(value):
		maxSize = value
		if maxSize < minSize:
			minSize = maxSize
		_overwrite_scale()

var textureSize: Vector2

func _ready() -> void:
	texture_changed.connect(_on_texture_change)

func _on_texture_change() -> void:
	textureSize = texture.get_size()
	print(textureSize)
	_overwrite_scale()

func _get_property_list() -> Array[Dictionary]:
	
	boundKeys = boundModeEnums.keys()
	boundList = ",".join(boundKeys)
	
	stretchKeys = stretchModeEnums.keys()
	stretchList = ",".join(stretchKeys)
	#print(stretchKeys)
	
	var properties : Array[Dictionary] = []
	
	properties.append({
		"name": "boundMode",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": boundList,
	})
	properties.append({
		"name": "stretchMode",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": stretchList,
	})
	
	properties.append({
		"name": "minSize",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint_string": "suffix:px",
	})
	properties.append({
		"name": "maxSize",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint_string": "suffix:px",
	})
	
	return properties

func _overwrite_scale() -> void:
	match stretchMode:
		stretchModeEnums.STRETCH_SCALE:
			_scale_mode()
		stretchModeEnums.STRETCH_KEEP:
			_keep_mode()
		stretchModeEnums.STRETCH_FIT_WIDTH:
			_width_mode()
		stretchModeEnums.STRETCH_FIT_HEIGHT:
			_height_mode()
		

# texture ratio is not regarded
func _scale_mode() -> void:
	if !textureSize:
		textureSize = texture.get_size()
	var desired := textureSize
	
	match boundMode:
		boundModeEnums.CONTAINED:
			desired = Vector2(
						clamp(desired.x, minSize.x, maxSize.x),
						clamp(desired.y, minSize.y, maxSize.y)
					  )
		boundModeEnums.MAX_SIZE_OR_LESS:
			desired = desired.min(maxSize)
		boundModeEnums.MIN_SIZE_OR_GREATER:
			desired = desired.max(minSize)
	scale = desired / textureSize

# texture ratio is persistent
func _keep_mode() -> void:
	match boundMode:
		boundModeEnums.CONTAINED:
			pass
		boundModeEnums.MAX_SIZE_OR_LESS:
			pass
		boundModeEnums.MIN_SIZE_OR_GREATER:
			pass
		

# attempt to keep ratio width is prioritized
func _width_mode() -> void:
	match boundMode:
		boundModeEnums.CONTAINED:
			pass
		boundModeEnums.MAX_SIZE_OR_LESS:
			pass
		boundModeEnums.MIN_SIZE_OR_GREATER:
			pass
		

# attempt to keep ratio height is prioritized
func _height_mode() -> void:
	match boundMode:
		boundModeEnums.CONTAINED:
			pass
		boundModeEnums.MAX_SIZE_OR_LESS:
			pass
		boundModeEnums.MIN_SIZE_OR_GREATER:
			pass
		
	
