
function setup()
    --[[
    demoControl = DemoControl()
    gridSize = 40
    local systems
    local gol = 1
    if gol == 1 then
        gridSize = 16
        function createCanContiguousGOL()
            return CellularAutomata({CanContiguousGOL()}, gridSize, gridSize)
        end
        systems = { ContiguousNestingGOL(createCanContiguousGOL) }
    elseif gol == 2 then
        function createNestedGOL()
            return CellularAutomata({ConwaysGameOfLife()})
        end
        systems = { NestingGameOfLife(createNestedGOL) }
    elseif gol == 3 then
        gridSize = 20
        systems = { ConwaysGameOfLife() }
    elseif gol == 4 then
        randomUpdates = true
        gridSize = math.random(5,40)
        local maxUpdateSize = math.ceil(gridSize * gridSize * 0.9)
        local minUpdateSize = math.floor(maxUpdateSize * .25)
        updateSize = math.random(minUpdateSize, maxUpdateSize)
        systems = { RandomOrderSystem(updateSize) }
    end
    local cellAuto = CellularAutomata(systems, gridSize, gridSize)
    updater = Updater(cellAuto)
    ]]
    local gridSize = 60
    grid = CAGrid(gridSize, gridSize) -- Create a 20x20 grid
    local conwaysGOL = ConwaysGOL() -- Create an instance of Conway's Game of Life rules
    updater = CAUpdater(grid, {conwaysGOL}) -- Create an updater with the grid and rules
    visualizer = Visualizer(grid)
    
    UnitTests_ConwaysGOL()
    UnitTests_CAUpdater()
end

function draw()
    background(37, 49, 72)
   -- demoControl:draw()
    updater:update()
    visualizer:draw()
    if randomUpdates and not infoPrinted then
        print("gridSize: ", gridSize, "\nupdateSize: ", updateSize,
        "\ntotal cells: ", gridSize * gridSize)
        infoPrinted = true
    end
end
