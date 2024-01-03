-- A self-nesting version of the Game of Life

NestingGameOfLife = class(ConwaysGameOfLife)

function NestingGameOfLife:init()
    ConwaysGameOfLife.init(self)  -- Call the superclass initializer
    self.class = "NestingGameOfLife" -- class definition has to come after superclass init
end

function NestingGameOfLife:setup(grid)
    self.grid = grid
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            if math.random(0, 1) == 1 then
                -- Randomly decide if a cell should be a nested CA
                grid.cells[i][j] = self:createNestedCA()
            else
                grid.cells[i][j] = 0  -- Non-nested cell
            end
        end
    end
end

function NestingGameOfLife:applyRule(grid, row, col)
    local cell = grid:getValueOrGrid(row, col, true)  -- Assuming wrap-around behavior
    local isAlive = self:isAlive(cell)
    local neighborCount = self:countNeighbors(grid, row, col)
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        return cell  -- Cell stays alive
    elseif not isAlive and neighborCount == 3 then
        return self:createNestedCA()  -- Cell becomes a nested CA
    else
        return 0  -- Cell dies
    end
end

function NestingGameOfLife:createNestedCA()
    local nestedCA = CellularAutomata({ConwaysGameOfLife()}, self.grid.rows, self.grid.cols)
    --nestedCA.color = self:randomColor()  -- Assign a random color
    return nestedCA
end

function NestingGameOfLife:randomColor()
    return color(math.random(255), math.random(255), math.random(255))
end

function NestingGameOfLife:isAlive(cell)
    return cell == 1 or (type(cell) == "table" and cell.class == "CellularAutomata")
end


NestingGameOfLife = class(ConwaysGameOfLife)

function NestingGameOfLife:init(createNestedGOLFunc)
    ConwaysGameOfLife.init(self)
    self.class = "NestingGameOfLife" -- class definition has to come after superclass init
    self.createNestedGOL = createNestedGOLFunc
end

function NestingGameOfLife:setup(grid)
    self.grid = grid
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            if math.random(0, 1) == 1 then
                -- Randomly decide if a cell should be a nested CA
                grid.cells[i][j] = self:createNestedGOL()
            else
                grid.cells[i][j] = 0  -- Non-nested cell
            end
        end
    end
end

function NestingGameOfLife:applyRule(grid, row, col)
    local cell = grid:getValueOrGrid(row, col, true)
    local isAlive = self:isAlive(cell)
    local neighborCount = self:countNeighbors(grid, row, col)
    
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        return grid:getFullCell(row, col, true)
    elseif not isAlive and neighborCount == 3 then
        if self.createNestedGOL then
            return self.createNestedGOL()  -- Create a nested CA
        end
    else
        return 0
    end
end

function NestingGameOfLife:updateGrid(grid)
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

function NestingGameOfLife:randomColor()
    return color(math.random(255), math.random(255), math.random(255))
end

function NestingGameOfLife:isAlive(cell)
    return cell ~= 0
end






CanContiguousGOL = class(ConwaysGameOfLife)

function CanContiguousGOL:init()
    ConwaysGameOfLife.init(self)
    self.class = "CanContiguousGOL" -- class definition has to come after superclass init
end

function CanContiguousGOL:updateGrid(grid)  
        ConwaysGameOfLife.updateGrid(self, grid)
end




ContiguousNestingGOL = class(NestingGameOfLife)

function ContiguousNestingGOL:init(createNestedGOLFunc)
    NestingGameOfLife.init(self, createNestedGOLFunc)
    self.class = "ContiguousNestingGOL" -- class definition has to come after superclass init
end

function ContiguousNestingGOL:applyRule(grid, row, col)
    local cell = grid:getValueOrGrid(row, col)
    local isAlive = self:isAlive(cell)
    local neighborCount = self:countNeighbors(grid, row, col)
    
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        local returnCell = grid:getFullCell(row, col)
        if returnCell == 1 then print ("got 1") end
        return returnCell
    elseif not isAlive and neighborCount == 3 then
        if self.createNestedGOL then
            return self.createNestedGOL()  -- Create a nested CA
        end
    else
        return 0
    end
end

function ContiguousNestingGOL:countNeighbors(grid, row, col)
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            -- Skip the current cell
            if not (i == 0 and j == 0) then
                local neighborRow = row + i
                local neighborCol = col + j
                
                -- Check for edge conditions
                if neighborRow >= 1 and neighborRow <= grid.rows and 
                neighborCol >= 1 and neighborCol <= grid.cols then
                    local neighbor = grid:getValueOrGrid(neighborRow, neighborCol)
                    count = count + (self:isAlive(neighbor) and 1 or 0)
                end
            end
        end
    end
    return count
