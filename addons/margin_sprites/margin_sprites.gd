@tool
extends EditorPlugin

#region constants
# Types
const MARGIN_SPRITE_2D_TYPE: String = "MarginSprite2D"
const MARGIN_SPRITE_3D_TYPE: String = "MarginSprite3D"
# Scripts
const MARGIN_SPRITE_2D_SCRIPT: String = "res://addons/margin_sprites/margin_sprite_2d.gd"
const MARGIN_SPRITE_3D_SCRIPT: String = "res://addons/margin_sprites/margin_sprite_3d.gd"
# Icons
const MARGIN_SPRITE_2D_ICON: String = "res://icon.svg"
const MARGIN_SPRITE_3D_ICON: String = "res://icon.svg"
#endregion

func _enter_tree() -> void:
	add_custom_type(MARGIN_SPRITE_2D_TYPE, "Sprite2D",
					preload(MARGIN_SPRITE_2D_SCRIPT),
					preload(MARGIN_SPRITE_2D_ICON))
	
	add_custom_type(MARGIN_SPRITE_3D_TYPE, "Sprite3D",
					preload(MARGIN_SPRITE_3D_SCRIPT),
					preload(MARGIN_SPRITE_3D_ICON))
	


func _exit_tree() -> void:
	remove_custom_type(MARGIN_SPRITE_2D_TYPE)
	remove_custom_type(MARGIN_SPRITE_3D_TYPE)
