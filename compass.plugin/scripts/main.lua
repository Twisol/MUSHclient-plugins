-- Will contain the ATCP plugin interface
atcp = nil


compass = {
  name = GetPluginID(),
  
  arrows = {
    ["n"]   = {x = 57,  y = 25},
    ["ne"]  = {x = 73,  y = 37},
    ["e"]   = {x = 80,  y = 57},
    ["se"]  = {x = 73,  y = 72},
    ["s"]   = {x = 57,  y = 80},
    ["sw"]  = {x = 38,  y = 72},
    ["w"]   = {x = 27,  y = 57},
    ["nw"]  = {x = 38,  y = 38},
    ["u"]   = {x = 115, y = 31},
    ["d"]   = {x = 115, y = 79},
    ["in"]  = {x = 81,  y = 116},
    ["out"] = {x = 33,  y = 114},
  },
  
  onmousedown = function(flags, dir)
    Send(dir)
  end,
  
  draw = function(active, num)
    -- Pre-render preparation
    WindowDeleteAllHotspots(compass.name)
    
    -- Draw the base
    WindowDrawImage(compass.name, "compass", 0, 0, 0, 0, 1)
    
    -- Draw every active arrow w/ hotspot
    local arrow = nil
    for _,dir in ipairs(active) do
      arrow = compass.arrows[dir]
      if arrow then
        local left = arrow.x
        local top = arrow.y
        local right = left + arrow.width
        local bottom = top + arrow.height
        
        WindowDrawImage(compass.name, dir,
                        left, top, right, bottom, 1)
        WindowAddHotspot(compass.name, dir,
                         left, top, right, bottom,
                         "", "", "compass.onmousedown", "", "", "", 1, 0)
      end -- if
    end -- for
    
    -- Draw a shadow
    WindowText(compass.name, "f", num,
               102, 132, 0, 0,
               0x000000)
    -- Draw the room number
    WindowText(compass.name, "f", num,
               100, 130, 0, 0,
               0xAAFFCC)
    
    -- Refresh the window
    WindowShow(compass.name, true)
  end,
}

local roomdata = {}

-- Executed when we get a Room.Exits message
OnATCP = function(messages)
  if messages["Room.Num"] then
    compass.draw(roomdata.exits, roomdata.num)
    roomdata.exits, roomdata.num = nil, nil
  end
end

OnRoomExits = function(message, content)
  roomdata.exits = utils.split(content, ",")
end

OnRoomNum = function(message, content)
  roomdata.num = "<" .. content .. ">"
end

local PPI = require("libraries.ppi")
-- Used to load plugin interfaces
OnPluginListChanged = function()
  local atcp, reloaded = PPI.Load("7c08e2961c5e20e5bdbf7fc5")
  if not atcp then
    -- no-op
  elseif reloaded then
    -- Registers functions to call when ATCP messages are received
    atcp.Listen("Room.Exits", OnRoomExits)
    atcp.Listen("Room.Num", OnRoomNum)
    atcp.ListenFull(OnATCP)
    -- Sets the global 'atcp' variable to the new value
    _G.atcp = atcp
  end
end


OnPluginInstall = function()
  local resources = plugger.path("resources")
  
  -- Set up the window
  WindowCreate(compass.name, 0, 0, 150, 150, 4, 0, ColourNameToRGB("black"))
  
  -- Add a font
  WindowFont(compass.name, "f", "Arial", 8)
  
  -- Load the base image
  WindowLoadImage(compass.name, "compass", resources .."compass.bmp")

  -- Load the image for each arrow
  for dir,arrow in pairs(compass.arrows) do
    WindowLoadImage(compass.name, dir, resources .. dir .. ".bmp")
    
    arrow.width  = WindowImageInfo(compass.name, dir, 2)
    arrow.height = WindowImageInfo(compass.name, dir, 3)
  end -- for
  
  -- Draw!
  compass.draw({}, "")
end

OnPluginClose = function()
  WindowDelete(compass.name)
end

OnPluginEnable = OnPluginInstall
OnPluginDisable = OnPluginClose