end


function ContiguousNestingGOL:updateGrid(grid)
    local newGrid = CAGrid(grid.rows, grid.cols)
    local persistingGrids = CAGrid(grid.rows, grid.cols)  -- For tracking persisting grids
    
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            local cell = grid:getValueOrGrid(i, j)
            local newCell = self:applyRule(grid, i, j)
            newGrid.cells[i][j] = newCell
            
            -- if cell is alive, reset 'isContiguous'
            if self:isAlive(cell) then
                grid:getFullCell(i,j).isContiguous = false
                -- if cell persists, update persistence tracking
                if self:isAlive(newCell) then
                    persistingGrids.cells[i][j] = 1
                end
            end
        end
    end
    
    -- Update the original grid's cells with the new states
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = newGrid.cells[i][j]
        end
    end
    
    -- Get clusters of contiguous grids
    self.clusters = self:getClustersFrom(grid, persistingGrids)
    
    -- update grids in those clusters
    for _, cluster in ipairs(self.clusters) do
        self:updateCluster(cluster)
    end
end

function ContiguousNestingGOL:updateCluster(cluster)
    local tempGrids = {}
    
    -- Create temporary grids for each cell in the cluster
    for _, clusterElement in ipairs(cluster) do
        local grid = clusterElement.cell.grid
        local tempGrid = CAGrid(grid.rows, grid.cols)
        tempGrids[grid] = tempGrid
    end
    
    -- Calculate new states for each cell in each grid
    for _, clusterElement in ipairs(cluster) do
        local grid = clusterElement.cell.grid
        for i = 1, grid.rows do
            for j = 1, grid.cols do
                local newState = self:specialApplyRule(clusterElement, i, j, cluster)
                tempGrids[grid].cells[i][j] = newState
            end
        end
    end
    
    -- Update original grids with the new states
    for _, clusterElement in ipairs(cluster) do
        local grid = clusterElement.cell.grid
        grid.cells = tempGrids[grid].cells
    end
end

function ContiguousNestingGOL:specialApplyRule(clusterElement, row, col, cluster)
    -- Count the neighbors considering the contiguous cluster
    local neighborCount = self:countL2CellNeighborsInCluster(clusterElement, row, col, cluster)
    
    -- Get the current cell state
    local cell = clusterElement.cell.grid:getValueOrGrid(row, col)
    local isAlive = self:isAlive(cell)
    
    -- Apply the Game of Life rules with additional considerations for contiguous CAs
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        return 1 -- Cell stays alive
    elseif not isAlive and neighborCount == 3 then
        return 1 -- Cell becomes alive
    else
        return 0 -- Cell dies
    end
end

function ContiguousNestingGOL:isAlive(cell)
    return cell ~= 0
end

function ContiguousNestingGOL:getClustersFrom(grid, persistingGrids)
    local clusters = {}
    for i = 1, persistingGrids.rows do
        for j = 1, persistingGrids.cols do
            if (persistingGrids.cells[i][j] == 1) then
                local fullCell = grid:getFullCell(i, j)
                if not fullCell.isContiguous then 
                    local cluster = self:findClusterAround(i, j, grid, persistingGrids)
                    if #cluster > 1 then  -- More than one cell in the cluster indicates contiguity
                        for _, cellTable in ipairs(cluster) do
                            cellTable.cell.isContiguous = true
                        end
                        table.insert(clusters, cluster)
                    else
                        cluster[1].cell.isContiguous = false
                    end
                end
            end
        end
    end
    return clusters
end

function ContiguousNestingGOL:findClusterAround(row, col, grid, persistingGrids)
    local cluster = {}
    local checked = {}  -- To keep track of cells already checked
    
    local function checkCell(r, c)
        -- Unique identifier for each cell
        local cellKey = r .. "," .. c
        
        -- Check if cell has been processed or is not persisting
        if checked[cellKey] or persistingGrids.cells[r][c] ~= 1 then
            return
        end
        
        -- Mark cell as checked
        checked[cellKey] = true
        
        -- Add cell to cluster
        local cell = grid:getFullCell(r, c)
        table.insert(cluster, { cell = cell, row = r, col = c })
        
        -- Recursively check orthogonal neighbors
        for _, direction in ipairs({{0, 1}, {1, 0}, {0, -1}, {-1, 0}}) do
            local neighborRow = r + direction[1]
            local neighborCol = c + direction[2]
            if neighborRow >= 1 and neighborRow <= grid.rows and neighborCol >= 1 and neighborCol <= grid.cols then
                checkCell(neighborRow, neighborCol)
            end
        end
    end
    
    -- Start the recursive checking from the initial cell
    checkCell(row, col)
    
    return cluster
