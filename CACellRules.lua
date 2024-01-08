-- base Cellular Automata structure
CACellRules = class()
function CACellRules:init() end
function CACellRules:setup(grid) end
function CACellRules:nextCellState(grid, row, col) end





-- Conway's Game Of Life in that structure
-- Conway's Game Of Life in that structure
ConwaysGOL = class(CACellRules)
ConwaysGOL.randomFill = function(grid)
    for i = 1, #grid do
        for j = 1, #grid[i] do
            grid[i][j] = math.random(0, 1) -- Randomly set to 0 or 1
        end
    end
end

function ConwaysGOL:init()
    CACellRules.init(self)
end

function ConwaysGOL:setup(grid)
    -- Randomly assign living (1) or dead (0) states to the grid cells
    self.randomFill(grid.cells)
    -- turn on grid wraparound
    grid.wrapsAround = true
end

function ConwaysGOL:nextCellState(grid, row, col)
    -- is cell alive?
    local isAlive = grid:queriedIsAlive(row, col)
    -- does cell have 2 neighbors?
    local hasTwo = grid:queryCell(row, col):queriedNeighborCountIs(2)
    -- does cell have 3 neighbors?
    local hasThree = grid:queryCell(row, col):queriedNeighborCountIs(3)
    -- if becoming alive, return 1
    if (not isAlive) and hasThree then return 1 end
    -- if staying alive, return whatever is in existing cell
    if isAlive and (hasTwo or hasThree) then
        return grid.cells[row][col]
    end
    -- otherwise, return 0 for being dead
    return 0
end





-- NestingGOLRules Class
NestingGOLRules = class(CACellRules)
NestingGOLRules.convertOnesToGrids = function(grid, rows, cols)
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            if grid.cells[i][j] ~= 0 then
                -- Convert cell to a nested grid
                local nestedGrid = CAGrid(rows, cols)
                nestedGrid.color = randomPastellyColor()
                grid.cells[i][j] = nestedGrid                
                -- Randomly initialize the nested grid
                for r = 1, rows do
                    for c = 1, cols do
                        nestedGrid.cells[r][c] = math.random(0, 1)
                    end
                end
            end
        end
    end
end

function NestingGOLRules:init(rows, cols)
    CACellRules.init(self)
    self.rows = rows or 6
    self.cols = cols or 6
end

function NestingGOLRules:setup(grid)
    self.convertOnesToGrids(grid, self.rows, self.cols)
end

function NestingGOLRules:nextCellState(grid, row, col)
    -- is cell alive?
    local isAlive = grid:queriedIsAlive(row, col)
    -- does cell have 2 neighbors?
    local hasTwo = grid:queryCell(row, col):queriedNeighborCountIs(2)
    -- does cell have 3 neighbors?
    local hasThree = grid:queryCell(row, col):queriedNeighborCountIs(3)
    -- if becoming alive, return new nested grid
    if (not isAlive) and hasThree then 
        local newGrid = CAGrid(self.rows, self.cols)
        newGrid.color = randomPastellyColor()
        ConwaysGOL.randomFill(newGrid.cells)
        return newGrid 
    end
    -- if staying alive, return whatever is in existing cell
    if isAlive and (hasTwo or hasThree) then
        local contents = grid.cells[row][col]
        -- Check for nested grid
        if type(contents) == "table" then
            local newStates = contents:resultsForEachCell(function(grid,row,col)
                return ConwaysGOL.nextCellState(self, grid, row,col)
            end)
            contents:applyNewStates(newStates)
        end
        return contents
    end
    -- otherwise, return 0 for being dead
    return 0
end

