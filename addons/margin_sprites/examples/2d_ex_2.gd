extends Node2D

const g_128_256 = preload("uid://cmotodt08k8pv")
const p_256_128 = preload("uid://w618xlhyjyvq")
var curr_g := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_switch)

func _switch() -> void:
	if curr_g:
		$MarginSprite2D.texture = p_256_128
	else:
		$MarginSprite2D.texture = g_128_256
	curr_g = not curr_g
