
CAUpdater = class()

function CAUpdater:init(grid, rulesTable)
    self.grid = grid
    self.rules = rulesTable or {}
    self.speed = 0.25
    self.timeCheck = ElapsedTime
    self:setUpRules(self.rules)
end

function CAUpdater:setUpRules(rulesTable)
    -- Iterate through the given rules table and run setup(grid) on each rule
    for _, rule in ipairs(rulesTable) do
        if rule.setup then
            rule:setup(self.grid)
        end
    end
end

function CAUpdater:update()
    --speed control:
    if ElapsedTime - self.timeCheck < self.speed then
        return 
    end
    self.timeCheck = ElapsedTime
    -- Create a new table for the updated states
    local newStates = {}
    -- Update each cell
    for i = 1, self.grid.rows do
        newStates[i] = {}
        for j = 1, self.grid.cols do
            -- Apply each rule to determine the next state of each cell
            for _, rule in ipairs(self.rules) do
                newStates[i][j] = rule:nextCellState(self.grid, i, j)
            end
        end
    end
    if isTesting then
        print("old: \n"..tostring(formatGrid(self.grid.cells)))
        print("new: \n"..tostring(formatGrid(newStates)))
    end
    -- Update the grid's cells with the new states
    for i = 1, self.grid.rows do
        for j = 1, self.grid.cols do
            self.grid.cells[i][j] = newStates[i][j]
        end
    end
end

function CAUpdater:become2x2NestedGrid(nestedSize)
    local nestedSize = nestedSize or 3
    self.grid = CAGrid(2,2)
    self:setUpRules(self.rules)
    for i = 1, 2 do
        for j = 1, 2 do
            self.grid.cells[i][j] = CAGrid(nestedSize, nestedSize)  -- Assuming 3x3 nested grid
        end
    end
end