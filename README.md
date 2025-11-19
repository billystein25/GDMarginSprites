# GoMarginSprites
This plugin adds support for Margin Sprites for Godot, both for 2D and 3D.[br]

A Margin Sprite allows you to set a minimum and maximum size in pixels or 
meters for 2D and 3D respectively. It works similarly to the auto scaling of
TextureRect.[br]

## Example
Imagine you need to have a pick-up-able item in your 2D space, but your player 
only has one item slot. In that case if the player is already holding an item you
would want the item to the ground to be replaced by the one your player is already
holding. But what happens if the two items have vastly different texture sizes?
In that case you would need to scale your sprite depending on what item is
currently being desplayed.[br]
GoMarginSprites implement exactly that by implementing minimum and maximum sizes
that the node will scale to. It also implements different stretch modes such as
keeping the (1, 1) ratio of your texture, modifying only one of the two axis, or
modifying both disregarding the ratio.[br]

## Usecase
This addon is not a substitute for properly sizing texture resources and it is
recommended that it is not used as such. It is intended to be used in gamejams and
other events where time is limited or you are unable to properly size your textures.

## Documentation
All the implemented members are well documented within the code itself but here is
a quick rundown.[br]
This addon works by modifying Node2D's and Node3D's scale property. As such, modifying
it manually is meaningless. That said if you manually set the scale at runtime the 
classes will respect your modification and will not overwrite it again. If you need
for whatever reason to force the overwrite algorithm to run you can call
force_overwrite_scale(), which is the only public method in the classes.[br]
Min Size and Max Size are the minimum and maximum sizes in pixels or meters that the 
node will scale to.[br]
Stretch Mode is the way in which the scale will be modified. Keep Ratio fits the
sprite within min size and max size while keeping the sprite's ratio at (1, 1). To
Fit just scales the sprite to fit within min size and max size without taking into
consideration the ratio of the scale. Fit Width and Fit Height work the same as To
Fit except they only modify scale.x and scale.y respectively while the unmodified
axis is set to the texture size.[br]
The classes keep track of their current scale before it is overwritten and they emit
the scale_changed signal when it is. The two parameters of that signal are the 'old'
scale and the 'new' scale. This signal is emitted only if the scale has changed, if
you need to know when the scale overwrite algorithm runs even if the scale isn't
modified use overwrite_scale_ran instead.[br]
