-------------------------------------------
-- color.lua - 1.10(c) - (Beckett Dunning 2014 - 2025) - color conversion /  transformaion for Lua
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

-- This class converts between defined color spaces to manipulate color values and modulate channel levels. 

-- Supported Color Spaces : RGB | HSV / HSB | HSL | HSI | HWB | HSM | HCG | CMY | CMYK | TSL | YUV | YCbCr (601,709,2020) | YCgCo | YDbDr | XYZ | HEX | LAB | LUV | LCHab | LCHuv |

---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 

----- ----- ----- ----- ----- -----
-- if true then return end -- blocks the code from running
----- ----- ----- ----- ----- -----

local abs,acos,cos,sqrt,pi,pow,ceil,floor,toint,round,iter,push,contains = math.abs, math.acos, math.sqrt, math.cos, math.pi, math.pow, math.ceil, math.floor, math.toint

---- ---- ---- -- -- ---- ---- ---- --
local _color = color -- stores native color data (codea light userdata)
local colorNames = require(asset.color_names)
---- ---- ---- -- -- ---- ---- ---- --
-- local object = require(asset.object) -- dev dep (object.lua)
---- ---- ---- -- -- ---- ---- ---- --

local toStringHandlers

---- ---- ---- -- -- ---- ---- ---- --

-- definitions - (TODO) - header flags are used to determine which definitions are part of the meain color object. i.e. color.CSS.red or color.red if there is more than onr color standard defined which is contains same value. i.e. color.red where color.CSS.red is the same as color.HTML.red and both are defined. A reference to these would return a color object.

local definitions = {
  CSS = true, HTML = true, 
  SVG = true, x11 = true
}

---- ---- ---- -- -- ---- ---- ---- -- -- ---- ---- ---- -- -- ---- ---- ---- 

local colorData = { -- holds: Properties / Range Data for colors
    
  -- intScale = false, -- scale on 0 - 1.0 vs. 0 - 100
  
  ---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ----
    
  spaces = { -- data storage: color space properties 
    
    RGB = { _link = "XYZ", -- RGB (red,green,blue) 
      {"r","red", min = 0, max = 255}, 
      {"g","green", min = 0, max = 255}, 
      {"b","blue", min = 0, max = 255}}, 
    
    HSV = { _link = "RGB", -- HSV (hue,saturation,value) 
      {"h","hue", min = 0, max = 360}, 
      {"s","saturation", min = 0, max = 100},
      {"v","value", min = 0, max = 100}}, 
    
    HSB = { _link = "RGB", -- HSB (hue,saturation,brightness) 
      {"h","hue", min = 0, max = 360}, 
      {"s","saturation", min = 0, max = 100}, 
      {"b","brightness", min = 0, max = 100}}, 
    
    HSL = { _link = "RGB", -- HSL (hue,saturation,lightness)
      {"h","hue", min = 0, max = 360}, 
      {"s","saturation", min = 0, max = 100}, 
      {"l","lightness", min = 0, max = 100}}, 
    
    HSI = { _link = "RGB", -- HSI (hue,saturation,intensity) 
      {"h","hue", min = 0, max = 360}, 
      {"s","saturation", min = 0, max = 100}, 
      {"i","intensity", min = 0, max = 100}}, 
    
    HWB = { _link = "RGB", -- HWB (hue,whiteness,blackness) 
      {"h","hue", min = 0, max = 360}, 
      {"w","Whiteness", min = 0, max = 100}, 
      {"b","blackness", min = 0, max = 100}}, 
    
    HCG = { _link = "RGB", -- HCG (hue,chroma,greyscale)
      {"h","hue", min = 0, max = 360},
      {"c","chroma", min = 0, max = 100}, 
      {"g","greyscale", min = 0, max = 100}}, 
    
    HSM = { _link = "RGB", -- HCG (hue,saturation,mixture)
      {"h","hue", min = 0, max = 360},
      {"s","saturation", min = 0, max = 100}, 
      {"m","mixture", min = 0, max = 100}}, 
    
    CMY = { _link = "RGB",-- CMY (cyan,magenta,yellow)
      {"c","cyan", min = 0, max = 100},
      {"m","magenta", min = 0, max = 100},
      {"y","yellow", min = 0, max = 100}},
    
    CMYK = { _link = "RGB", -- CMY (cyan,magenta,yellow,key/black)
      {"c","cyan", min = 0, max = 100},
      {"m","magenta", min = 0, max = 100}, 
      {"y","yellow", min = 0, max = 100},
      {"k","black","key", min = 0, max = 100}},
    
    XYZ = { _link = "RGB",
      {"x", min = 0, max = 100},
      {"y", min = 0, max = 100},
      {"z", min = 0, max = 100}},
    
    LAB = { _link = "XYZ",
      {"l","lightness", min = 0, max = 100},
      {"a", min = -100, max = 100},
      {"b", min = -100, max = 100}},
    
    LUV = { _link = "XYZ",
      {"l","lightness", min = 0, max = 100},
      {"u", min = -134, max = 224},
      {"v", min = -140, max = 122}},
    
    LCHab = { _link = "LAB",
      {"l","lightness", min = 0, max = 100},
      {"c","chroma", min = 0, max = 100},
      {"h","hue", min = 0, max = 360}},
    
    LCHuv = { _link = "LUV",
      {"l","lightness", min = 0, max = 100},
      {"c","chroma", min = 0, max = 100},
      {"h","hue", min = 0, max = 360}},
    
    TSL = { _link = "RGB",
      {"t","tint", min = 0, max = 100},
      {"s","saturation", min = 0, max = 100},
      {"l","lightness", min = 0, max = 100}},
    
    YCbCr = { _link = "RGB",
      {"y", min = 0, max = 100},
      {"cb", min = -50, max = 50},
      {"cr", min = -50, max = 50}},
    
    YUV = { _link = "RGB",
      {"y", min = 0, max = 100},
      {"u", min = -43.6, max = 43.6},
      {"v", min = -61.5, max = 61.5}},
    
    YCgCo = { _link = "RGB",
      {"y", min = 0, max = 100},
      {"cg", min = -50, max = 50},
      {"co", min = -50, max = 50}},
    
    YDbDr = { _link = "RGB",
      {"y", min = 0, max = 100},
      {"db", min = -133.3, max = 133.3},
      {"dr", min = -133.3, max = 133.3}},
    
  },
  
  ---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ----
    
  codecs = { -- holds: arguments for special color spaces
    
    YCbCr601 = { _link = "RGB",
      _alias = {"YCC601","YPbPr"},
      {"y", min = 0, max = 100},
      {"cb", min = -50, max = 50},
      {"cr", min = -50, max = 50}},
    
    YCbCr709 = { _link = "RGB",
      _alias = {"YCC709"},
      {"y", min = 0, max = 100},
      {"cb", min = -50, max = 50},
      {"cr", min = -50, max = 50}},
    
    YCbCr2020 = { _link = "RGB",
      _alias = {"YCC2020", "YcCbcCrc"},
      {"y", min = 0, max = 100},
      {"cb", min = -50, max = 50},
      {"cr", min = -50, max = 50}},
    
  },  
  
  ---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ----
  -- this is where the defined cololors of different definitions are added. Actual color names are defined externally ...
  
  definitions = colorNames

  ---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ----
  
}

----- ----------- ----------- ----------- ----------- ----------- 
---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ----

-- Color Space Data - Alias Population

local function _populateAlias(lookup)
  local _alias = {} for k,v in pairs(lookup) do 
    if v._alias then local name 
      for i = 1, #v._alias do name = v._alias[i] 
        if type(name) == 'string' then _alias[name] = lookup[k] end 
      end end end
  
  for k,v in pairs(_alias) do lookup[k] = {} 
    for i = 1, #_alias[k] do lookup[k][i] = v[i] end
    lookup[k]._link = v._link lookup[k]._alias = nil
    
  end end 

------ ----- ----- ----- ----- ----- -----
_populateAlias(colorData.spaces) -- populate space aliases
_populateAlias(colorData.codecs) -- populate extraSpace aliases
------ ----- ----- ----- ----- ----- -----

----- ----------- ----------- ----------- ----------- ----------- 
-- [private] - helper utility functions
---- ---- --- -- --- ---- ---- ---- --- -- --- ---- ---- ---- ---

---- ---- --- -- --- ---- ---- 
-- polyfill: math.pow

if not pow then 
 pow = function(val,exp)
  local out = 1
  for i = 1,exp do out = out * val end
  return out end
end

---- ---- --- -- --- ---- ---- 
-- helper: creates iterator for vararg

iter = function(...)
 local args, i = {...}, 0 
 return function() i = i + 1;
  if i <= #args then return i, args[i] end
  return nil end
end -- returns: (function - iterator)

---- ---- --- -- --- ---- ---- 
-- helper: rounds floating point number to a given number of decimal places

round = function(float,dps)
  local mult = 10 ^ (dps or 0)
  return (float * mult) % 1 >= 0.5 and ceil(float * mult)/mult or 
    floor(float * mult)/mult
end

---- ---- --- -- --- ---- ---- 
-- helper: pushes values to the end of table

push = function(self,...)
  local insert,val = table.insert
  for i = 1, select("#",...) do
   val = select(i,...); insert(self,val) end
return obj end

---- ---- --- -- --- ---- ---- 
-- helper: contains(...) - determines if one or more entries exists in a source table

contains = function(self,...) -- determines if table contains entry
 
 if not self or type(self) ~= "table" then
  return false end
  
 local count = select("#",...)
 if count == 1 then; local val = select(1,...)
  for _,v in pairs(self) do if v == val then return true end end return false end

 local args,vals,arg = {...},{} -- used if more than one argument is passed
  for i = 1,#args do arg = args[i]
   if arg == nil then return false
   elseif not vals[arg] then vals[arg] = true
   else count = count - 1 end
 end
    
 local index,value = next(self)             
 while value do 
  if vals[value] then
   vals[value] = nil count = count - 1
   if count == 0 then return true end
  end  
 
  index,value = next(self,index) end 
  
 return false end -- returns: true or false

---- ---- --- -- --- ---- ---- 

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- -----

-- [color object] -- creates: lua color object

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- -----

-- New color objects can be created using methods color() or color.new(). The initializers follow:

--   color(255,255,255) -- creates RGB color object
--   color({r = 255, g = 0, b = 255}) -- auto detect color based on properties
--   color("RGB",255,0,255) -- space/model name passed as string       
--   color.RGB(255,0,255) -- indexed space/model creation
--   color.RGB({r = 255, g = 0, b = 255}) -- strict creation

--------------- --------------- --------------- --------------- ---------------

-- Color object properties / methods:

--  .space / .model -- (set) convert to color space | (get) return space description string
--  :to("space") / :convertTo("space") -- convert color to color space 
--  :as("space") -- create a copy of color and convert it to space

-- Properties: All color objects can access their channel properties through their abbreviated or verbose keys.
--  reference names for properties are case insensitive i.e.

--   color.r  color.red  color.Hue  color.V  color.SaTuRaTiOn


---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- -----

---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
local color = {} -- color object base class
---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
color.new = color -- creates new color object - (color.new() == color())
---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- 
-- color meta -- helper functions ...
---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

