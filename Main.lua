
function setup()
    local gridSize = math.random(10, 60)
    gridSize = 22
    local nestedSize = 8
    grid = CAGrid(gridSize, gridSize) -- Create a 20x20 grid
    grid.color = randomPastellyColor()
    local conwaysGOL = ConwaysGOL() -- Create an instance of Conway's Game of Life rules
    local nestingGOL = NestingGOLRules(nestedSize, nestedSize)
    updater = CAUpdater(grid, {conwaysGOL, nestingGOL}) -- Create an updater with the grid and rules
--    updater:become2x2NestedGrid(5)
    updater.grid.color = randomPastellyColor()
    visualizer = Visualizer(updater.grid)

    UnitTests_ConwaysGOL()
    UnitTests_CAUpdater()
--    UnitTests_Nesting()
end

function draw()
    background(37, 49, 72)
    updater:update()
    visualizer:draw()
end