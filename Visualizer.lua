

Visualizer = class()

function Visualizer:init(ca)
    self.ca = ca
    self:calculateCellSizeAndOffset()
end

function Visualizer:draw()
    for i = 1, self.ca.grid.rows do
        for j = 1, self.ca.grid.cols do
            local cell = self.ca.grid.cells[i][j]
            local x = (j - 1) * self.cellWidth + self.offsetX
            local y = (i - 1) * self.cellHeight + self.offsetY
            
            if type(cell) == "table" and cell.class == "CellularAutomata" then
                -- Draw the nested CA
                self:drawNestedCA(cell, x, y, self.cellWidth, self.cellHeight, i, j)
            else
                -- Draw regular cell (alive cells in white, dead cells in black)
                fill(cell == 1 and color(255) or color(0))
                rect(x, y, self.cellWidth, self.cellHeight)
            end
        end
    end
end

function Visualizer:drawNestedCA(nestedCA, x, y, width, height)
    local nestedCellWidth = width / nestedCA.grid.cols
    local nestedCellHeight = height / nestedCA.grid.rows
    
    -- Draw semi-transparent background if nestedCA has a color
    if nestedCA.color then
        fill(0)
        rect(x, y, width, height)
        fill(nestedCA.color.r, nestedCA.color.g, nestedCA.color.b, 61) -- 51 is about 20% opacity
        rect(x, y, width, height)
    end
    
    for i = 1, nestedCA.grid.rows do
        for j = 1, nestedCA.grid.cols do
            local cell = nestedCA.grid:getValueOrGrid(i, j)
            local nestedX = x + (j - 1) * nestedCellWidth
            local nestedY = y + (i - 1) * nestedCellHeight
            
            if type(cell) == "table" and cell.class == "CellularAutomata" then
                -- Recursively draw deeper nested CA
                self:drawNestedCA(cell, nestedX, nestedY, nestedCellWidth, nestedCellHeight)
            elseif cell == 1 then
                -- Draw the nested cell
                fill(nestedCA.color or color(10, 110, 220))
                rect(nestedX, nestedY, nestedCellWidth * 1.65, nestedCellHeight * 1.65)
            end
        end
    end
end

function Visualizer:drawNestedCA(nestedCA, x, y, width, height)
    local nestedCellWidth = width / nestedCA.grid.cols
    local nestedCellHeight = height / nestedCA.grid.rows
    
    -- Draw semi-transparent background if nestedCA has a color
    if nestedCA.color then
        fill(0)
        rect(x, y, width, height)
        fill(nestedCA.color.r, nestedCA.color.g, nestedCA.color.b, 51) -- 20% opacity
        rect(x, y, width, height)
    end
    
    for i = 1, nestedCA.grid.rows do
        for j = 1, nestedCA.grid.cols do
            local cell = nestedCA.grid:getValueOrGrid(i, j)
            local nestedX = x + (j - 1) * nestedCellWidth
            local nestedY = y + (i - 1) * nestedCellHeight
            
            if type(cell) == "table" then
                -- Recursively draw deeper nested CA
                self:drawNestedCA(cell, nestedX, nestedY, nestedCellWidth, nestedCellHeight)
            elseif cell == 1 then
                -- Draw the nested cell
                fill(nestedCA.color or color(10, 110, 220))
                rect(nestedX, nestedY, nestedCellWidth * 1.65, nestedCellHeight * 1.65)
            end
        end
    end

    if nestedCA.isContiguous then
        fill(255, 0, 0) -- Red color for the marker
        ellipse(x + (width * 0.85), y + (height * 0.8), 10) -- Position and size of the marker
    end
end


function Visualizer:calculateCellSizeAndOffset()
    local margin = math.min(WIDTH, HEIGHT) / 23
    local maxCellsInRow = math.max(self.ca.grid.rows, self.ca.grid.cols)
    local minDimension = math.min(WIDTH, HEIGHT)
    local cellSize = (minDimension - 2 * margin) / maxCellsInRow
    
    self.cellWidth = cellSize
    self.cellHeight = cellSize
    
    -- Calculate offset to center the grid
    self.offsetX = (WIDTH - self.cellWidth * self.ca.grid.cols) / 2
    self.offsetY = (HEIGHT - self.cellHeight * self.ca.grid.rows) / 2
end

