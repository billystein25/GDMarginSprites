@tool
extends EditorPlugin

# Thank you so much for installing my plugin!
# If you find any issues feel free to report them on github.

#region constants
# Types
const MARGIN_SPRITE_2D_TYPE_NAME: String = "MarginSprite2D"
const MARGIN_SPRITE_3D_TYPE_NAME: String = "MarginSprite3D"
# Scripts
const MARGIN_SPRITE_2D_SCRIPT: String = "uid://dn06g0o5len06"
const MARGIN_SPRITE_3D_SCRIPT: String = "uid://bk6gigavy5v6y"
# Icons
const MARGIN_SPRITE_2D_ICON: String = "uid://bxcin50vaqw7i"
const MARGIN_SPRITE_3D_ICON: String = "uid://cryuo7exbojfl"
#endregion

func _enter_tree() -> void:
	add_custom_type(MARGIN_SPRITE_2D_TYPE_NAME, "Sprite2D",
					preload(MARGIN_SPRITE_2D_SCRIPT),
					preload(MARGIN_SPRITE_2D_ICON))
	
	add_custom_type(MARGIN_SPRITE_3D_TYPE_NAME, "Sprite3D",
					preload(MARGIN_SPRITE_3D_SCRIPT),
					preload(MARGIN_SPRITE_3D_ICON))

func _exit_tree() -> void:
	remove_custom_type(MARGIN_SPRITE_2D_TYPE_NAME)
	remove_custom_type(MARGIN_SPRITE_3D_TYPE_NAME)
