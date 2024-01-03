CAGrid = class()

CAGrid.gridOfZeros = function(rows, cols) 
    local newGrid = {}
    for i = 1, rows do
        newGrid[i] = {}
        for j = 1, cols do
            newGrid[i][j] = 0
        end
    end
    return newGrid
end

function CAGrid:init(rows, cols)
    self.rows = rows or 14
    self.cols = cols or 14
    self.cells = self.gridOfZeros(self.rows, self.cols)
    self.query = nil
    self.wrapsAround = false
    self.color = color(255)
end

function CAGrid:clear()
    for i = 1, self.rows do
        for j = 1, self.cols do
            self.cells[i][j] = 0  -- Set all cells to dead
        end
    end
end

function CAGrid:queryCell(row, col)
    -- Set the currently focused cell for querying
    if row and col then
        self.query = { row = row, col = col }
    end
    return self
end

function CAGrid:resolveQueriedCoords(row, col)
    -- If row and col are provided, use them as the coordinates
    if row and col then
        return { row = row, col = col }
        -- If a query cell is already set, use its coordinates
    elseif self.query then
        return self.query
    else
        -- Handle the case where neither coordinates nor a queried cell are available
        print("resolveQueriedCoords: no coordinates provided and no queried cell set")
        return nil
    end
end

function CAGrid:countQueriedNeighbors(row, col)
    local coords = self:resolveQueriedCoords(row, col)
    -- Count neighbors
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local r, c
                if self.wrapsAround then
                    r = (coords.row + i - 1 + self.rows) % self.rows + 1
                    c = (coords.col + j - 1 + self.cols) % self.cols + 1
                else
                    r = coords.row + i
                    c = coords.col + j
                    -- Skip counting if outside grid bounds
                    if r < 1 or r > self.rows or c < 1 or c > self.cols then
                        goto continue
                    end
                end
                if self.cells[r][c] == 1 then
                    count = count + 1
                end
                ::continue::
            end
        end
    end
    return count
end

function CAGrid:queriedNeighborCountIs(count, row, col)
    local coords = self:resolveQueriedCoords(row, col)
    local result = self:countQueriedNeighbors(coords.row, coords.col)
    return result == count
end

function CAGrid:queriedIsAlive(row, col)
    local coords = self:resolveQueriedCoords(row, col)
    return self.cells[coords.row][coords.col] ~= 0
end

