local alias = require("reflex").alias
local trigger = require("reflex").trigger


trigger {
  match   = [[^(?:You are packed much too tightly into the earth to do that\.|You are asleep and can do nothing\. WAKE will attempt to wake you\.|Please await your next instruction\.)$]],
  enabled = false,
  regexp  = true,
  group   = "fail",
  
  omit_from_log    = true,
  omit_from_output = true,
  
  send_to = 14,
  send    = [[
    EnableGroup("mapbegin", false)
    EnableTrigger("mapsize", false)
    EnableGroup("fail", false)
    
    --EnableTrigger("prompt", true)
  ]],
}

trigger["notmapped"] {
  match   = [[This room has not been mapped.]],
  enabled = false,
  group   = "mapbegin",
  
  omit_from_log    = true,
  omit_from_output = true,
  
  send_to = 14,
  send    = [[
    EnableGroup("mapbegin", false)
    EnableGroup("fail", false)
    --EnableTrigger("prompt", true)
    
    map:ClearGrid()
  ]],
}

trigger["arealine"] {
  match   = [[^\-+ Area (?:\d+): (?:.+?) \-+$]],
  enabled = true,
  regexp  = true,
  group   = "mapbegin",
  
  omit_from_log    = true,
  omit_from_output = true,
  
  send_to = 14,
  send    = [[
    EnableGroup("mapbegin", false)
    EnableGroup("fail", false)
    EnableGroup("parsemap", true)
    --print("arealine")
    grid = {}
  ]],
}
trigger["arealine2"] {
  match   = [[^\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-$]],
  enabled = true,
  regexp  = true,
  group   = "mapbegin",
  
  omit_from_log    = true,
  omit_from_output = true,
  
  send_to = 14,
  send    = [[
    EnableGroup("mapbegin", false)
    EnableGroup("fail", false)
    EnableGroup("parsemap", true)
    --print("arealine")
    grid = {}
  ]],
}

trigger["maprows"] {
  match   = [[^.*$]],
  enabled = false,
  regexp  = true,
  group   = "parsemap",
  
  script   = "ParseLine",
  sequence = 101,
 

  omit_from_log    = true,
  omit_from_output = true,
}

trigger["coordline"] {
  match   = [[^\-+(?:[A-Za-z'"\-_&, ]+ )?(?:\-+)? -?\d+:-?\d+:-?\d+ \-+$]],
  enabled = true,
  regexp  = true,
  group   = "parsemap",
  
	sequence = 100,
  omit_from_log    = true,
  omit_from_output = true,
  
  send_to = 14,
  send    = [[
	  --print("coordline")
    EnableGroup("parsemap", false)
    --EnableGroup("mapbegin", true)
    --EnableTrigger("prompt", true)
    map:ClearGrid()
    map:DrawGrid(grid)
  ]],
}

trigger {
  match   = [[^(?:Your map view is set to (\d) by (\d)\.|You cannot set the (?:radius|width|height) greater than 5\.|Usage:)$]],
  enabled = false,
  regexp  = true,
  group   = "mapsize",
  
  send_to = 12,
  send    = [[
    EnableTrigger("mapsize", false)
    EnableGroup("fail", false)
    
    if tonumber("%1") and tonumber("%2") then
      map:MapSize(tonumber("%1"), tonumber("%2"))
      Execute("map parse")
    end
  ]],
}



alias {
  match  = [[^\s*map(?:\s+(.+?))?\s*$]],
  regexp = true,
  
  script = "MapAlias",
}

alias {
  match = [[^\s*map\s+help\s*$]],
  regexp = true,
  
  send_to = 12,
  send    = [[
    Note(GetPluginInfo(GetPluginID(), 3))
  ]],
}