function Visualizer:drawNestedCA(nestedCA, x, y, width, height, macroRow, macroCol)
    local nestedCellWidth = width / nestedCA.grid.cols
    local nestedCellHeight = height / nestedCA.grid.rows
    
    -- Draw semi-transparent background if nestedCA has a color
    if nestedCA.color then
        fill(0)
        rect(x, y, width, height)
        fill(nestedCA.color.r, nestedCA.color.g, nestedCA.color.b, 51) -- 20% opacity
        rect(x, y, width, height)
    end
    
    local macroNeighbors = nestedCA.neighborDirections or {}
    local macroNeighbors = self.ca.systems[1]:directionsOfNeighbors(self.ca.grid, macroRow, macroCol)
    for i = 1, nestedCA.grid.rows do
        for j = 1, nestedCA.grid.cols do
            local cell = nestedCA.grid:getFullCell(i, j)
            local nestedX = x + (j - 1) * nestedCellWidth
            local nestedY = y + (i - 1) * nestedCellHeight
            
            if type(cell) == "table" then
                -- Recursively draw deeper nested CA
                self:drawNestedCA(cell, nestedX, nestedY, nestedCellWidth, nestedCellHeight)
            else
                -- Draw the cell with neighbor information if it's a CanContiguousGOL
                if nestedCA.class == "CanContiguousGOL" then
                   -- self:drawCellWithNeighborInfo(cell, nestedX, nestedY, macroNeighbors)
                else
                    -- Draw regular cell
                    fill(cell == 1 and color(10, 110, 220) or color(0))
                    rect(nestedX, nestedY, nestedCellWidth * 1.65, nestedCellHeight * 1.65)
                end
            end
        end
    end
    fill(236, 205, 67)
    text(#macroNeighbors, x + (width * 0.2), y + (height * 0.2))
    if nestedCA.class == "CanContiguousGOL" then
        self:drawCellWithNeighborInfo(cell, nestedX, nestedY, macroNeighbors)
    end
end

function Visualizer:drawDirectionIndicator(x, y, direction)
    -- Draw a small marker for the direction
    local markerSize = math.min(self.cellWidth, self.cellHeight) / 44
    local offsetX, offsetY = self:getOffsetForDirection(direction, self.cellWidth, self.cellHeight)
    
    fill(255) -- White color for the marker
    ellipse(x + offsetX, y + offsetY, markerSize, markerSize)
end

function Visualizer:getOffsetForDirection(direction, cellWidth, cellHeight)
    local offsets = {
        N = {cellWidth / 2, 0},
        S = {cellWidth / 2, cellHeight},
        E = {cellWidth, cellHeight / 2},
        W = {0, cellHeight / 2},
        -- Add other directions as needed
    }
    return offsets[direction][1], offsets[direction][2]
end


-- ... existing code ...

function Visualizer:drawNestedCA(nestedCA, x, y, width, height, macroRow, macroCol)
    local nestedCellWidth = width / nestedCA.grid.cols
    local nestedCellHeight = height / nestedCA.grid.rows
    
    -- Draw semi-transparent background if nestedCA has a color
    if nestedCA.color then
        fill(0)
        rect(x, y, width, height)
        fill(nestedCA.color.r, nestedCA.color.g, nestedCA.color.b, 51) -- 20% opacity
        rect(x, y, width, height)
    end
    
    -- Get neighbor directions for the macro cell
    local macroNeighbors = self.ca.systems[1]:directionsOfNeighbors(self.ca.grid, macroRow, macroCol)
    
    for i = 1, nestedCA.grid.rows do
        for j = 1, nestedCA.grid.cols do
            local cell = nestedCA.grid:getFullCell(i, j)
            local nestedX = x + (j - 1) * nestedCellWidth
            local nestedY = y + (i - 1) * nestedCellHeight
            
            if type(cell) == "table" then
                self:drawNestedCA(cell, nestedX, nestedY, nestedCellWidth, nestedCellHeight, i, j)
            else
                --self:drawCellWithNeighborInfo(cell, nestedX, nestedY, macroNeighbors)
            end
        end
    end
    fill(236, 205, 67)
    text(#macroNeighbors, x + (width * 0.2), y + (height * 0.2))
    if nestedCA.class == "CanContiguousGOL" then
        self:drawCellWithNeighborInfo(nestedCA, nestedX, nestedY, macroNeighbors)
    end
end

function Visualizer:drawCellWithNeighborInfo(cell, x, y, neighborDirections)
    -- Determine the color or marker based on the neighborDirections
    local hasNeighbors = #neighborDirections > 0
    local fillColor = hasNeighbors and color(0, 255, 0, 100) -- Light green with some transparency
    or color(255, 0, 0, 100) -- Light red with some transparency
    
    -- Draw the cell with the determined color
    fill(fillColor)
    rect(x, y, self.cellWidth, self.cellHeight)
    
    -- Optionally, draw markers or indicators for specific neighbor directions
    if hasNeighbors then
        for _, direction in ipairs(neighborDirections) do
            self:drawDirectionIndicator(x, y, direction)
        end
    end
end

function Visualizer:drawDirectionIndicator(x, y, direction)
    local markerSize = math.min(self.cellWidth, self.cellHeight) / 7
    local offsetX, offsetY = self:getOffsetForDirection(direction)
    
    -- Debugging: Use different colors for different directions
    local colorMap = { N = color(255, 0, 0), S = color(0, 255, 0), E = color(0, 94, 255), W = color(255, 255, 0) }
    fill(colorMap[direction] or color(255, 0))  -- Default to white if direction not found
    ellipse(x + offsetX, y + offsetY, markerSize, markerSize)
end

function Visualizer:getOffsetForDirection(direction)
    local offsets = {
        N = {0, self.cellHeight * 0.35},  -- Slightly above the cell
        S = {0, self.cellHeight * -0.35},  -- Slightly below the cell
        E = {self.cellWidth * 0.4, 0},  -- Slightly to the right of the cell
        W = {self.cellWidth * -0.4, 0},  -- Slightly to the left of the cell
        -- Add other directions as needed
    }
    return offsets[direction] and offsets[direction][1] or 0, offsets[direction] and offsets[direction][2] or 0
end

function Visualizer:draw()
    for i = 1, self.ca.grid.rows do
        for j = 1, self.ca.grid.cols do
            local cell = self.ca.grid.cells[i][j]
            local x = (j - 1) * self.cellWidth + self.offsetX
            local y = (i - 1) * self.cellHeight + self.offsetY
            
            if type(cell) == "table" and cell.class == "CellularAutomata" then
                -- Draw the nested CA
                self:drawNestedCA(cell, x, y, self.cellWidth, self.cellHeight, i, j)
            else
                -- Draw regular cell (alive cells in white, dead cells in black)
                fill(cell == 1 and color(255) or color(0))
                rect(x, y, self.cellWidth, self.cellHeight)
            end
        end
    end
end

function Visualizer:drawNestedCA(nestedCA, x, y, width, height, macroRow, macroCol)
    local nestedCellWidth = width / nestedCA.grid.cols
    local nestedCellHeight = height / nestedCA.grid.rows
    
    -- Draw semi-transparent background if nestedCA has a color
    if nestedCA.color then
        fill(0)
        rect(x, y, width, height)
        fill(nestedCA.color.r, nestedCA.color.g, nestedCA.color.b, 51) -- 20% opacity
        rect(x, y, width, height)
    end
    
    for i = 1, nestedCA.grid.rows do
        for j = 1, nestedCA.grid.cols do
            local cell = nestedCA.grid:getFullCell(i, j)
            local nestedX = x + (j - 1) * nestedCellWidth
            local nestedY = y + (i - 1) * nestedCellHeight
            
            if type(cell) == "table" then
                -- Recursively draw deeper nested CA
                self:drawNestedCA(cell, nestedX, nestedY, nestedCellWidth, nestedCellHeight)
            else
                -- Draw regular microcell
                fill(cell == 1 and nestedCA.color or color(0))
                rect(nestedX, nestedY, nestedCellWidth * 1.65, nestedCellHeight * 1.65)
            end
        end
    end
    
    -- Draw neighbor information after all microcells
    self:drawMacroCellNeighborInfo(x, y, width, height, macroRow, macroCol)
end

function Visualizer:drawMacroCellNeighborInfo(x, y, width, height, macroRow, macroCol)
    local macroNeighbors = self.ca.systems[1]:directionsOfNeighbors(self.ca.grid, macroRow, macroCol)
    
    -- Draw neighbor count
    fill(236, 205, 67)
    text(#macroNeighbors, x + (width * 0.2), y + (height * 0.2))
    
    -- Draw direction indicators
    for _, direction in ipairs(macroNeighbors) do
        self:drawDirectionIndicator(x + width / 2, y + height / 2, direction)
    end
end

function Visualizer:drawDirectionIndicator(x, y, direction)
    local markerSize = math.min(self.cellWidth, self.cellHeight) / 5
    local offsetX, offsetY = self:getOffsetForDirection(direction)
    
    -- Debugging: Use different colors for different directions
    local colorMap = {
        N = color(255, 0, 0), S = color(0, 255, 0), 
        E = color(0, 0, 255), W = color(255, 255, 0),
        NE = color(255, 0, 255), SE = color(0, 255, 255),
        SW = color(100, 255, 0), NW = color(255, 100, 0)
    }
    fill(colorMap[direction] or color(255))  -- Default to white if direction not found
    ellipse(x + offsetX, y + offsetY, markerSize, markerSize)
end

function Visualizer:getOffsetForDirection(direction)
    local offsets = {
        N = {0, self.cellHeight * 0.5},
        S = {0, self.cellHeight * -0.5},
        E = {self.cellWidth * 0.4, 0},
        W = {self.cellWidth * -0.4, 0},
        NE = {self.cellWidth * 0.3, self.cellHeight * 0.3},
        SE = {self.cellWidth * 0.3, self.cellHeight * -0.3},
        SW = {self.cellWidth * -0.3, self.cellHeight * -0.3},
        NW = {self.cellWidth * -0.3, self.cellHeight * 0.3}
    }
    return offsets[direction] and offsets[direction][1] or 0, offsets[direction] and offsets[direction][2] or 0
end

function Visualizer:drawMacroCellNeighborInfo(x, y, width, height, macroRow, macroCol)
local macroNeighbors = self.ca.systems[1]:directionsOfNeighbors(self.ca.grid, macroRow, macroCol)

-- Draw neighbor count
fill(236, 205, 67)
text(#macroNeighbors, x + (width * 0.2), y + (height * 0.2))

-- Draw direction indicators
for _, direction in ipairs(macroNeighbors) do
    self:drawDirectionIndicator(x + width / 2, y + height / 2, direction)
end
end

function Visualizer:drawCellWithNeighborInfo(cell, x, y, neighborDirections)
    -- Determine the color or marker based on the neighborDirections
    local hasNeighbors = #neighborDirections > 0
    local fillColor = hasNeighbors and color(0, 255, 0, 100) -- Light green with some transparency
    or color(255, 0, 0, 100) -- Light red with some transparency
    
    -- Draw the cell with the determined color
    fill(fillColor)
    rect(x, y, self.cellWidth, self.cellHeight)
    
    -- Optionally, draw markers or indicators for specific neighbor directions
    if hasNeighbors then
        for _, direction in ipairs(neighborDirections) do
            self:drawDirectionIndicator(x, y, direction)
        end
    end
end

function Visualizer:drawDirectionIndicator(x, y, direction)
    local markerSize = math.min(self.cellWidth, self.cellHeight) / 5
    local offsetX, offsetY = self:getOffsetForDirection(direction)
    
    -- Debugging: Use different colors for different directions
    local colorMap = { N = color(255, 0, 0), S = color(0, 255, 0), E = color(188, 125, 225), W = color(255, 255, 0) }
    
    -- Assign colors following the sequence of the color wheel
    local colorMap = {
        N = color(255, 0, 0), -- Red
        NE = color(255, 127, 0), -- Orange
        E = color(255, 255, 0), -- Yellow
        SE = color(0, 255, 0), -- Green
        S = color(0, 255, 255), -- Cyan
        SW = color(0, 0, 255), -- Blue
        W = color(127, 0, 255), -- Indigo
        NW = color(255, 0, 255) -- Violet
    }
    pushStyle()
    rectMode(CENTER)
    fill(colorMap[direction] or color(255, 0))  -- Default to white if direction not found
    rect(x + offsetX, y + offsetY, markerSize, markerSize)
    popStyle()
end

function Visualizer:getOffsetForDirection(direction)
    local offset = (self.cellHeight * 0.4) - 1
    local offsets = {
        N = {0, offset},  -- Slightly above the cell
        S = {0, -offset},  -- Slightly below the cell
        E = {offset, 0},  -- Slightly to the right of the cell
        W = {-offset, 0},  -- Slightly to the left of the cell
        NE = {offset, offset},
        SE = {offset, -offset},
        SW = {-offset, -offset},
        NW = {-offset, offset}
    }
    return offsets[direction] and offsets[direction][1] or 0, offsets[direction] and offsets[direction][2] or 0
end


Visualizer = class()

function Visualizer:init(grid)
    self.grid = grid
    self:calculateCellSizeAndOffset()
end

function Visualizer:draw()
    for i = 1, self.grid.rows do
        for j = 1, self.grid.cols do
            local cell = self.grid.cells[i][j]
            local x = (j - 1) * self.cellWidth + self.offsetX
            local y = (i - 1) * self.cellHeight + self.offsetY
            
            -- Draw regular cell (alive cells in white, dead cells in black)
            fill(cell == 1 and color(255) or color(0))
            rect(x, y, self.cellWidth, self.cellHeight)
        end
    end
end

function Visualizer:calculateCellSizeAndOffset()
    local margin = math.min(WIDTH, HEIGHT) / 23
    local maxCellsInRow = math.max(self.grid.rows, self.grid.cols)
    local minDimension = math.min(WIDTH, HEIGHT)
    local cellSize = (minDimension - 2 * margin) / maxCellsInRow
    
    self.cellWidth = cellSize
    self.cellHeight = cellSize
    
    -- Calculate offset to center the grid
    self.offsetX = (WIDTH - self.cellWidth * self.grid.cols) / 2
    self.offsetY = (HEIGHT - self.cellHeight * self.grid.rows) / 2
end