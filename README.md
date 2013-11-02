Color-Space.lua
===============

Lua - Color Space Conversion 

This function written in Lua will allow you to convert between color spaces
Currently Supported Color Spaces

RGB - Red Green Blue (0-255,0-255,0-255)

HSI - Hue Saturation Intensity (0-255,0-100,0-255)

HSV - Hue Saturation Value (0-360,0-100,0-100)

HSL - Hue Saturation Lightness (0-360,0-100,0-100)

LCH 601 - Luma Chroma Hue (0-100,0-100,0-360)

LCH 709 - Luma Chroma Hue (0-100,0-100,0-360)


Impots/Exports

Hex - Hex string can be passed as an argument to convert to value above or to export from value.

Usage - 
In - (string) - Input format from list above

Out - (string) - Output format from list above

Vararg - Accepts table of values or sequential entry of color values

Returns Keyed table of values