---- ---- --- -- --- ---- ---- 
-- creates (6 char) hex string

local function _processHEX(inputStr) 
  
  local hex = ""
  if string.find(inputStr,"^[#]?%x%x%x%x%x%x(%x?%x?)$") then
    hex = hexString
  elseif string.find(inputStr,"^[#]?%x%x%x(%x?)$") then for match in string.gmatch(inputStr,".") do
      if match == "#" then hex = hex.."#"
      else hex = hex..match..match end end
    
  return hex end
  
end

---- ---- --- -- --- ---- ---- 
-- converts RGB channel value (number) to HEX string

local function toHEX(channel)
 if not channel then return end
 local channel = string.format("%x",round(channel)):upper() 
 return channel:len() == 1 and "0"..channel or channel     
end -- returns: HEX (8 char) -> #RRGGBBAA


---- ---- --- -- --- ---- ---- 
-- (temp) - gets a list of the defined css colors as a table

local function _getCSSColors()
  
  local css = colorNames.dictionaries.CSS
  
  local names = {}
  local i,lookup = next(css)
  while(lookup) do      
   for name,value in pairs(lookup) do
    names[name] = value end
   i,lookup = next(css,i)
  end 

 return names 
  
end --> (table) {colorName:data,...}

---- ---- --- -- --- ---- ---- 
-- (WIP) - first pass ... if a color has defined names in a given standard, they are returned by this function ... 

local function _getColorNames(self)

   local names,hex = {}, self.hex
   local cat = table.concat

   local dicts = colorNames.dictionaries
   for standard,lookup in pairs(dicts) do 
    if standard == "CSS" then
     lookup = _getCSSColors()
    end
    
    -- todo - round can be used here ...
    for name,col in pairs(lookup) do
     if col.hex:upper() == hex then
      push(names,cat{"(",
       standard:lower(),"):'",name,"'"})
     end end end
  
    if #names > 0 then table.sort(names)
     return names end
  
end

---- ---- --- -- --- ---- ---- 
-- expands color source for base color object i.e. color.css ...

local function expandColorSource(key)
  
    -------- ------ -------- ------ 
    -- ::mark:: definedColors - creates / expands predefined color tags into color objects
    
    local definitions = colorData.definitions.dictionaries   
  
    ------ ---- ------ ---- -------
    --- key formatting (alternate names)
    key = key == "css" and "CSS" or key == "html" and "HTML" or key
   ------ ---- ------ ---- -------
  
    local source = definitions and definitions[key] and definitions[key]
    if not source then return end
  
    local def = {}
  
    if key == "CSS" then
      source = _getCSSColors()
    end
  
    local meta = {
                    
     __index = function(self,key) 
         -- look here!!!!!!!!
      if source[key] then
       local hex = source[key].hex
       return color(hex)
      end
      
      end,       
      
      __tostring = toStringHandlers.definitions(source,key) 
    }       
  
    -------- ------ -------- ------  
    
    setmetatable(def,meta)
  
    return def -- returns: pointer to creation table

 end


----- ----------- ----------- ----------- ----------- ----------- 
-- creates the color object metatable ... 

