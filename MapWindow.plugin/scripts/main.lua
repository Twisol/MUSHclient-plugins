-- Used to load the ATCP/GMCP interface
local PPI = require("ppi")

-- Simple window class used by the map
Window = require("scripts.window")

--require "gmcphelper"

 
-- translate MAP markers
roomcode = {["S"] = "$", -- shop
            ["+"] = "@", -- current location
            ["$"] = "B", -- bank
            ["N"] = "N", -- newsroom
            ["P"] = "P", -- post office
            ["@"] = "W", -- wilderness exit
           }
 
-- color-code "special" rooms
roomcolor = {["@"] = 0xFFFFFF, -- white
             ["B"] = 0xFF8800, -- deep blue
             ["N"] = 0xFF8800, -- deep blue
             ["P"] = 0xFF8800, -- deep blue
             ["W"] = 0x0000FF, -- red
            }
 
-- prevents two map parses from going off at the same time
-- otherwise, one or more MAPs wouldn't be gagged
mapping = false

-- tells the ending trigger whether to re-enable gagging
-- This allows MAP to be parsed but still be shown, but
-- MAP PARSE to be parsed without being shown
gagging = true

-- Executed when you get a GMCP message!

OnPluginInstall = function()
  print("installing mapwindow plugin")
  local x = GetVariable("x") or 0
  local y = GetVariable("y") or 0
  local width = GetVariable("width") or 5
  local height = GetVariable("height") or 5
 
  map = Window.new(GetPluginID(), x, y, width, height)
	--[[PPI.OnLoad("29a4c0721bef6ae11c3e9a82", function(gmcp)
	  print("registering listener")
    gmcp.Listen("Redirect.Window", OnChangedRoom)
  end)]]
end

OnPluginSaveState = function()
  SetVariable("x", map.x)
  SetVariable("y", map.y)
  SetVariable("width", map.width)
  SetVariable("height", map.height)
end

-- (ID, on_success, on_failure)
PPI.OnLoad("29a4c0721bef6ae11c3e9a82", function(gmcp)
  gmcp.Listen("Redirect.Window", OnChangedRoom)
	end,
	function(reason)
    Note("GMCP interface unavailable: ", reason)
end)

--Listen("Room.Info", OnChangedRoom)
--testGMCP()
OnChangedRoom = function(message, content)
	--print("room changed")
  if content==nil then
	return
  end
  window_redirect = content
  if window_redirect=="map" then
    if mapping then
	    return
    end
    mapping = true
	  grid={}
    
    --EnableGroup("parsemap", true)
		--print("enabling mapbegin")
		EnableGroup("mapbegin", true)
  elseif window_redirect=="main" then
    mapping=false
		EnableGroup("mapbegin",false)
	  --EnableGroup("parsemap", false)
		EnableTrigger("coordline", true)
		EnableTrigger("prompt",true)
	  map:ClearGrid()
    map:DrawGrid(grid)
  end
    --SendNoEcho("map")
end

-- (ID, on_success, on_failure)
PPI.OnLoad("7c08e2961c5e20e5bdbf7fc5", function(atcp)
  atcp.Listen("Room.Num", OnChangedRoom)
end)

OnPluginListChanged = function()
  PPI.Refresh()
end
 
GagOption = function(bool)
  bool = (bool and "1" or "0")
  
  local names = {
    "notmapped", "maprows",
    "coordline",
    "arealine" , "fail",
  }
  
  for _, name in ipairs(names) do
    SetTriggerOption(name, "omit_from_log", bool)
    SetTriggerOption(name, "omit_from_output", bool)
  end
end

commands = {
  ["^radius%s+"] = function(line)
    EnableGroup("mapsize", true)
    EnableGroup("fail", true)
    SendNoEcho(line)
  end,
  ["^width%s+"] = function(line)
    EnableGroup("mapsize", true)
    EnableGroup("fail", true)
    SendNoEcho(line)
  end,
  ["^height%s+"] = function(line)
    EnableGroup("mapsize", true)
    EnableGroup("fail", true)
    SendNoEcho(line)
  end,
  ["^move$"] = function(line)
    Note("Current location: (" .. map.x .. ", " .. map.y .. ")")
  end,
  ["^move%s+(%d+)%s+(%d+)$"] = function(line, x, y)
    map:MoveWindow(tonumber(x), tonumber(y))
  end,
  ["^fontsize$"] = function(line)
    Note("Current font size: " .. map.fontsize)
  end,
  ["^fontsize%s+(%d+)$"] = function(line, size)
    map:FontSize(tonumber(size))
  end,
  ["^parse$"] = function(line)
    SendNoEcho("map")
  end,
  ["^$"] = function(line)
    gagging = false
    GagOption(false)
    
    if not mapping then
      mapping = true
      EnableGroup("mapbegin", true)
      EnableGroup("fail", true)
    end
    SendNoEcho("map")
  end,
}

MapAlias = function(name, line, matches, styles)
  matches[1] = matches[1] or ""
  
  for k,v in pairs(commands) do
    local args = {matches[1]:match(k)}
    if args[1] then
      v(line, unpack(args))
      return
    end
  end
  
  -- if no match:
  SendNoEcho(line)
end
 
-- runs for each row in the MAP output
ParseLine = function(name, line, matches, styles)
  -- expand the style runs
  local line = {}
  for _, style in ipairs(styles) do
    for i = 1, style.length do
      table.insert(line, {char = style.text:sub(i, i), textcolour = style.textcolour})
    end
  end
 
  -- contains {char, colour} pairs for each cell
  local row = {}
 
  -- Increment by two to skip over unnecessary spaces
  -- from the original (including the [ and ] marks)
  for i = 1, table.getn(line), 2 do
    cell = {}
 
    -- if this is true, we know it's a "[ ]"
    if (i % 4 == 3) and (line[i-1].char == "[") then
      -- replace it with an appropriate mark
      cell.char  = roomcode[line[i].char] or "#"
      cell.style = roomcolor[cell.char] or line[i-1].textcolour
    else
      -- keep the same character that was there
      cell.char  = line[i].char:upper()
      cell.style = line[i].textcolour
    end
    table.insert(row, cell)
  end
 
  -- after the entire map is processed, it draws the
  -- entire grid, so we store each row for later
  table.insert(grid, row)
end

GagLines=function()
  DeleteLines(1)
end

function OnPlugin_IAC_GA()
	--EnableTrigger("prompt", false)
	EnableGroup("mapbegin", true)
	EnableGroup("parsemap",false)
    
	mapping = false
	if not gagging then
		gagging = true
		GagOption(true)
	end
end

require("reflexes.map")