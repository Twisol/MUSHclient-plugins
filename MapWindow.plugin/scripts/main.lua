-- Simple window class used by the map
Window = require("scripts.window")

-- Used to load the ATCP interface
PPI = require("libraries.ppi")

-- Will contain the ATCP interface
atcp = nil

 
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

-- current room num
current_room = nil

-- tells the ending trigger whether to re-enable gagging
-- This allows MAP to be parsed but still be shown, but
-- MAP PARSE to be parsed without being shown
gagging = true


OnPluginInstall = function()
  local x = GetVariable("x") or 0
  local y = GetVariable("y") or 0
  local width = GetVariable("width") or 5
  local height = GetVariable("height") or 5
 
  map = Window.new(GetPluginID(), x, y, width, height)
end

OnPluginSaveState = function()
  SetVariable("x", map.x)
  SetVariable("y", map.y)
  SetVariable("width", map.width)
  SetVariable("height", map.height)
end


-- Executed when you get an ATCP message!
OnRoomNum = function(message, content)
  local next_room = tonumber(content)
  if current_room ~= next_room then
    current_room = next_room
    Execute("map parse")
  end
end

-- Loads the ATCP library
OnPluginListChanged = function()
  local atcp, reloaded = PPI.Load("7c08e2961c5e20e5bdbf7fc5")
  if not atcp then
    -- Doesn't really matter - it won't do anything
  elseif reloaded then
    -- Registers a function to call when Client.Compose is received.
    atcp.Listen("Room.Num", OnRoomNum)
    _G.atcp = atcp
  end
end
 
GagOption = function(bool)
  bool = (bool and "1" or "0")
  
  local names = {
    "notmapped", "maprows",
    "coordline", "prompt",
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
    map:MoveWindow(tonumber(y), tonumber(y))
  end,
  ["^fontsize$"] = function(line)
    Note("Current font size: " .. map.fontsize)
  end,
  ["^fontsize%s+(%d+)$"] = function(line, size)
    map:FontSize(tonumber(size))
  end,
  ["^parse$"] = function(line)
    if mapping then
      return
    end
    mapping = true
    
    EnableGroup("mapbegin", true)
    EnableGroup("fail", true)
    
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


require("reflexes.map")