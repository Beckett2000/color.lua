-- Converts Between Color Spaces and Conversions
-- Accepts/Outputs RGB/HSV/HSL/HSI/LCH 601/LCH 709/Hex
function ColorSpace(input,output,...)
    
    local In if input and type(input) == "string" then In = string.upper(input) 
     else print("Input must be valid string.") return end
    local Out if output and type(output) == "string" then Out = string.upper(output)
     else print("Output must be valid string.") return end
    
    local Values = {...}
    local ColorTable = type(Values[1]) == "table"
    
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
    
    -- Outputs Values Converted to RGB
    local function ConversionNS(Input,values) 
        
     -- Simple Hue Chroma Conversion Model
     if Input == "HSV" or Input == "HSL" or Input == "LCH 601" or Input == "LCH 709" then
      local Values = {} -- Color Table Evaluation
    
      if Input == "HSV" then Values.h = values.h or values[1] Values.s = values.s or values[2]
       Values.v = values.v or values[3] Values.s = Values.s / 100 Values.v = Values.v / 100
      elseif Input == "HSL" then Values.h = values.h or values[1] Values.s = values.s or values[2] 
       Values.l = values.l or values[3] Values.s = Values.s / 100 Values.l = Values.l / 100
      elseif Input == "LCH 601" or In == "LCH 709" then Values.y = values.y or values[1]
       Values.c = values.c or values[2] Values.h = values.h or values[3] 
       Values.y = Values.y / 100 Values.c = Values.c / 100  end
    
      local Hdash,RGB = Values.h/60,{R = 0, G = 0, B = 0}
      local Chroma if Input == "HSV" then Chroma = Values.v * Values.s
      elseif Input == "HSL" then Chroma = (1 - math.abs((2 * Values.l) - 1)) * Values.s
      elseif Input == "LCH 601" or Input == "LCH 709" then Chroma = Values.c end
      local X = Chroma * (1.0 - math.abs((Hdash % 2.0) - 1.0))
     
      if Hdash < 1.0 then RGB.R = Chroma  RGB.G = X
      elseif Hdash < 2.0 then RGB.R = X RGB.G = Chroma
      elseif Hdash < 3.0 then RGB.G = Chroma RGB.B = X
      elseif Hdash < 4.0 then RGB.G = X RGB.B = Chroma
      elseif Hdash < 5.0 then RGB.R = X RGB.B = Chroma
      elseif Hdash <= 6.0 then RGB.R = Chroma RGB.B = X end 
    
      local R,G,B = RGB.R,RGB.G,RGB.B
      local Min if In == "HSV" then Min = Values.v - Chroma
      elseif Input == "HSL" then Min = Values.l - (0.5 * Chroma)
      elseif Input == "LCH 601" then Min = Values.y - ((0.2990 * R) + (0.5864 * G) + (0.1146 * B))
      elseif Input == "LCH 709" then Min = Values.y - ((0.2126 * R) + (0.7152 * G) + (0.0722 * B)) end
      RGB.R = RGB.R + Min RGB.G = RGB.G + Min RGB.B = RGB.B + Min
      return {r = RGB.R * 255, g = RGB.G * 255, b = RGB.B * 255} 
    
     elseif Input == "HSI" then -- Converts HSI Space to RGB
      local Values = {} Values.h = values.h or values[1] Values.s = values.s or values[2]
       Values.i = values.i or values[3] 
      
      local h,s,i = Values.h * (math.pi/180),Values.s/100,Values.i/255
      local R,G,B if h >= 0 and h < (2 * math.pi)/3 then B = i*(1 - s) 
       R =  i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) G = (3 * i)-(B + R) 
      elseif h >= (2*math.pi)/3 and h < (4 * math.pi)/3 then h = h-((2*math.pi)/3) R = i*(1-s) 
       G = i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) B = (3 * i)-(R + G) 
      elseif h >= (4 * math.pi)/3 and h < 2 * math.pi then h = h-((4*math.pi)/3) G = i*(1-s) 
       B =  i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) R = (3 * i)-(G + B) end
    
      return {r = R * 255, g = G * 255, b = B * 255} 
    
     elseif Input == "HEX" then -- Converts Hex String to RGB
      local Hexes = {A = 10, B = 11, C = 12, D = 13, E = 14, F  = 15}
      local RGB = {} for Hex in string.gmatch(values[1],"%w%w") do 
      local Value = 0 for First,Last in string.gmatch(Hex,"(%w)(%w)") do
       if Hexes[string.upper(First)] == nil then Value = Value + (tonumber(First) * 16)
       else Value = Value + (Hexes[string.upper(First)] * 16) end
       if Hexes[string.upper(Last)] == nil then Value = Value + tonumber(Last)
       else Value = Value + Hexes[string.upper(Last)] end end
        
      if RGB.r == nil then RGB.r = Value elseif RGB.g == nil then RGB.g = Value
       elseif RGB.b == nil then RGB.b = Value end end 
      return RGB end end 
    
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
    
    -- Outputs Values Converted from RGB
    local function ConversionS(Output,values)
        
      -- Evaluates Entries from input table
      local R,G,B = values.r or values[1], values.g or values[2], values.b or values[3]
    
      -- Simple Hue Chroma Conversion Model
      if Output == "HSV" or Output == "HSL" or Output == "LCH 601" or Output == "LCH 709" then
       local R,G,B = R/255, G/255, B/255 -- Normalizes Color Values
    
       local Max,Min = math.max(R,G,B),math.min(R,G,B)
       local Chroma if R == 0 or G == 0 or B == 0 then Chroma = Max
       else Chroma = Max - Min end
    
       local Hue if Chroma == 0 then Hue = 0
       elseif Max == R then Hue = 60 * (((G - B)/Chroma) % 6)
       elseif Max == G then Hue = 60 * (((B - R)/Chroma) + 2)
       elseif Max == B then Hue = 60 * (((R - G)/Chroma) + 4) end 
     
       if Output == "HSV" then -- Hue Saturation Value Space
        local V,S = Max if Chroma == 0 then S = 0 else S = Chroma/V end
        return {h = Hue, s = S * 100, v = V * 100}
       elseif Output == "HSL" then -- sHue Saturation Lightness Space
        local L,S = 0.5 * (Max + Min), 0
        if Chroma == 0 then S = 0 else S = Chroma / (1 - math.abs((2 * L) - 1)) end
        return {h = Hue, s = S * 100, l = L * 100}
       elseif Output == "LCH 601" then -- Luma Chroma Hue (NTSC) Space
        local Luma = (0.2990 * R) + (0.5864 * G) + (0.1146 * B)
        return {y = Luma * 100, c = Chroma * 100, h = Hue}
       elseif Output == "LCH 709" then -- Luma Chroma Hue (sRGB) Space
        local Luma = (0.2126 * R) + (0.7152 * G) + (0.0722 * B)
        return {y = Luma * 100, c = Chroma * 100, h = Hue} end
        
      elseif Output == "HSI" then -- Converts Entries to HSI Space
       local r,g,b = R/(R+G+B),G/(R+G+B),B/(R+G+B)
       local Hue = math.acos(0.5*((r-g)+(r-b))/math.sqrt(math.pow((r-g),2)+(r-b)*(g-b)))
       local Min,Ity,Sat = math.min(r,g,b),(R + G + B)/(3 * 255) 
       if Ity == 0 then Sat = 0 else Sat = 1 - (3 * Min) end
       if b > g then Hue = (2 * math.pi) - Hue end 
       return {h = (Hue * 180)/math.pi, s = Sat * 100, i = Ity * 255}
    
      elseif Output == "HEX" then -- Converts Entry to Hex String
       local Hex,Val = "#",{"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
       local RGB,Hex = {R * 255,G * 255,B * 255},"#" for _,Col in pairs(RGB) do
        local Tens,Ones = math.floor(Col/16), Col % 16 Hex = Hex..Val[Tens + 1]..Val[Ones + 1] end 
       return Hex end end
    
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

    local Vals if ColorTable then Vals = Values[1]
      elseif not ColorTable then Vals = {Values[1],Values[2],Values[3]} end 
    if In == "RGB" then return ConversionS(Out,Vals)
    elseif Out == "RGB" then return ConversionNS(In,Vals) 
    else local Color = ConversionNS(In,Vals) return ConversionS(Out,Color) end
    
end