end

function ContiguousNestingGOL:findNeighborsInCluster(clusterElement, cluster)
    local neighbors = {}
    
    -- Check each adjacent direction
    for _, direction in ipairs({{0, 1, 'up'}, {1, 0, 'right'}, {0, -1, 'down'}, {-1, 0, 'left'}}) do
        local neighborRow = clusterElement.row + direction[1]
        local neighborCol = clusterElement.col + direction[2]
        
        -- Check if there's a CA in the neighboring cell
        for _, element in ipairs(cluster) do
            if element.row == neighborRow and element.col == neighborCol then
                neighbors[direction[3]] = element
                break
            end
        end
    end
    
    return neighbors
end

function ContiguousNestingGOL:countL2CellNeighborsInCluster(clusterElement, row, col, cluster)
    local neighborCount = 0
    local grid = clusterElement.cell.grid
    
    -- Check neighbors within the current CA
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local neighborRow = row + i
                local neighborCol = col + j
                local neighbor = grid:getValueOrGrid(neighborRow, neighborCol)
                if neighbor and neighbor == 1 then
                    neighborCount = neighborCount + 1
                end
            end
        end
    end
    
    -- Get neighboring CAs and their directions
    local neighboringCAs = ContiguousNestingGOL:findNeighborsInCluster(clusterElement, cluster)
    
    -- Check neighbors in adjacent CAs
    for direction, adjacentElement in pairs(neighboringCAs) do
        -- Define edge row and column based on direction
        local edgeRow, edgeCol = clusterElement.row, clusterElement.col
        if direction == 'up' then edgeRow = adjacentElement.cell.grid.rows
        elseif direction == 'down' then edgeRow = 1
        elseif direction == 'left' then edgeCol = adjacentElement.cell.grid.cols
        elseif direction == 'right' then edgeCol = 1
        end
        
        local adjacentCell = adjacentElement.cell.grid:getValueOrGrid(edgeRow, edgeCol)
        if adjacentCell and adjacentCell == 1 then
            neighborCount = neighborCount + 1
        end
    end
    
    return neighborCount
end
















ContiguousNestingGOL = class()

function ContiguousNestingGOL:init(createNestingReadyGOL)
    self.class = "ContiguousNestingGOL" -- class definition has to come after superclass init
    -- Custom function to create a nested CA
    self.createNestingReadyGOL = createNestingReadyGOL or function() return nil end
end

function ContiguousNestingGOL:setup(grid)
    -- Define a local function to customize the parentDataFetcher for CanContiguousGOL
    local function customizedDataFetcher(queryName, row, col)
        if queryName == "connectedDirections" then
            return self:directionsOfNeighbors(grid, row, col)
        end
        return nil
    end
    
    -- Store the original factory function for later use
    self.originalFactoryFunction = self.createNestingReadyGOL
    
    -- Override the createNestingReadyGOL method to include the customized data fetcher
    self.createNestingReadyGOL = function()
        local nestedCA = self.originalFactoryFunction() -- Use the original factory function
        nestedCA.parentDataFetcher = customizedDataFetcher -- Attach the custom data fetcher
        return nestedCA
    end
    
    -- Initialize the grid with nested CanContiguousGOL instances or empty cells
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = math.random(0, 1) == 1 and self:createNestingReadyGOL() or 0
        end
    end
end

function ContiguousNestingGOL:updateGrid(grid)
    local newGrid = CAGrid(grid.rows, grid.cols)
    
    -- Compute new macro grid states
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            newGrid.cells[i][j] = self:applyRule(grid, i, j)
        end
    end
    
    -- Update the macro grid with the new states
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = newGrid.cells[i][j]
        end
    end
    
end

function ContiguousNestingGOL:applyRule(grid, row, col)
    local cell = grid.cells[row][col]
    local isAlive = self:isAlive(cell)
    local neighborDirections = self:directionsOfNeighbors(grid, row, col)
    -- Store neighborDirections in the cell for later use
    if type(cell) == "table" then
        cell.neighborDirections = neighborDirections
    end
    local neighborCount = #neighborDirections -- a
    if isAlive and (neighborCount == 2 or neighborCount == 3) then
        return cell -- Cell stays alive
    elseif not isAlive and neighborCount == 3 then
        return self:createNestingReadyGOL(grid) -- Cell becomes a nested CA
    else
        return 0 -- Cell dies
    end
end

function ContiguousNestingGOL:isAlive(cell)
    return cell ~= 0
end

