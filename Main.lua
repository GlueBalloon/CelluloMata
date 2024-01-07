
function setup()
    local gridSize = math.random(10, 60)
    gridSize = 10
    grid = CAGrid(gridSize, gridSize) -- Create a 20x20 grid
    grid.color = randomPastellyColor()
    local conwaysGOL = ConwaysGOL() -- Create an instance of Conway's Game of Life rules
    local nestingGOL = NestingGOLRules(20, 20)
    updater = CAUpdater(grid, {conwaysGOL, nestingGOL}) -- Create an updater with the grid and rules
    visualizer = Visualizer(updater.grid)

    UnitTests_ConwaysGOL()
    UnitTests_CAUpdater()
    UnitTests_Nesting()
end

function draw()
    background(37, 49, 72)
    updater:update()
    visualizer:draw()
end
