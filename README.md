color.lua
===============

Convert between color spaces in lua with functional or object oriented callbacks.

------ ------ ------ ------ ------

Constructor Syntax: New color objects can be created using methods `color()` or `color.new()`. The initializers follow:

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
print(purple) 
```
```
(color:(RGB)): {
  r = 128, 
  g = 0, 
  b = 128, 
  hex = '#800080', 
  names = '[(css):'purple', (html):'PURPLE', (svg):'purple']', 
  alpha = 255
}
```
```lua
purple:to("HSV")
print(purple) 
```
```
(color:(HSV)): {
  h = 300.0, 
  s = 100.0, 
  v = 50.196078431373, 
  hex = '#800080', 
  names = '[(css):'purple', (html):'PURPLE', (svg):'purple']', 
  alpha = 255
}
```
```lua
-- this is a copy of purple in CMYK
local fuchsia = purple:as("CMYK")
print(fuchsia)  
```
```
-- note: this is a copy of the color purple before it is changed to fuchsia ...

(color:(CMYK)): {
  c = 0.0, 
  m = 100.0, 
  y = 0.0, 
  k = 49.803921568627, 
  hex = '#800080', 
  names = '[(css):'purple', (html):'PURPLE', (svg):'purple']', 
  alpha = 255
}
```
```lua
-- assigning the .hex changes the color value
fuchsia.hex = "FF00FF" 
print(fuchsia, fuchsia:as("RGB")) 
```
```
(color:(CMYK)): {
  c = 0.0, 
  m = 100.0, 
  y = 0.0, 
  k = 0.0, 
  hex = '#FF00FF', 
  names = '[(css):'fuchsia', (css):'magenta', (html):'FUCHSIA', (svg):'fuchsia', (svg):'magenta', (x11):'Magenta1']', 
  alpha = 255
}	

(color:(RGB)): {
  r = 255.0, 
  g = 0, 
  b = 255.0, 
  hex = '#FF00FF', 
  names = '[(css):'fuchsia', (css):'magenta', (html):'FUCHSIA', (svg):'fuchsia', (svg):'magenta', (x11):'Magenta1']', 
  alpha = 255
}

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
print(teal,teal:compliment()) ---> color:(RGB) {r = 128.0, g = 0.0, b = 0.0}
```
```
-- this is the color: teal
(color:(RGB)): {
  r = 0,
  g = 128.0
  b = 128.0,
  hex = '#008080', 
  alpha = 255
}

-- this is the .compliment color: maroon
(color:(RGB)): {
  r = 128.0, 
  g = 0.0, 
  b = 0.0, 
  hex = '#800000', 
  alpha = 255
}
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