local color_meta = {
  
  __index = function(self,key)
    
    -------- ------ -------- ------
    
    if key == "HEX" then return 
      
      function(hex)     
        local encodedHex = _processHEX(hex)
        local colorObj = self("RGB",self.convert.HEX.RGB(encodedHex))
                
        if colorObj and not colorObj.alpha then colorObj.alpha = 255 return colorObj end end 
      
    end
    
    -------- ------ -------- ------ 
  
    -- ::mark:: named colors / definitions - creates / expands predefined color tags into color objects
    
    local definitions = colorData.definitions.dictionaries   
    
    -- --- -- --- -- --- -- ---
    if key == "css" then key = "CSS"
    elseif key == "html" then key = "HTML"
    elseif key == "svg" then key = "SVG"
    elseif key == "X11" then key = "x11" end
    -- --- -- --- -- --- -- ---
    
    local source = definitions and definitions[key]
    
    if source then
      return expandColorSource(key)
    end
    
    -------- ------ -------- ------
    
    if colorData.spaces[key] or colorData.codecs[key] then 
      -- local color = color and color or self
      
      -- handles color constructor indexing col.HSV(...) -> col("HSV",...)
      	return function(...)  
        -- print("Got to here: ",key)
      return self(key,...) end end 
  
  end,
  
  ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  -- ::mark:: __call(...) - color object creation / meta methods
  ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  __call = function(super,...) -- creates: color object
    
    local alpha = 255 -- initial alpha value
    local count = select("#",...) if count == 0 then -- error("attemt to call color() with no arguments.")
    return super(0,0,0,alpha) end
    -- print("Meta was called.")
    
    local first,second,colorSpaces,extraColorSpaces = select(1,...),select(2,...),colorData.spaces, colorData.codecs
    
    local form1,form2 = first and type(first),second and type(second)
    -- print("To here:",first,second)
    
    --------- ---------- ----------
    --- ::mark:: constructor for empty col
    
    if (colorSpaces[first] or  extraColorSpaces[first]) and not second then -- print("I was here")
      local col = super("RGB",0,0,0,alpha)
      return col:to(first)
    end 
    
    --------- ----------
    
    --[[
    if form2 == "table" then 
    print("[.__call] The table data: ", object(second)) 
    end
    ]]
    
    ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    local _colorData,out = {}, {} -- parameter data / color object (output)
    ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    local meta = { space = nil, data = _colorData,
            
      ---- ------  ---- ------
      -- Handles color stringification / pretty print
      
      __tostring = toStringHandlers.objects, -- (tostring(object)) - converts color object to string
        
      ---- ------  ---- ------
      
      __len = function(self) -- (# operator) - gets number of color object channels + alpha
        local space = getmetatable(self).space local target = colorSpaces[space] or extraColorSpaces[space]
        if target then return #target + 1 end end, 
      
      ----- ----- ----- -----    
      -- Operator overloads - Document
      ----- ----- ----- -----
      
      __add = function(self,val) -- Add to color object (RGB)
        local space = self.space if not val then return self:as(self.space) end
        local form,subj,col = type(val), self:as("RGB") if form == 'string' or (form == 'table' and not val.space) then
          col = color(val) if col.space ~= "RGB" then col:to("RGB") end else col = val:as("RGB") end
        subj.r,subj.g,subj.b = (subj.r + col.r)/2,(subj.g + col.g)/2,(subj.b + col.b)/2
        getmetatable(subj).data.alpha = (subj.alpha + col.alpha)/2
      return subj:to(space) end,
      
      __sub = function(self,val) -- Subtract from color object (RGB)
        local space = self.space if not val then return self:as(self.space) end
        local form,subj,col = type(val), self:as("RGB") if form == 'string' or (form == 'table' and not val.space) then
          col = color(val) if col.space ~= "RGB" then col:to("RGB") end else col = val:as("RGB") end
        subj.r,subj.g,subj.b = (subj.r - col.r)/2,(subj.g - col.g)/2,(subj.b - col.b)/2
        getmetatable(subj).data.alpha = (subj.alpha - col.alpha)/2
      return subj:to(space) end,
      
      __unm = function(self) -- Create a 'negative' color (RGB)
        local out,space = self:as("RGB"), self.space 
        out.r,out.g,out.b,out.alpha = abs(out.r - 255), abs(out.g - 255), abs(out.b - 255), abs(out.alpha - 255)
        if space ~= "RGB" then out:to(space) end return out end,
      
      ----- ----- ----- -----
      
      __eq = function(self,value) -- compares two colors for equality based on parameters
        
        return self.hex == value.hex
        
        --return super(value).hex == super(self).hex
        
        --[=[  
        local metaA,metaB = type(self) == "table" and getmetatable(self), type(value) == "table" and getmetatable(value)
        local spaceA,spaceB,target = metaA and metaA.space, metaB and metaB.space
        
        if spaceA == spaceB or spaceA or spaceB then -- handles: comarison of 2 colors in same space
        target = (spaceA == spaceB or spaceA) and spaceA or spaceB and spaceB or nil
        target = target and colorData.spaces[target] or colorData.codecs[target]
        
        if target then for i = 1, #target do -- compares if color space is valid
        	if self[target[i][1]] ~= value[target[i][1]] then return false end end
        if self.alpha == value.alpha then return true else return false end 
        	
        	elseif not target then -- compares if color space is invalid or nil
        	  print("comparison made without space declaration")
        
        
        	  local passed,entry = false 
        
        	  for key, value in pairs(self) do 
        
        target = colorData.spaces for k,v in pairs(target) do 
        	for a = 1,#target[k] do for b = 1,#target[k][a] do 
        if self[key] == target[k][a][b] then passed = true break end 
        if passed then break end end if passed then passed = false break end end end 
        
        target = colorData.codecs for k,v in pairs(target) do 
        	for a = 1,#target[k] do for b = 1,#target[k][a] do 
        if self[key] == target[k][a][b] then passed = true break end 
        if passed then break end end if passed then passed = false break end end end 
        
        if not passed then return false else return true end end 
        
        	  return false end -- TBA: Compare target is space name not know
        
        end 
        
        --]=]  
        
      end,
            
      ----- ----- ----- -----
            
            
      ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
      -- ::mark:: color.__newindex(key,value) - color object new index handling
      ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
            
      -- TODO - This is where you add offset notation. 0x        
            
      __newindex = function(self,key,value)
        
        local meta = getmetatable(self) local data,space = meta.data,meta.space 
        local entry = string.lower(key) local target = colorSpaces[space] or extraColorSpaces[space] 
        
        ------ ------ ------ ------ ------ 
        --[[ [setter]: hex string to color 
        color.hex = FFF(F) / FFFFFF(FF)
        4th channel is optional alpha ]]
        ------ ------ ------ ------ ------
        
        if key == "hex" then 
          
          local space = self.space
          local format = type(value)

          if format == "number" then
           return        
          end
          
          if format ~= "string" then   
                      
            print("Tring to set a hex value with type: ("..format..")") 
            
          return end
          
          local str68 = "^[#]?(%x%x)(%x%x)(%x%x)(%x?%x?)$"
          local str34 = "^[#]?(%x)(%x)(%x)(%x?)$"
          local patterns = {str68,str34}
          
          for _,pattern in pairs(patterns) do
            local r,g,b,alpha = value:match(pattern)
            
            -- print(value,r,g,b)
            
            if r and g and b then
            -- print(object.tostring(self,"v"))
              if space ~= "RGB" then
                self:to("RGB")
              end
              
              -- Expands hex values
              if pattern == str34 then
                r = r..r; g = g..g; 
                b = b..b; alpha = alpha..alpha
              end
              
              --print("matches",r,g,b,alpha)
              
              self.r,self.g,self.b = r,g,b 
              if alpha:len() == 2 then
                self.alpha = alpha 
              end
              
              if space ~= "RGB" then
                self:to(space)
              end
              
            end  
          end
          
        end
        
        ------ ------ ------ ------ ------   
        -- [setter]: color.channel = "FF" Uses a hex string or integer offset to assign a value to a RGB or alpha color channel
        ------ ------ ------ ------ ------ 
    
        local hex = (type(value) == "string" and tonumber(value,16)) or (type(value) == "number" and value)
                
        if (entry == "a" and not colorData.spaces[space][2][entry]) then
                    
         print("Got to the a channel key")
          
        end
                
        if (space == "RGB" or (entry == "alpha" or entry == "opacity")) and type(hex) == "number" then 
        
        -- (entry == "a" and not colorData.spaces[space][2][entry] ))
                     
          hex = hex > 255 and 255 or hex < 0 and 0 or hex   
                     
        end
        
        ------ ------ ------ ------ ------  
        -- [setter]: color.space = "space" converts between color spaces
        ------ ------ ------ ------ ------  
        
        if key == "space" or key == "model" then 
          local subject,k = colorSpaces[value] or extraColorSpaces[value]
          
          if not space then meta.space = subject and value end
          if subject then if meta.space ~= value then meta.space = value
              super.convert[space][value](self) end
            
            -- value scalar by defs.
            for i = 1,#subject do k = subject[i][1] -- clamps values after color space has been set
              
              rawset(data,k, not self[k] and 0 or self[k] >= subject[i].min and self[k] <= subject[i].max and self[k] or 
              self[k] < subject[i].min and subject[i].min or self[k] > subject[i].max and subject[i].max) end
            
          else print("color space: '"..tostring(value).."' not found.") return end
          
          --- ------ --- ------ --- ------ 
          -- [setter]: col.alpha -> (0 - 255)
          --- ------ --- ------ --- ------ 
          
        elseif --[[ entry == "a" or ]] entry == "alpha" or entry == "opacity" then 
          if hex and type(hex) == "number" then rawset(data,"alpha",hex)
          else rawset(data,"alpha",value >= 0 and value <= 255 and value or value > 255 and 255 or value < 0 and 0) return end
          
          --- ------ --- ------ --- ------
          
        elseif target then -- processes: property keys of current color space directly
          
          for a = 1, #target do for b = 1,#target[a] do
              if target[a][b] == key then -- clamps values for declared parameters (min / max)
                
                -- Note: This explicitly returns and may need to be changed later
                if hex and type(hex) == "number" then data[target[a][1]] = hex return     
                  
                elseif not value then rawset(data,target[a][1],nil) 
                else rawset(data,target[a][1], value >= target[a].min and value <= target[a].max and value or 
                  value < target[a].min and target[a].min or value > target[a].max and target[a].max) 
                return end end end end end 
        
        -------------- ---------- -----
        -- ToDo: Think about behavior if setting color channels for different spaces
        
        for k,v in pairs(colorSpaces) do -- processes: property keys from all color spaces
          for a = 1,#v do for b = 1,#v[a] do if v[a][b] == key then -- clamps values for declared parameters (min / max)
                rawset(data,v[a][1],value) end end end end 
        
      return end,
      
      -- ]=====]
      
      ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
      -- ::mark:: color.__index(key) - color object index lookups
      ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
      
      __index = function(self,key)
                
        local meta = getmetatable(self) local data,space = meta.data,meta.space  
        
        if color[key] then return color[key] end
        
        local target,entry = colorSpaces[space] or extraColorSpaces[space], string.lower(key)

       -- local conversionSet =  
        
        local foundTo,foundAs = key:match("^to(.+)$") or key:match("^convert(.+)$") or key:match("^convertTo(.+)$"), key:match("^as(.+)$")
        
        local form = foundAs and 'as' or 'to'
        
        if type(key) == "number" then
          if key <= #target then return data[target[key][1]]
          elseif key == #target + 1 then return data.alpha end
          
        elseif key == "space" or key == "model" then return space -- (getter) returns: (string) color space name
          
        elseif --[[entry == "a" or ]] entry == "alpha" or entry == "opacity" then return data.alpha -- (getter) returns: (number) alpha property value
          
          ----- ----- ----- ----- ----- -----
          -- [getter] color.hex -> hex string
          ----- ----- ----- ----- ----- -----
          
        elseif entry == "hex" or entry == "hex8" then 
          local floor,format = math.floor, string.format
          local channels,space,key,code = {}, self.space for i = 1,#colorData.spaces[space] do 
            key = colorData.spaces[space][i][1] channels[key] = self[key] end
          if super.convert[space].HEX then code = super.convert[space].HEX(channels)
          else local current,_space = colorData.spaces[space] or colorData.codecs[space], space
            while not super.convert[_space].HEX do super.convert[_space][current._link](channels) _space = current._link 
              current = colorData.spaces[_space] or colorData.codecs[_space]; end
            code = super.convert[_space].HEX(channels) end
                    
          --- --- ---- ----   
                    
          -- TODO: expose these methods at the top level so they can be seen when reading over the API
          
          if entry == "hex8" then 
           code = code..toHEX(alpha) -- returns: HEX (8 char) -> #RRGGBBAA
          end
        
          return code -- returns: HEX (6 char) -> #RRGGBB
                    
          --- --- ---- ----   
          
          ---- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
                    
        -- to() / as() / convert() object methods - convert color object to a given color space (clone?) 
          
        elseif foundTo or foundAs then  -- processes color:toSpace() / color:asSpace() / etc.
          return function() return self[form](self,(foundTo or foundAs)) end 
          
        elseif key == "to" or key == "as" or key == "convert" or key == "convertTo" then 
          
          return function(self,cs) if not self or not cs then return end if space == cs then return self end 
            -- print("This is cs:",self,cs)
            
            local target,current = colorSpaces[cs] or extraColorSpaces[cs], colorSpaces[space] or extraColorSpaces[space]
            
            -- ::mark - Fix color channel rounding here
            
            local copy if key == "as" then copy = {} for i = 1,#current do copy[current[i][1]] = self[current[i][1]] end 
              copy = super(space,copy); 
              
              copy.alpha = meta.data.alpha; if space == cs then return copy end end
            
            local clone = key == "as"
            local pointer = clone and copy or self
            
            --  print("The conversion data:",target,pointer)
            
            if target and super.convert[space][cs] then 
              
              -- Fix - Setting object color space before processing color conversions
              
              -- print("(1) -> pointer:",pointer,space,cs)
              
              local meta = getmetatable(pointer)
              if meta and meta.space then meta.space = cs end
            
              local value = super.convert[space][cs](pointer) 
              
              -- print("(2) -> pointer:", value)
              
            else local link = target._link -- Handles mult-step color space conversions
              if super.convert[space][link] then super.convert[space][link](pointer) super.convert[link][cs](pointer) 
              else local links,entry = {link} while not super.convert[space][links[#links]] do
                  entry = colorSpaces[links[#links]] or extraColorSpaces[links[#links]] 
                  if entry._link == links[#links] or #links > 1 and entry._link == links[#links-1] then break 
                  else table.insert(links,entry._link) end end
                if super.convert[space][links[#links]] then local count = #links 
                  while count > 0 do super.convert[links[count+1]][links[count]](pointer) 
                  count = count - 1 end  super.convert[link][cs](pointer) 
                  
                else local _space,entry = space -- reverse _link lookkup - self > self._space
                  	while not super.convert[_space][cs] do 
                    	 entry = colorSpaces[_space] or extraColorSpaces[_space] 
                    super.convert[_space][entry._link](pointer); _space = entry._link end 
                  super.convert[_space][cs](pointer) end end end 
            
            --print(clone,copy,pointer)
          getmetatable(pointer).space = cs return not clone and self or copy end 
          
          
          ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
          -- color harmony function support
          
        elseif key == "compliment" then
          return color.compliment
        elseif key == "triad" then 
          return color.triad
        elseif key == "square" then 
          return color.square
          
        end
        
        ----- ----- -----
        
        for a = 1,#target do for b = 1, #target[a] do 
            if target[a][b] == entry then return data[target[a][1]] end end end 
        for k,v in pairs(colorSpaces) do for a = 1,#v do for b = 1,#v[a] do
              if v[a][b] == entry then return data[v[a][1]] end end end end end
      
    } setmetatable(out,meta) -- sets metatable for returned color object
    
    ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    -- ::mark:: __call(...) - color object creation argument parsing
    ---- ----- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    
    if form1 == "string" then -- string passed as first argument: color('space name',...)
      
      --- ::mark:: - Creates color based on hex string #FFF(F) #FFFFFF(FF)
      
      local str68 = "^[#]?(%x%x)%x%x%x%x(%x?%x?)$"
      local str34 = "^[#]?(%x)%x%x(%x?)$"
      local patterns = {str68,str34}
      
      for i,pattern in pairs(patterns) do
        
        local start,alphaHex = string.match(first,pattern)
        
        local isHex = not colorSpaces[first] and not extraColorSpaces[first]
        if start and isHex then
          
          local colorObj = super("RGB",super.convert.HEX.RGB(first)) 
          
          local alpha = pattern == str68 and alphaHex or pattern == str34 and alphaHex..alphaHex
          
          alpha = tonumber(alpha,16) or 255
          colorObj.alpha = alpha > 255 and 255 or alpha < 0 and 0 or alpha  
          
        return colorObj end end
      
      if not colorSpaces[first] and not extraColorSpaces[first] then 
      return error("invalid argument 1 to color(). no color space named '"..first.."'.") end
      
      rawset(meta,"space",first) local data = colorSpaces[first] or extraColorSpaces[first] 
      local second = select(2,...) local form2 = second and type(second) local total = #data
      
      ------- -------- ------- --------
      --- ::mark:: ToDo - Possible entry point for greyscale values
      
      -- print(form1,form2)
      
      if (form1 == "string" and first == "RGB" and form2 == "number" and (count == 2 or count == 3)) then
        
        out.alpha = select(3,...) or 255
        out.r, out.g, out.b = second, second, second
        
        -- print("I got to this point.",form1,form2) 
        
        ------- -------- ------- --------
        
      elseif form2 == "number" then -- (second arg: number) - color('space name', 255,...)
        rawset(meta,"space",first) for i = 1, total do out[data[i][1]] = select(i+1,...) end
        local ex1 = select(2 + total,...) out.alpha = ex1 and type(ex1) == "number" and ex1 or 255
        
      elseif form2 == "table" then -- (second arg: table) - color('space name',{...})
        
        -- print("[ex] got to here",first,object(second)) 
        
        -- (value array) - color('space name',{val,val,val,...})
        if second[1] and second[2] and second[3] then 
          
          rawset(meta,"space",first) for i = 1, total do out[data[i][1]] = second[i] end 
          
          local ex1 = second[total+1]; out.alpha = ex1 and type(ex1) == "number" and ex1 or 255
          
        else -- (value table) - color('space name',{key = val, key = val, key = val})
          
          local pram   
          rawset(meta,"space",first)
          for k,val in pairs(second) do 
            pram = string.lower(k)
            
            if pram == "a" or 
            pram == "opacity" then pram = "alpha" end 
            
            if pram == "alpha" and type(val) == "number" then  
              val = val >= 255 and 255 or val <= 0 and 0 or val; out.alpha = val -- rawset(data,pram, val) 
              
            else for a = 1,total do for b = 1, #data[a] do if data[a][b] == pram then out[data[a][1]] = val  
                    -- print(data[a][1],val) 
                  end end end end end end
        
        -- color('space name','HEX String')
      elseif form2 == "string" then 
        
        -- print("Creating color object in space ("..first..")") 
        
        local str68,str34 = "^[#]?%x%x%x%x%x%x(%x?%x?)$",
        "^[#]?%x%x%x(%x?)$"
        
        --print("[Const.] I am here:", second)  
        
        local val,alpha 
        local patterns = {str68,str34}
        for _,pattern in pairs(patterns) do
          
          if string.find(second,pattern) then
            alpha = string.match(second,pattern)
            
            if alpha then 
              if pattern == str34 then 
              alpha = alpha..alpha end
              
              -- print("Found alpha:",alpha)     
                              
            alpha = tonumber(alpha,16) end
          val = second end   
          
        end
        
        v = super.convert.HEX.RGB(val)  
        
        -- ToDo - RGB to XYZ may be losing data in conversion
        
        if super.convert.RGB[first] then super.convert.RGB[first](v) 
        else local target = colorSpaces[first] or extraColorSpaces[first]
          
          local link = target._link 
          --print(link)
          if super.convert.RGB[link] then super.convert.RGB[link](v) super.convert[link][first](v) 
          else local links,entry = {link} while not super.convert.RGB[links[#links]] do
              entry = colorSpaces[links[#links]] or extraColorSpaces[links[#links]]
            table.insert(links,entry._link) end super.convert.RGB[links[#links]](v)
            local count = #links - 1 while count > 0 do 
              super.convert[links[count+1]][links[count]](v) count = count - 1 end  
            super.convert[link][first](v) end
          
        end v = super(first,v) -- creates color object     
        
        v.alpha = alpha and alpha or 255
        --  v.alpha = (char4 or char8) and super.convert.HEX.RGB(string.sub(val,val:len()-1)).r or 255 
        
      return v end
      
    elseif form1 == "table" then -- table passed as first argument (auto detect space) : color({key = val, key = val, ...}) 
      
      for k,v in pairs(colorSpaces) do if meta.space then break end
        local total,didMatch,matchNo,comp,pram = #colorSpaces[k], false, 0
        for a = 1, #v do for b = 1, #v[a] do comp,pram = v[a][b], nil
            for key,value in pairs(select(1,...)) do pram = string.lower(key) 
              if pram == "alpha" or pram == "opacity" then out.alpha = value 
              elseif comp == pram then didMatch = true out[v[a][1]] = value break end end
            if didMatch then didMatch = false matchNo = matchNo + 1  break end end 
          if matchNo == total then out.space = k out.alpha = out.alpha or 255 
          return out end end end 
      
    elseif form1 == "number" then -- number vararg passed (assumes RGB) color(...)
      
      rawset(meta,"space","RGB")
      
      ------- -------- ------- --------
      --- ::mark:: color(128) - Greyscale RGB Values
      
      if (count == 1 or count == 2) then 
        -- print("In the conditional")
        out.alpha = form2 == "number" and second or 255
        out.r, out.g, out.b = first, first, first 
        
        ------- -------- ------- --------    
        
      else -- Standard RGB Values
        out.r = select(1,...) out.g = select(2,...) out.b = select(3,...) 
        out.alpha = select(4,...) or 255
      end end
    
    ------- -------- ------- --------  
    
  return out end,
  
} 

setmetatable(color,color_meta)


---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- Color Harmony Creation Functions
---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -

color.compliment = function(col) -- calculates the compliment of a color
  local ref = (type(col) == 'table' and col.space) and col or color(col)
  local compliment = ref:as("HSV") compliment.hue = compliment.hue + 180 % 360
  compliment:to(ref.space) return compliment 
end -- returns: color object compliment

color.triad = function(col) -- calculates the triadic scheme for a color
  local ref = (type(col) == 'table' and type(col.space) == 'string') and col or color(col)
  local triadA = ref:as("HSV") triadA.hue = triadA.hue + 120 % 360 
  local triadB = triadA:as("HSV") triadB.hue = triadB.hue + 120 % 360 
  triadA:to(ref.space) triadB:to(ref.space) return ref,triadA,triadB
end -- returns: 3 color objects (ref,triadA,triadB)

color.square = function(col) -- calculates the square scheme for a color
  local ref = (type(col) == 'table' and col.space) and col or color(col)
  local squareA = ref:as("HSV") squareA.hue = squareA.hue + 90 % 360
  local squareB = squareA:as("HSV") squareB.hue = squareB.hue + 90 % 360 
  local squareC = squareB:as("HSV") squareC.hue = squareC.hue + 90 % 360   
  squareA:to(ref.space) squareB:to(ref.space) squareC:to(ref.space)
  return ref,squareA,squareB,squareC
end -- returns: 4 color objects (ref,squareA,squareB,squareC)


---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- -----

-- Color Conversion Functions

-- Supported Normal Spaces: | RGB | HSV | HSB | HSL | HSI | HWB | HCG | CMY | CMYK |
-- Supported Extra Spaces: | YCbCr 601 | YCbCr 709 | YCbCr 2020 | YCgCo | YDbDr |
-- Beta / Testing Spaces: | HSM | TSL | XYZ

-- RGB -> HEX String Supported (no alpha channel)

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- -
-- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ---

color.convert = { -- Holds internal color conversion functions
  
  RGB = { -- Convert from RGB (Red,Green,Blue)
    
    HSV = function(vals) -- converts: RGB to HSV (Hue,Saturation,Value) 
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local max,min = math.max(r,g,b),math.min(r,g,b)
      local chroma = (r == 0 or g == 0 or b == 0) and max or max - min
      local hue = chroma == 0 and 0 or max == r and 60 * (((g - b)/chroma) % 6) or
      max == g and 60 * (((b - r)/chroma) + 2) or max == b and 60 * (((r - g)/chroma) + 4)
      local v,s = max; s = chroma == 0 and 0 or chroma/v 
      vals.r,vals.g,vals.b,vals.h,vals.s,vals.v = nil,nil,nil, hue, s * 100, v * 100
    return vals end, -- returns: (table) HSV Values {h = ?, s = ?, v = ?}
    
    HSB = function(vals) -- converts: RGB to HSV (Hue,Saturation,Brightness) 
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local max,min = math.max(r,g,b),math.min(r,g,b)
      local chroma = (r == 0 or g == 0 or b == 0) and max or max - min
      local hue = chroma == 0 and 0 or max == r and 60 * (((g - b)/chroma) % 6) or
      max == g and 60 * (((b - r)/chroma) + 2) or max == b and 60 * (((r - g)/chroma) + 4)
      local b,s = max; s = chroma == 0 and 0 or chroma/b 
      vals.r,vals.g,vals.h,vals.s,vals.b = nil,nil, hue, s * 100, b * 100
    return vals end, -- returns: (table) HSB Values {h = ?, s = ?, b = ?}
    
    HSL = function(vals) -- converts: RGB to HSL (Hue,Saturation,Lightness) 
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local max,min = math.max(r,g,b),math.min(r,g,b)
      local chroma = (r == 0 or g == 0 or b == 0) and max or max - min
      local hue = chroma == 0 and 0 or max == r and 60 * (((g - b)/chroma) % 6) or
      max == g and 60 * (((b - r)/chroma) + 2) or max == b and 60 * (((r - g)/chroma) + 4)
      local l,s = 0.5 * (max + min); s = chroma == 0 and 0 or chroma / (1 - math.abs((2 * l) - 1))
      vals.r,vals.g,vals.b,vals.h,vals.s,vals.l = nil,nil,nil, hue, s * 100, l * 100
    return vals end, -- returns: (table) HSL Values {h = ?, s = ?, l = ?}
    
    HSI = function(vals) -- converts: RGB to HSI (Hue,Saturation,Intensity) 
      local total = vals.r + vals.g + vals.b local r,g,b = vals.r/total,vals.g/total,vals.b/total
      
      local hue = math.acos(0.5*((r-g)+(r-b))/math.sqrt((r-g) * (r-g)+(r-b)*(g-b)))
      local min,ity,sat = math.min(r,g,b),(vals.r + vals.g + vals.b)/(3 * 255)
      sat = ity == 0 and 0 or 1 - (3 * min) if b > g then hue = (2 * math.pi) - hue end 
      hue = hue * 180/math.pi hue = hue >= 0 and hue or hue <= 360 and hue or 0
      vals.r,vals.g,vals.b,vals.h,vals.s,vals.i = nil,nil,nil,hue, sat * 100, ity * 100
    return vals end, -- returns: (table) HSI Values {h = ?, s = ?, i = ?}
    
    HWB = function(vals) -- converts: RGB to HWB (Hue,Whiteness,Blackness) 
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local max,min = math.max(r,g,b),math.min(r,g,b) local delta = max - min
      local chroma = (r == 0 or g == 0 or b == 0) and max or max - min
      local hue = chroma == 0 and 0 or max == r and 60 * (((g - b)/chroma) % 6) or
      max == g and 60 * (((b - r)/chroma) + 2) or max == b and 60 * (((r - g)/chroma) + 4)
      local w,b = math.min(r,math.min(g,b)), 1 - math.max(r,math.max(g,b))
      vals.r,vals.g,vals.h,vals.w,vals.b = nil,nil,hue, w * 100, b * 100
    return vals end,  -- returns: (table) HWB Values {h = ?, w = ?, b = ?}
    
    HCG = function(vals) -- converts: RGB to HCG (Hue,Chroma,Greyscale)
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local max,min,greyscale,hue = math.max(r,g,b),math.min(r,g,b) local chroma = max - min
      greyscale = chroma < 1 and min/(1 - chroma) or 0; if chroma > 0 then 
        hue = max == r and ((g-b) / chroma) % 6 or max == g and 2 + (b - r) / chroma or
      4 + (r - g) / chroma; hue = (hue/6) % 1 ; else hue = 0 end 
      vals.r,vals.b,vals.h,vals.c,vals.g = nil,nil,hue*360, chroma*100, greyscale*100
    return vals end,  -- returns: (table) HCG Values {h = ?, c = ?, g = ?}
    
    ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
    -- RGB to TSL Conversion - port from: https://stackoverflow.com/questions/43696998/tsltorgb-colorspace-conversion
    
    TSL = function(vals) -- converts: RGB to TSL (Tint,Saturation,Lightness) 
      local r,g,b = vals.r, vals.g, vals.b -- normalized properties
      if r == 0 and g == 0 and b == 0 then 
      vals.r,vals.g,vals.b,vals.t,vals.s,vals.l = nil,nil,nil, 0,0,0 return vals end
      
      local l = 0.299 * r + 0.587 * g + 0.114 * b;
      local r1, g1 = r / (r + g + b) - 1.0 / 3, g / (r + g + b) - 1.0 / 3
      local s = math.sqrt(9.0 / 5 * (r1 * r1 + g1 * g1))
      local t if g1 == 0 then if r < b then t = -0.0 else t = 0.0 end
      else t = math.atan(r1/g1) / math.pi / 2 + 0.25 if g1 < 0 and t == t then t = t + 0.5 end end
      vals.r,vals.g,vals.b,vals.t,vals.s,vals.l = nil,nil,nil, t * 100, s * 100, l * 1
    return vals end,  -- returns: (table) TSL Values {t = ?, s = ?, l = ?}
    
    ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
    
    -- Fix Me!! -- November 14, 2017 BD
    
    HSM = function(vals) -- converts: RGB to HSM (Hue,Saturation,Mixture) 
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local m = ((4*r)+(2*g)+b)/7
      
      local lvl = math.sqrt(pow((r-m),2) + pow((g-m),2) + pow((b-m),2))
      local angle = math.acos(( ((3*(r-m))-(4*(g-m))-(4*(b-m)) ) / math.sqrt(41)) / lvl)
      
      --angle = angle ~= angle and 0 or angle
      local w = b <= g and angle or b > g and (2 * math.pi) - angle
      local h,s = w / (2 * math.pi)
      
      if 0 <= m and m <= 1/7 then
        s = lvl / math.sqrt(pow(0-m,2) + pow(0-m,2) + pow(7-m,2))
      elseif 1/7 < m and m <= 3/7 then
        s = lvl / math.sqrt(pow(0-m,2) + pow((((7*m)-1)/2)-m,2) + pow(1-m,2))
      elseif 3/7 < m and m <= 1/2 then
        s = lvl / math.sqrt(pow((((7*m)-3)/2)-m,2) + pow(1-m,2) + pow(1-m,2))
      elseif 1/2 < m and m <= 4/7 then
        s = lvl / math.sqrt(pow(((7*m)/4)-m,2) + pow(0-m,2) + pow(0-m,2))
      elseif 4/7 < m and m <= 6/7 then
        s = lvl / math.sqrt(pow(1-m,2) + pow((((7*m)-4)/2)-m,2) + pow(0-m,2))
      elseif 6/7 < m and m <= 1 then
        s = lvl / math.sqrt(pow(1-m,2) + pow(1-m,2) + pow(((7*m)-6)-m,2) )
      end
      
      h,s,m = h ~= h and 0 or h, s ~= s and 0 or s, m ~= m and 0 or m
      vals.r,vals.g,vals.b,vals.h,vals.s,vals.m = nil,nil,nil, h * 360, s * 100, m * 100
    return vals end, -- returns: (table) HSM Values {h = ?, s = ?, m = ?}
    
    
    ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
    
    YUV = function(vals) -- converts: RGB to YUV (Luma,Chroma Blue,Chroma Red)
      local r,g,b = vals.r/255,vals.g/255,vals.b/255 
      local y = (r * 0.299) + (g * 0.587) + (b * 0.114) 
      local u,v = 0.436 * ((b - y)/0.886), 0.615 * ((r - y)/0.701)
      	vals.r,vals.g,vals.b,vals.y,vals.u,vals.v = nil,nil,nil, y * 100, u * 100, v * 100
    return vals end, -- returns: (table) YUV Values {y = ?, u = ?, u = ?}
    
    YCbCr601 = function(vals) -- converts: RGB to YCbCr 601 (Luminence,Chroma Blue,Chroma Red)
      local r,g,b,kR,kB = vals.r/255,vals.g/255,vals.b/255, 0.2990, 0.1146
      local y = (kR * r) + ((1 - kR - kB) * g) + (kB * b)
      local cB,cR = 0.5 * ((b - y)/(1 - kB)), 0.5 * ((r - y)/(1 - kR))
      vals.r,vals.g,vals.b,vals.y,vals.cb,vals.cr = nil,nil,nil, y * 100, cB * 100, cR * 100
    return vals end, -- returns: (table) YCbCr 601 Values {y = ?, cb = ?, cr = ?}
    
    YCbCr709 = function(vals) -- converts: RGB to YCbCr 709 (Luminence,Chroma Blue,Chroma Red)
      local r,g,b,kR,kB = vals.r/255,vals.g/255,vals.b/255, 0.2126, 0.0722 
      local y = (kR * r) + ((1 - kR - kB) * g) + (kB * b)
      local cB,cR = 0.5 * ((b - y)/(1 - kB)), 0.5 * ((r - y)/(1 - kR))
      vals.r,vals.g,vals.b,vals.y,vals.cb,vals.cr = nil,nil,nil, y * 100, cB * 100, cR * 100
    return vals end, -- returns: (table) YCbCr 709 Values {y = ?, cb = ?, cr = ?}
    
    YCbCr2020 = function(vals) -- converts: RGB to YCbCr 2020 (Luminence,Chroma Blue,Chroma Red)
      local r,g,b,kR,kB = vals.r/255,vals.g/255,vals.b/255, 0.2627, 0.0593 
      local y = (kR * r) + ((1 - kR - kB) * g) + (kB * b)
      local cB,cR = 0.5 * ((b - y)/(1 - kB)), 0.5 * ((r - y)/(1 - kR))
      vals.r,vals.g,vals.b,vals.y,vals.cb,vals.cr = nil,nil,nil, y * 100, cB * 100, cR * 100
    return vals end, -- returns: (table) YCbCr 2020 Values {y = ?, cb = ?, cr = ?}
    
    YCgCo = function(vals) -- converts: RGB to YCgCo (Luminence,Chroma Green,Chroma Orange)
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      vals.r,vals.g,vals.b = nil,nil,nil vals.y = ((0.25*r)+(0.5*g)+(0.25*b)) * 100
      vals.cg, vals.co = ((-0.25*r)+(0.5*g)-(0.25*b)) * 100, ((0.5*r)-(0.5*b)) * 100
    return vals end, -- returns: (table) YCgCo Values {y = ?, cg = ?, co = ?}
    
    YDbDr = function(vals) -- converts: RGB to YDbDr (Luminence,Chroma Blue,Chroma Red)
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local y,db,dr = 0.299*r + 0.587*g + 0.114*b, -0.450*r - 0.883*g + 1.333*b, -1.333*r + 1.116*g + 0.217*b 
      vals.r,vals.g,vals.b,vals.y,vals.db,vals.dr = nil, nil, nil, y * 100, db * 100, dr * 100
    return vals end, -- returns: (table) YDbDr Values {y = ?, db = ?, dr = ?}
    
    XYZ = function(vals)  -- converts: RGB to XYZ (X,Y,Z)
      local r,g,b,pow,x,y,z = vals.r/255, vals.g/255, vals.b/255, pow
      r = r > 0.04045 and pow(((r + 0.055) / 1.055), 2.4) or (r / 12.92);
      g = g > 0.04045 and pow(((g + 0.055) / 1.055), 2.4) or (g / 12.92);
      b = b > 0.04045 and pow(((b + 0.055) / 1.055), 2.4) or (b / 12.92);
      x = (r * 0.41239079926595) + (g * 0.35758433938387) + (b * 0.18048078840183);
      y = (r * 0.21263900587151) + (g * 0.71516867876775) + (b * 0.072192315360733);
      z = (r * 0.019330818715591) + (g * 0.11919477979462) + (b * 0.95053215224966);
      vals.r,vals.g,vals.b,vals.x,vals.y,vals.z = nil,nil,nil, x*100, y*100, z*100
    return vals end, -- returns: (table) XYZ Values {x = ?, y = ?, z = ?}
    
    CMY = function(vals) -- converts: RGB to CMY (Cyan,Magenta,Yellow)
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      vals.r,vals.g,vals.b,vals.c,vals.m,vals.y = nil,nil,nil,(1-r)*100,(1-g)*100,(1-b)*100
    return val end, -- returns: (table) CMY Values {c = ?, m = ?, y = ?, k = ?}
    
    CMYK = function(vals) -- converts: RGB to CMYK (Cyan,Magenta,Yellow,Key/Black)
      local r,g,b = vals.r/255, vals.g/255, vals.b/255 -- normalized properties
      local k = math.min(1-r,1-g,1-b) local c,m,y = (1-r-k)/(1-k),(1-g-k)/(1-k),(1-b-k)/(1-k)
      c,m,y,k = c ~= c and 0 or c, m ~= m and 0 or m, y ~= y and 0 or y, k ~= k and 0 or k
      vals.r,vals.g,vals.b,vals.c,vals.m,vals.y,vals.k = nil,nil,nil,c*100,m*100,y*100,k*100
    return vals end, -- returns: (table) CMYK Values {c = ?, m = ?, y = ?, k = ?}
    
    HEX = function(vals) -- converts: RGB to HEX String
      
      local r,g,b,a = vals.r,vals.g,vals.b,vals.a
      r,g,b,a = round(r), round(g),round(b), a and round(a)
        
      local hex = {r,g,b,a} 
      for idx,channel in ipairs(hex) do
       channel = string.format("%x",channel):upper()
       if channel:len() == 1 then channel = "0"..channel end
       hex[idx] = channel
      end
            
      table.insert(hex,1,"#")
            
    return table.concat(hex) end, -- returns: (string) Hex String         
    
  }, 
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HSV = { -- Converts from HSV (Hue,Saturation,Value)
    
    RGB = function(vals) -- converts: HSV to RGB (Red,Green,Blue)
      
      local h,s,v = vals.h,vals.s / 100, vals.v / 100
      local hdash,chroma,r,g,b = vals.h / 60, v * s, 0,0,0
      local x,min = chroma * (1.0 - math.abs((hdash % 2.0) - 1.0)), v - chroma 
      if hdash < 1.0 then r,g = chroma,x elseif hdash < 2.0 then r,g = x,chroma
      elseif hdash < 3.0 then g,b = chroma,x elseif hdash < 4.0 then g,b = x,chroma 
      elseif hdash < 5.0 then r,b = x,chroma elseif hdash <= 6.0 then r,b = chroma,x end 
      
      -- print("got to here:",h,s,v,r,g,b)
      vals.h,vals.s,vals.v,vals.r,vals.g,vals.b = nil,nil,nil, r + min, g + min, b + min
      vals.r,vals.g,vals.b = vals.r * 255, vals.g * 255, vals.b * 255
      
      --print("Got vals:",vals,vals.r,r,g,b)
      
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    HSB = function(vals) -- converts: HSV to HSB (Hue,Saturation,Brightness)
      vals.v,vals.b = nil,vals.v 
    return vals end, -- returns: (table) HSB Values {h = ?, s = ?, b = ?}
    
    HSL = function(vals) -- converts: HSV to HSL (Hue,Saturation,Lightness)
      local s,v = vals.s/100, vals.v/100; local l = ((2 - s) * v); vals.l = (l / 2) * 100
      local mod = l <= 1 and l or 2 - l; vals.s,vals.v = ((s * v) / mod) * 100, nil
    return vals end, -- returns: (table) HSL Values {h = ?, s = ?, l = ?}
    
    HWB = function(vals) -- converts: HSV to HWB (Hue,Whiteness,Blackness)
      local h,s,v = vals.h,vals.s/100,vals.v/100
      local b = 1 - v local w = (1 - s) * v
      vals.s,vals.v,vals.h,vals.w,vals.b = nil,nil, h, w * 100, b * 100
    return vals end, -- returns: (table) HWB Values {h = ?, w = ?, b = ?}
    
    HCG = function(vals) -- converts: HSV to HCG (Hue,Chroma,Greyscale)
      local h,s,v = vals.h,vals.s/100,vals.v/100 local c,r,g,b = s*v
      local ent = c < 1 and (v - c)/(1 - c) or 0
      vals.s,vals.v,vals.h,vals.c,vals.g = nil,nil, h, c * 100, ent * 100
    return vals end -- returns: (table) HCG Values {h = ?, c = ?, g = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HSB = { -- Converts from HSB (Hue,Saturation,Brightness)
    
    --[==[
    RGB = function(vals) -- converts: HSB to RGB (Red,Green,Blue)
    
    -- [[ -- (temp.) - This would work
    if true then
    return vals:to("HSV"):toRGB()
    end
    -- ]]
    
    end,
    -- ]==]
    
    RGB = function(vals) -- converts: HSV to RGB (Red,Green,Blue)
      
      local h,s,v = vals.h,vals.s / 100, vals.b / 100
      
      local hdash,chroma,r,g,b = vals.h / 60, v * s, 0,0,0
      local x,min = chroma * (1.0 - math.abs((hdash % 2.0) - 1.0)), v - chroma 
      
      if hdash < 1.0 then r,g = chroma,x elseif hdash < 2.0 then r,g = x,chroma
      elseif hdash < 3.0 then g,b = chroma,x elseif hdash < 4.0 then g,b = x,chroma 
      elseif hdash < 5.0 then r,b = x,chroma elseif hdash <= 6.0 then r,b = chroma,x end
      
      local scaledB = vals.b / 100 * 255 
      vals.h,vals.s,vals.v,vals.r,vals.g,vals.b = nil,nil,nil, r + min, g + min, b + min
      
      vals.r,vals.g,vals.b = vals.r * 255, vals.g * 255, vals.b * 255
      
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    HSV = function(vals) -- converts: HSB to HSV (Hue,Saturation,Value)
      vals.b,vals.v = nil,vals.b 
    return vals end, -- returns: (table) HSV Values {h = ?, s = ?, v = ?}
    
    HSL = function(vals) -- converts: HSB to HSL (Hue,Saturation,Lightness)
      local s,v = vals.s/100, vals.b/100; local l = ((2 - s) * v); vals.l = (l / 2) * 100
      local mod = l <= 1 and l or 2 - l; vals.s,vals.v = ((s * v) / mod) * 100, nil
    return vals end, -- returns: (table) HSL Values {h = ?, s = ?, l = ?}
    
    HWB = function(vals) -- converts: HSB to HWB (Hue,Whiteness,Blackness)
      local h,s,v = vals.h,vals.s/100,vals.b/100
      local b = 1 - v local w = (1 - s) * v
      vals.s,vals.v,vals.h,vals.w,vals.b = nil,nil, h, w * 100, b * 100
    return vals end, -- returns: (table) HWB Values {h = ?, w = ?, b = ?}
    
    HCG = function(vals) -- converts: HSB to HCG (Hue,Chroma,Greyscale)
      local h,s,v = vals.h,vals.s/100,vals.b/100 local c,r,g,b = s*v
      local ent = c < 1 and (v - c)/(1 - c) or 0
      vals.s,vals.v,vals.h,vals.c,vals.g = nil,nil, h, c * 100, ent * 100
    return vals end -- returns: (table) HCG Values {h = ?, c = ?, g = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HSL = { -- Converts from HSL (Hue,Saturation,Lightness)
    
    RGB = function(vals) -- converts: HSL to RGB (Red,Green,Blue) 
      local h,s,l,hdash = vals.h, vals.s / 100, vals.l / 100, vals.h / 60
      local chroma,r,g,b = (1 - math.abs((2 * l) - 1)) * s, 0,0,0 
      local x,min = chroma * (1.0 - math.abs((hdash % 2.0) - 1.0)), l - (0.5 * chroma) 
      if hdash < 1.0 then r,g = chroma,x elseif hdash < 2.0 then r,g = x,chroma
      elseif hdash < 3.0 then g,b = chroma,x elseif hdash < 4.0 then g,b = x,chroma 
      elseif hdash < 5.0 then r,b = x,chroma elseif hdash <= 6.0 then r,b = chroma,x end 
      vals.h,vals.s,vals.l,vals.r,vals.g,vals.b = nil,nil,nil, r + min, g + min, b + min
      vals.r,vals.g,vals.b = vals.r * 255, vals.g * 255, vals.b * 255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    HSV = function(vals) -- converts: HSL to HSV (Hue,Saturation,Value)
      local h,s,l,s1,v = vals.h,vals.s/100, vals.l/100; if l == 0 then h,s1,v = 0,0,0
      else l = l * 2; s = l <= 1 and s*l or s*(2 - l); v = (l+s)/2; s1 = (2*s)/(l+s) end
      vals.l,vals.h,vals.s,vals.v = nil, h, s1 * 100, v * 100 
    return vals end, -- returns: (table) HSV Values {h = ?, s = ?, v = ?}
    
    HSB = function(vals) -- converts: HSL to HSB (Hue,Saturation,Brightness)
      local h,s,l,s1,b = vals.h,vals.s/100, vals.l/100; if l == 0 then h,s1,b = 0,0,0
      else l = l * 2; s = l <= 1 and s*l or s*(2 - l); b = (l+s)/2; s1 = (2*s)/(l+s) end
      vals.l,vals.h,vals.s,vals.b = nil, h, s1 * 100, b * 100 
    return vals end, -- returns: (table) HSB Values {h = ?, s = ?, b = ?}
    
    HCG = function(vals) -- converts: HSL to HCG (Hue,Chroma,Greyscale)
      local s,l = vals.s/100, vals.l/100 local c = l < 0.5 and 2 * s * l or 2 * s * (1-l) 
      local g = c < 1 and (l - 0.5 * c) / (1 - c) or 0
      vals.s, vals.l, vals.g, vals.c = nil, nil, g * 100, c * 100
    return vals end -- returns: (table) HCG Values {h = ?, c = ?, g = ?}
    
  },  
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HSI = { -- Converts from HSI (Hue,Saturation,Intensity)
    
    RGB = function(vals) -- converts: HSI to RGB (Red,Green,Blue)
      local h,s,i = vals.h * (math.pi/180), vals.s/100, vals.i/100
      local r,g,b if h >= 0 and h < (2 * math.pi)/3 then b = i*(1 - s) 
        r = i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) g = (3 * i)-(b + r) 
      elseif h >= (2*math.pi)/3 and h < (4 * math.pi)/3 then h = h-((2*math.pi)/3) r = i*(1-s) 
        g = i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) b = (3 * i)-(r + g) 
      elseif h >= (4 * math.pi)/3 and h <= 2 * math.pi then h = h-((4*math.pi)/3) g = i*(1-s) 
      b =  i * (1+((s * math.cos(h))/math.cos((math.pi/3) - h))) r = (3 * i)-(g + b) end
      vals.h,vals.s,vals.i,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HWB = { -- Converts from HWB (Hue,Whiteness,Blackness)
    
    RGB = function(vals) -- converts: HWB to RGB (Red,Green,Blue)
      local h,w,b = vals.h/360, vals.w/100, vals.b/100 local ratio = w + b
      if ratio > 1 then b,w = b/ratio, w/ratio end local i,v = math.floor(6*h),1-b
      local f,r,g,b = 6 * h - i if i % 2 ~= 0 then f = 1 - f end local n = w + f * (v - w)
      r = (i == 0 or i == 5) and v or (i == 1 or i == 4) and n or (i == 2 or i == 3) and w 
      g = (i == 0 or i == 3) and n or (i == 1 or i == 2) and v or (i == 4 or i == 5) and w
      b = (i == 0 or i == 1) and w or (i == 2 or i == 5) and n or (i == 3 or i == 4) and v
      vals.h,vals.w,vals.r,vals.g,vals.b = nil,nil, r * 255, g * 255, b * 255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    HSV = function(vals) -- converts: HWB to HSV (Hue,Saturation,Value)
      local h,w,b = vals.h,vals.w/100,vals.b/100 local v = (-1*b) + 1 
      local s = (w == 0 or b == 1) and 0 or (1-(w/(1-b)))
      vals.w,vals.b,vals.h,vals.s,vals.v = nil,nil, h,s*100,v*100
    return vals end, -- returns: (table) HSV Values {h = ?, s = ?, v = ?}
    
    HSB = function(vals) -- converts: HWB to HSV (Hue,Saturation,Brightness)
      local h,w,b = vals.h,vals.w/100,vals.b/100 local v = (-1*b) + 1 
      local s = (w == 0 or b == 1) and 0 or (1-(w/(1-b)))
      vals.w,vals.h,vals.s,vals.b = nil, h,s*100,v*100
    return vals end -- returns: (table) HSB Values {h = ?, s = ?, b = ?}
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HCG = { -- Converts from HCG (Hue,Chroma,Greyscale)
    
    RGB = function(vals) -- converts: HCG to RGB (Red,Green,Blue)
      local h,c,g = vals.h/360,vals.c/100,vals.g/100 if c == 0 then 
      vals.h,vals.c,vals.r,vals.g,vals.b = nil,nil,g*255,g*255,g*255 return vals end
      local hi,mg,r,g,b = (h%1)*6,(1-c)*g local v,i = hi%1, math.floor(hi) local w = 1-v 
      r = i == 0 and 1 or i == 1 and w or (i == 2 or i == 3) and 0 or i == 4 and v or 1
      g = i == 0 and v or (i == 1 or i == 2) and 1 or i == 3 and w or 0
      b = (i == 0 or i == 1) and 0 or i == 2 and v or (i == 3 or i == 4) and 1 or w 
      vals.h,vals.c,vals.r,vals.g,vals.b = nil,nil,((c*r)+mg)*255,((c*g)+mg)*255,((c*b)+mg)*255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    HSV = function(vals) -- converts: HCG to HSV (Hue,Saturation,Value)
      local hue,c,g = vals.h,vals.c / 100,vals.g / 100 local vh,h,s,v = c+g*(1.0-c)
      vals.c,vals.g,vals.h,vals.s,vals.v = nil, nil, hue, (c/vh) * 100, vh * 100
    return vals end, -- returns: (table) HSV Values {h = ?, s = ?, v = ?}
    
    HSB = function(vals) -- converts: HCG to HSB (Hue,Saturation,Brightness)
      local hue,c,g = vals.h,vals.c / 100,vals.g / 100 local vh,h,s,b = c+g*(1.0-c)
      vals.c,vals.g,vals.h,vals.s,vals.b = nil, nil, hue, (c/vh) * 100, vh * 100
    return vals end, -- returns: (table) HSB Values {h = ?, s = ?, b = ?}
    
    HSL = function(vals) -- converts: HCG to HSL (Hue,Saturation,Lightness)
      local h,c,g = vals.h,vals.c / 100,vals.g / 100 local l,s = g*(1-c)+0.5*c,0
      if l < 1 and l > 0 then s = l < 0.5 and c/(2*l) or c/(2*(1-l)) end
      vals.c,vals.g,vals.h,vals.s,vals.l = nil, nil, h, s * 100, l * 100
    return vals end -- returns: (table) HSL Values {h = ?, s = ?, l = ?}
    
  },
  
  ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  -- TSL to RGB Conversion - port from: https://stackoverflow.com/questions/43696998/tsltorgb-colorspace-conversion
  
  TSL = { -- Converts from TSL (Tint,Saturation,Lightness)
    
    RGB = function(vals) -- Converts TSL to RGB (Red,Green,Blue)
      local t,s,l = vals.t/100, vals.s/100, vals.l/1 -- normalized properties
      if l == 0 then -- returns: (table) RGB Values {r = 0, g = 0, b = 0}
        vals.t,vals.s,vals.l,vals.r,vals.g,vals.b = nil,nil,nil,0,0,0 
      return vals end
      
      local r1,g1 if (1/t) == -math.huge then g1 = 0 r1 = -math.sqrt(5)/3*s
      elseif (1/t) == math.huge then g1 = 0 r1 = math.sqrt(5)/3*s
      else local x = -1.0 / math.tan(2* math.pi * t)   
        g1 = math.sqrt(5/(1 + x * x)) / 3.0 * s
        if t > 0.5 then g1 = -g1 end r1 = x * g1 end
      
      local r,g = r1 + 1.0/3, g1 + 1.0/3 local b = 1 - r - g
      local k = l / (0.185 * r + 0.473 * g + 0.114)
      vals.t,vals.s,vals.l,vals.r,vals.g,vals.b = nil,nil,nil,r * k, g * k, b * k
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  
  -- Fix Me!! -- November 14, 2017 BD
  
  HSM = { -- Converts from HSM (Hue,Saturation,Mixture)
    
    RGB = function(vals) -- Converts HSM to RGB (Red,Green,Blue)
      local h,s,m = vals.h / 360, vals.s / 100, vals.m / 100
      local r = (3/41) * s * math.cos(h) + m - ((4/861) * math.sqrt( ((861)*(s^2)) * (1 - pow(math.cos(h),2))))
      local g = ((math.sqrt(41)*s) * math.cos(h) + (23*m) - (19*r)) / 4
      local b = ((11*r) - (9*m) - (math.sqrt(41)*s) * math.cos(h))/2
      
      vals.h,vals.s,vals.m,vals.r,vals.g,vals.b = nil,nil,nil,r*255,g*255,b*255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  
  YUV = { -- Converts from YUV (Luma,Chroma Blue,Chroma Red)
    
    RGB = function(vals) -- converts: YUV to RGB (Red,Green,Blue)
      local y,u,v,max,min = vals.y/100, vals.u/100, vals.v/100, math.max, math.min
      local r = y + (v * (0.701 / 0.615))
      local g = y - (u * (0.101004 / 0.255932)) - (v * (0.209599 / 0.361005))
      local b = y + (u * (0.886 / 0.436))
      vals.y,vals.u,vals.v,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    --[[
    -- Fix Me!! - The scale factors are approximations and should be more precise
    YDbDr = function(vals) -- converts: YUV to YDbDr (Luminence,Chroma Blue,Chroma Red)
    local u,v = vals.u, vals.v
    vals.u,vals.v,vals.db,vals.dr = nil,nil, u * 3.0573448009416, -v * 2.1694966913406  
    return vals end -- returns: (table) YDbDr Values {y = ?, db = ?, dr = ?}
    --]]
    
  },
  
  ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  
  YCbCr601 = { -- Converts from YCbCr 601 (Luminence,Chroma Blue,Chroma Red)
    
    RGB = function(vals) -- converts: YCbCr 601 to RGB (Red,Green,Blue)
      local y,cb,cr,kR,kB = vals.y/100, vals.cb/100, vals.cr/100, 0.2990, 0.1146
      local r,b,g = cr * 2 * (1 - kR) + y, cb * 2 * (1 - kB) + y
      g = (y - (r * kR) - (b * kB)) / (1 - kR - kB)
      vals.y,vals.cb,vals.cr,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  YCbCr709 = { -- Converts from YCbCr 709 (Luminence,Chroma Blue,Chroma Red)
    
    RGB = function(vals) -- converts: YCbCr 709 to RGB (Red,Green,Blue)
      local y,cb,cr,kR,kB = vals.y/100, vals.cb/100, vals.cr/100, 0.2126, 0.0722 
      local r,b,g = cr * 2 * (1 - kR) + y, cb * 2 * (1 - kB) + y
      g = (y - (r * kR) - (b * kB)) / (1 - kR - kB)
      vals.y,vals.cb,vals.cr,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  YCbCr2020 = { -- Converts from YCbCr 2020 (Luminence,Chroma Blue,Chroma Red)
    
    RGB = function(vals) -- converts: YCbCr 2020 to RGB (Red,Green,Blue)
      local y,cb,cr,kR,kB = vals.y/100, vals.cb/100, vals.cr/100, 0.2627, 0.0593 
      local r,b,g = cr * 2 * (1 - kR) + y, cb * 2 * (1 - kB) + y
      g = (y - (r * kR) - (b * kB)) / (1 - kR - kB)
      vals.y,vals.cb,vals.cr,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  YCgCo = { -- Converts from YCgCo (Luminence,Chroma Green,Chroma Orange)
    
    RGB = function(vals) -- converts: YCgCo to RGB (Red,Green,Blue)
      local y,cg,co = vals.y/100,vals.cg/100,vals.co/100 
      local mod = y - cg local r,g,b = mod + co, y + cg, mod - co
      vals.y,vals.cg,vals.co,vals.r,vals.g,vals.b = nil,nil,nil, r * 255, g * 255, b * 255
    return vals end -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  YDbDr = { -- Converts from YDbDr (Luminence,Chroma Blue,Chroma Red)
    
    RGB = function(vals) -- converts: YDbDr to RGB (Red,Green,Blue)
      local y,db,dr,r,g,b = vals.y/100, vals.db/100, vals.dr/100
      r = y + 0.000092303716148 * db - 0.525912630661865 * dr;
      g = y - 0.129132898890509 * db + 0.267899328207599 * dr;
      b = y + 0.664679059978955 * db - 0.000079202543533 * dr;
      
      -- Values returned are clipped to 12 decimal places
      vals.y,vals.db,vals.dr = nil,nil,nil
      vals.r = math.floor(r * 255 * (10^12) + 0.5) / (10^12)
      vals.g = math.floor(g * 255 * (10^12) + 0.5) / (10^12)
      vals.b = math.floor(b * 255 * (10^12) + 0.5) / (10^12)
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    --[[
    -- Fix Me!! - The scale factors are approximations and should be more precise
    YUV = function(vals) -- converts: YDbDr to YUV (Luma,Chroma Blue,Chroma Red)
    local y,db,dr,r,g,b = vals.y, vals.db, vals.dr
    vals.db,vals.dr,vals.u,vals.v = nil,nil, db / 3.0573448009416, -dr / 2.1694966913406
    return vals end -- returns: (table) YUV Values {y = ?, u = ?, v = ?}
    --]]
    
  },
  
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  XYZ = { -- Converts from XYZ (X,Y,Z)
    
    RGB = function(vals) -- converts: XYZ to RGB (Red,Green,Blue)
      local x,y,z,pow,max,min = vals.x/100,vals.y/100,vals.z/100,pow,math.max,math.min
      r = (x * 3.240969941904521) + (y * -1.537383177570093) + (z * -0.498610760293);
      g = (x * -0.96924363628087) + (y * 1.87596750150772) + (z * 0.041555057407175);
      b = (x * 0.055630079696993) + (y * -0.20397695888897) + (z * 1.056971514242878);
      r = r > 0.0031308 and ((1.055 * pow(r, 1.0 / 2.4)) - 0.055) or (r * 12.92);
      g = g > 0.0031308 and ((1.055 * pow(g, 1.0 / 2.4)) - 0.055) or (g * 12.92);
      b = b > 0.0031308 and ((1.055 * pow(b, 1.0 / 2.4)) - 0.055) or (b * 12.92);
      r = min(max(0, r), 1); g = min(max(0, g), 1); b = min(max(0, b), 1);
      
      -- Values returned are clipped to 9 decimal places
      vals.x,vals.y,vals.z = nil,nil,nil
      vals.r = math.floor(r * 255 * (10^9) + 0.5) / (10^9)
      vals.g = math.floor(g * 255 * (10^9) + 0.5) / (10^9)
      vals.b = math.floor(b * 255 * (10^9) + 0.5) / (10^9)
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    
    LAB = function(vals) -- converts: XYZ to LAB [CIELAB] (Lightness,Green-Red,Blue-Yellow)
      local x,y,z,pow = vals.x/95.047,vals.y/100,vals.z/108.883, pow
      x = x > 0.008856 and pow(x, 1/3) or (7.787 * x) + (16 / 116)
      	 y = y > 0.008856 and pow(y, 1/3) or (7.787 * y) + (16 / 116)
      	 z = z > 0.008856 and pow(z, 1/3) or (7.787 * z) + (16 / 116)
      
      vals.x,vals.y,vals.z = nil,nil,nil 
      vals.l,vals.a,vals.b = (116 * y) - 16, 500 * (x - y), 200 * (y - z);
    return vals end, -- returns: (table) LAB Values {l = ?, a = ?, b = ?}
    
    
    LUV = function(vals) -- converts: XYZ to LUV [CIELUV] (Lightness,U,V)
      local x,y,z,pow = vals.x, vals.y, vals.z, pow
      local xn,yn,zn = 100,100,100 -- placeholder: see white levels
      local un,vn = (4 * xn) / (xn + (15 * yn) + (3 * zn)), (9 * yn) / (xn + (15 * yn) + (3 * zn));
      
      local k,e,yr = pow((29/3),3), pow((6/29),3),y / yn
      local l = yr <= e and k * yr or 116 * pow(yr, 1/3) - 16
      local _u = (4 * x) / (x + (15 * y) + (3 * z)) or 0
      	 local _v = (9 * y) / (x + (15 * y) + (3 * z)) or 0
      
      vals.x,vals.y,vals.z = nil,nil,nil 
      vals.l = yr <= e and k * yr or 116 * pow(yr, 1/3) - 16
      vals.u,vals.v = 13 * l * (_u - un), 13 * l * (_v - vn);
    return vals end, -- returns: (table) LUV Values {l = ?, u = ?, v = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  LAB = { -- Converts from LAB [CIELAB] (Lightness,Green-Red,Blue-Yellow)
    
    XYZ = function(vals) -- converts: LAB to XYZ (X,Y,Z)
      local l,a,b,pow = vals.l,vals.a,vals.b,pow
      local y,y2 if l <= 8 then y = (l*100) / 903.3; y2 = (7.787 * (y / 100)) + (16 / 116)
      else y = 100 * pow((l + 16) / 116, 3); y2 = pow(y / 100, 1/3) end
      local x,z = 100,100 -- Placeholder (see white points x and z)
      x = x / 95.047 <= 0.008856 and (95.047 * ((a / 500) + y2 - (16 / 116))) / 7.787 or 95.047 * pow((a / 500) + y2, 3);
      z = z / 108.883 <= 0.008859 and (108.883 * (y2 - (b / 200) - (16 / 116))) / 7.787 or 108.883 * pow(y2 - (b / 200), 3);
      vals.l,vals.a,vals.b,vals.x,vals.y,vals.z = nil,nil,nil,x,y,z
    return vals end, -- returns: (table) XYZ Values {x = ?, y = ?, z = ?}
    
    LCHab = function(vals) -- converts: LAB to LCHab (Lightness,Chroma,Hue)
      local a,b,atan2,sqrt = vals.a,vals.b,math.atan2,math.sqrt
      local hr = atan2(b,a) local h = hr * 360 / 2 / math.pi 
      local c = sqrt(a * a + b * b) if h < 0 then h = h + 360 end 
      vals.a,vals.b,vals.c,vals.h = nil,nil,c,h
    return vals end -- returns: (table) LCH Values {l = ?, c = ?, h = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  LUV = { -- Converts from LUV [CIELAB] (Lightness,U,V)
    
    XYZ = function(vals) -- converts: LUV to XYZ (X,Y,Z)
      local l,u,v,pow = vals.l,vals.u,vals.v,pow
      if l == 0 then -- returns: (table) XYZ Values {x = 0, y = 0, z = 0}
      vals.l,vals.u,vals.v,vals.x,vals.y,vals.z = nil,nil,nil,0,0,0 return vals end
      local xn,yn,zn = 100,100,100 -- placeholder: see white levels
      local un,vn = (4 * xn) / (xn + (15 * yn) + (3 * zn)), (9 * yn) / (xn + (15 * yn) + (3 * zn))
      local _u,_v = u / (13 * l) + un or 0, v / (13 * l) + vn or 0
      	 local y = l > 8 and yn * pow( (l + 16) / 116 , 3) or yn * l * k;
      
      vals.l,vals.u,vals.v = nil,nil,nil
      	 vals.y = l > 8 and yn * pow((l + 16)/116, 3) or yn * l * k;
      	 vals.x = y * 9 * _u / (4 * _v) or 0;
      	 vals.z = y * (12 - 3 * _u - 20 * _v) / (4 * _v) or 0;
    return vals end, -- returns: (table) XYZ Values {x = ?, y = ?, z = ?}
    
    LCHuv = function(vals) -- converts: LUV to LCHuv (Lightness,Chroma,Hue)
      local u,v,atan2,sqrt = vals.u,vals.v,math.atan2,math.sqrt
      local hr = atan2(v,u) local h = hr * 360 / 2 / math.pi 
      local c = sqrt(u * u + v * v) if h < 0 then h = h + 360 end 
      vals.u,vals.v,vals.c,vals.h = nil,nil,c,h
    return vals end -- returns: (table) LCH Values {l = ?, c = ?, h = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  LCHab = { -- Converts from LCHab (Lightness,Chroma,Hue)
    
    LAB = function(vals) -- convers: LCHab to LAB 
      local c,h,cos,sin = vals.c, vals.h, math.cos, math.sin
      local hr = h / 360 * 2 * math.pi
      vals.c,vals.h,vals.a, vals.b = nil,nil, c * cos(hr), c * sin(hr)
    return vals end -- returns: (table) LAB Values {l = ?, a = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  LCHuv = { -- Converts from LCHuv (Lightness,Chroma,Hue)
    
    LAB = function(vals) -- convers: LCHuv to LAB 
      local c,h,cos,sin = vals.c, vals.h, math.cos, math.sin
      local hr = h / 360 * 2 * math.pi
      vals.c,vals.h,vals.u, vals.v = nil,nil, c * cos(hr), c * sin(hr)
    return vals end -- returns: (table) LAB Values {l = ?, a = ?, b = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  CMY = { -- Concverts from CMY (Cyan,Magenta,Yellow)
    
    RGB = function(vals) -- converts: CMY to RGB (Red,Green,Blue)
      local c,m,y = vals.c/100,vals.m/100,vals.y/100 local r,g,b = (1-c),(1-m),(1-y)
      vals.c,vals.m,vals.y,vals.k,vals.r,vals.g,vals.b = nil,nil,nil,nil,r*255,g*255,b*255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    CMYK = function(vals) -- converts: CMY to CMYK (Cyan,Magenta,Yellow,Key/Black)
      local c,m,y = vals.c/100, vals.m/100, vals.y/100 -- normalized properties
      local k = math.min(c,m,y) c,m,y = (c-k)/(1-k),(m-k)/(1-k),(y-k)/(1-k)
      c,m,y,k = c ~= c and 0 or c, m ~= m and 0 or m, y ~= y and 0 or y, k ~= k and 0 or k
      vals.r,vals.g,vals.b,vals.c,vals.m,vals.y,vals.k = nil,nil,nil,c*100,m*100,y*100,k*100
    return vals end, -- returns: (table) CMYK Values {c = ?, m = ?, y = ?, k = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  CMYK = { -- Concverts from CMYK (Cyan,Magenta,Yellow,Key/Black)
    
    RGB = function(vals) -- converts: CMYK to RGB (Red,Green,Blue)
      local c,m,y,k = vals.c/100,vals.m/100,vals.y/100,vals.k/100
      local r,g,b = 1-math.min(1,c*(1-k)+k),1-math.min(1,m*(1-k)+k),1-math.min(1,y*(1-k)+k)   
      vals.c,vals.m,vals.y,vals.k,vals.r,vals.g,vals.b = nil,nil,nil,nil,r*255,g*255,b*255
    return vals end, -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
    CMY = function(vals) -- converts: CMYK to CMY (Cyan,Magenta,Yellow)
      local c,m,y,k = vals.c/100,vals.m/100,vals.y/100,vals.k/100
      c,m,y = math.min(1,c*(1-k)+k),math.min(1,m*(1-k)+k),math.min(1,y*(1-k)+k) 
      vals.k,vals.c,vals.m,vals.y = nil,c*100,m*100,y*100
    return vals end -- returns: (table) CMY Values {c = ?, m = ?, y = ?}
    
  },
  
  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  
  HEX = { -- Converts from HEX String (#FFFFFF) / (#FFF)
    
    RGB = function(str) -- converts: Hex (string) to RGB (Red,Green,Blue)
      
      if type(str) ~= "string" then
        error("Invalid argument 1 to color.convert.HEX.RGB. Expected (string) got ("..type(str)..").")
      return end 
      
      -- Removes pound sign if present
      if string.sub(str,1,1) == "#" then
        str = string.sub(str,2)
      end
      
      local out,value = {} 
      local count = #str
      local selector = (count == 6 or count == 8) and "(%x%x)" or (count == 3 or count == 4) and "(%x)"
      -- print("Failed here")
      --print(str)
      
      for entry in string.gmatch(str,selector) do 
        
        if count == 3 or count == 4 then
          entry = entry..entry
        end
        
        value = tonumber(entry,16) -- base 16 hex conversion
        
        if not out.r then out.r = value elseif not out.g then out.g = value 
        elseif not out.b then out.b = value 
        elseif not out.a then out.a = value end end 
      
    return out end  -- returns: (table) RGB Values {r = ?, g = ?, b = ?}
    
  },
  
}

---- ---- --- -- --- ---- ---- ---- --- -- 
------ ----- ----- ----- ----- ----- -----

-- Color Space Conversions - Alias Population

local function _populateConversions(lookup)
  local _aliases = {} for k,v in pairs(lookup) do if v._alias then local name 
      for i = 1, #v._alias do name = v._alias[i] 
        if type(name) == 'string' then _aliases[name] = k end end end end
  for k,v in pairs(_aliases) do color.convert[k] = color.convert[v] 
    	color.convert[v][k] = function(self) self._space = v return self end
    for a,b in pairs(color.convert) do if b[v] then b[k] = b[v] 
      end end end end

------ ----- ----- ----- ----- ----- ----- 

_populateConversions(colorData.spaces,color.convert) -- populate space aliases
_populateConversions(colorData.codecs,color.convert) -- populate extraSpace aliases

------ ----- ----- ----- ----- ----- ----- 

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ----

-- Color Object Utility Functions
      
color.tostring = function(self,opt)  
  return toStringHandlers.objects(self,opt)
end

--- --- --- ---- --- --- --- ---- --- ---
color.toString = color.tostring ----
--- --- --- ---- --- --- --- ---- --- ---

---- ----- ---- --- -- --- ---- ----- ---- ---
-- tostring helpers for color data printing

toStringHandlers = {
  
  ---- ------ ---- ------
  
  definitions = function(src,key,opt)
  
   local cat,sort = table.concat, table.sort
  
   return function()
      
    local defs = src
      
    if key == "CSS" or key == "css" then 
     defs = _getCSSColors() end
      
    local colorDefs,count = {}, 0
    for entry,_ in pairs(defs) do 
      local color = color(_.hex)
      
      table.insert(colorDefs,
      "\""..entry.."\": "..color:tostring("h").."")
      count = count + 1
      
    end
    
    local spacer = "  "
    
    local out = {"(["..key.."]:colors("..count..")): {"}
    
    sort(colorDefs)
    push(out,"\n"..spacer,cat(colorDefs,", \n"..spacer),"\n}")
    
   return cat(out) end
  
  end,
  
  ---- ------ ---- ------
  
  objects = function(self,opt) -- converts color object to string
    
    if not opt then opt = "v" end
    
    local format = type(opt)
    local isVertical = opt == "v" and true or opt == "h" and false or contains(opt,"v","vertical")
    local useOffsets = format == "table" and opt.offset == true and true or contains(opt,"o","offset")
    
    local insert,cat = table.insert, table.concat
    local meta = getmetatable(self); setmetatable(self,nil);
    
    local offset = string.match(tostring(self),"0x%x+")
    setmetatable(self,meta)
    
    local spacer = "\n  "
    local data,space = meta.data, meta.space
    local out = {"(color:("..space..")"}
    
    if useOffset then 
    push(out,": ",offset) end
    
    push(out,"): {")
    
    if isVertical then 
    push(out,spacer) end
    
    local colorSpaces, codecs = colorData.spaces, colorData.codecs
    
    local target,key = colorSpaces[space] or codecs[space] 
    
    for i = 1,#target do key = target[i][1] -- adds color channel keys to string
      
      if data[key] then 
        
        push(out, key, " = ", tostring(data[key]))
        
        if i ~= #target then 
          insert(out,", ")
          
          if isVertical then 
            push(out,spacer)
            
          end end
        
      end end
    
    push(out,", ",isVertical and spacer or "","hex = '", self.hex, "'")

    ---- -------- ---- 
    -- adds color names to color data
    
    local names = _getColorNames(self)
    if names then
     push(out,", ",isVertical and spacer or "","names = '[", cat(names,", "),"]'")
    end
    
    ---- -------- ---- 
    
    if data.alpha then   
      push(out,", ",isVertical and spacer or "","alpha = ",data.alpha)
    end
    
    push(out,opt == "v" and "\n" or "","}") 
    
    return cat(out) 
    
  end
}

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ----

----- ----------- ----------- -----------  
return color --> --- ---- -----
----- ----------- ----------- -----------  

----- ----------- ----------- ----------- ----------- 
-- {{ File End - color.lua }}
----- ----------- ----------- ----------- ----------- 