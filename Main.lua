
function setup()
    local gridSize = math.random(10, 60)
    gridSize = 14
    grid = CAGrid(gridSize, gridSize) -- Create a 20x20 grid
    grid.color = randomPastellyColor()
    local conwaysGOL = ConwaysGOL() -- Create an instance of Conway's Game of Life rules
    updater = CAUpdater(grid, {conwaysGOL}) -- Create an updater with the grid and rules
    visualizer = Visualizer(grid)
    
    UnitTests_ConwaysGOL()
    UnitTests_CAUpdater()
end

function draw()
    background(37, 49, 72)
    updater:update()
    visualizer:draw()
end
