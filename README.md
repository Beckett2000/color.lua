color.lua
===============

Convert between color spaces in lua with functional or object oriented callbacks.

------ ------ ------ ------ ------

Constructors: New color objects can be created using methods color() or color.new(). The initializers follow:

```lua
  color(255,255,255) -- creates RGB color object
  color({r = 255, g = 0, b = 255}) -- auto detect color based on properties
  color("RGB",255,0,255) -- space/model name passed as string       
  color.RGB(255,0,255) -- indexed space/model creation
  color.RGB({r = 255, g = 0, b = 255}) -- strict creation

------ ------ ------ ------ ------

Supported Color Spaces:

------ ------ ------ 

```
RGB
HSV
HSB
HSL
HAI
HWB
HCG
HSM

CMY
CMYK

XYZ
LAB
LUV

LCHab
LCHub

TSL

YCbCr
YUV
YCgCo
YDbDr
```

```
--------------- --------------- --------------- --------------- ---------------

-- Color object properties / methods:
```
--  .space / .model -- (set) convert to color space | (get) return space description string
--  :to("space") / :convertTo("space") -- convert color to color space 
--  :as("space") -- create a copy of color and convert it to space
```
-- Properties: All color objects can access their channel properties through their abbreviated or verbose keys.
--  reference names for properties are case insensitive i.e.

--   color.r  color.red  color.Hue  color.V  color.SaTuRaTiOn

--------------- --------------- --------------- --------------- ---------------
