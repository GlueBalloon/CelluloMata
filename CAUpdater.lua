
CAUpdater = class()

function CAUpdater:init(grid, rulesTable)
    self.grid = grid
    self.rules = rulesTable or {}
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
    -- Create a new table for the updated states
    local newStates = {}
    -- Uodate each cell
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