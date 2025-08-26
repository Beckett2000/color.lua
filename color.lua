-------------------------------------------
-- color.lua - 1.10(b) - (Beckett Dunning 2014 - 2025) - color conversion /  transformaion for Lua
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

-- This class converts between defined color spaces to manipulate color values and modulate channel levels. 

-- The Color Space converter converts colors between color spaces (HSI,HSV,HSL,RGB) and also between some experimental formats such as (YCbCr 601 and YCbCr 709). In addition to this, the function can also output and Input Hex strings for Color derivation. The function uses teo sub functions to perform conversions. RGB serves as the transient space, and one function converts colors to RGB while the other converts RGB to the other spaces. The usage description is below:

-- Supported Color Spaces : RGB | HSV / HSB | HSL | HSI | HWB | HSM | HCG | CMY | CMYK | TSL | YUV | YCbCr (601,709,2020) | YCgCo | YDbDr | XYZ | HEX | LAB | LUV | LCHab | LCHuv |

---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 

----- ----- ----- ----- ----- -----
-- if true then return end -- blocks the code from running
----- ----- ----- ----- ----- -----

local abs,acos,cos,sqrt,pi,pow,ceil,floor,toint,round,iter,push,contains = math.abs, math.acos, math.sqrt, math.cos, math.pi, math.pow, math.ceil, math.floor, math.toint

---- ---- ---- -- -- ---- ---- ---- --
local _color = color -- stores native color data (codea light userdata)
---- ---- ---- -- -- ---- ---- ---- --
-- local object = require(asset.object) -- dev dep (object.lua)
---- ---- ---- -- -- ---- ---- ---- --