function ContiguousNestingGOL:directionsOfNeighbors(grid, row, col)
    local neighborDirections = {}
    
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local neighborRow = ((row + i - 1) % grid.rows) + 1
                local neighborCol = ((col + j - 1) % grid.cols) + 1
                local neighbor = grid.cells[neighborRow][neighborCol]
                
                if self:isAlive(neighbor) then
                    -- Determine the direction and add to the table
                    local direction = self:determineDirection(i, j)
                    table.insert(neighborDirections, direction)
                end
            end
        end
    end
    return neighborDirections
end

function ContiguousNestingGOL:determineDirection(deltaRow, deltaCol)
    if deltaRow == 1 and deltaCol == 0 then
        return "N"
    elseif deltaRow == -1 and deltaCol == 0 then
        return "S"
    elseif deltaRow == 0 and deltaCol == -1 then
        return "W"
    elseif deltaRow == 0 and deltaCol == 1 then
        return "E"
    elseif deltaRow == 1 and deltaCol == -1 then
        return "NW"
    elseif deltaRow == 1 and deltaCol == 1 then
        return "NE"
    elseif deltaRow == -1 and deltaCol == -1 then
        return "SW"
    elseif deltaRow == -1 and deltaCol == 1 then
        return "SE"
    end
end







CanContiguousGOL = class(ConwaysGameOfLife)

function CanContiguousGOL:init()
    ConwaysGameOfLife.init(self)
    self.class = "CanContiguousGOL" -- class definition has to come after superclass init
end

function CanContiguousGOL:updateGrid(grid)
    
    local macroCellFetcher = self.macroCellFetcher

    local newGrid = CAGrid(grid.rows, grid.cols)
    
    -- Compute new states for each cell
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            newGrid.cells[i][j] = self:applyRule(grid, i, j, macroCellFetcher)
        end
    end
    
    -- Update the grid with the new states
    for i = 1, grid.rows do
        for j = 1, grid.cols do
            grid.cells[i][j] = newGrid.cells[i][j]
        end
    end
end

function CanContiguousGOL:countNeighbors(grid, row, col)
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local neighbor = grid:getValueOrGrid(row + i, col + j, true) -- Assuming wrap-around behavior
                count = count + (neighbor == 1 and 1 or 0)
            end
        end
    end
    return count
end

function CanContiguousGOL:getCorrespondingCell(offsets, grid)
    local correspondingRow = offsets[1] == -1 and 1 or (offsets[1] == 1 and grid.rows or -1)
    local correspondingCol = offsets[2] == -1 and 1 or (offsets[2] == 1 and grid.cols or -1)
    
    -- Handle diagonal cases
    if correspondingRow == -1 then
        correspondingRow = math.floor(grid.rows / 2)
    end
    if correspondingCol == -1 then
        correspondingCol = math.floor(grid.cols / 2)
    end
    
    return correspondingRow, correspondingCol
end


-- Get row and column offsets based on the direction
function CanContiguousGOL:getOffsetsForDirection(direction)
    local offsets = {
        N = {0, -1},
        NE = {1, -1},
        E = {1, 0},
        SE = {1, 1},
        S = {0, 1},
        SW = {-1, 1},
        W = {-1, 0},
        NW = {-1, -1}
    }
    return offsets[direction]
end

function CanContiguousGOL:applyRule(grid, row, col)
    local cell = grid.cells[row][col]
    local neighborCount = self:countNeighbors(grid, row, col)
    
    -- If part of a contiguous cluster, count neighbors from adjacent CAs
    local connectedDirections = self.parentDataFetcher("connectedDirections", row, col)
    if connectedDirections then
        for _, direction in ipairs(connectedDirections) do
            neighborCount = neighborCount + self:countContiguousNeighborsInDirection(row, col, direction)
        end
    end
    
    return (neighborCount == 3 or (cell == 1 and neighborCount == 2)) and 1 or 0
end

-- Count contiguous neighbors in a specific direction
function CanContiguousGOL:countContiguousNeighborsInDirection(sourceRow, sourceCol, direction)
    local offsets = self:getOffsetsForDirection(direction)
    local neighborRow = sourceRow + offsets[1]
    local neighborCol = sourceCol + offsets[2]
    local neighborCount = 0
    
    -- Ensure the neighbor coordinates are within the bounds of the macro grid
    local neighborCell = self.parentDataFetcher("connectedDirections", neighborRow, neighborCol)
    if neighborCell then
        -- Check if the neighbor is alive and part of a contiguous CA
        if type(neighborCell) == "table" and neighborCell.isContiguous then
            -- Check the corresponding cell in the neighbor CA
            local correspondingRow, correspondingCol = self:getCorrespondingCell(offsets, neighborCell.grid)
            if neighborCell.grid.cells[correspondingRow][correspondingCol] == 1 then
                neighborCount = neighborCount + 1
            end
        end
    end
    
    return neighborCount
end
