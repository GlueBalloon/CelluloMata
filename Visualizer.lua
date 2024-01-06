
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
            fill(cell == 1 and self.grid.color or color(0))
            rect(x, y, self.cellWidth, self.cellHeight)

            --needs to detect a nested table, and draw its cells within the cell
            if type(cell) == "table" then
                for k = 1, #cell do
                    local subCell = cell[k]
                    local subX = x + (k - 1) * self.cellWidth / #cell
                    local subY = y + (k - 1) * self.cellHeight / #cell
                    fill(subCell == 1 and self.grid.color or color(0))
                    rect(subX, subY, self.cellWidth / #cell, self.cellHeight / #cell)
                end
            end
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