

function UnitTests_Nesting()
    print("___---___---___---\nUnitTests_Nesting")
    
    -- Test Function for NestingGOLRules setup
    function testNestingInitialization()
        local testGrid = CAGrid(13, 13)
        local conwaysGOL = ConwaysGOL()
        local nestingGOL = NestingGOLRules()
        local updater = CAUpdater(testGrid, {conwaysGOL, nestingGOL})
        
        local countGrids = 0
        local countZeroes = 0
        
        -- Check if each cell is either 0 or a nested grid, and count them
        for i = 1, testGrid.rows do
            for j = 1, testGrid.cols do
                local cell = testGrid.cells[i][j]
                if type(cell) == "table" then
                    countGrids = countGrids + 1
                elseif cell == 0 then
                    countZeroes = countZeroes + 1
                else
                    assert(false, "Cell [" .. i .. "," .. j .. "] is not properly nested")
                end
            end
        end
        
        -- Check if the number of grids and zeroes are statistically equal
        local totalCells = testGrid.rows * testGrid.cols
        local expectedCount = totalCells / 2
        local tolerance = 0.15 * expectedCount  -- Allowing 10% tolerance
        
        print("Distribution of grids: " .. countGrids .. " grids, " .. countZeroes .. " zeroes")
        assert(math.abs(countGrids - expectedCount) <= tolerance, 
        "Uneven distribution of grids")
        
        print("* Nesting Initialization Test Passed")
    end
    
    -- Test function for NestingGOLRules custom sizes
    local function runNestingCustomSizesTest(description, rows, cols)
        print("Test: " .. description)
        local testGrid = CAGrid(3, 3)
        local nestingRules = NestingGOLRules(rows, cols)
        local updater = CAUpdater(testGrid, {nestingRules})
        
        -- Verify the dimensions of each nested grid
        for i = 1, testGrid.rows do
            for j = 1, testGrid.cols do
                if testGrid.cells[i][j] ~= 0 then
                    local nestedGrid = testGrid.cells[i][j]
                    assert(#nestedGrid == rows and #nestedGrid[1] == cols, 
                    "Nested grid at [" .. i .. "," .. j .. "] does not have " ..
                    "the correct dimensions (" .. rows .. "x" .. cols .. ")")
                end
            end
        end
        print(" Passed")
    end
    
    -- Test different nesting sizes
    function testNestingRulesWithCustomSizes()
        runNestingCustomSizesTest("Nesting with 4x4 grids", 4, 4)
        runNestingCustomSizesTest("Nesting with 5x3 grids", 5, 3)
        runNestingCustomSizesTest("Nesting with 2x6 grids", 2, 6)
        print("* Nesting Custom Sizes Test Passed")
    end

    
    -- Helper function to create a test grid
    local function createTestGridWithNesting(rows, cols, nestingRows, nestingCols)
        local grid = CAGrid(rows, cols)
        -- Initialize with some non-zero values
        for i = 1, rows do
            grid.cells[i] = {}
            for j = 1, cols do
                grid.cells[i][j] = math.random(0, 1)
                if grid.cells[i][j] ~= 0 then
                    -- Convert cell to a nested grid (data table, not a class)
                    grid.cells[i][j] = CAGrid.gridOfZeros(nestingRows, nestingCols)
                end
            end
        end
        return grid
    end
    
    --test if whole nesting cells live or die consistent with Conway's GOL rules
    function testNestingCellAliveness()
        local nestingRows, nestingCols = 2, 2  -- Define dimensions for nested grids
    
        -- Test function for NestingGOL with Conway's GOL rules
        local function runNestingConwaysGOLTest(description, startGridState, expectedGridState)
            print("Test: " .. description)
            local testGrid = CAGrid(3, 3)
    
            local conwaysGOL = ConwaysGOL()
            local nestingGOL = NestingGOLRules(nestingRows, nestingCols)
            local updater = CAUpdater(testGrid, {conwaysGOL, nestingGOL})
            
            -- Set up the initial grid state and turn off wraparound
            for i = 1, 3 do
                updater.grid.cells[i] = {}
                for j = 1, 3 do
                    local cellIsAlive = startGridState[i][j] == 1
                    updater.grid.cells[i][j] = cellIsAlive and CAGrid.gridOfZeros(nestingRows, nestingCols) or 0
                end
            end
            updater.grid.wrapsAround = false
            

            local startGrid = stringForCAGrid(updater.grid)
            --print("Starting Grid State:")
            --print(startGrid)
    
            updater:update()  -- Perform an update
            
            local expGrid = stringForGridTable(expectedGridState, nestingRows, nestingCols)
            --print("Expected Grid State:")
            --print(expGrid)
            
            local actGrid = stringForCAGrid(updater.grid)
            --print("Actual Grid State:")
            --print(actGrid)
            
            local statesMatch = expGrid == actGrid
            --print("States match: ", statesMatch)
            
            assert(statesMatch, "States do not match")
            
            print(" Passed")
        end
    
        -- Test scenarios
        -- Test: Dead cell with three live neighbors becomes alive
        runNestingConwaysGOLTest("Dead cell with three live neighbors becomes alive",
            {
                {0, 1, 0},
                {1, 0, 1},
                {0, 0, 0}
            },
            {
                {0, 1, 0},
                {0, 1, 0},
                {0, 0, 0}
            }
        )
    
        -- Test: Live cell with two live neighbors stays alive
        runNestingConwaysGOLTest("Live cell with two live neighbors stays alive",
            {
                {0, 1, 0},
                {1, 1, 0},
                {0, 0, 0}
            },
            {
                {1, 1, 0},
                {1, 1, 0},
                {0, 0, 0}
            }
        )
    
        -- Test: Live cell with fewer than two live neighbors dies
        runNestingConwaysGOLTest("Live cell with fewer than two live neighbors dies",
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
        runNestingConwaysGOLTest("Live cell with more than three live neighbors dies",
            {
                {1, 1, 1},
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
    
    -- Function to print the grid state (for debugging and test clarity)
    function stringForCAGrid(grid)
        local gridString = ""
        for i = 1, #grid.cells do
            local row = ""
            for j = 1, #grid.cells[i] do
                row = row .. (type(grid.cells[i][j]) == "table" and "G" or tostring(grid.cells[i][j])) .. " "
            end
            gridString = gridString .. row .. "\n"
        end
        return gridString
    end
    
    -- Function to return the grid state as a single string
    function stringForGridTable(gridState, nestingRows, nestingCols)
        local gridString = ""
        for i = 1, #gridState do
            local row = ""
            for j = 1, #gridState[i] do
                row = row .. (gridState[i][j] == 1 and "G" or tostring(gridState[i][j])) .. " "
            end
            gridString = gridString .. row .. "\n"
        end
        return gridString
    end
    
    -- Run the tests
    testNestingInitialization()
    testNestingRulesWithCustomSizes()
    testNestingCellAliveness()
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


function UnitTests_ConwaysGOL()
    print("___---___---___---\nUnitTests_ConwaysGOL")
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
            --"a" for "alive":
            gridString = gridString .. (grid[i][j] ~= 0 and "a" or "0") .. " "
        end
        gridString = gridString:sub(1, -2)  -- Remove the trailing space
        gridString = gridString .. "\n"     -- Add a newline after each row
    end
    return gridString
end


