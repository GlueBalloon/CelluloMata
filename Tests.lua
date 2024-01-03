

function UnitTests_ConwaysGOL()
    -- Test function
    function runConwaysGOLTest(description, gridSetup, expectedResult)
        print("Test: " .. description)
        local testGrid = CAGrid(3, 3)
        gridSetup(testGrid)
        local conwaysGOL = ConwaysGOL()
        local result = conwaysGOL:nextCellState(testGrid, 2, 2)
        assert(result == expectedResult, "Expected " .. tostring(expectedResult) .. ", got " .. tostring(result))
        print(" Passed")
    end
    
    
    -- Test: Dead cell with three live neighbors becomes alive
    runConwaysGOLTest("Dead cell with three live neighbors becomes alive",
    function(grid)
        grid.cells[1][2] = 1
        grid.cells[2][1] = 1
        grid.cells[2][3] = 1
    end,
    1)
    
    -- Test: Live cell with two live neighbors stays alive
    runConwaysGOLTest("Live cell with two live neighbors stays alive",
    function(grid)
        grid.cells[2][2] = 1
        grid.cells[1][2] = 1
        grid.cells[2][1] = 1
    end,
    1)
    
    -- Test: Live cell with fewer than two live neighbors dies
    runConwaysGOLTest("Live cell with fewer than two live neighbors dies",
    function(grid)
        grid.cells[2][2] = 1
        grid.cells[1][2] = 1
    end,
    0)
    
    -- Test: Live cell with more than three live neighbors dies
    runConwaysGOLTest("Live cell with more than three live neighbors dies",
    function(grid)
        grid.cells[2][2] = 1
        grid.cells[1][1] = 1
        grid.cells[1][2] = 1
        grid.cells[1][3] = 1
        grid.cells[2][1] = 1
    end,
    0)
    
end


function formatGrid(grid)
    local gridString = ""
    for i = 1, #grid do
        gridString = gridString .. "Row " .. i .. ": "
        for j = 1, #grid[i] do
            gridString = gridString .. (grid[i][j] == 1 and "1" or "0") .. " "
        end
        gridString = gridString:sub(1, -2)  -- Remove the trailing space
        gridString = gridString .. "\n"     -- Add a newline after each row
    end
    return gridString
end


function UnitTests_CAUpdater()
    print("___---___---___---\nUnitTests_CAUpdater")
    -- Test function for random initialization
    local function testRandomInitialization()
        local rows, cols = 40, 40 -- Grid size for the test
        local testGrid = CAGrid(rows, cols)
        
        -- Verify initial state (all cells should be dead)
        print("Test: All cells start dead")
        for i = 1, rows do
            for j = 1, cols do
                assert(testGrid.cells[i][j] == 0, "Initial cell state should be dead (0)")
            end
        end
        print(" Passed")
        
        -- Initialize CAUpdater with ConwaysGOL and the grid
        local conwaysGOL = ConwaysGOL()
        local updater = CAUpdater(testGrid, {conwaysGOL})

        -- Count live and dead cells
        local liveCount, deadCount = 0, 0
        for i = 1, rows do
            for j = 1, cols do
                if testGrid.cells[i][j] == 1 then
                    liveCount = liveCount + 1
                else
                    deadCount = deadCount + 1
                end
            end
        end
        
        -- Check for rough equivalence between live and dead counts
        print("Test: Live and dead cells roughly equivalent")
        local totalCells = rows * cols
        assert(liveCount > 0 and deadCount > 0, "Only one kind of cells")
        assert(math.abs(liveCount - deadCount) < totalCells * 0.2, "Too much variation between live and dead cells")
        
        print(" Passed")
    end
    
    
    -- Test function for CAUpdater's update process
    local function runCAUpdaterTest(description, initialGridState, expectedGridState)
        print("Test: " .. description)
        local testGrid = CAGrid(3, 3)
        
        -- Initialize CAUpdater with ConwaysGOL and the test grid
        local conwaysGOL = ConwaysGOL()
        local updater = CAUpdater(testGrid, {conwaysGOL})
        
        -- Set up the initial grid state and turn off wraparound
        for i = 1, 3 do
            for j = 1, 3 do
                testGrid.cells[i][j] = initialGridState[i][j]
            end
        end
        testGrid.wrapsAround = false
        
        -- Perform an update
        updater:update()
        
        -- Check the updated grid state
        for i = 1, 3 do
            for j = 1, 3 do
                local result = testGrid.cells[i][j] == 1 and 1 or 0
                local expected = expectedGridState[i][j]
                if result ~= expected then
                    local failureMessage = createTestResultMessage(expectedGridState, testGrid.cells, i, j, expected, result)
                    error(failureMessage)
                end
            end
        end
        print(" Passed")
    end
    
    function createTestResultMessage(expectedGrid, actualGrid, i, j, expected, result)
        local message = "Test failed at Cell [" .. i .. "," .. j .. "] - Expected: " .. tostring(expected) .. ", got: " .. tostring(result) .. "\n"
        message = message .. "Expected Grid:\n" .. formatGrid(expectedGrid) .. "\n"
        message = message .. "Actual Grid:\n" .. formatGrid(actualGrid)
        return message
    end
    
    function testUpdating()
        -- Test: Live cell with two live neighbors stays alive
        runCAUpdaterTest("Live cell with two live neighbors stays alive",
        {
            {0, 0, 1},
            {0, 1, 0},
            {1, 0, 0}
        },
        {
            {0, 0, 0},
            {0, 1, 0},
            {0, 0, 0}
        }
        )
        
        -- Test: Dead cell with three live neighbors becomes alive
        runCAUpdaterTest("Dead cell with three live neighbors becomes alive",
        {
            {0, 1, 0},
            {0, 0, 1},
            {1, 0, 0}
        },
        {
            {0, 0, 0},
            {0, 1, 0},
            {0, 0, 0}
        }
        )
        
        -- Test: Live cell with fewer than two live neighbors dies
        runCAUpdaterTest("Live cell with fewer than two live neighbors dies",
        {
            {0, 1, 0},
            {0, 1, 0},
            {0, 0, 0}
        },
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        }
        )
        
        -- Test: Live cell with more than three live neighbors dies
        runCAUpdaterTest("Live cell with more than three live neighbors dies",
        {
            {1, 0, 1},
            {1, 1, 1},
            {0, 0, 0}
        },
        {
            {1, 0, 1},
            {1, 0, 1},
            {0, 1, 0}
        }
        )
    end
    
    -- Run the tests
    testRandomInitialization()
    testUpdating()
end