local handleToString

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
    
    local _handleToString =  function(src)
      
      return function()
      
      --print(#source)
      local colorDefs,count = {}, 0
      for entry,_ in pairs(src) do 
        table.insert(colorDefs,
        "\""..entry.."\"")
        count = count + 1
        --output = output.."\""
        -- print("here")
      end
      
      local output = "[["..key.."]:colors("..count..")] {"
      
      table.sort(colorDefs)   
      output = output..
      table.concat(colorDefs,", " )
      output = output.."}"
      return output
      
    end end
    
    -------- ------ -------- ------ 

    
    -------- ------ -------- ------ 
    -- ::mark:: definedColors - creates / expands predefined color tags into color objects
    
    local definedColors = colorData.definedColors
        
    local source = definedColors.dictionaries and definedColors.dictionaries[key]
    
    if source then
    
      if key == "HTML" or key == "SVG" or key == "x11" then

       local definitionTable = {}
                
       local meta = {
                    
        __index = function(self,key) 
                        
         print("inside color index")

         if source[key] then 
          return function()
           -- print("What is the color object:",object.toString(color))
           local rgb = source[key].rgb
                                  
          return 
                    
          color(table.unpack(rgb)) 
                
          end end end,       
      
        __tostring = _handleToString(source) 
      }
                
       setmetatable(definitionTable,meta)
       return definitionTable
                
     end
            
      --------------
            
      local spaceCSS = key == "CSS"   
      	local definitionTable = {} setmetatable(definitionTable, {
        
        __index = function(dataStore,key) 
          local data = source[key]
          
          -- CSS color expansion
          if spaceCSS then
            local cssSpace = self("RGB",data[key].rgb) 
            
            local meta = getmetatable(cssSpace)
            local level = data
            
            return cssSpace
          end
          
          if data then  
            return self("RGB",data.rgb)
          end
          
        end,
        
        -- toString for predefined colors
        __tostring = _handleToString(source),
        
      })
      
    return definitionTable end -- returns: pointer to creation table
        
    
    -------- ------ -------- ------
    
    if colorData.spaces[key] or colorData.codecs[key] then 
      --local color = color and color or self
      
      -- handles color constructor indexing col.HSV(...) -> col("HSV",...)
      	return function(...)  
        -- print("Got to here: ",key)
      return self(key,...) end end end,
  
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
      
      __tostring = handleToString, -- (tostring(object)) - converts color object to string
        
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
  return handleToString(self,opt)
end

--- --- --- ---- --- --- --- ---- --- ---
color.toString = color.tostring ----
--- --- --- ---- --- --- --- ---- --- ---

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ----

-- tostring helpers for color data printing

handleToString = function(self,opt) -- converts color object to string

  if not opt then opt = "v" end
  
  local format = type(opt)
  local isVertical = opt == "v" and true or opt == "h" and false or contains(opt,"v","vertical")
  local useOffsets = format == "table" and opt.offset == true and true or contains(opt,"o","offset")

  local insert,cat = table.insert, table.concat
  local meta = getmetatable(self); setmetatable(self,nil);
  
  local offset = string.match(tostring(self),"0x%x+")
  setmetatable(self,meta)
  
  local spacer = "  "
  local data,space = meta.data, meta.space
  local out = {"(color:("..space..")"}
    
  if useOffset then 
   push(out,": ",offset) end
 
  push(out,"): {")
  
  if isVertical then 
   push(out,"\n",spacer) end
  
  local colorSpaces, codecs = colorData.spaces, colorData.codecs
  
  local target,key = colorSpaces[space] or codecs[space] 
  
  for i = 1,#target do key = target[i][1] -- adds color channel keys to string
    
    if data[key] then 

     push(out, key, " = ", tostring(data[key]))
      
     if i ~= #target then 
      insert(out,", ")
        
     if isVertical then 
       push(out,"\n",spacer)
          
    end end
      
  end end

  push(out,", \n",isVertical and spacer or "","hex = '", self.hex, "'")
  
  if data.alpha then   
   push(out,", \n",isVertical and spacer or "","alpha = ",data.alpha)
  end

  push(out,opt == "v" and "\n" or "","}") 

  return cat(out) 

end

---- ----- ---- --- -- --- ---- ----- ---- --- -- --- ---- ----- ----

---------- ---------- ---------- ----------

-- ::mark:: definedColors - The defined colors section contains the names, color channels, and hexidecimal representations of color names in various standards. Currently supports HTML, SVG, and x11. WIP 
-- Note: There are also color groupings in the CSS key, but this may be removed / changed in the future as it is basically just a filtered version of SVG colors.

---------- ---------- ---------- ---------- 

definedColors = {

  ------- -------- --------
  -- Dictionary lookups for colors defined in various standards
  ------- -------- --------
  
dictionaries = { 
  
    ------------ ------------ 
    HTML = { -- (case insensitive)
      
      BLACK = {
        ["rgb"] = {0,0,0},
        ["hex"] = "#000000"}, 
      SILVER = {
        ["rgb"] = {192,192,192},
        ["hex"] = "#C0C0C0"}, 
      GRAY = {
        ["rgb"] = {128,128,128},
        ["hex"] = "#808080"}, 
      WHITE = {
        ["rgb"] = {255,255,255},
        ["hex"] = "#FFFFFF"}, 
      MAROON = {
        ["rgb"] = {128,0,0},
        ["hex"] = "#800000"}, 
      RED = {
        ["rgb"] = {255,0,0},
        ["hex"] = "#FF0000"}, 
      PURPLE = {
        ["rgb"] = {128,0,128},
        ["hex"] = "#800080"}, 
      FUCHSIA = {
        ["rgb"] = {255,0,255},
        ["hex"] = "#FF00FF"}, 
      GREEN = {
        ["rgb"] = {0,128,0},
        ["hex"] = "#008000"}, 
      LIME = {
        ["rgb"] = {0,255,0},
        ["hex"] = "#00FF00"}, 
      OLIVE = {
        ["rgb"] = {128,128,0},
        ["hex"] = "#808000"}, 
      YELLOW = {
        ["rgb"] = {255,255,0},
        ["hex"] = "#FFFF00"}, 
      NAVY = {
        ["rgb"] = {0,0,128},
        ["hex"] = "#000080"}, 
      BLUE = {
        ["rgb"] = {0,0,255},
        ["hex"] = "#0000FF"}, 
      TEAL = {
        ["rgb"] = {0,128,128},
        ["hex"] = "#008080"}, 
      AQUA = {
        ["rgb"] = {0,255,255},
        ["hex"] = "#00FFFF"}  
    },
    
    ------------ ------------  
    -- https://www.rapidtables.com/web/css/css-color.html
    ------------ ------------  
    
    CSS = { -- CSS color names (from SVG)
      
      red = {
        
        lightsalmon = {
          ["rgb"] = {255,160,122}, 
          ["hex"] = "#FFA07A"},
        salmon = {
          ["rgb"] = {250,128,114}, 
          ["hex"] = "#FA8072"},
        darksalmon = {
          ["rgb"] = {233,150,122}, 
          ["hex"] = "#E9967A"},
        lightcoral = {
          ["rgb"] = {240,128,128}, 
          ["hex"] = "#F08080"},
        indianred = {
          ["rgb"] = {205,92,92}, 
          ["hex"] = "#CD5C5C"},
        crimson = {
          ["rgb"] = {220,20,60}, 
          ["hex"] = "#DC143C"},
        firebrick = {
          ["rgb"] = {178,34,34}, 
          ["hex"] = "#B22222"},
        red = {
          ["rgb"] = {255,0,0}, 
          ["hex"] = "#FF0000"},
        darkred = {
          ["rgb"] = {139,0,0}, 
          ["hex"] = "#8B0000"}
        
      },
      
      orange = {
        
        coral = {
          ["rgb"] = {255,127,80}, 
          ["hex"] = "#FF7F50"},
        tomato = {
          ["rgb"] = {255,99,71}, 
          ["hex"] = "#FF6347"},
        orangered = {
          ["rgb"] = {255,69,0}, 
          ["hex"] = "#FF4500"},
        gold = {
          ["rgb"] = {255,215,0}, 
          ["hex"] = "#FFD700"},
        orange = {
          ["rgb"] = {255,165,0}, 
          ["hex"] = "#FFA500"},
        darkorange = {
          ["rgb"] = {255,140,0}, 
          ["hex"] = "#FF8C00"}
        
      },
      
      yellow = {
        
        lightyellow = {
          ["rgb"] = {255,255,224}, 
          ["hex"] = "#FFFFE0"},
        lemonchiffon = {
          ["rgb"] = {255,250,205}, 
          ["hex"] = "#FFFACD"},
        lightgoldenrodyellow = {
          ["rgb"] = {250,250,210}, 
          ["hex"] = "#FAFAD2"},
        papayawhip = {
          ["rgb"] = {255,239,213}, 
          ["hex"] = "#FFEFD5"},
        moccasin = {
          ["rgb"] = {255,228,181}, 
          ["hex"] = "#FFE4B5"},
        peachpuff = {
          ["rgb"] = {255,218,185}, 
          ["hex"] = "#FFDAB9"},
        palegoldenrod = {
          ["rgb"] = {238,232,170}, 
          ["hex"] = "#EEE8AA"},
        khaki = {
          ["rgb"] = {240,230,140}, 
          ["hex"] = "#F0E68C"},
        darkkhaki = {
          ["rgb"] = {189,183,107}, 
          ["hex"] = "#BDB76B"},
        yellow = {
          ["rgb"] = {255,255,0}, 
          ["hex"] = "#FFFF00"}
      },
      
      green = {
        
        lawngreen = {
          ["rgb"] = {124,252,0}, 
          ["hex"] = "#7CFC00"},
        chartreuse = {
          ["rgb"] = {127,255,0}, 
          ["hex"] = "#7FFF00"},
        limegreen = {
          ["rgb"] = {50,205,50}, 
          ["hex"] = "#32CD32"},
        lime = {
          ["rgb"] = {0,255,0}, 
          ["hex"] = "#00FF00"},
        forestgreen = {
          ["rgb"] = {34,139,34}, 
          ["hex"] = "#228B22"},
        green = {
          ["rgb"] = {0,128,0}, 
          ["hex"] = "#008000"},
        darkgreen = {
          ["rgb"] = {0,100,0}, 
          ["hex"] = "#006400"},
        greenyellow = {
          ["rgb"] = {173,255,47}, 
          ["hex"] = "#ADFF2F"},
        yellowgreen = {
          ["rgb"] = {154,205,50}, 
          ["hex"] = "#9ACD32"},
        springgreen = {
          ["rgb"] = {0,255,127}, 
          ["hex"] = "#00FF7F"},
        mediumspringgreen = {
          ["rgb"] = {0,250,154}, 
          ["hex"] = "#00FA9A"},
        lightgreen = {
          ["rgb"] = {144,238,144}, 
          ["hex"] = "#90EE90"},
        palegreen = {
          ["rgb"] = {152,251,152}, 
          ["hex"] = "#98FB98"},
        darkseagreen = {
          ["rgb"] = {143,188,143}, 
          ["hex"] = "#8FBC8F"},
        mediumseagreen = {
          ["rgb"] = {60,179,113}, 
          ["hex"] = "#3CB371"},
        seagreen = {
          ["rgb"] = {46,139,87}, 
          ["hex"] = "#2E8B57"},
        olive = {
          ["rgb"] = {128,128,0}, 
          ["hex"] = "#808000"},
        darkolivegreen = {
          ["rgb"] = {85,107,47}, 
          ["hex"] = "#556B2F"},
        olivedrab = {
          ["rgb"] = {107,142,35}, 
          ["hex"] = "#6B8E23"}
      },
      
      cyan = {
        
        lightcyan = {
          ["rgb"] = {224,255,255}, 
          ["hex"] = "#E0FFFF"},
        cyan = {
          ["rgb"] = {0,255,255}, 
          ["hex"] = "#00FFFF"},
        aqua = {
          ["rgb"] = {0,255,255}, 
          ["hex"] = "#00FFFF"},
        aquamarine = {
          ["rgb"] = {127,255,212}, 
          ["hex"] = "#7FFFD4"},
        mediumaquamarine = {
          ["rgb"] = {102,205,170}, 
          ["hex"] = "#66CDAA"},
        paleturquoise = {
          ["rgb"] = {175,238,238}, 
          ["hex"] = "#AFEEEE"},
        turquoise = {
          ["rgb"] = {64,224,208}, 
          ["hex"] = "#40E0D0"},
        mediumturquoise = {
          ["rgb"] = {72,209,204}, 
          ["hex"] = "#48D1CC"},
        darkturquoise = {
          ["rgb"] = {0,206,209}, 
          ["hex"] = "#00CED1"},
        lightseagreen = {
          ["rgb"] = {32,178,170}, 
          ["hex"] = "#20B2AA"},
        cadetblue = {
          ["rgb"] = {95,158,160}, 
          ["hex"] = "#5F9EA0"},
        darkcyan = {
          ["rgb"] = {0,139,139}, 
          ["hex"] = "#008B8B"},
        teal = {
          ["rgb"] = {0,128,128}, 
          ["hex"] = "#008080"}
      },
      
      blue = {
        
        powderblue = {
          ["rgb"] = {176,224,230}, 
          ["hex"] = "#B0E0E6"},
        lightblue = {
          ["rgb"] = {173,216,230}, 
          ["hex"] = "#ADD8E6"},
        lightskyblue = {
          ["rgb"] = {135,206,250}, 
          ["hex"] = "#87CEFA"},
        skyblue = {
          ["rgb"] = {135,206,235}, 
          ["hex"] = "#87CEEB"},
        deepskyblue = {
          ["rgb"] = {0,191,255}, 
          ["hex"] = "#00BFFF"},
        lightsteelblue = {
          ["rgb"] = {176,196,222}, 
          ["hex"] = "#B0C4DE"},
        dodgerblue = {
          ["rgb"] = {30,144,255}, 
          ["hex"] = "#1E90FF"},
        cornflowerblue = {
          ["rgb"] = {100,149,237}, 
          ["hex"] = "#6495ED"},
        steelblue = {
          ["rgb"] = {70,130,180}, 
          ["hex"] = "#4682B4"},
        royalblue = {
          ["rgb"] = {65,105,225}, 
          ["hex"] = "#4169E1"},
        blue = {
          ["rgb"] = {0,0,255}, 
          ["hex"] = "#0000FF"},
        mediumblue = {
          ["rgb"] = {0,0,205}, 
          ["hex"] = "#0000CD"},
        darkblue = {
          ["rgb"] = {0,0,139}, 
          ["hex"] = "#00008B"},
        navy = {
          ["rgb"] = {0,0,128}, 
          ["hex"] = "#000080"},
        midnightblue = {
          ["rgb"] = {25,25,112}, 
          ["hex"] = "#191970"},
        mediumslateblue = {
          ["rgb"] = {123,104,238}, 
          ["hex"] = "#7B68EE"},
        slateblue = {
          ["rgb"] = {106,90,205}, 
          ["hex"] = "#6A5ACD"},
        darkslateblue = {
          ["rgb"] = {72,61,139}, 
          ["hex"] = "#483D8B"}
      },
      
      purple = {
        
        lavender = {
          ["rgb"] = {230,230,250}, 
          ["hex"] = "#E6E6FA"},
        thistle = {
          ["rgb"] = {216,191,216}, 
          ["hex"] = "#D8BFD8"},
        plum = {
          ["rgb"] = {221,160,221}, 
          ["hex"] = "#DDA0DD"},
        violet = {
          ["rgb"] = {238,130,238}, 
          ["hex"] = "#EE82EE"},
        orchid = {
          ["rgb"] = {218,112,214}, 
          ["hex"] = "#DA70D6"},
        fuchsia = {
          ["rgb"] = {255,0,255}, 
          ["hex"] = "#FF00FF"},
        magenta = {
          ["rgb"] = {255,0,255}, 
          ["hex"] = "#FF00FF"},
        mediumorchid = {
          ["rgb"] = {186,85,211}, 
          ["hex"] = "#BA55D3"},
        mediumpurple = {
          ["rgb"] = {147,112,219}, 
          ["hex"] = "#9370DB"},
        blueviolet = {
          ["rgb"] = {138,43,226}, 
          ["hex"] = "#8A2BE2"},
        darkviolet = {
          ["rgb"] = {148,0,211}, 
          ["hex"] = "#9400D3"},
        darkorchid = {
          ["rgb"] = {153,50,204}, 
          ["hex"] = "#9932CC"},
        darkmagenta = {
          ["rgb"] = {139,0,139}, 
          ["hex"] = "#8B008B"},
        purple = {
          ["rgb"] = {128,0,128}, 
          ["hex"] = "#800080"},
        indigo = {
          ["rgb"] = {75,0,130}, 
          ["hex"] = "#4B0082"}
      },
      
      pink = {
        
        pink = {
          ["rgb"] = {255,192,203}, 
          ["hex"] = "#FFC0CB"},
        lightpink = {
          ["rgb"] = {255,182,193}, 
          ["hex"] = "#FFB6C1"},
        hotpink = {
          ["rgb"] = {255,105,180}, 
          ["hex"] = "#FF69B4"},
        deeppink = {
          ["rgb"] = {255,20,147}, 
          ["hex"] = "#FF1493"},
        palevioletred = {
          ["rgb"] = {219,112,147}, 
          ["hex"] = "#DB7093"},
        mediumvioletred = {
          ["rgb"] = {199,21,133}, 
          ["hex"] = "#C71585"}
        
      },
      
      white = {
        
        white = {
          ["rgb"] = {255,255,255}, 
          ["hex"] = "#FFFFFF"},
        snow = {
          ["rgb"] = {255,250,250}, 
          ["hex"] = "#FFFAFA"},
        honeydew = {
          ["rgb"] = {240,255,240}, 
          ["hex"] = "#F0FFF0"},
        mintcream = {
          ["rgb"] = {245,255,250}, 
          ["hex"] = "#F5FFFA"},
        azure = {
          ["rgb"] = {240,255,255}, 
          ["hex"] = "#F0FFFF"},
        aliceblue = {
          ["rgb"] = {240,248,255}, 
          ["hex"] = "#F0F8FF"},
        ghostwhite = {
          ["rgb"] = {248,248,255}, 
          ["hex"] = "#F8F8FF"},
        whitesmoke = {
          ["rgb"] = {245,245,245}, 
          ["hex"] = "#F5F5F5"},
        seashell = {
          ["rgb"] = {255,245,238}, 
          ["hex"] = "#FFF5EE"},
        beige = {
          ["rgb"] = {245,245,220}, 
          ["hex"] = "#F5F5DC"},
        oldlace = {
          ["rgb"] = {253,245,230}, 
          ["hex"] = "#FDF5E6"},
        floralwhite = {
          ["rgb"] = {255,250,240}, 
          ["hex"] = "#FFFAF0"},
        ivory = {
          ["rgb"] = {255,255,240}, 
          ["hex"] = "#FFFFF0"},
        antiquewhite = {
          ["rgb"] = {250,235,215}, 
          ["hex"] = "#FAEBD7"},
        linen = {
          ["rgb"] = {250,240,230}, 
          ["hex"] = "#FAF0E6"},
        lavenderblush = {
          ["rgb"] = {255,240,245}, 
          ["hex"] = "#FFF0F5"},
        mistyrose = {
          ["rgb"] = {255,228,225}, 
          ["hex"] = "#FFE4E1"}
      },
      
      gray = {
        
        gainsboro = {
          ["rgb"] = {220,220,220}, 
          ["hex"] = "#DCDCDC"},
        lightgray = {
          ["rgb"] = {211,211,211}, 
          ["hex"] = "#D3D3D3"},
        silver = {
          ["rgb"] = {192,192,192}, 
          ["hex"] = "#C0C0C0"},
        darkgray = {
          ["rgb"] = {169,169,169}, 
          ["hex"] = "#A9A9A9"},
        gray = {
          ["rgb"] = {128,128,128}, 
          ["hex"] = "#808080"},
        dimgray = {
          ["rgb"] = {105,105,105}, 
          ["hex"] = "#696969"},
        lightslategray = {
          ["rgb"] = {119,136,153}, 
          ["hex"] = "#778899"},
        slategray = {
          ["rgb"] = {112,128,144}, 
          ["hex"] = "#708090"},
        darkslategray = {
          ["rgb"] = {47,79,79}, 
          ["hex"] = "#2F4F4F"},
        black = {
          ["rgb"] = {0,0,0}, 
          ["hex"] = "#000000"}
      },
      
      brown = {
        
        cornsilk = {
          ["rgb"] = {255,248,220}, 
          ["hex"] = "#FFF8DC"},
        blanchedalmond = {
          ["rgb"] = {255,235,205}, 
          ["hex"] = "#FFEBCD"},
        bisque = {
          ["rgb"] = {255,228,196}, 
          ["hex"] = "#FFE4C4"},
        navajowhite = {
          ["rgb"] = {255,222,173}, 
          ["hex"] = "#FFDEAD"},
        wheat = {
          ["rgb"] = {245,222,179}, 
          ["hex"] = "#F5DEB3"},
        burlywood = {
          ["rgb"] = {222,184,135}, 
          ["hex"] = "#DEB887"},
        tan = {
          ["rgb"] = {210,180,140}, 
          ["hex"] = "#D2B48C"},
        rosybrown = {
          ["rgb"] = {188,143,143}, 
          ["hex"] = "#BC8F8F"},
        sandybrown = {
          ["rgb"] = {244,164,96}, 
          ["hex"] = "#F4A460"},
        goldenrod = {
          ["rgb"] = {218,165,32}, 
          ["hex"] = "#DAA520"},
        peru = {
          ["rgb"] = {205,133,63}, 
          ["hex"] = "#CD853F"},
        chocolate = {
          ["rgb"] = {210,105,30}, 
          ["hex"] = "#D2691E"},
        saddlebrown = {
          ["rgb"] = {139,69,19}, 
          ["hex"] = "#8B4513"}
      }
      
    },

    ------------ ------------ 
    SVG = { -- SVG 1.0 color keyword names
      
      aliceblue = {
        ["rgb"] = {240,248,255},
        ["hex"] = "#F0F8FF"}, 
      antiquewhite = {
        ["rgb"] = {250,235,215},
        ["hex"] = "#FAEBD7"}, 
      aqua = {
        ["rgb"] = {0,255,255},
        ["hex"] = "#00FFFF"}, 
      aquamarine = {
        ["rgb"] = {127,255,212},
        ["hex"] = "#7FFFD4"}, 
      azure = {
        ["rgb"] = {240,255,255},
        ["hex"] = "#F0FFFF"}, 
      beige = {
        ["rgb"] = {245,245,220},
        ["hex"] = "#F5F5DC"}, 
      bisque = {
        ["rgb"] = {255,228,196},
        ["hex"] = "#FFE4C4"}, 
      black = {
        ["rgb"] = {0,0,0},
        ["hex"] = "#000000"}, 
      blanchedalmond = {
        ["rgb"] = {255,235,205},
        ["hex"] = "#FFEBCD"}, 
      blue = {
        ["rgb"] = {0,0,255},
        ["hex"] = "#0000FF"}, 
      blueviolet = {
        ["rgb"] = {138,43,226},
        ["hex"] = "#8A2BE2"}, 
      brown = {
        ["rgb"] = {165,42,42},
        ["hex"] = "#A52A2A"}, 
      burlywood = {
        ["rgb"] = {222,184,135},
        ["hex"] = "#DEB887"}, 
      cadetblue = {
        ["rgb"] = {95,158,160},
        ["hex"] = "#5F9EA0"}, 
      chartreuse = {
        ["rgb"] = {127,255,0},
        ["hex"] = "#7FFF00"}, 
      chocolate = {
        ["rgb"] = {210,105,30},
        ["hex"] = "#D2691E"}, 
      coral = {
        ["rgb"] = {255,127,80},
        ["hex"] = "#FF7F50"}, 
      cornflowerblue = {
        ["rgb"] = {100,149,237},
        ["hex"] = "#6495ED"}, 
      cornsilk = {
        ["rgb"] = {255,248,220},
        ["hex"] = "#FFF8DC"}, 
      crimson = {
        ["rgb"] = {220,20,60},
        ["hex"] = "#DC143C"}, 
      cyan = {
        ["rgb"] = {0,255,255},
        ["hex"] = "#00FFFF"}, 
      darkblue = {
        ["rgb"] = {0,0,139},
        ["hex"] = "#00008B"}, 
      darkcyan = {
        ["rgb"] = {0,139,139},
        ["hex"] = "#008B8B"}, 
      darkgoldenrod = {
        ["rgb"] = {184,134,11},
        ["hex"] = "#B8860B"}, 
      darkgray = {
        ["rgb"] = {169,169,169},
        ["hex"] = "#A9A9A9"}, 
      darkgreen = {
        ["rgb"] = {0,100,0},
        ["hex"] = "#006400"}, 
      darkgrey = {
        ["rgb"] = {169,169,169},
        ["hex"] = "#A9A9A9"}, 
      darkkhaki = {
        ["rgb"] = {189,183,107},
        ["hex"] = "#BDB76B"}, 
      darkmagenta = {
        ["rgb"] = {139,0,139},
        ["hex"] = "#8B008B"}, 
      darkolivegreen = {
        ["rgb"] = {85,107,47},
        ["hex"] = "#556B2F"}, 
      darkorange = {
        ["rgb"] = {255,140,0},
        ["hex"] = "#FF8C00"}, 
      darkorchid = {
        ["rgb"] = {153,50,204},
        ["hex"] = "#9932CC"}, 
      darkred = {
        ["rgb"] = {139,0,0},
        ["hex"] = "#8B0000"}, 
      darksalmon = {
        ["rgb"] = {233,150,122},
        ["hex"] = "#E9967A"}, 
      darkseagreen = {
        ["rgb"] = {143,188,143},
        ["hex"] = "#8FBC8F"}, 
      darkslateblue = {
        ["rgb"] = {72,61,139},
        ["hex"] = "#483D8B"}, 
      darkslategray = {
        ["rgb"] = {47,79,79},
        ["hex"] = "#2F4F4F"}, 
      darkslategrey = {
        ["rgb"] = {47,79,79},
        ["hex"] = "#2F4F4F"}, 
      darkturquoise = {
        ["rgb"] = {0,206,209},
        ["hex"] = "#00CED1"}, 
      darkviolet = {
        ["rgb"] = {148,0,211},
        ["hex"] = "#9400D3"}, 
      deeppink = {
        ["rgb"] = {255,20,147},
        ["hex"] = "#FF1493"}, 
      deepskyblue = {
        ["rgb"] = {0,191,255},
        ["hex"] = "#00BFFF"}, 
      dimgray = {
        ["rgb"] = {105,105,105},
        ["hex"] = "#696969"}, 
      dimgrey = {
        ["rgb"] = {105,105,105},
        ["hex"] = "#696969"}, 
      dodgerblue = {
        ["rgb"] = {30,144,255},
        ["hex"] = "#1E90FF"}, 
      firebrick = {
        ["rgb"] = {178,34,34},
        ["hex"] = "#B22222"}, 
      floralwhite = {
        ["rgb"] = {255,250,240},
        ["hex"] = "#FFFAF0"}, 
      forestgreen = {
        ["rgb"] = {34,139,34},
        ["hex"] = "#228B22"}, 
      fuchsia = {
        ["rgb"] = {255,0,255},
        ["hex"] = "#FF00FF"}, 
      gainsboro = {
        ["rgb"] = {220,220,220},
        ["hex"] = "#DCDCDC"}, 
      ghostwhite = {
        ["rgb"] = {248,248,255},
        ["hex"] = "#F8F8FF"}, 
      gold = {
        ["rgb"] = {255,215,0},
        ["hex"] = "#FFD700"}, 
      goldenrod = {
        ["rgb"] = {218,165,32},
        ["hex"] = "#DAA520"}, 
      gray = {
        ["rgb"] = {128,128,128},
        ["hex"] = "#808080"}, 
      green = {
        ["rgb"] = {0,128,0},
        ["hex"] = "#008000"}, 
      greenyellow = {
        ["rgb"] = {173,255,47},
        ["hex"] = "#ADFF2F"}, 
      grey = {
        ["rgb"] = {128,128,128},
        ["hex"] = "#808080"}, 
      honeydew = {
        ["rgb"] = {240,255,240},
        ["hex"] = "#F0FFF0"}, 
      hotpink = {
        ["rgb"] = {255,105,180},
        ["hex"] = "#FF69B4"}, 
      indianred = {
        ["rgb"] = {205,92,92},
        ["hex"] = "#CD5C5C"}, 
      indigo = {
        ["rgb"] = {75,0,130},
        ["hex"] = "#4B0082"}, 
      ivory = {
        ["rgb"] = {255,255,240},
        ["hex"] = "#FFFFF0"}, 
      khaki = {
        ["rgb"] = {240,230,140},
        ["hex"] = "#F0E68C"}, 
      lavender = {
        ["rgb"] = {230,230,250},
        ["hex"] = "#E6E6FA"}, 
      lavenderblush = {
        ["rgb"] = {255,240,245},
        ["hex"] = "#FFF0F5"}, 
      lawngreen = {
        ["rgb"] = {124,252,0},
        ["hex"] = "#7CFC00"}, 
      lemonchiffon = {
        ["rgb"] = {255,250,205},
        ["hex"] = "#FFFACD"}, 
      lightblue = {
        ["rgb"] = {173,216,230},
        ["hex"] = "#ADD8E6"}, 
      lightcoral = {
        ["rgb"] = {240,128,128},
        ["hex"] = "#F08080"}, 
      lightcyan = {
        ["rgb"] = {224,255,255},
        ["hex"] = "#E0FFFF"}, 
      lightgoldenrodyellow = {
        ["rgb"] = {250,250,210},
        ["hex"] = "#FAFAD2"}, 
      lightgray = {
        ["rgb"] = {211,211,211},
        ["hex"] = "#D3D3D3"}, 
      lightgreen = {
        ["rgb"] = {144,238,144},
        ["hex"] = "#90EE90"}, 
      lightgrey = {
        ["rgb"] = {211,211,211},
        ["hex"] = "#D3D3D3"}, 
      lightpink = {
        ["rgb"] = {255,182,193},
        ["hex"] = "#FFB6C1"}, 
      lightsalmon = {
        ["rgb"] = {255,160,122},
        ["hex"] = "#FFA07A"}, 
      lightseagreen = {
        ["rgb"] = {32,178,170},
        ["hex"] = "#20B2AA"}, 
      lightskyblue = {
        ["rgb"] = {135,206,250},
        ["hex"] = "#87CEFA"}, 
      lightslategray = {
        ["rgb"] = {119,136,153},
        ["hex"] = "#778899"}, 
      lightslategrey = {
        ["rgb"] = {119,136,153},
        ["hex"] = "#778899"}, 
      lightsteelblue = {
        ["rgb"] = {176,196,222},
        ["hex"] = "#B0C4DE"}, 
      lightyellow = {
        ["rgb"] = {255,255,224},
        ["hex"] = "#FFFFE0"}, 
      lime = {
        ["rgb"] = {0,255,0},
        ["hex"] = "#00FF00"}, 
      limegreen = {
        ["rgb"] = {50,205,50},
        ["hex"] = "#32CD32"}, 
      linen = {
        ["rgb"] = {250,240,230},
        ["hex"] = "#FAF0E6"}, 
      magenta = {
        ["rgb"] = {255,0,255},
        ["hex"] = "#FF00FF"}, 
      maroon = {
        ["rgb"] = {128,0,0},
        ["hex"] = "#800000"}, 
      mediumaquamarine = {
        ["rgb"] = {102,205,170},
        ["hex"] = "#66CDAA"}, 
      mediumblue = {
        ["rgb"] = {0,0,205},
        ["hex"] = "#0000CD"}, 
      mediumorchid = {
        ["rgb"] = {186,85,211},
        ["hex"] = "#BA55D3"}, 
      mediumpurple = {
        ["rgb"] = {147,112,219},
        ["hex"] = "#9370DB"}, 
      mediumseagreen = {
        ["rgb"] = {60,179,113},
        ["hex"] = "#3CB371"}, 
      mediumslateblue = {
        ["rgb"] = {123,104,238},
        ["hex"] = "#7B68EE"}, 
      mediumspringgreen = {
        ["rgb"] = {0,250,154},
        ["hex"] = "#00FA9A"}, 
      mediumturquoise = {
        ["rgb"] = {72,209,204},
        ["hex"] = "#48D1CC"}, 
      mediumvioletred = {
        ["rgb"] = {199,21,133},
        ["hex"] = "#C71585"}, 
      midnightblue = {
        ["rgb"] = {25,25,112},
        ["hex"] = "#191970"}, 
      mintcream = {
        ["rgb"] = {245,255,250},
        ["hex"] = "#F5FFFA"}, 
      mistyrose = {
        ["rgb"] = {255,228,225},
        ["hex"] = "#FFE4E1"}, 
      moccasin = {
        ["rgb"] = {255,228,181},
        ["hex"] = "#FFE4B5"}, 
      navajowhite = {
        ["rgb"] = {255,222,173},
        ["hex"] = "#FFDEAD"}, 
      navy = {
        ["rgb"] = {0,0,128},
        ["hex"] = "#000080"}, 
      oldlace = {
        ["rgb"] = {253,245,230},
        ["hex"] = "#FDF5E6"}, 
      olive = {
        ["rgb"] = {128,128,0},
        ["hex"] = "#808000"}, 
      olivedrab = {
        ["rgb"] = {107,142,35},
        ["hex"] = "#6B8E23"}, 
      orange = {
        ["rgb"] = {255,165,0},
        ["hex"] = "#FFA500"}, 
      orangered = {
        ["rgb"] = {255,69,0},
        ["hex"] = "#FF4500"}, 
      orchid = {
        ["rgb"] = {218,112,214},
        ["hex"] = "#DA70D6"}, 
      palegoldenrod = {
        ["rgb"] = {238,232,170},
        ["hex"] = "#EEE8AA"}, 
      palegreen = {
        ["rgb"] = {152,253,152},
        ["hex"] = "#98FD98"}, 
      paleturquoise = {
        ["rgb"] = {175,238,238},
        ["hex"] = "#AFEEEE"}, 
      palevioletred = {
        ["rgb"] = {219,112,147},
        ["hex"] = "#DB7093"}, 
      papayawhip = {
        ["rgb"] = {255,239,213},
        ["hex"] = "#FFEFD5"}, 
      peachpuff = {
        ["rgb"] = {255,218,185},
        ["hex"] = "#FFDAB9"}, 
      peru = {
        ["rgb"] = {205,133,63},
        ["hex"] = "#CD853F"}, 
      pink = {
        ["rgb"] = {255,192,205},
        ["hex"] = "#FFC0CD"}, 
      plum = {
        ["rgb"] = {221,160,221},
        ["hex"] = "#DDA0DD"}, 
      powderblue = {
        ["rgb"] = {176,224,230},
        ["hex"] = "#B0E0E6"}, 
      purple = {
        ["rgb"] = {128,0,128},
        ["hex"] = "#800080"}, 
      red = {
        ["rgb"] = {255,0,0},
        ["hex"] = "#FF0000"}, 
      rosybrown = {
        ["rgb"] = {188,143,143},
        ["hex"] = "#BC8F8F"}, 
      royalblue = {
        ["rgb"] = {65,105,225},
        ["hex"] = "#4169E1"}, 
      saddlebrown = {
        ["rgb"] = {139,69,19},
        ["hex"] = "#8B4513"}, 
      salmon = {
        ["rgb"] = {250,128,114},
        ["hex"] = "#FA8072"}, 
      sandybrown = {
        ["rgb"] = {244,164,96},
        ["hex"] = "#F4A460"}, 
      seagreen = {
        ["rgb"] = {46,139,87},
        ["hex"] = "#2E8B57"}, 
      seashell = {
        ["rgb"] = {255,245,238},
        ["hex"] = "#FFF5EE"}, 
      sienna = {
        ["rgb"] = {160,82,45},
        ["hex"] = "#A0522D"}, 
      silver = {
        ["rgb"] = {192,192,192},
        ["hex"] = "#C0C0C0"}, 
      skyblue = {
        ["rgb"] = {135,206,235},
        ["hex"] = "#87CEEB"}, 
      slateblue = {
        ["rgb"] = {106,90,205},
        ["hex"] = "#6A5ACD"}, 
      slategray = {
        ["rgb"] = {112,128,144},
        ["hex"] = "#708090"}, 
      slategrey = {
        ["rgb"] = {112,128,144},
        ["hex"] = "#708090"}, 
      snow = {
        ["rgb"] = {255,250,250},
        ["hex"] = "#FFFAFA"}, 
      springgreen = {
        ["rgb"] = {0,255,127},
        ["hex"] = "#00FF7F"}, 
      steelblue = {
        ["rgb"] = {70,130,180},
        ["hex"] = "#4682B4"}, 
      tan = {
        ["rgb"] = {210,180,140},
        ["hex"] = "#D2B48C"}, 
      teal = {
        ["rgb"] = {0,128,128},
        ["hex"] = "#008080"}, 
      thistle = {
        ["rgb"] = {216,191,216},
        ["hex"] = "#D8BFD8"}, 
      tomato = {
        ["rgb"] = {255,99,71},
        ["hex"] = "#FF6347"}, 
      turquoise = {
        ["rgb"] = {64,224,208},
        ["hex"] = "#40E0D0"}, 
      saddlebrown = {
        ["rgb"] = {139,69,19},
        ["hex"] = "#8B4513"}, 
      violet = {
        ["rgb"] = {238,130,238},
        ["hex"] = "#EE82EE"}, 
      wheat = {
        ["rgb"] = {245,222,179},
        ["hex"] = "#F5DEB3"}, 
      white = {
        ["rgb"] = {255,255,255},
        ["hex"] = "#FFFFFF"}, 
      whitesmoke = {
        ["rgb"] = {245,245,245},
        ["hex"] = "#F5F5F5"}, 
      yellow = {
        ["rgb"] = {255,255,0},
        ["hex"] = "#FFFF00"}, 
      yellowgreen = {
        ["rgb"] = {154,205,50},
        ["hex"] = "#9ACD32"}
      
    },
    
    ------------ ------------
    x11 = { -- x11 color keywords
      
      AntiqueWhite1 = {
        ["rgb"] = {255,238,219},
        ["hex"] = "#FFEEDB"}, 
      AntiqueWhite2 = {
        ["rgb"] = {237,223,204},
        ["hex"] = "#EDDFCC"}, 
      AntiqueWhite3 = {
        ["rgb"] = {205,191,175},
        ["hex"] = "#CDBFAF"}, 
      AntiqueWhite4 = {
        ["rgb"] = {138,130,119},
        ["hex"] = "#8A8277"}, 
      Aquamarine1 = {
        ["rgb"] = {126,255,211},
        ["hex"] = "#7EFFD3"}, 
      Aquamarine2 = {
        ["rgb"] = {118,237,197},
        ["hex"] = "#76EDC5"}, 
      Aquamarine3 = {
        ["rgb"] = {102,205,170},
        ["hex"] = "#66CDAA"}, 
      Aquamarine4 = {
        ["rgb"] = {68,138,116},
        ["hex"] = "#448A74"}, 
      Azure1 = {
        ["rgb"] = {239,255,255},
        ["hex"] = "#EFFFFF"}, 
      Azure2 = {
        ["rgb"] = {224,237,237},
        ["hex"] = "#E0EDED"}, 
      Azure3 = {
        ["rgb"] = {192,205,205},
        ["hex"] = "#C0CDCD"}, 
      Azure4 = {
        ["rgb"] = {130,138,138},
        ["hex"] = "#828A8A"}, 
      Bisque1 = {
        ["rgb"] = {255,227,196},
        ["hex"] = "#FFE3C4"}, 
      Bisque2 = {
        ["rgb"] = {237,212,182},
        ["hex"] = "#EDD4B6"}, 
      Bisque3 = {
        ["rgb"] = {205,182,158},
        ["hex"] = "#CDB69E"}, 
      Bisque4 = {
        ["rgb"] = {138,124,107},
        ["hex"] = "#8A7C6B"}, 
      Blue1 = {
        ["rgb"] = {0,0,255},
        ["hex"] = "#0000FF"}, 
      Blue2 = {
        ["rgb"] = {0,0,237},
        ["hex"] = "#0000ED"}, 
      Blue3 = {
        ["rgb"] = {0,0,205},
        ["hex"] = "#0000CD"}, 
      Blue4 = {
        ["rgb"] = {0,0,138},
        ["hex"] = "#00008A"}, 
      Brown1 = {
        ["rgb"] = {255,63,63},
        ["hex"] = "#FF3F3F"}, 
      Brown2 = {
        ["rgb"] = {237,58,58},
        ["hex"] = "#ED3A3A"}, 
      Brown3 = {
        ["rgb"] = {205,51,51},
        ["hex"] = "#CD3333"}, 
      Brown4 = {
        ["rgb"] = {138,34,34},
        ["hex"] = "#8A2222"}, 
      Burlywood1 = {
        ["rgb"] = {255,211,155},
        ["hex"] = "#FFD39B"}, 
      Burlywood2 = {
        ["rgb"] = {237,196,145},
        ["hex"] = "#EDC491"}, 
      Burlywood3 = {
        ["rgb"] = {205,170,124},
        ["hex"] = "#CDAA7C"}, 
      Burlywood4 = {
        ["rgb"] = {138,114,84},
        ["hex"] = "#8A7254"}, 
      CadetBlue1 = {
        ["rgb"] = {151,244,255},
        ["hex"] = "#97F4FF"}, 
      CadetBlue2 = {
        ["rgb"] = {141,228,237},
        ["hex"] = "#8DE4ED"}, 
      CadetBlue3 = {
        ["rgb"] = {122,196,205},
        ["hex"] = "#7AC4CD"}, 
      CadetBlue4 = {
        ["rgb"] = {82,133,138},
        ["hex"] = "#52858A"}, 
      Chartreuse1 = {
        ["rgb"] = {126,255,0},
        ["hex"] = "#7EFF00"}, 
      Chartreuse2 = {
        ["rgb"] = {118,237,0},
        ["hex"] = "#76ED00"}, 
      Chartreuse3 = {
        ["rgb"] = {102,205,0},
        ["hex"] = "#66CD00"}, 
      Chartreuse4 = {
        ["rgb"] = {68,138,0},
        ["hex"] = "#448A00"}, 
      Chocolate1 = {
        ["rgb"] = {255,126,35},
        ["hex"] = "#FF7E23"}, 
      Chocolate2 = {
        ["rgb"] = {237,118,33},
        ["hex"] = "#ED7621"}, 
      Chocolate3 = {
        ["rgb"] = {205,102,28},
        ["hex"] = "#CD661C"}, 
      Chocolate4 = {
        ["rgb"] = {138,68,19},
        ["hex"] = "#8A4413"}, 
      Coral1 = {
        ["rgb"] = {255,114,85},
        ["hex"] = "#FF7255"}, 
      Coral2 = {
        ["rgb"] = {237,105,79},
        ["hex"] = "#ED694F"}, 
      Coral3 = {
        ["rgb"] = {205,90,68},
        ["hex"] = "#CD5A44"}, 
      Coral4 = {
        ["rgb"] = {138,62,47},
        ["hex"] = "#8A3E2F"}, 
      Cornsilk1 = {
        ["rgb"] = {255,247,220},
        ["hex"] = "#FFF7DC"}, 
      Cornsilk2 = {
        ["rgb"] = {237,232,205},
        ["hex"] = "#EDE8CD"}, 
      Cornsilk3 = {
        ["rgb"] = {205,200,176},
        ["hex"] = "#CDC8B0"}, 
      Cornsilk4 = {
        ["rgb"] = {138,135,119},
        ["hex"] = "#8A8777"}, 
      Cyan1 = {
        ["rgb"] = {0,255,255},
        ["hex"] = "#00FFFF"}, 
      Cyan2 = {
        ["rgb"] = {0,237,237},
        ["hex"] = "#00EDED"}, 
      Cyan3 = {
        ["rgb"] = {0,205,205},
        ["hex"] = "#00CDCD"}, 
      Cyan4 = {
        ["rgb"] = {0,138,138},
        ["hex"] = "#008A8A"}, 
      DarkGoldenrod1 = {
        ["rgb"] = {255,184,15},
        ["hex"] = "#FFB80F"}, 
      DarkGoldenrod2 = {
        ["rgb"] = {237,173,14},
        ["hex"] = "#EDAD0E"}, 
      DarkGoldenrod3 = {
        ["rgb"] = {205,149,12},
        ["hex"] = "#CD950C"}, 
      DarkGoldenrod4 = {
        ["rgb"] = {138,100,7},
        ["hex"] = "#8A6407"}, 
      DarkOliveGreen1 = {
        ["rgb"] = {201,255,112},
        ["hex"] = "#C9FF70"}, 
      DarkOliveGreen2 = {
        ["rgb"] = {187,237,104},
        ["hex"] = "#BBED68"}, 
      DarkOliveGreen3 = {
        ["rgb"] = {161,205,89},
        ["hex"] = "#A1CD59"}, 
      DarkOliveGreen4 = {
        ["rgb"] = {109,138,61},
        ["hex"] = "#6D8A3D"}, 
      DarkOrange1 = {
        ["rgb"] = {255,126,0},
        ["hex"] = "#FF7E00"}, 
      DarkOrange2 = {
        ["rgb"] = {237,118,0},
        ["hex"] = "#ED7600"}, 
      DarkOrange3 = {
        ["rgb"] = {205,102,0},
        ["hex"] = "#CD6600"}, 
      DarkOrange4 = {
        ["rgb"] = {138,68,0},
        ["hex"] = "#8A4400"}, 
      DarkOrchid1 = {
        ["rgb"] = {191,62,255},
        ["hex"] = "#BF3EFF"}, 
      DarkOrchid2 = {
        ["rgb"] = {177,58,237},
        ["hex"] = "#B13AED"}, 
      DarkOrchid3 = {
        ["rgb"] = {154,49,205},
        ["hex"] = "#9A31CD"}, 
      DarkOrchid4 = {
        ["rgb"] = {104,33,138},
        ["hex"] = "#68218A"}, 
      DarkSeaGreen1 = {
        ["rgb"] = {192,255,192},
        ["hex"] = "#C0FFC0"}, 
      DarkSeaGreen2 = {
        ["rgb"] = {179,237,179},
        ["hex"] = "#B3EDB3"}, 
      DarkSeaGreen3 = {
        ["rgb"] = {155,205,155},
        ["hex"] = "#9BCD9B"}, 
      DarkSeaGreen4 = {
        ["rgb"] = {104,138,104},
        ["hex"] = "#688A68"}, 
      DarkSlateGray1 = {
        ["rgb"] = {150,255,255},
        ["hex"] = "#96FFFF"}, 
      DarkSlateGray2 = {
        ["rgb"] = {140,237,237},
        ["hex"] = "#8CEDED"}, 
      DarkSlateGray3 = {
        ["rgb"] = {121,205,205},
        ["hex"] = "#79CDCD"}, 
      DarkSlateGray4 = {
        ["rgb"] = {81,138,138},
        ["hex"] = "#518A8A"}, 
      DeepPink1 = {
        ["rgb"] = {255,20,146},
        ["hex"] = "#FF1492"}, 
      DeepPink2 = {
        ["rgb"] = {237,17,136},
        ["hex"] = "#ED1188"}, 
      DeepPink3 = {
        ["rgb"] = {205,16,118},
        ["hex"] = "#CD1076"}, 
      DeepPink4 = {
        ["rgb"] = {138,10,79},
        ["hex"] = "#8A0A4F"}, 
      DeepSkyBlue1 = {
        ["rgb"] = {0,191,255},
        ["hex"] = "#00BFFF"}, 
      DeepSkyBlue2 = {
        ["rgb"] = {0,177,237},
        ["hex"] = "#00B1ED"}, 
      DeepSkyBlue3 = {
        ["rgb"] = {0,154,205},
        ["hex"] = "#009ACD"}, 
      DeepSkyBlue4 = {
        ["rgb"] = {0,104,138},
        ["hex"] = "#00688A"}, 
      DodgerBlue1 = {
        ["rgb"] = {29,144,255},
        ["hex"] = "#1D90FF"}, 
      DodgerBlue2 = {
        ["rgb"] = {28,133,237},
        ["hex"] = "#1C85ED"}, 
      DodgerBlue3 = {
        ["rgb"] = {23,116,205},
        ["hex"] = "#1774CD"}, 
      DodgerBlue4 = {
        ["rgb"] = {16,77,138},
        ["hex"] = "#104D8A"}, 
      Firebrick1 = {
        ["rgb"] = {255,48,48},
        ["hex"] = "#FF3030"}, 
      Firebrick2 = {
        ["rgb"] = {237,43,43},
        ["hex"] = "#ED2B2B"}, 
      Firebrick3 = {
        ["rgb"] = {205,38,38},
        ["hex"] = "#CD2626"}, 
      Firebrick4 = {
        ["rgb"] = {138,25,25},
        ["hex"] = "#8A1919"}, 
      Gold1 = {
        ["rgb"] = {255,215,0},
        ["hex"] = "#FFD700"}, 
      Gold2 = {
        ["rgb"] = {237,201,0},
        ["hex"] = "#EDC900"}, 
      Gold3 = {
        ["rgb"] = {205,173,0},
        ["hex"] = "#CDAD00"}, 
      Gold4 = {
        ["rgb"] = {138,117,0},
        ["hex"] = "#8A7500"}, 
      Goldenrod1 = {
        ["rgb"] = {255,192,36},
        ["hex"] = "#FFC024"}, 
      Goldenrod2 = {
        ["rgb"] = {237,179,33},
        ["hex"] = "#EDB321"}, 
      Goldenrod3 = {
        ["rgb"] = {205,155,28},
        ["hex"] = "#CD9B1C"}, 
      Goldenrod4 = {
        ["rgb"] = {138,104,20},
        ["hex"] = "#8A6814"}, 
      Gray0 = {
        ["rgb"] = {189,189,189},
        ["hex"] = "#BDBDBD"}, 
      Green0 = {
        ["rgb"] = {0,255,0},
        ["hex"] = "#00FF00"}, 
      Green1 = {
        ["rgb"] = {0,255,0},
        ["hex"] = "#00FF00"}, 
      Green2 = {
        ["rgb"] = {0,237,0},
        ["hex"] = "#00ED00"}, 
      Green3 = {
        ["rgb"] = {0,205,0},
        ["hex"] = "#00CD00"}, 
      Green4 = {
        ["rgb"] = {0,138,0},
        ["hex"] = "#008A00"}, 
      Grey0 = {
        ["rgb"] = {189,189,189},
        ["hex"] = "#BDBDBD"}, 
      Honeydew1 = {
        ["rgb"] = {239,255,239},
        ["hex"] = "#EFFFEF"}, 
      Honeydew2 = {
        ["rgb"] = {224,237,224},
        ["hex"] = "#E0EDE0"}, 
      Honeydew3 = {
        ["rgb"] = {192,205,192},
        ["hex"] = "#C0CDC0"}, 
      Honeydew4 = {
        ["rgb"] = {130,138,130},
        ["hex"] = "#828A82"}, 
      HotPink1 = {
        ["rgb"] = {255,109,179},
        ["hex"] = "#FF6DB3"}, 
      HotPink2 = {
        ["rgb"] = {237,105,167},
        ["hex"] = "#ED69A7"}, 
      HotPink3 = {
        ["rgb"] = {205,95,144},
        ["hex"] = "#CD5F90"}, 
      HotPink4 = {
        ["rgb"] = {138,58,98},
        ["hex"] = "#8A3A62"}, 
      IndianRed1 = {
        ["rgb"] = {255,105,105},
        ["hex"] = "#FF6969"}, 
      IndianRed2 = {
        ["rgb"] = {237,99,99},
        ["hex"] = "#ED6363"}, 
      IndianRed3 = {
        ["rgb"] = {205,84,84},
        ["hex"] = "#CD5454"}, 
      IndianRed4 = {
        ["rgb"] = {138,58,58},
        ["hex"] = "#8A3A3A"}, 
      Ivory1 = {
        ["rgb"] = {255,255,239},
        ["hex"] = "#FFFFEF"}, 
      Ivory2 = {
        ["rgb"] = {237,237,224},
        ["hex"] = "#EDEDE0"}, 
      Ivory3 = {
        ["rgb"] = {205,205,192},
        ["hex"] = "#CDCDC0"}, 
      Ivory4 = {
        ["rgb"] = {138,138,130},
        ["hex"] = "#8A8A82"}, 
      Khaki1 = {
        ["rgb"] = {255,246,142},
        ["hex"] = "#FFF68E"}, 
      Khaki2 = {
        ["rgb"] = {237,229,132},
        ["hex"] = "#EDE584"}, 
      Khaki3 = {
        ["rgb"] = {205,197,114},
        ["hex"] = "#CDC572"}, 
      Khaki4 = {
        ["rgb"] = {138,133,77},
        ["hex"] = "#8A854D"}, 
      LavenderBlush1 = {
        ["rgb"] = {255,239,244},
        ["hex"] = "#FFEFF4"}, 
      LavenderBlush2 = {
        ["rgb"] = {237,224,228},
        ["hex"] = "#EDE0E4"}, 
      LavenderBlush3 = {
        ["rgb"] = {205,192,196},
        ["hex"] = "#CDC0C4"}, 
      LavenderBlush4 = {
        ["rgb"] = {138,130,133},
        ["hex"] = "#8A8285"}, 
      LemonChiffon1 = {
        ["rgb"] = {255,249,205},
        ["hex"] = "#FFF9CD"}, 
      LemonChiffon2 = {
        ["rgb"] = {237,232,191},
        ["hex"] = "#EDE8BF"}, 
      LemonChiffon3 = {
        ["rgb"] = {205,201,165},
        ["hex"] = "#CDC9A5"}, 
      LemonChiffon4 = {
        ["rgb"] = {138,136,112},
        ["hex"] = "#8A8870"}, 
      LightBlue1 = {
        ["rgb"] = {191,238,255},
        ["hex"] = "#BFEEFF"}, 
      LightBlue2 = {
        ["rgb"] = {177,223,237},
        ["hex"] = "#B1DFED"}, 
      LightBlue3 = {
        ["rgb"] = {154,191,205},
        ["hex"] = "#9ABFCD"}, 
      LightBlue4 = {
        ["rgb"] = {104,130,138},
        ["hex"] = "#68828A"}, 
      LightCyan1 = {
        ["rgb"] = {224,255,255},
        ["hex"] = "#E0FFFF"}, 
      LightCyan2 = {
        ["rgb"] = {209,237,237},
        ["hex"] = "#D1EDED"}, 
      LightCyan3 = {
        ["rgb"] = {179,205,205},
        ["hex"] = "#B3CDCD"}, 
      LightCyan4 = {
        ["rgb"] = {122,138,138},
        ["hex"] = "#7A8A8A"}, 
      LightGoldenrod1 = {
        ["rgb"] = {255,235,138},
        ["hex"] = "#FFEB8A"}, 
      LightGoldenrod2 = {
        ["rgb"] = {237,220,130},
        ["hex"] = "#EDDC82"}, 
      LightGoldenrod3 = {
        ["rgb"] = {205,189,112},
        ["hex"] = "#CDBD70"}, 
      LightGoldenrod4 = {
        ["rgb"] = {138,128,75},
        ["hex"] = "#8A804B"}, 
      LightPink1 = {
        ["rgb"] = {255,174,184},
        ["hex"] = "#FFAEB8"}, 
      LightPink2 = {
        ["rgb"] = {237,161,173},
        ["hex"] = "#EDA1AD"}, 
      LightPink3 = {
        ["rgb"] = {205,140,149},
        ["hex"] = "#CD8C95"}, 
      LightPink4 = {
        ["rgb"] = {138,94,100},
        ["hex"] = "#8A5E64"}, 
      LightSalmon1 = {
        ["rgb"] = {255,160,122},
        ["hex"] = "#FFA07A"}, 
      LightSalmon2 = {
        ["rgb"] = {237,149,114},
        ["hex"] = "#ED9572"}, 
      LightSalmon3 = {
        ["rgb"] = {205,128,98},
        ["hex"] = "#CD8062"}, 
      LightSalmon4 = {
        ["rgb"] = {138,86,66},
        ["hex"] = "#8A5642"}, 
      LightSkyBlue1 = {
        ["rgb"] = {175,226,255},
        ["hex"] = "#AFE2FF"}, 
      LightSkyBlue2 = {
        ["rgb"] = {164,211,237},
        ["hex"] = "#A4D3ED"}, 
      LightSkyBlue3 = {
        ["rgb"] = {140,181,205},
        ["hex"] = "#8CB5CD"}, 
      LightSkyBlue4 = {
        ["rgb"] = {95,123,138},
        ["hex"] = "#5F7B8A"}, 
      LightSteelBlue1 = {
        ["rgb"] = {201,225,255},
        ["hex"] = "#C9E1FF"}, 
      LightSteelBlue2 = {
        ["rgb"] = {187,210,237},
        ["hex"] = "#BBD2ED"}, 
      LightSteelBlue3 = {
        ["rgb"] = {161,181,205},
        ["hex"] = "#A1B5CD"}, 
      LightSteelBlue4 = {
        ["rgb"] = {109,123,138},
        ["hex"] = "#6D7B8A"}, 
      LightYellow1 = {
        ["rgb"] = {255,255,224},
        ["hex"] = "#FFFFE0"}, 
      LightYellow2 = {
        ["rgb"] = {237,237,209},
        ["hex"] = "#EDEDD1"}, 
      LightYellow3 = {
        ["rgb"] = {205,205,179},
        ["hex"] = "#CDCDB3"}, 
      LightYellow4 = {
        ["rgb"] = {138,138,122},
        ["hex"] = "#8A8A7A"}, 
      Magenta1 = {
        ["rgb"] = {255,0,255},
        ["hex"] = "#FF00FF"}, 
      Magenta2 = {
        ["rgb"] = {237,0,237},
        ["hex"] = "#ED00ED"}, 
      Magenta3 = {
        ["rgb"] = {205,0,205},
        ["hex"] = "#CD00CD"}, 
      Magenta4 = {
        ["rgb"] = {138,0,138},
        ["hex"] = "#8A008A"}, 
      Maroon0 = {
        ["rgb"] = {175,48,95},
        ["hex"] = "#AF305F"}, 
      Maroon1 = {
        ["rgb"] = {255,52,178},
        ["hex"] = "#FF34B2"}, 
      Maroon2 = {
        ["rgb"] = {237,48,167},
        ["hex"] = "#ED30A7"}, 
      Maroon3 = {
        ["rgb"] = {205,40,144},
        ["hex"] = "#CD2890"}, 
      Maroon4 = {
        ["rgb"] = {138,28,98},
        ["hex"] = "#8A1C62"}, 
      MediumOrchid1 = {
        ["rgb"] = {224,102,255},
        ["hex"] = "#E066FF"}, 
      MediumOrchid2 = {
        ["rgb"] = {209,94,237},
        ["hex"] = "#D15EED"}, 
      MediumOrchid3 = {
        ["rgb"] = {179,81,205},
        ["hex"] = "#B351CD"}, 
      MediumOrchid4 = {
        ["rgb"] = {122,54,138},
        ["hex"] = "#7A368A"}, 
      MediumPurple1 = {
        ["rgb"] = {170,130,255},
        ["hex"] = "#AA82FF"}, 
      MediumPurple2 = {
        ["rgb"] = {159,121,237},
        ["hex"] = "#9F79ED"}, 
      MediumPurple3 = {
        ["rgb"] = {136,104,205},
        ["hex"] = "#8868CD"}, 
      MediumPurple4 = {
        ["rgb"] = {93,71,138},
        ["hex"] = "#5D478A"}, 
      MistyRose1 = {
        ["rgb"] = {255,227,225},
        ["hex"] = "#FFE3E1"}, 
      MistyRose2 = {
        ["rgb"] = {237,212,210},
        ["hex"] = "#EDD4D2"}, 
      MistyRose3 = {
        ["rgb"] = {205,182,181},
        ["hex"] = "#CDB6B5"}, 
      MistyRose4 = {
        ["rgb"] = {138,124,123},
        ["hex"] = "#8A7C7B"}, 
      NavajoWhite1 = {
        ["rgb"] = {255,221,173},
        ["hex"] = "#FFDDAD"}, 
      NavajoWhite2 = {
        ["rgb"] = {237,206,160},
        ["hex"] = "#EDCEA0"}, 
      NavajoWhite3 = {
        ["rgb"] = {205,178,138},
        ["hex"] = "#CDB28A"}, 
      NavajoWhite4 = {
        ["rgb"] = {138,121,94},
        ["hex"] = "#8A795E"}, 
      OliveDrab1 = {
        ["rgb"] = {191,255,62},
        ["hex"] = "#BFFF3E"}, 
      OliveDrab2 = {
        ["rgb"] = {178,237,58},
        ["hex"] = "#B2ED3A"}, 
      OliveDrab3 = {
        ["rgb"] = {154,205,49},
        ["hex"] = "#9ACD31"}, 
      OliveDrab4 = {
        ["rgb"] = {104,138,33},
        ["hex"] = "#688A21"}, 
      Orange1 = {
        ["rgb"] = {255,165,0},
        ["hex"] = "#FFA500"}, 
      Orange2 = {
        ["rgb"] = {237,154,0},
        ["hex"] = "#ED9A00"}, 
      Orange3 = {
        ["rgb"] = {205,132,0},
        ["hex"] = "#CD8400"}, 
      Orange4 = {
        ["rgb"] = {138,89,0},
        ["hex"] = "#8A5900"}, 
      OrangeRed1 = {
        ["rgb"] = {255,68,0},
        ["hex"] = "#FF4400"}, 
      OrangeRed2 = {
        ["rgb"] = {237,63,0},
        ["hex"] = "#ED3F00"}, 
      OrangeRed3 = {
        ["rgb"] = {205,54,0},
        ["hex"] = "#CD3600"}, 
      OrangeRed4 = {
        ["rgb"] = {138,36,0},
        ["hex"] = "#8A2400"}, 
      Orchid1 = {
        ["rgb"] = {255,130,249},
        ["hex"] = "#FF82F9"}, 
      Orchid2 = {
        ["rgb"] = {237,122,232},
        ["hex"] = "#ED7AE8"}, 
      Orchid3 = {
        ["rgb"] = {205,104,201},
        ["hex"] = "#CD68C9"}, 
      Orchid4 = {
        ["rgb"] = {138,71,136},
        ["hex"] = "#8A4788"}, 
      PaleGreen1 = {
        ["rgb"] = {154,255,154},
        ["hex"] = "#9AFF9A"}, 
      PaleGreen2 = {
        ["rgb"] = {144,237,144},
        ["hex"] = "#90ED90"}, 
      PaleGreen3 = {
        ["rgb"] = {124,205,124},
        ["hex"] = "#7CCD7C"}, 
      PaleGreen4 = {
        ["rgb"] = {84,138,84},
        ["hex"] = "#548A54"}, 
      PaleTurquoise1 = {
        ["rgb"] = {186,255,255},
        ["hex"] = "#BAFFFF"}, 
      PaleTurquoise2 = {
        ["rgb"] = {174,237,237},
        ["hex"] = "#AEEDED"}, 
      PaleTurquoise3 = {
        ["rgb"] = {150,205,205},
        ["hex"] = "#96CDCD"}, 
      PaleTurquoise4 = {
        ["rgb"] = {102,138,138},
        ["hex"] = "#668A8A"}, 
      PaleVioletRed1 = {
        ["rgb"] = {255,130,170},
        ["hex"] = "#FF82AA"}, 
      PaleVioletRed2 = {
        ["rgb"] = {237,121,159},
        ["hex"] = "#ED799F"}, 
      PaleVioletRed3 = {
        ["rgb"] = {205,104,136},
        ["hex"] = "#CD6888"}, 
      PaleVioletRed4 = {
        ["rgb"] = {138,71,93},
        ["hex"] = "#8A475D"}, 
      PeachPuff1 = {
        ["rgb"] = {255,218,184},
        ["hex"] = "#FFDAB8"}, 
      PeachPuff2 = {
        ["rgb"] = {237,202,173},
        ["hex"] = "#EDCAAD"}, 
      PeachPuff3 = {
        ["rgb"] = {205,175,149},
        ["hex"] = "#CDAF95"}, 
      PeachPuff4 = {
        ["rgb"] = {138,119,100},
        ["hex"] = "#8A7764"}, 
      Pink1 = {
        ["rgb"] = {255,181,196},
        ["hex"] = "#FFB5C4"}, 
      Pink2 = {
        ["rgb"] = {237,169,183},
        ["hex"] = "#EDA9B7"}, 
      Pink3 = {
        ["rgb"] = {205,145,158},
        ["hex"] = "#CD919E"}, 
      Pink4 = {
        ["rgb"] = {138,99,108},
        ["hex"] = "#8A636C"}, 
      Plum1 = {
        ["rgb"] = {255,186,255},
        ["hex"] = "#FFBAFF"}, 
      Plum2 = {
        ["rgb"] = {237,174,237},
        ["hex"] = "#EDAEED"}, 
      Plum3 = {
        ["rgb"] = {205,150,205},
        ["hex"] = "#CD96CD"}, 
      Plum4 = {
        ["rgb"] = {138,102,138},
        ["hex"] = "#8A668A"}, 
      Purple0 = {
        ["rgb"] = {160,31,239},
        ["hex"] = "#A01FEF"}, 
      Purple1 = {
        ["rgb"] = {155,48,255},
        ["hex"] = "#9B30FF"}, 
      Purple2 = {
        ["rgb"] = {145,43,237},
        ["hex"] = "#912BED"}, 
      Purple3 = {
        ["rgb"] = {124,38,205},
        ["hex"] = "#7C26CD"}, 
      Purple4 = {
        ["rgb"] = {84,25,138},
        ["hex"] = "#54198A"}, 
      Red1 = {
        ["rgb"] = {255,0,0},
        ["hex"] = "#FF0000"}, 
      Red2 = {
        ["rgb"] = {237,0,0},
        ["hex"] = "#ED0000"}, 
      Red3 = {
        ["rgb"] = {205,0,0},
        ["hex"] = "#CD0000"}, 
      Red4 = {
        ["rgb"] = {138,0,0},
        ["hex"] = "#8A0000"}, 
      RosyBrown1 = {
        ["rgb"] = {255,192,192},
        ["hex"] = "#FFC0C0"}, 
      RosyBrown2 = {
        ["rgb"] = {237,179,179},
        ["hex"] = "#EDB3B3"}, 
      RosyBrown3 = {
        ["rgb"] = {205,155,155},
        ["hex"] = "#CD9B9B"}, 
      RosyBrown4 = {
        ["rgb"] = {138,104,104},
        ["hex"] = "#8A6868"}, 
      RoyalBlue1 = {
        ["rgb"] = {72,118,255},
        ["hex"] = "#4876FF"}, 
      RoyalBlue2 = {
        ["rgb"] = {67,109,237},
        ["hex"] = "#436DED"}, 
      RoyalBlue3 = {
        ["rgb"] = {58,94,205},
        ["hex"] = "#3A5ECD"}, 
      RoyalBlue4 = {
        ["rgb"] = {38,63,138},
        ["hex"] = "#263F8A"}, 
      Salmon1 = {
        ["rgb"] = {255,140,104},
        ["hex"] = "#FF8C68"}, 
      Salmon2 = {
        ["rgb"] = {237,130,98},
        ["hex"] = "#ED8262"}, 
      Salmon3 = {
        ["rgb"] = {205,112,84},
        ["hex"] = "#CD7054"}, 
      Salmon4 = {
        ["rgb"] = {138,75,57},
        ["hex"] = "#8A4B39"}, 
      SeaGreen1 = {
        ["rgb"] = {84,255,159},
        ["hex"] = "#54FF9F"}, 
      SeaGreen2 = {
        ["rgb"] = {77,237,147},
        ["hex"] = "#4DED93"}, 
      SeaGreen3 = {
        ["rgb"] = {67,205,127},
        ["hex"] = "#43CD7F"}, 
      SeaGreen4 = {
        ["rgb"] = {45,138,86},
        ["hex"] = "#2D8A56"}, 
      Seashell1 = {
        ["rgb"] = {255,244,237},
        ["hex"] = "#FFF4ED"}, 
      Seashell2 = {
        ["rgb"] = {237,228,221},
        ["hex"] = "#EDE4DD"}, 
      Seashell3 = {
        ["rgb"] = {205,196,191},
        ["hex"] = "#CDC4BF"}, 
      Seashell4 = {
        ["rgb"] = {138,133,130},
        ["hex"] = "#8A8582"}, 
      Sienna1 = {
        ["rgb"] = {255,130,71},
        ["hex"] = "#FF8247"}, 
      Sienna2 = {
        ["rgb"] = {237,121,66},
        ["hex"] = "#ED7942"}, 
      Sienna3 = {
        ["rgb"] = {205,104,57},
        ["hex"] = "#CD6839"}, 
      Sienna4 = {
        ["rgb"] = {138,71,38},
        ["hex"] = "#8A4726"}, 
      SkyBlue1 = {
        ["rgb"] = {135,206,255},
        ["hex"] = "#87CEFF"}, 
      SkyBlue2 = {
        ["rgb"] = {125,191,237},
        ["hex"] = "#7DBFED"}, 
      SkyBlue3 = {
        ["rgb"] = {108,165,205},
        ["hex"] = "#6CA5CD"}, 
      SkyBlue4 = {
        ["rgb"] = {73,112,138},
        ["hex"] = "#49708A"}, 
      SlateBlue1 = {
        ["rgb"] = {130,110,255},
        ["hex"] = "#826EFF"}, 
      SlateBlue2 = {
        ["rgb"] = {122,103,237},
        ["hex"] = "#7A67ED"}, 
      SlateBlue3 = {
        ["rgb"] = {104,89,205},
        ["hex"] = "#6859CD"}, 
      SlateBlue4 = {
        ["rgb"] = {71,59,138},
        ["hex"] = "#473B8A"}, 
      SlateGray1 = {
        ["rgb"] = {197,226,255},
        ["hex"] = "#C5E2FF"}, 
      SlateGray2 = {
        ["rgb"] = {184,211,237},
        ["hex"] = "#B8D3ED"}, 
      SlateGray3 = {
        ["rgb"] = {159,181,205},
        ["hex"] = "#9FB5CD"}, 
      SlateGray4 = {
        ["rgb"] = {108,123,138},
        ["hex"] = "#6C7B8A"}, 
      Snow1 = {
        ["rgb"] = {255,249,249},
        ["hex"] = "#FFF9F9"}, 
      Snow2 = {
        ["rgb"] = {237,232,232},
        ["hex"] = "#EDE8E8"}, 
      Snow3 = {
        ["rgb"] = {205,201,201},
        ["hex"] = "#CDC9C9"}, 
      Snow4 = {
        ["rgb"] = {138,136,136},
        ["hex"] = "#8A8888"}, 
      SpringGreen1 = {
        ["rgb"] = {0,255,126},
        ["hex"] = "#00FF7E"}, 
      SpringGreen2 = {
        ["rgb"] = {0,237,118},
        ["hex"] = "#00ED76"}, 
      SpringGreen3 = {
        ["rgb"] = {0,205,102},
        ["hex"] = "#00CD66"}, 
      SpringGreen4 = {
        ["rgb"] = {0,138,68},
        ["hex"] = "#008A44"}, 
      SteelBlue1 = {
        ["rgb"] = {99,183,255},
        ["hex"] = "#63B7FF"}, 
      SteelBlue2 = {
        ["rgb"] = {91,172,237},
        ["hex"] = "#5BACED"}, 
      SteelBlue3 = {
        ["rgb"] = {79,147,205},
        ["hex"] = "#4F93CD"}, 
      SteelBlue4 = {
        ["rgb"] = {53,99,138},
        ["hex"] = "#35638A"}, 
      Tan1 = {
        ["rgb"] = {255,165,79},
        ["hex"] = "#FFA54F"}, 
      Tan2 = {
        ["rgb"] = {237,154,73},
        ["hex"] = "#ED9A49"}, 
      Tan3 = {
        ["rgb"] = {205,132,63},
        ["hex"] = "#CD843F"}, 
      Tan4 = {
        ["rgb"] = {138,89,43},
        ["hex"] = "#8A592B"}, 
      Thistle1 = {
        ["rgb"] = {255,225,255},
        ["hex"] = "#FFE1FF"}, 
      Thistle2 = {
        ["rgb"] = {237,210,237},
        ["hex"] = "#EDD2ED"}, 
      Thistle3 = {
        ["rgb"] = {205,181,205},
        ["hex"] = "#CDB5CD"}, 
      Thistle4 = {
        ["rgb"] = {138,123,138},
        ["hex"] = "#8A7B8A"}, 
      Tomato1 = {
        ["rgb"] = {255,99,71},
        ["hex"] = "#FF6347"}, 
      Tomato2 = {
        ["rgb"] = {237,91,66},
        ["hex"] = "#ED5B42"}, 
      Tomato3 = {
        ["rgb"] = {205,79,57},
        ["hex"] = "#CD4F39"}, 
      Tomato4 = {
        ["rgb"] = {138,53,38},
        ["hex"] = "#8A3526"}, 
      Turquoise1 = {
        ["rgb"] = {0,244,255},
        ["hex"] = "#00F4FF"}, 
      Turquoise2 = {
        ["rgb"] = {0,228,237},
        ["hex"] = "#00E4ED"}, 
      Turquoise3 = {
        ["rgb"] = {0,196,205},
        ["hex"] = "#00C4CD"}, 
      Turquoise4 = {
        ["rgb"] = {0,133,138},
        ["hex"] = "#00858A"}, 
      VioletRed1 = {
        ["rgb"] = {255,62,150},
        ["hex"] = "#FF3E96"}, 
      VioletRed2 = {
        ["rgb"] = {237,58,140},
        ["hex"] = "#ED3A8C"}, 
      VioletRed3 = {
        ["rgb"] = {205,49,119},
        ["hex"] = "#CD3177"}, 
      VioletRed4 = {
        ["rgb"] = {138,33,81},
        ["hex"] = "#8A2151"}, 
      Wheat1 = {
        ["rgb"] = {255,230,186},
        ["hex"] = "#FFE6BA"}, 
      Wheat2 = {
        ["rgb"] = {237,216,174},
        ["hex"] = "#EDD8AE"}, 
      Wheat3 = {
        ["rgb"] = {205,186,150},
        ["hex"] = "#CDBA96"}, 
      Wheat4 = {
        ["rgb"] = {138,125,102},
        ["hex"] = "#8A7D66"}, 
      Yellow1 = {
        ["rgb"] = {255,255,0},
        ["hex"] = "#FFFF00"}, 
      Yellow2 = {
        ["rgb"] = {237,237,0},
        ["hex"] = "#EDED00"}, 
      Yellow3 = {
        ["rgb"] = {205,205,0},
        ["hex"] = "#CDCD00"}, 
      Yellow4 = {
        ["rgb"] = {138,138,0},
        ["hex"] = "#8A8A00"}
    }
  },
  
  ------- -------- ------- -------- ------
  --- lists (arrays) of color names
  ------- -------- ------- -------- ------
  
  ------- -------- --------
  lists = {
  ------- -------- --------
    
    HTML = {"WHITE","SILVER","GRAY","BLACK","RED","MAROON","YELLOW","OLIVE","LIME","GREEN","AQUA","TEAL","BLUE","NAVY","FUCHSIA","PURPLE"},
    
    SVG = 
    {"aliceblue", "antiquewhite", "aqua", "aquamarine", "azure", "beige", "bisque", "black", "blanchedalmond", "blue", "blueviolet", "brown", "burlywood", "cadetblue", "chartreuse", "chocolate", "coral", "cornflowerblue", "cornsilk", "crimson", "cyan", "darkblue", "darkcyan", "darkgoldenrod", "darkgray", "darkgreen", "darkgrey", "darkkhaki", "darkmagenta", "darkolivegreen", "darkorange", "darkorchid", "darkred", "darksalmon", "darkseagreen", "darkslateblue", "darkslategray", "darkslategrey", "darkturquoise", "darkviolet", "deeppink", "deepskyblue", "dimgray", "dimgrey", "dodgerblue", "firebrick", "floralwhite", "forestgreen", "fuchsia", "gainsboro", "ghostwhite", "gold", "goldenrod", "gray", "green", "greenyellow", "grey", "honeydew", "hotpink", "indianred", "indigo", "ivory", "khaki", "lavender", "lavenderblush", "lawngreen", "lemonchiffon", "lightblue", "lightcoral", "lightcyan", "lightgoldenrodyellow", "lightgray", "lightgreen", "lightgrey", "lightpink", "lightsalmon", "lightseagreen", "lightskyblue", "lightslategray", "lightslategrey", "lightsteelblue", "lightyellow", "lime", "limegreen", "linen", "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid", "mediumpurple", "mediumseagreen", "mediumslateblue", "mediumspringgreen", "mediumturquoise", "mediumvioletred", "midnightblue", "mintcream", "mistyrose", "moccasin", "navajowhite", "navy", "oldlace", "olive", "olivedrab", "orange", "orangered", "orchid", "palegoldenrod", "palegreen", "paleturquoise", "palevioletred", "papayawhip", "peachpuff", "peru", "pink", "plum", "powderblue", "purple", "red", "rosybrown", "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen", "seashell", "sienna", "silver", "skyblue", "slateblue", "slategray", "slategrey", "snow", "springgreen", "steelblue", "tan", "teal", "thistle", "tomato", "turquoise", "saddlebrown", "violet", "wheat", "white", "whitesmoke", "yellow", "yellowgreen"}
    
  }
}

------- -------- ------- -------- ------
colorData.definedColors = definedColors
------- -------- ------- -------- ------

local dicts = definedColors.dictionaries
local metaHTML = {
    
    -- Makes HTML colors case insensitive
    __index = function(self,key)
        local upper = string.upper(key)
       -- print("got to here",key,self)
        if self[upper] then
            return self[upper] end
    end
    
} setmetatable(dicts.HTML,metaHTML)


---------- ---------- ---------- ---------- ---------- ---------- 

----- ----------- ----------- ----------- ----------- 

return color --> --- ---- -----

----- ----------- ----------- ----------- ----------- 
-- {{ File End - color.lua }}
----- ----------- ----------- ----------- ----------- 