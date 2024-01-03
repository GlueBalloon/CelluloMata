
ConwaysGOL = class()

function ConwaysGOL:nextCellState(grid, row, col)
    -- does cell have 3 neighbors?
    local hasThree = grid:livingNeighborCountIs(row, col, 3)
    -- is cell already alive with 2 neighbors?
    local aliveWithTwo = grid:isAlive(row, col) and grid:livingNeighborCountIs(row, col, 2)
    -- lives if either is true
    return hasThree or aliveWithTwo
end

CAGrid = class()

function CAGrid:init(rows, cols)
    self.rows = rows
    self.cols = cols
    -- Initialize other properties...
    self.queriedCell = nil  -- To store the focused cell coordinates
end

function CAGrid:cellQuery(row, col)
    self.queriedCell = {row = row, col = col}
    return self
end

function CAGrid:makeTableOrGetQueriedCell(row, col)
    if row and col then
        return {row = row, col = col}
    elseif self.queriedCell then
        return self.queriedCell
    else 
        print("makeTableOrGetQueriedCell: no parameters or queriedCell")
        return nil
    end
end

function CAGrid:confirmNeighborCount(count, row, col)
    if row and col then return self:confirmNeighborCountViaCoords(count, row, col)
    elseif self.queriedCell then return self:confirmNeighborCountViaQueriedCell(count)
    else 
        print("confirmNeighborCount: no coords or queriedCell")
        return nil
    end 
end

--[[
function NestedGameOfLife:nextCellState(row,Col)
    local returnValue
    -- does cell have 3 neighbors?
    local hasThree = grid:queryCell(row, col):livingNeighborCountIs(3)
    -- is cell already alive with 2 neighbors?
    local aliveWithTwo = grid:queryCell():isAlive():livingNeighborCountIs(2)
    -- update any nested CA
    if hasThree or aliveWithTwo then
        returnValue = grid:queryCell():nextNestedState(function(row, col)
            -- does cell have 3 neighbors?
            local hasThree = grid:queryNested(row, col):livingNeighborCountIs(3)
            -- is cell already alive with 2 neighbors?
            local aliveWithTwo = grid:queryNested():isAlive():livingNeighborCountIs(2)
            -- update any nested CA
            if hasThree or aliveWithTwo then return true end
        end)
        return returnValue
    end
end
]]

function CAGrid:isAlive()
    if not self.queriedCell then
        error("No cell queried to check if alive.")
        return false
    end
    
    return self:getCellState(self.queriedCell.row, self.queriedCell.col) == 1
end

-- Implement other methods like getCellState, countNeighbors...



System = class()

function System:init()
    self.class = "System"
    -- Initialization for generic system rules
end

function System:setup(grid)
    -- Setup logic specific to the system
end

function System:applyRule(grid, row, col)
    -- To be overridden in subclasses
    if not applyRuleWarningGiven then
        print("applyRule not implemented")
        applyRuleWarningGiven = true
    end
end

-- Generic parentDataFetcher method, which can be overridden
function System:parentDataFetcher(queryName, ...)
    -- Default implementation, can be overridden by subclasses
    return nil
end

-- New method for actions after all updates
function System:afterUpdates(grid)
    -- Default implementation does nothing
    -- Subclasses can override this method
end




-- Conway's Game of Life as a System object

ConwaysGameOfLife = class(System)

function ConwaysGameOfLife:init()
    System.init(self)
    self.class = "ConwaysGameOfLife" -- class definition has to come after superclass init
    -- Initialization
end

function ConwaysGameOfLife:setup(grid)
    -- Initialize the grid, if needed
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = math.random(0, 1)  -- Randomly assign cell as alive (1) or dead (0)
        end
    end
end

function ConwaysGameOfLife:updateGrid(grid)
    local newGrid = CAGrid(grid.rows, grid.cols)
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            newGrid.cells[i][j] = self:applyRule(grid, i, j)
        end
    end
    
    -- Update the original grid's cells with the new states
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = newGrid.cells[i][j]
        end
    end
end

function ConwaysGameOfLife:applyRule(grid, row, col)
    local neighborCount = self:countNeighbors(grid, row, col)
    local cell = grid:getValueOrGrid(row, col, true) -- Assuming wrap-around behavior
    return (neighborCount == 3 or (cell == 1 and neighborCount == 2)) and 1 or 0
end

function ConwaysGameOfLife:countNeighbors(grid, row, col)
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local neighbor = grid:getValueOrGrid(row + i, col + j, true) -- Wrap-around
                count = count + (self:isAlive(neighbor) and 1 or 0)
            end
        end
    end
    return count
end

function ConwaysGameOfLife:isAlive(cell)
    return cell == 1
end




-- Conway's Game of Life but cells update in random order

RandomOrderSystem = class(System)

function RandomOrderSystem:init(updateCountPerCycle)
    System.init(self)  -- Initialize the base system
    self.class = "RandomOrderSystem" -- class definition has to come after superclass init
    self.updateCountPerCycle = updateCountPerCycle or 1  -- Number of cells to update per cycle, defaulting to 1
    self.updateOrder = {}  -- List to store the order in which cells will be updated
end

function RandomOrderSystem:setup(grid)
    -- initialize the grid
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = math.random(0, 1)
        end
    end
    -- Generate the initial random update order
    self:generateRandomUpdateOrder(grid)
end

function RandomOrderSystem:generateRandomUpdateOrder(grid)
    self.updateOrder = {}
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            table.insert(self.updateOrder, {row = i, col = j})
        end
    end
    -- Shuffle the update order randomly
    for i = #self.updateOrder, 2, -1 do
        local j = math.random(i)
        self.updateOrder[i], self.updateOrder[j] = self.updateOrder[j], self.updateOrder[i]
    end
end

function RandomOrderSystem:updateGrid(grid)
    local newStates = {}  -- Temporary storage for the new states
    local cellsToUpdate = math.min(self.updateCountPerCycle, #self.updateOrder)
    
    -- Calculate the new states for a certain number of cells
    for i = 1, cellsToUpdate do
        if #self.updateOrder > 0 then
            local cellCoords = table.remove(self.updateOrder)  -- Get the next cell coordinates
            local newState = self:applyRule(grid, cellCoords.row, cellCoords.col)
            table.insert(newStates, {coords = cellCoords, state = newState})
        end
    end
    
    -- Apply the new states to the grid
    for _, cellState in ipairs(newStates) do
        grid.cells[cellState.coords.row][cellState.coords.col] = cellState.state
    end
    
    -- If all cells have been updated, regenerate the update order
    if #self.updateOrder == 0 then
        self:generateRandomUpdateOrder(grid)
    end
end


function RandomOrderSystem:applyRule(grid, row, col)
    local neighborCount = self:countNeighbors(grid, row, col)
    local cell = grid:getValueOrGrid(row, col)
    local isAlive = cell == 1  -- Assuming 1 represents a living cell
    
    -- Apply the Game of Life rules
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        return 1  -- Cell stays alive
    elseif not isAlive and neighborCount == 3 then
        return 1  -- Cell becomes alive
    else
        return 0  -- Cell dies or remains dead
    end
end

function RandomOrderSystem:countNeighbors(grid, row, col)
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local neighbor = grid:getValueOrGrid(row + i, col + j)
                if neighbor == 1 then  -- Assuming 1 represents a living cell
                    count = count + 1
                end
            end
        end
    end
    return count
end

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

-- Implement the isAliveConsideringNeighbors method in CAGrid
