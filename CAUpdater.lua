
CAUpdater = class()

function CAUpdater:init(grid, rulesTable)
    self.grid = grid
    self.rules = rulesTable or {}
    self.speed = 0.05
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
    if (not isTesting) and 
        ElapsedTime - self.timeCheck < self.speed then
        return 
    end
    self.timeCheck = ElapsedTime
    -- Generate new states for each cell by applying the rules
    local newStates = self.grid:resultsForEachCell(function(grid, i, j)
        local currentState = grid.cells[i][j]
        for _, rule in ipairs(self.rules) do
            currentState = rule:nextCellState(grid, i, j, currentState)
        end
        return currentState
    end)
    if isTesting then
        print("old: \n"..tostring(formatGrid(self.grid.cells)))
        print("new: \n"..tostring(formatGrid(newStates)))
    end
    self.grid:applyNewStates(newStates)
end

function CAUpdater:become2x2NestedGrid(nestedSize)
    local nestedSize = nestedSize or 3
    self.grid = CAGrid(2,2)
    self:setUpRules(self.rules)
    self.grid.wrapsAround = false
    for i = 1, 2 do
        for j = 1, 2 do
            self.grid.cells[i][j] = CAGrid(nestedSize, nestedSize)
            ConwaysGOL.randomFill(self.grid.cells[i][j].cells)
            self.grid.cells[i][j].color = randomPastellyColor()
        end
    end
end