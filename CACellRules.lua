-- base Cellular Automata structure
CACellRules = class()
function CACellRules:init() end
function CACellRules:setup(grid) end
function CACellRules:nextCellState(grid, row, col) end





-- Conway's Game Of Life in that structure
ConwaysGOL = class(CACellRules)

function ConwaysGOL:init()
    CACellRules.init(self)
end

function ConwaysGOL:setup(grid)
    -- Randomly assign living (1) or dead (0) states to the grid cells
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = math.random(0, 1) -- Randomly set to 0 or 1
        end
    end
    -- turn on grid wraparound
    grid.wrapsAround = true
end

function ConwaysGOL:nextCellState(grid, row, col)
    -- does cell have 3 neighbors?
    local hasThree = grid:queryCell(row, col):queriedNeighborCountIs(3)
    -- is cell already alive with 2 neighbors?
    local aliveWithTwo = grid:queriedIsAlive(row, col) and grid:queriedNeighborCountIs(2)
    -- lives if either is true
    return (hasThree or aliveWithTwo) and 1 or 0
end





-- NestingGOLRules Class
NestingGOLRules = class(CACellRules)

function NestingGOLRules:init(rows, cols)
    CACellRules.init(self)
    self.rows = rows or 6
    self.cols = cols or 6
end

function NestingGOLRules:setup(grid)
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            if grid.cells[i][j] ~= 0 then
                -- Convert cell to a nested grid
                local nestedGrid = CAGrid.gridOfZeros(self.rows, self.cols)
                grid.cells[i][j] = nestedGrid
                
                -- Randomly initialize the nested grid
                for r = 1, self.rows do
                    for c = 1, self.cols do
                        nestedGrid[r][c] = math.random(0, 1)
                    end
                end
            end
        end
    end
end

function NestingGOLRules:nextCellState(grid, row, col)
    -- Check if the cell currently has a nested grid or is empty
    local currentCell = grid.cells[row][col]
    local isNestedGrid = type(currentCell) == "table"  
    -- does cell have 3 neighbors?
    local hasThree = grid:queryCell(row, col):queriedNeighborCountIs(3)
    -- is cell already alive with 2 neighbors?
    local aliveWithTwo = isNestedGrid and grid:queriedNeighborCountIs(2)
    
    if hasThree or aliveWithTwo then
        -- If the cell should be alive, return the existing grid if present, or create a new one
        return isNestedGrid and currentCell or CAGrid.gridOfZeros(grid.rows, grid.cols)
    else
        -- If the cell should be dead, return 0
        return 0
    end
end

