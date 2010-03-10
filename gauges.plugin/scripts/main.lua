-- Will contain the ATCP plugin interface
atcp = nil


gauges = {
  name = GetPluginID(),
  
  stats = {
    NL = {curr = 0,   max = 100, x = 56, y = 28},
    H  = {curr = 100, max = 100, x = 56, y = 53},
    M  = {curr = 100, max = 100, x = 56, y = 68},
    E  = {curr = 100, max = 100, x = 56, y = 83},
    W  = {curr = 100, max = 100, x = 56, y = 98},
  },
  
  percent = function(stat)
    local percent = math.floor(stat.curr/stat.max * 100)
    if percent > 100 then
      percent = 100
    elseif percent < 0 then
      percent = 0
    end
    
    return percent
  end,
  
  draw = function ()
    local left, top, width
    
    -- Draw the base image
    WindowDrawImage(gauges.name, "gauges", 0, 0, 0, 0, 1)
    
    -- Draw the individual bars
    for name,stat in pairs(gauges.stats) do
      left, top = stat.x, stat.y
      width = math.floor(gauges.percent(stat)/2)
      
      if width > 0 then
        WindowDrawImage(gauges.name, name,
                        left, top, 0, 0,
                        1,
                        0, 0, width, 0)
      end
      
      local txt = tostring(width*2) .. "%"
      -- draw shadow
      WindowText(gauges.name, "f", txt,
                 stat.x + 50 + 4, top, 0, 0,
                 0x000000)
      -- draw text
      WindowText(gauges.name, "f", txt,
                 stat.x + 50 + 2, top-2, 0, 0,
                 0xAAFFCC)
    end
    WindowShow(gauges.name, true)
  end,
}


-- Executed when you get an ATCP message!
OnCharVitals = function(message, content)
  for stat, curr, max in string.gmatch(content, "(%w+):(%d+)/(%d+)") do
    gauges.stats[stat].curr = curr
    gauges.stats[stat].max = max
  end
  
  gauges.draw()
end

local PPI = require("libraries.ppi")
-- Use this to load the ATCP library
OnPluginListChanged = function()
  local atcp, reloaded = PPI.Load("7c08e2961c5e20e5bdbf7fc5")
  if not atcp then
    -- no-op
  elseif reloaded then
    atcp.Listen("Char.Vitals", OnCharVitals)
    _G.atcp = atcp
  end
end

OnPluginInstall = function()
  local resources = plugger.path("resourceS")
  
  -- Set up the window
  WindowCreate(gauges.name, 0, 0, 150, 139, 10, 0, ColourNameToRGB("black"))
  
  -- Add a font
  WindowFont(gauges.name, "f", "Arial", 7.5)
  
  -- Load the base image
  WindowLoadImage(gauges.name, "gauges", resources .. "gauges.bmp")
  
  -- Load the image for each gauge
  for stat,_ in pairs(gauges.stats) do
    WindowLoadImage(gauges.name, stat, resources .. stat .. ".bmp")
  end -- for
  
  -- Draw!
  gauges.draw()
end

OnPluginClose = function()
  WindowDelete(gauges.name)
end

OnPluginEnable = OnPluginInstall
OnPluginDisable = OnPluginClose