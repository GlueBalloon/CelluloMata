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

