-- Used to load the ATCP interface
PPI = require("libraries.ppi")

-- Will contain the ATCP interface
atcp = nil


-- Executed when you get an ATCP message!
OnClientCompose = function(message, content)
  local mid = content:find("\n", nil, true) or (#content + 1)
  local title, text = content:sub(1, mid-1), content:sub(mid+1)
  
  text = utils.editbox("Enter your content below", title, string.gsub(text, "\n", "\r\n"))
  if not text then
    SendNoEcho("*q")
    SendNoEcho("no")
  else
    atcp.Send("olesetbuf\n" .. string.gsub(text, "\r\n", "\n"))
    SendNoEcho("*s")
  end
end

-- Loads the ATCP library
OnPluginListChanged = function()
  local atcp, reloaded = PPI.Load("7c08e2961c5e20e5bdbf7fc5")
  if not atcp then
    -- Doesn't really matter - it won't do anything
  elseif reloaded then
    -- Registers a function to call when Client.Compose is received.
    atcp.Listen("Client.Compose", OnClientCompose)
    _G.atcp = atcp
  end
end