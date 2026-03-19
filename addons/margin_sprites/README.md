# GDMarginSprites
This plugin adds support for Margin Sprites for Godot, both for 2D and 3D.<br>

A Margin Sprite allows you to set a minimum and maximum size in pixels or meters for 2D and 3D respectively, while the sprite itself will scale automatically to fit these margines. It works similarly to the auto scaling of TextureRect.<br>

## Usecase Example
Imagine you need to have a an item that can be picked up in your 2D space, but your player only has one item slot. In that case if the player is already holding another item you would want the item on the ground to be replaced by the one your player is already holding. But what happens if the two items have vastly different texture sizes? In that case you would need to scale your sprite depending on what item is currently being displayed.<br>

GDMarginSprites adds that functionality by implementing minimum and maximum sizes that the node will scale to. It also implements different stretch modes such as keeping the `(1, 1)` ratio of your texture, scaling the sprite disregarding the ratio, and attempting to keep the `(1, 1)` ratio and disregarding the offending axis if that fails.<br>

## Note on Usecases
This plugin is not a substitute for creating properly sized texture resources and it is recommended that it is not used as such. It is intended to be used in gamejams and other events where time is limited or you are unable to properly make images in the ideal resolution.

## Documentation
All the implemented members are well documented within the code itself but here is
a quick rundown.<br>

This plugin works by modifying Node2D's and Node3D's scale property. As such, modifying
it manually is meaningless. That said if you manually set the scale at runtime the 
classes will respect your modification and will not overwrite it again until any of
its relevant properties is set. Those properties being `Scale Mode`, `Min Size`, `Max Size` and
`Texture`. If you need for whatever reason to force the overwrite algorithm to run
you can call `force_overwrite_scale()`, which is the only public method in the classes.<br>

Min Size and Max Size are the minimum and maximum sizes in world-space that the node will scale to. For 2D sprites they are in Pixels while in 3D they are in Meters.<br>

Stretch Mode is the way in which the scale will be modified.<br>
• `Keep` scales the sprite so that it fits within min size and max size while also keeping the sprite's ratio at `(1, 1)`. If it is impossible to achieve that then no change is applied.<br>
• `To Fit` just scales the sprite to fit within min size and max size without taking into consideration the ratio of the scale.<br>
• `To Fit` Smart will first attempt to scale the sprite just like in `Keep` mode. However if it is impossible to do so, then `To Fit` will be applied.<br>

The classes keep track of their current scale before it is overwritten and they emit the `scale_changed` signal when it is. The two parameters of that signal are the `old` scale and the `new` scale. This signal is emitted only if the scale has changed, if you need to know when the scale overwrite algorithm runs even if the scale isn't modified use `overwrite_scale_ran` instead.<br>

## Installation 
• From within Godot: (This method does not work as of now. awaiting approval of asset library and asset store) You can download and install this plugin from within Godot itself by navigating to the top panel section and selecting AssetLib. From there you can search for GDMarginSprites and you will find this plugin made by me, billystein25. Once you find it, click on download and then install. Godot will take care of the rest.<br>

• Manually: If you prefer the manual method you can download this plugin by cloning this repository, or by downloading its files as a .zip file. From there once you extract the contents of the .zip file, copy the assets folder into your Godot project. Make sure that you merge with the existing assets folder if you already have one. Finally, make sure that the plugin in is enabled by navigating to Project/Project Settings/Plugins and enabling GDMarginSprites.<br>

For more information check the [official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).