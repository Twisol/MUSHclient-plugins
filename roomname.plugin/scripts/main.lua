-- Used to load the ATCP interface
PPI = require("libraries.ppi")

-- Will contain the ATCP interface
atcp = nil


-- Executed when you get an ATCP message!
OnRoomBrief = function(message, content)
  SetStatus(content .. ".")
end

-- Loads the ATCP library
OnPluginListChanged = function()
  local atcp, reloaded = PPI.Load("7c08e2961c5e20e5bdbf7fc5")
  if not atcp then
    -- Normally, you might put an error or a warning note here.
    -- Roomname won't do anything if ATCP isn't available, so
    -- it's safe to leave it running until ATCP comes online.
  elseif reloaded then
    -- Registers a function to call when Room.Brief is received.
    atcp.Listen("Room.Brief", OnRoomBrief)
  end
end