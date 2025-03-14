color.lua
===============

Convert between color spaces in lua with functional or object oriented callbacks.

------ ------ ------ ------ ------

Constructor Syntax: New color objects can be created using methods color() or color.new(). The initializers follow:

```lua
color(255,255,255) -- creates RGB color object
color({r = 255, g = 0, b = 255}) -- auto detect color based on properties
color("RGB",255,0,255) -- space/model name passed as string       

color.RGB(255,0,255) -- indexed space/model creation
color.RGB({r = 255, g = 0, b = 255}) -- strict creation
color.HEX("FFF") / color.HEX("00FFFF") -- hex color creation
```
------ ------ ------ ------ ------

Color Conversions:

```
.space / .model -- (set) convert to color space | (get) return space description string
:to("space") / :convertTo("space") -- convert color to color space 
:as("space") -- create a copy of color and convert it to space
```

```lua
local purple = color("RGB",128,0,128)
print(purple) --> color]:(RGB) {r = 128, g = 0, b = 128}
purple:to("HSV")
print(purple) --> [color]:(HSV) {h = 300.0, s = 100.0, v = 50.196}
```

--------------- --------------- --------------- --------------- ---------------

Supported Color Spaces:

```
RGB - {red,green,bulue}
HSV - {hue,saturation,value}
HSB - {hue,saturation,brightness}
HSL - {hue,saturation,lightness}
HSI - {hue,saturatio,intensity}
HWB - {hue,whiteness,blackness}
HCG - {hue,chroma,greyscale}
HSM - {hue,saturation,mixture}

CMY - {cyan,magenta,yellow}
CMYK - {cyan,magenta,yellow,keytone}

XYZ
LAB
LUV

LCHab
LCHuv

TSL - {teint,saturation,luma}

YCbCr
YUV
YCgCo
YDbDr
```

------------ --------------- --------------- --------------- ---------------

Color Harmony Methods:

```
color.compliment
color.triad
color.square
```

```lua
local teal = color(0,128,128) ---> color:(RGB) {r = 0.0, g = 128.0, b = 128.0}
print(teal:compliment()) ---> color:(RGB) {r = 128.0, g = 0.0, b = 0.0}
```

------------ --------------- --------------- --------------- ---------------

Standards:


------------ --------------- --------------- --------------- ---------------

Properties: All color objects can access their channel properties through their abbreviated or verbose keys.
Reference names for properties are case insensitive i.e.

```
  color.r  color.red  color.Hue  color.V  color.SaTuRaTiOn
```
```
  color.hex
```




--------------- --------------- --------------- --------------- ---------------
