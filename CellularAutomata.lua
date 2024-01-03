CellularAutomata = class()

function CellularAutomata:init(systems, rows, cols, aColor)
    self.class = "CellularAutomata"
    local defaultSize = 80
    self.grid = CAGrid(rows or defaultSize, cols or defaultSize)
    self.color = aColor or color(math.random(100,255), math.random(120,255), math.random(200,255))
    self.systems = systems or {}
    for i = 1, self.grid.rows do
        self.grid[i] = {}
        for j = 1, self.grid.cols do
            self.grid[i][j] = 0
        end
    end
    for _, system in ipairs(self.systems) do
        if system.setup then
            system:setup(self.grid)
        end
    end
end

