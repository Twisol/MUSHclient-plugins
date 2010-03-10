local Window
Window = {
  new = function(name, x, y, width, height)
    local o = {}
    setmetatable(o, Window)
    Window.__index = Window
 
    o.name = name
    o.x = x or 0
    o.y = y or 0
    o.width = width or 5
    o.height = height or 5
    o.grid = {}
 
    -- Dummy window to load font
    WindowCreate(o.name, 0, 0, 1, 1, 0, 0, 0)
 
    o:FontSize(10) -- set size and reload map
 
    return o
  end,
 
  -- resizes the map
  MapSize = function(self, width, height)
                    -- (3+width*4) px = number of cells
                    --       width(5) = cells(23)
 
    self.width = width
    self.winwidth = self.textwidth*(3+width*4) + 2
    self.height = height
    self.winheight = self.textheight*(3+height*4) + 2
 
    WindowCreate(self.name, self.x, self.y, self.winwidth, self.winheight, 6, 2, 0x000000)
    WindowShow(self.name, true)
  end,
 
  FontSize = function(self, size)
    self.fontsize = size
    WindowFont(self.name, "f", "Lucida Console", self.fontsize, false, false, false, false, 1, 0)
 
    self.textwidth = WindowTextWidth(self.name, "f", "#")
    self.textheight = WindowFontInfo(self.name, "f",  1)
 
    self:MapSize(self.width, self.height)
    self:DrawGrid(self.grid)
  end,
 
  MoveWindow = function(self, x, y)
    self.x = x
    self.y = y
    WindowPosition(self.name, x, y, 6, 2)
  end,
 
  DrawCell = function(self, cell, x, y)
    -- Index into the appropriate cell, and add for the window edge
    local x = self.textwidth*x + 1
    local y = self.textheight*y + 1
 
    WindowText(self.name, "f", cell.char, x, y, 0, 0, cell.style, false)
  end,
 
  DrawRow = function(self, line, row)
    for i = 1, math.min(table.getn(line) or 23) do
      self:DrawCell(line[i] or " ", i-1, row)
    end
  end,
 
  DrawGrid = function(self, grid)
    self:ClearGrid()
 
    -- store this grid
    self.grid = grid
 
  -- Draws gridlines
--[[
    for i = 1, 23 do
      WindowLine(self.name, 0, i*self.textheight, self.winwidth, i*self.textheight, 0x666666, 0, 1)
    end
    for i = 1, 23 do
      WindowLine(self.name, 3+i*self.textwidth, 0, 3+i*self.textwidth, self.winheight, 0x666666, 0, 1)
    end
--]]
 
    for i = 1, 23 do
      self:DrawRow(grid[i] or {}, i-1)
    end
  end,
 
  ClearGrid = function(self)
    self.grid = {}
 
    WindowRectOp(self.name, 2, 0, 0, 0, 0, 0x000000)
 
    -- Draws borders
--[[
    WindowLine(self.name, 0, 0, 0, self.winheight-1, 0x666666, 0, 1)
    WindowLine(self.name, 0, 0, self.winwidth-1, 0, 0x666666, 0, 1)
    WindowLine(self.name, 0, self.winheight-1, self.winwidth-1, self.winheight-1, 0x666666, 0, 1)
    WindowLine(self.name, self.winwidth-1, 0, self.winwidth-1, self.winheight-1, 0x666666, 0, 1)
--]]
  end,
}

return Window